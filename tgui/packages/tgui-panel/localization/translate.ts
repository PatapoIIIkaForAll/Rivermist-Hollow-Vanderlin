import type {
  CaseKey,
  Cases,
  CompiledPattern,
  Dictionary,
  Lang,
} from './types';

const EDGES_REGEX = /^(\s*)([\s\S]*?)(\s*)$/;
const TOKEN_REGEX = /\$(\d+)(?:\|(nom|gen|dat|acc|ins|pre))?/g;
const ARTICLE_REGEX = /^(?:the|an|a)\s+/i;
const CACHE_LIMIT = 4000;

let lang: Lang = 'en';
let nouns: Record<string, Cases> = {};
let honorifics: Record<string, Cases> = {};
let honorificsByLength: string[] = [];
let fragments: Record<string, string> = {};
let patterns: CompiledPattern[] = [];
let declensions: Record<string, Cases> = {};
let cache = new Map<string, string>();
let loaded = false;

function resetCache(): void {
  cache = new Map();
}

export function setLang(next: Lang): void {
  if (next === lang) return;
  lang = next;
  resetCache();
}

export function getLang(): Lang {
  return lang;
}

export function loadDictionary(data: Dictionary): void {
  nouns = data?.nouns ?? {};
  honorifics = data?.honorifics ?? {};
  honorificsByLength = Object.keys(honorifics).sort(
    (a, b) => b.length - a.length,
  );
  fragments = data?.fragments ?? {};
  patterns = [];
  for (const entry of data?.patterns ?? []) {
    try {
      patterns.push({ re: new RegExp(entry.re), ru: entry.ru });
    } catch {
      continue;
    }
  }
  loaded = true;
  resetCache();
}

export function loadDeclensions(payload: Record<string, Cases>): void {
  for (const name in payload) {
    declensions[name] = payload[name];
  }
  resetCache();
}

export function resetDeclensions(): void {
  declensions = {};
  resetCache();
}

export function isActive(): boolean {
  return loaded && lang === 'ru';
}

function lookup(value: string): Cases | undefined {
  return nouns[value] ?? declensions[value];
}

function declineTitled(value: string, caseKey: CaseKey): string | undefined {
  for (const title of honorificsByLength) {
    if (!value.startsWith(`${title} `)) {
      continue;
    }
    const rest = value.slice(title.length + 1);
    if (!rest) {
      continue;
    }
    const declinedTitle = honorifics[title][caseKey] ?? title;
    return `${declinedTitle} ${lookup(rest)?.[caseKey] ?? rest}`;
  }
  return undefined;
}

function decline(value: string, caseKey: CaseKey): string {
  let entry = lookup(value);
  if (!entry) {
    const bare = value.replace(ARTICLE_REGEX, '');
    entry =
      lookup(bare) ?? lookup(bare.charAt(0).toLowerCase() + bare.slice(1));
  }
  if (!entry) {
    return declineTitled(value, caseKey) ?? value;
  }
  return entry[caseKey] ?? value;
}

type Decline = (value: string, caseKey: CaseKey) => string;

function expand(
  template: string,
  match: RegExpMatchArray,
  declineCapture: Decline,
): string {
  return template.replace(
    TOKEN_REGEX,
    (whole, index: string, caseKey?: string) => {
      const captured = match[Number(index)];
      if (captured === undefined) {
        return whole;
      }
      return caseKey ? declineCapture(captured, caseKey as CaseKey) : captured;
    },
  );
}

function translateCore(
  core: string,
  declineCapture: Decline = decline,
): string | null {
  const exact = fragments[core];
  if (exact !== undefined) {
    return exact;
  }
  for (const pattern of patterns) {
    const match = core.match(pattern.re);
    if (match) {
      return expand(pattern.ru, match, declineCapture);
    }
  }
  return null;
}

export function translateText(text: string): string {
  if (!isActive() || !text.trim()) {
    return text;
  }
  const hit = cache.get(text);
  if (hit !== undefined) {
    return hit;
  }
  const edges = text.match(EDGES_REGEX);
  const before = edges ? edges[1] : '';
  const core = edges ? edges[2] : text;
  const after = edges ? edges[3] : '';
  const translated = translateCore(core);
  const result = translated === null ? text : before + translated + after;
  if (cache.size >= CACHE_LIMIT) {
    resetCache();
  }
  cache.set(text, result);
  return result;
}

const SLOT_OPEN = '';
const SLOT_CLOSE = '';
const SLOT_REGEX = new RegExp(`${SLOT_OPEN}(\\d+)${SLOT_CLOSE}`, 'g');
const WHOLE_SLOT_REGEX = new RegExp(`^${SLOT_OPEN}(\\d+)${SLOT_CLOSE}$`);

function slotMark(index: number): string {
  return `${SLOT_OPEN}${index}${SLOT_CLOSE}`;
}

function translateRun(node: Element): Set<Node> | undefined {
  const children = Array.from(node.childNodes);
  let first = -1;
  let last = -1;
  children.forEach((child, index) => {
    if (child.nodeType === Node.TEXT_NODE && child.textContent?.trim()) {
      first = first < 0 ? index : first;
      last = index;
    }
  });
  if (first < 0) {
    return undefined;
  }
  const slots: Element[] = [];
  let text = '';
  for (let i = first; i <= last; i++) {
    const child = children[i];
    if (child.nodeType === Node.TEXT_NODE) {
      text += child.textContent ?? '';
      continue;
    }
    if (
      !(child instanceof Element) ||
      child.childElementCount ||
      !child.textContent?.trim()
    ) {
      return undefined;
    }
    text += slotMark(slots.length);
    slots.push(child);
  }
  if (!slots.length) {
    return undefined;
  }
  const edges = text.match(EDGES_REGEX);
  const core = edges ? edges[2] : text;
  const declined = new Map<number, string>();
  const translated = translateCore(core, (value, caseKey) => {
    const slot = value.match(WHOLE_SLOT_REGEX);
    if (!slot) {
      return decline(value, caseKey);
    }
    const index = Number(slot[1]);
    declined.set(index, decline(slots[index].textContent ?? '', caseKey));
    return value;
  });
  if (translated === null) {
    return undefined;
  }
  const result = (edges ? edges[1] : '') + translated + (edges ? edges[3] : '');
  const anchor = children[last].nextSibling;
  const written = new Set<Node>();
  const line = document.createDocumentFragment();
  let from = 0;
  for (const mark of result.matchAll(SLOT_REGEX)) {
    line.append(result.slice(from, mark.index));
    const index = Number(mark[1]);
    const slot = written.has(slots[index])
      ? (slots[index].cloneNode(true) as Element)
      : slots[index];
    const word = declined.get(index);
    slot.textContent = word ?? translateText(slot.textContent ?? '');
    line.append(slot);
    written.add(slot);
    from = (mark.index ?? 0) + mark[0].length;
  }
  line.append(result.slice(from));
  for (let i = first; i <= last; i++) {
    if (children[i].parentNode === node) {
      node.removeChild(children[i]);
    }
  }
  for (const child of Array.from(line.childNodes)) {
    written.add(child);
  }
  node.insertBefore(line, anchor);
  return written;
}

export function translateNode(node: Node): void {
  if (!isActive()) {
    return;
  }
  const written = node instanceof Element ? translateRun(node) : undefined;
  const children = Array.from(node.childNodes);
  for (let i = 0; i < children.length; i++) {
    const child = children[i];
    if (written?.has(child)) {
      continue;
    }
    if (child.nodeType === Node.TEXT_NODE) {
      const text = child.textContent;
      if (!text) continue;
      const translated = translateText(text);
      if (translated !== text) {
        child.textContent = translated;
      }
    } else {
      translateNode(child);
    }
  }
}
