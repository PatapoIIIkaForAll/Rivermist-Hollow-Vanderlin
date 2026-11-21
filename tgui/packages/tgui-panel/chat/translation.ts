import * as z from 'zod';
import { chatRenderer } from './renderer';
import { highlightNode } from './replaceInTextNode';

const updateSchema = z.object({
  id: z.string().regex(/^tsl-[a-z0-9]+-[0-9]+$/),
  status: z.enum(['done', 'failed']),
  translated: z.string().nullish(),
});

type TranslationUpdate = z.infer<typeof updateSchema>;

type Patch = (span: Element) => void;

// The server answers well inside this; anything older was restored from
// storage or lost, and will never get its update.
const STALE_AFTER = 15000;
const STALE_SWEEP_INTERVAL = 5000;
const SEARCH_DEPTH = 80;
const WAITING_LIMIT = 200;
const WAITING_TIME = 30000;

// An update can arrive before its line, e.g. when the line is resent.
const waiting = new Map<string, { update: TranslationUpdate; at: number }>();

function markDone(span: Element, translated: string): void {
  span.setAttribute('title', span.textContent ?? '');
  span.textContent = translated;
  span.classList.replace('tsl-pending', 'tsl-done');
  span.removeAttribute('data-tsl-id');
}

function markFailed(span: Element): void {
  span.classList.remove('tsl-pending');
  span.removeAttribute('data-tsl-id');
}

// Saved and rebuilt chat is made from message.html, not from the live node.
function patchHtml(
  message: { html?: string } | null,
  selector: string,
  patch: Patch,
): void {
  if (!message?.html) {
    return;
  }
  const template = document.createElement('template');
  template.innerHTML = message.html;
  const spans = template.content.querySelectorAll(selector);
  if (spans.length === 0) {
    return;
  }
  for (const span of spans) {
    patch(span);
  }
  message.html = template.innerHTML;
}

function highlight(span: Element, messageNode: unknown): void {
  for (const parser of chatRenderer.highlightParsers ?? []) {
    const count = highlightNode(
      span,
      parser.highlightRegex,
      parser.highlightWords,
      (text) => {
        const node = document.createElement('span');
        node.className = 'Chat__highlight';
        node.setAttribute('style', `background-color:${parser.highlightColor}`);
        node.textContent = text;
        return node;
      },
    );
    if (count && parser.highlightWholeMessage) {
      if (messageNode instanceof HTMLElement) {
        messageNode.classList.add('ChatMessage--highlighted');
      }
    }
  }
}

// Lines on another chat tab are detached from the document.
function locate(id: string): { span: Element; message: any } | null {
  const selector = `[data-tsl-id="${id}"]`;
  const { messages } = chatRenderer;
  const last = Math.max(0, messages.length - SEARCH_DEPTH);
  for (let i = messages.length - 1; i >= last; i--) {
    const node = messages[i].node;
    const span = node instanceof HTMLElement && node.querySelector(selector);
    if (span) {
      return { span, message: messages[i] };
    }
  }
  const span = document.querySelector(selector);
  return span && { span, message: null };
}

function apply(update: TranslationUpdate): boolean {
  const found = locate(update.id);
  if (!found) {
    return false;
  }
  const { span, message } = found;
  const translated = update.status === 'done' && update.translated;
  const patch: Patch = translated
    ? (target) => markDone(target, translated)
    : markFailed;
  patchHtml(message, `[data-tsl-id="${update.id}"]`, patch);
  patch(span);
  if (translated) {
    span.classList.add('tsl-fresh');
    // Re-inserting the line on a tab switch would replay the fade.
    span.addEventListener(
      'animationend',
      () => span.classList.remove('tsl-fresh'),
      { once: true },
    );
    if (!message?.avoidHighlighting) {
      highlight(span, message?.node);
    }
  }
  return true;
}

function clearStale(): void {
  const cutoff = Date.now() - STALE_AFTER;
  for (const message of chatRenderer.messages) {
    if (message.createdAt > cutoff || !message.html?.includes('tsl-pending')) {
      continue;
    }
    if (message.node instanceof HTMLElement) {
      message.node.querySelectorAll('.tsl-pending').forEach(markFailed);
    }
    patchHtml(message, '.tsl-pending', markFailed);
  }
}

chatRenderer.events.on('translation', (payload: unknown) => {
  const result = updateSchema.safeParse(payload);
  if (!result.success || apply(result.data)) {
    return;
  }
  if (waiting.size >= WAITING_LIMIT) {
    const oldest = waiting.keys().next().value;
    if (oldest !== undefined) {
      waiting.delete(oldest);
    }
  }
  waiting.set(result.data.id, { update: result.data, at: Date.now() });
});

// The first batch holds the chat restored from storage.
let restoredCleared = false;

chatRenderer.events.on('batchProcessed', () => {
  if (!restoredCleared) {
    restoredCleared = true;
    clearStale();
  }
  const now = Date.now();
  for (const [id, entry] of waiting) {
    if (now - entry.at > WAITING_TIME || apply(entry.update)) {
      waiting.delete(id);
    }
  }
});

setInterval(clearStale, STALE_SWEEP_INTERVAL);
