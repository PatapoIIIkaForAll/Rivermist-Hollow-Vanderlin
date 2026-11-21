import { describe, expect, test } from 'bun:test';

import {
  applyLawbookLanguage,
  copy,
  currentDraft,
  currentNotes,
  type Draft,
  type Entry,
  emphasisRuns,
  type Lawbook,
  lawbookLanguage,
  loadedDraft,
  move,
  type Notes,
  newId,
  rebase,
} from './types';

describe('scribe editor document boundaries', () => {
  test('adding after loading a saved draft cannot reuse its local identifier', () => {
    const next = newId();
    const n = Number(next.slice('draft_'.length));
    const reserved = `draft_${n + 1}`;
    loadedDraft({
      epoch: 'round',
      revision: 1,
      content: [{ id: reserved, text: 'Saved' }],
    });
    expect(newId()).not.toBe(reserved);
  });

  test('old-round IDs cannot alias unrelated laws in the new round', () => {
    const saved: Draft<Entry[]> = {
      epoch: 'old',
      revision: 10,
      content: [{ id: 'entry_1', text: 'Old text' }],
    };
    const current: Draft<Entry[]> = {
      epoch: 'new',
      revision: 1,
      content: [{ id: 'entry_1', text: 'Unrelated new law' }],
    };
    const result = rebase(saved, current, 'law_code');
    expect(result.epoch).toBe('new');
    expect(result.revision).toBe(1);
    expect(result.content[0].id).not.toBe('entry_1');
    expect(current.content[0].text).toBe('Unrelated new law');
    expect(saved.epoch).toBe('old');
  });

  test('same-round rebase retains surviving official IDs and renews removed IDs', () => {
    const saved: Draft<Entry[]> = {
      epoch: 'round',
      revision: 1,
      content: [
        { id: 'entry_1', text: 'Changed text' },
        { id: 'entry_2', text: 'Restore removed law' },
      ],
    };
    const current: Draft<Entry[]> = {
      epoch: 'round',
      revision: 2,
      content: [{ id: 'entry_1', text: 'Current' }],
    };
    const result = rebase(saved, current, 'law_code');
    expect(result.content[0].id).toBe('entry_1');
    expect(result.content[1].id).toStartWith('draft_');
    expect(result.content[0].text).toBe('Changed text');
  });

  test('loading a saved book does not share mutable chapter/article arrays', () => {
    const book: Lawbook = {
      title: 'Tome',
      chapters: [
        {
          id: 'entry_1',
          title: 'Chapter',
          intro: '',
          articles: [{ id: 'entry_2', title: 'Article', body: 'Original' }],
        },
      ],
    };
    const loaded = copy(book);
    loaded.chapters[0].articles[0].body = 'Unsaved change';
    expect(book.chapters[0].articles[0].body).toBe('Original');
  });

  test('book rebase renews chapter and article IDs from a different round', () => {
    const book: Lawbook = {
      title: 'Tome',
      chapters: [
        {
          id: 'entry_1',
          title: 'Chapter',
          intro: '',
          articles: [{ id: 'entry_2', title: 'Article', body: 'Original' }],
        },
      ],
    };
    const result = rebase(
      { epoch: 'old', revision: 9, content: book },
      { epoch: 'new', revision: 1, content: book },
      'lawbook',
    );
    const resultBook = result.content as Lawbook;
    expect(resultBook.chapters[0].id).toStartWith('draft_');
    expect(resultBook.chapters[0].articles[0].id).toStartWith('draft_');
    expect(resultBook.chapters[0].id).not.toBe(
      resultBook.chapters[0].articles[0].id,
    );
  });

  test('reordering keeps stable IDs and leaves the original snapshot intact', () => {
    const entries = [{ id: 'entry_1' }, { id: 'entry_2' }];
    expect(move(entries, 1, -1).map((row) => row.id)).toEqual([
      'entry_2',
      'entry_1',
    ]);
    expect(entries.map((row) => row.id)).toEqual(['entry_1', 'entry_2']);
    expect(move(entries, 0, -1)).toBe(entries);
  });

  test('English translations follow their law through saved drafts, reorder and rebase', () => {
    const source: Entry[] = [
      { id: 'entry_1', text: 'First source', text_en: 'First English' },
      { id: 'entry_2', text: 'Second source', text_en: 'Second English' },
    ];
    const draft = loadedDraft({
      epoch: 'before',
      revision: 1,
      content: source,
    });
    const rebased = rebase(
      draft,
      { epoch: 'after', revision: 1, content: source },
      'law_code',
    );
    const reordered = move(rebased.content as Entry[], 1, -1);
    expect(reordered[0].text_en).toBe('Second English');
    expect(reordered[1].text_en).toBe('First English');
    reordered[0].text_en = 'Local change';
    expect(source[1].text_en).toBe('Second English');
  });
});

describe('private notes preserve unsaved changes', () => {
  test('a save acknowledgement adopts official IDs and the new revision', () => {
    const working: Notes = {
      revision: 1,
      entries: [{ id: 'draft_1', title: 'Note', body: 'Private text' }],
    };
    const saved: Notes = {
      revision: 2,
      entries: [{ ...working.entries[0], id: 'note_1' }],
    };
    expect(currentNotes(saved, working)).toBe(saved);
    expect(working.entries[0].id).toBe('draft_1');
  });
  test('a competing save cannot discard a different local text', () => {
    const saved: Notes = {
      revision: 3,
      entries: [{ id: 'note_1', title: 'Other', body: 'Other window' }],
    };
    const working: Notes = {
      revision: 2,
      entries: [{ id: 'note_1', title: 'Note', body: 'Unsaved' }],
    };
    expect(currentNotes(saved, working)).toBe(working);
    expect(currentNotes(saved, null)).toBe(saved);
  });
  test('reordering and deleting notes remain pending until acknowledged', () => {
    const saved: Notes = {
      revision: 3,
      entries: [
        { id: 'note_1', title: 'One', body: 'First' },
        { id: 'note_2', title: 'Two', body: 'Second' },
      ],
    };
    const reordered = { ...saved, entries: move(saved.entries, 1, -1) };
    expect(currentNotes(saved, reordered)).toBe(reordered);
    const deleted = { ...saved, entries: [] };
    expect(currentNotes(saved, deleted)).toBe(deleted);
    expect(saved.entries[0].id).toBe('note_1');
    expect(currentNotes({ revision: 4, entries: [] }, deleted).revision).toBe(
      4,
    );
  });
});

describe('poster handwriting is safe Unicode data', () => {
  test('style indexes follow DM code points across Cyrillic and supplementary characters', () => {
    const runs = emphasisRuns('Я😀AБ', [1, 0, 2, 2]);
    expect(runs).toEqual([
      { offset: 0, text: 'Я', style: 1 },
      { offset: 1, text: '😀', style: 0 },
      { offset: 2, text: 'AБ', style: 2 },
    ]);
  });
  test('unmarked text stays a single run; formatting never interprets HTML', () => {
    expect(emphasisRuns('<script>bad()</script>')).toEqual([
      { offset: 0, text: '<script>bad()</script>', style: 0 },
    ]);
    expect(emphasisRuns('', [])).toEqual([]);
    expect(emphasisRuns('AB', [3, 3])).toEqual([
      { offset: 0, text: 'AB', style: 3 },
    ]);
  });
});

describe('bilingual books and publication acknowledgements', () => {
  const book: Lawbook = {
    title: 'Исходная книга',
    title_en: 'Translated book',
    chapters: [
      {
        id: 'entry_1',
        title: 'Исходная глава',
        intro: 'Вступление',
        articles: [
          {
            id: 'entry_2',
            title: 'Исходная статья',
            body: 'Исходный текст',
            body_en: 'English body',
          },
        ],
      },
    ],
  };
  test('readers fall back per field without changing the source or IDs', () => {
    const view = lawbookLanguage(book, true);
    expect(view.title).toBe('Translated book');
    expect(view.chapters[0].title).toBe(book.chapters[0].title);
    expect(view.chapters[0].articles[0].body).toBe('English body');
    expect(view.chapters[0].articles[0].id).toBe('entry_2');
    expect(book.chapters[0].articles[0].body).toBe('Исходный текст');
  });
  test('English edits stay in translations and retain source text', () => {
    const view = lawbookLanguage(book, true, false);
    expect(view.chapters[0].title).toBe('');
    view.chapters[0].title = 'Translated chapter';
    view.chapters[0].articles[0].body = 'Edited English';
    const updated = applyLawbookLanguage(book, view, true);
    expect(updated.chapters[0].title).toBe(book.chapters[0].title);
    expect(updated.chapters[0].title_en).toBe('Translated chapter');
    expect(updated.chapters[0].articles[0].body).toBe('Исходный текст');
    expect(updated.chapters[0].articles[0].body_en).toBe('Edited English');
    expect(book.chapters[0].articles[0].body_en).toBe('English body');
  });
  test('English structural edits preserve translations and untouched incomplete source fields', () => {
    const incomplete = copy(book);
    incomplete.chapters[0].title = '';
    const view = lawbookLanguage(incomplete, true, false);
    view.chapters[0].articles = [
      { id: 'draft_new', title: 'New English', body: 'Unpublished' },
    ];
    const updated = applyLawbookLanguage(incomplete, view, true);
    expect(updated.chapters[0].title).toBe('');
    expect(updated.chapters[0].articles[0].body).toBe('');
    expect(updated.chapters[0].articles[0].body_en).toBe('Unpublished');
    expect(updated.chapters[0].articles.some((a) => a.id === 'entry_2')).toBe(
      false,
    );
  });
  test('a publication acknowledgement adopts stable IDs and its revision', () => {
    const working: Draft<Entry[]> = {
      epoch: 'same',
      revision: 1,
      content: [{ id: 'draft_x', text: 'Mine' }],
    };
    const current: Draft<Entry[]> = {
      epoch: 'same',
      revision: 2,
      content: [{ id: 'entry_9', text: 'Mine', text_en: '' }],
    };
    expect(currentDraft(current, working)).toBe(current);
    expect(working.content[0].id).toBe('draft_x');
  });
  test('another writer or subsequent typing cannot overwrite local work', () => {
    const working: Draft<Entry[]> = {
      epoch: 'same',
      revision: 1,
      content: [{ id: 'draft_x', text: 'Still typing' }],
    };
    const other: Draft<Entry[]> = {
      epoch: 'same',
      revision: 2,
      content: [{ id: 'entry_9', text: 'Earlier text' }],
    };
    expect(currentDraft(other, working)).toBe(working);
    expect(
      currentDraft(
        { ...other, epoch: 'new' },
        { ...working, content: other.content },
      ),
    ).not.toBe(other);
  });
  test('book acknowledgement includes translations and ignores only server IDs and empty optional fields', () => {
    const working: Draft<Lawbook> = {
      epoch: 'same',
      revision: 1,
      content: copy(book),
    };
    const content = copy(book);
    content.chapters[0].id = 'entry_8';
    content.chapters[0].title_en = '';
    const current = { ...working, revision: 2, content };
    expect(currentDraft(current, working)).toBe(current);
    current.content.chapters[0].articles[0].body_en = 'Someone else';
    expect(currentDraft(current, working)).toBe(working);
  });
});

describe('interface language from player preferences', () => {
  test('Russian and English chrome use the same stable message key', async () => {
    const { rmhText } = await import('./locale');
    expect(rmhText('ru', 'Сохранить черновик')).toBe('Сохранить черновик');
    expect(rmhText('en', 'Сохранить черновик')).toBe('Save draft');
    expect(rmhText('en', 'Статья {0}', 4)).toBe('Article 4');
  });
  test('translation preserves surrounding spaces and leaves unknown authored text intact', async () => {
    const { rmhText } = await import('./locale');
    expect(rmhText('en', ' Указ ')).toBe(' Decree ');
    expect(rmhText('en', '<script>this is document text</script>')).toBe(
      '<script>this is document text</script>',
    );
  });
});
