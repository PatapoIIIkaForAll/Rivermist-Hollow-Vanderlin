import type { BooleanLike } from 'tgui-core/react';

export type Entry = { id: string; text: string; text_en?: string };
export type Decree = Entry & {
  revision: number;
  marks?: number[];
  marks_en?: number[];
};
export type Note = { id: string; title: string; body: string };
export type Notes = { revision: number; entries: Note[] };
export type Article = {
  id: string;
  title: string;
  title_en?: string;
  body: string;
  body_en?: string;
};
export type Chapter = {
  id: string;
  title: string;
  title_en?: string;
  intro: string;
  intro_en?: string;
  articles: Article[];
};
export type Lawbook = { title: string; title_en?: string; chapters: Chapter[] };
export type DocumentId = 'law_code' | 'lawbook';
export type Content = Entry[] | Lawbook;
export type Draft<T extends Content = Content> = {
  epoch: string;
  revision: number;
  content: T;
};
export type Data = {
  max_action_chunks?: number;
  language?: 'en' | 'ru';
  epoch: string;
  role: string | null;
  character: string | null;
  editor_key: string;
  can_edit: BooleanLike;
  locked: BooleanLike;
  code_revision: number;
  book_revision: number;
  law_code: Entry[];
  lawbook: Lawbook;
  saved: Partial<Record<DocumentId, Draft>> | null;
  notes: Notes | null;
  decrees: Decree[];
};
export type Act = (action: string, params?: Record<string, unknown>) => void;

let draftId = 0;
const reservedIds = new Set<string>();

export function loadedDraft(draft: Draft): Draft {
  const result = copy(draft);
  const visit = (value: unknown) => {
    if (!value || typeof value !== 'object') return;
    if ('id' in value && typeof value.id === 'string')
      reservedIds.add(value.id);
    for (const child of Object.values(value)) visit(child);
  };
  visit(result.content);
  return result;
}
export function newId() {
  let id: string;
  do {
    draftId += 1;
    id = `draft_${draftId}`;
  } while (reservedIds.has(id));
  reservedIds.add(id);
  return id;
}

export function copy<T>(value: T): T {
  return JSON.parse(JSON.stringify(value));
}

export function move<T>(values: T[], index: number, direction: number): T[] {
  const target = index + direction;
  if (target < 0 || target >= values.length) return values;
  const result = values.slice();
  [result[index], result[target]] = [result[target], result[index]];
  return result;
}

export function publication(data: Data, id: DocumentId): Draft {
  return {
    epoch: data.epoch,
    revision: id === 'law_code' ? data.code_revision : data.book_revision,
    content: id === 'law_code' ? data.law_code : data.lawbook,
  };
}

// A saved old-round ID can coincide with an unrelated current-round ID.
// Only retain official IDs when both snapshots belong to this world.
export function rebase<T extends Content>(
  draft: Draft<T>,
  current: Draft<T>,
  id: DocumentId,
): Draft<T> {
  const content = copy(draft.content);
  const ids = new Set<string>();
  if (id === 'law_code') {
    for (const entry of current.content as Entry[]) ids.add(entry.id);
    for (const entry of content as Entry[]) {
      if (draft.epoch !== current.epoch || !ids.has(entry.id))
        entry.id = newId();
    }
  } else {
    const articleIds = new Set<string>();
    const book = current.content as Lawbook;
    for (const chapter of book.chapters) {
      ids.add(chapter.id);
      for (const article of chapter.articles) articleIds.add(article.id);
    }
    for (const chapter of (content as Lawbook).chapters) {
      if (draft.epoch !== current.epoch || !ids.has(chapter.id))
        chapter.id = newId();
      for (const article of chapter.articles) {
        if (draft.epoch !== current.epoch || !articleIds.has(article.id))
          article.id = newId();
      }
    }
  }
  return { epoch: current.epoch, revision: current.revision, content };
}

export function currentNotes(saved: Notes, working: Notes | null): Notes {
  const text = (notes: Notes) =>
    JSON.stringify(notes.entries.map(({ title, body }) => ({ title, body })));
  return !working || text(saved) === text(working) ? saved : working;
}

/** DM copytext_char indexes code points. Group styles to avoid a node per glyph. */
export function emphasisRuns(text: string, marks: number[] = []) {
  const result: { offset: number; text: string; style: number }[] = [];
  let index = 0;
  for (const letter of text) {
    const style = (marks[index] || 0) & 3;
    const last = result[result.length - 1];
    if (last && last.style === style) last.text += letter;
    else result.push({ offset: index, text: letter, style });
    index++;
  }
  return result;
}

// Translations share structure and IDs. Editors see empty EN fields; readers fall back.
export function lawbookLanguage(
  book: Lawbook,
  english: boolean,
  fallback = true,
): Lawbook {
  if (!english) return book;
  const text = (source: string, translated?: string) =>
    translated?.trim() ? translated : fallback ? source : translated || '';
  return {
    ...book,
    title: text(book.title, book.title_en),
    chapters: book.chapters.map((chapter) => ({
      ...chapter,
      title: text(chapter.title, chapter.title_en),
      intro: text(chapter.intro, chapter.intro_en),
      articles: chapter.articles.map((article) => ({
        ...article,
        title: text(article.title, article.title_en),
        body: text(article.body, article.body_en),
      })),
    })),
  };
}

export function applyLawbookLanguage(
  source: Lawbook,
  edited: Lawbook,
  english: boolean,
): Lawbook {
  if (!english) return edited;
  const chapters = new Map(
    source.chapters.map((chapter) => [chapter.id, chapter]),
  );
  const articles = new Map(
    source.chapters.flatMap((chapter) =>
      chapter.articles.map((article) => [article.id, article] as const),
    ),
  );
  return {
    ...source,
    title_en: edited.title,
    chapters: edited.chapters.map((chapter) => {
      const original = chapters.get(chapter.id);
      return {
        id: chapter.id,
        title: original?.title ?? 'Новая глава',
        intro: original?.intro || '',
        title_en: chapter.title,
        intro_en: chapter.intro,
        articles: chapter.articles.map((article) => {
          const previous = articles.get(article.id);
          return {
            id: article.id,
            title: previous?.title ?? 'Новая статья',
            body: previous?.body || '',
            title_en: article.title,
            body_en: article.body,
          };
        }),
      };
    }),
  };
}

// Adopt server IDs/revision only when an acknowledged publication matches our text.
// A competing writer or edits made while awaiting the response retain the working copy.
export function currentDraft(current: Draft, working: Draft): Draft {
  if (current.epoch !== working.epoch || current.revision === working.revision)
    return working;
  const text = (value: unknown): unknown => {
    if (Array.isArray(value)) return value.map(text);
    if (value && typeof value === 'object')
      return Object.fromEntries(
        Object.entries(value)
          .filter(
            ([key, child]) => key !== 'id' && !(key.endsWith('_en') && !child),
          )
          .sort(([a], [b]) => a.localeCompare(b))
          .map(([key, child]) => [key, text(child)]),
      );
    return value;
  };
  return JSON.stringify(text(current.content)) ===
    JSON.stringify(text(working.content))
    ? current
    : working;
}
