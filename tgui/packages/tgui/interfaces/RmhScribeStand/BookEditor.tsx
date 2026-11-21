import { useState } from 'react';
import { Box, Button, Input, Section, TextArea } from 'tgui-core/components';
import {
  CodexFrame,
  type DocumentControls,
  DocumentToolbar,
  matches,
  type Navigation,
  Prose,
  scrollToEntry,
  TocEntry,
} from './Layout';
import { useRmhText } from './locale';
import {
  type Article,
  applyLawbookLanguage,
  type Chapter,
  type Entry,
  type Lawbook,
  lawbookLanguage,
  move,
  newId,
} from './types';

type Props = Navigation &
  DocumentControls & {
    book: Lawbook;
    readOnly: boolean;
    onChange: (book: Lawbook) => void;
  };
function roman(number: number) {
  let result = '';
  for (const [value, symbol] of [
    [10, 'X'],
    [9, 'IX'],
    [5, 'V'],
    [4, 'IV'],
    [1, 'I'],
  ] as const) {
    while (number >= value) {
      result += symbol;
      number -= value;
    }
  }
  return result;
}
export function BookEditor(props: Props) {
  const t = useRmhText();
  const { readOnly } = props;
  const [english, setEnglish] = useState(false);
  const book = lawbookLanguage(props.book, english, readOnly);
  const onChange = (next: Lawbook) =>
    props.onChange(applyLawbookLanguage(props.book, next, english));
  const [query, setQuery] = useState('');
  const [selected, setSelected] = useState<string | null>(null);
  const [editingChapter, setEditingChapter] = useState<string | null>(null);
  const [editingArticle, setEditingArticle] = useState<string | null>(null);
  const chosen = book.chapters.find((chapter) => chapter.id === selected);
  const articleCount = book.chapters.reduce(
    (sum, chapter) => sum + chapter.articles.length,
    0,
  );
  const updateChapter = (next: Chapter) =>
    onChange({
      ...book,
      chapters: book.chapters.map((chapter) =>
        chapter.id === next.id ? next : chapter,
      ),
    });
  const addChapter = () => {
    const id = newId();
    onChange({
      ...book,
      chapters: [
        ...book.chapters,
        {
          id,
          title: t('Новая глава'),
          intro: '',
          articles: [],
        },
      ],
    });
    setSelected(id);
    setEditingChapter(id);
  };
  let ordinal = 0;
  return (
    <CodexFrame
      {...props}
      title={chosen?.title || book.title || t('Книга законов')}
      tag={
        chosen
          ? t('Глава {0}', roman(book.chapters.indexOf(chosen) + 1))
          : t('Книга законов')
      }
      subtitle={
        chosen?.intro ||
        t(
          'Подробные законы града, разделённые по главам. Книга публикуется независимо от краткого свода.',
        )
      }
      meters={[
        { value: book.chapters.length, label: t('глав') },
        {
          value: articleCount,
          label: t('статей'),
        },
        {
          value: props.data.book_revision,
          label: t('редакция'),
        },
      ]}
      search={query}
      onSearch={setQuery}
      sidebar={
        <>
          {!readOnly && (
            <Button
              className="RmhCodex__sideAdd"
              icon="plus"
              fluid
              disabled={book.chapters.length >= 32}
              onClick={addChapter}
            >
              {t('Новая глава')}
            </Button>
          )}
          <TocEntry
            id="all"
            title={t('Вся книга')}
            subtitle={t(
              '{0} глав · {1} статей',
              book.chapters.length,
              articleCount,
            )}
            selected={!chosen}
            onClick={() => setSelected(null)}
          />
          {book.chapters.map((chapter, index) => {
            const start = ordinal;
            ordinal += chapter.articles.length;
            const articles = chapter.articles.filter((article) =>
              matches(query, chapter.title, article.title, article.body),
            );
            if (
              !articles.length &&
              !matches(query, chapter.title, chapter.intro)
            )
              return null;
            return (
              <Box key={chapter.id} className="RmhCodex__tocGroup">
                <Button
                  className="RmhCodex__tocHeading"
                  selected={chosen?.id === chapter.id}
                  onClick={() => setSelected(chapter.id)}
                >
                  {roman(index + 1)}. {chapter.title || t('Без названия')}
                </Button>
                {articles.map((article) => (
                  <TocEntry
                    key={article.id}
                    id={article.id}
                    sub
                    number={start + chapter.articles.indexOf(article) + 1}
                    title={article.title || t('Новая статья')}
                    selected={editingArticle === article.id}
                    onClick={() => {
                      setSelected(chapter.id);
                      scrollToEntry(article.id);
                    }}
                  />
                ))}
              </Box>
            );
          })}
          {!book.chapters.length && (
            <Box className="RmhCodex__empty">{t('В книге ещё нет глав.')}</Box>
          )}
        </>
      }
    >
      <DocumentToolbar {...props} />
      <Section
        title={t('Версия книги')}
        className="RmhCodex__card"
        buttons={
          <>
            <Button selected={!english} onClick={() => setEnglish(false)}>
              {t('RU / исходник')}
            </Button>
            <Button selected={english} onClick={() => setEnglish(true)}>
              {t('EN / перевод')}
            </Button>
          </>
        }
      >
        <Box className="RmhCodex__muted">
          {t(
            'Перевод вводится вручную для тех же глав и статей. Публикуются оба языка. Если перевод поля отсутствует, читатель увидит исходник. Добавление и удаление глав или статей меняет общую структуру книги.',
          )}
        </Box>
      </Section>
      {!readOnly && <BookName book={book} onChange={onChange} />}
      <Box className="RmhCodex__page">
        {!book.chapters.length && (
          <Box className="RmhCodex__empty">
            {t('Добавьте первую главу книги.')}
          </Box>
        )}
        {(chosen ? [chosen] : book.chapters).map((chapter) => {
          const index = book.chapters.indexOf(chapter);
          const offset = book.chapters
            .slice(0, index)
            .reduce((sum, row) => sum + row.articles.length, 0);
          return (
            <ChapterSection
              key={chapter.id}
              chapter={chapter}
              number={roman(index + 1)}
              offset={offset}
              readOnly={readOnly}
              editChapter={editingChapter === chapter.id}
              editArticle={editingArticle}
              onEditChapter={() => setEditingChapter(chapter.id)}
              onDoneChapter={() => setEditingChapter(null)}
              onEditArticle={setEditingArticle}
              onChange={updateChapter}
              upDisabled={!index}
              downDisabled={index === book.chapters.length - 1}
              onMove={(direction) =>
                onChange({
                  ...book,
                  chapters: move(book.chapters, index, direction),
                })
              }
              onDelete={() =>
                onChange({
                  ...book,
                  chapters: book.chapters.filter(
                    (row) => row.id !== chapter.id,
                  ),
                })
              }
              canAdd={articleCount < 128}
            />
          );
        })}
      </Box>
    </CodexFrame>
  );
}
function BookName({
  book,
  onChange,
}: {
  book: Lawbook;
  onChange: (book: Lawbook) => void;
}) {
  const t = useRmhText();
  const [open, setOpen] = useState(false);
  return (
    <Box className="RmhCodex__bookName">
      <Button icon="pen" selected={open} onClick={() => setOpen(!open)}>
        {t('Название книги')}
      </Button>
      {open && (
        <Input
          fluid
          maxLength={128}
          value={book.title}
          onChange={(title) => onChange({ ...book, title })}
        />
      )}
    </Box>
  );
}
type ChapterProps = {
  chapter: Chapter;
  number: string;
  offset: number;
  readOnly: boolean;
  editChapter: boolean;
  editArticle: string | null;
  onEditChapter: () => void;
  onDoneChapter: () => void;
  onEditArticle: (id: string | null) => void;
  onChange: (chapter: Chapter) => void;
  upDisabled: boolean;
  downDisabled: boolean;
  onMove: (direction: number) => void;
  onDelete: () => void;
  canAdd: boolean;
};
function ChapterSection(props: ChapterProps) {
  const t = useRmhText();
  const { chapter, readOnly, onChange } = props;
  return (
    <Box className="RmhCodex__chapter">
      {!readOnly && props.editChapter ? (
        <Section
          title={t('Глава {0}', props.number)}
          className="RmhCodex__card"
        >
          <Box className="RmhCodex__fieldLabel">{t('Название главы')}</Box>
          <Input
            fluid
            maxLength={128}
            value={chapter.title}
            onChange={(title) => onChange({ ...chapter, title })}
          />
          <Box className="RmhCodex__fieldLabel">{t('Вступление')}</Box>
          <TextArea
            fluid
            height={5}
            maxLength={8192}
            value={chapter.intro}
            onChange={(intro) => onChange({ ...chapter, intro })}
          />
          <Button icon="check" mt={1} onClick={props.onDoneChapter}>
            {t('Готово')}
          </Button>
        </Section>
      ) : (
        <Box className="RmhCodex__chapterHead">
          <Box className="RmhCodex__tag">
            {t('ГЛАВА ')}
            {props.number}
          </Box>
          <h3>{chapter.title || t('Новая глава')}</h3>
          {!!chapter.intro && (
            <Box className="RmhCodex__intro">{chapter.intro}</Box>
          )}
          <Box className="RmhCodex__ornament">◆</Box>
        </Box>
      )}
      {!readOnly && (
        <Box className="RmhCodex__chapterTools">
          <Button
            icon="arrow-up"
            tooltip={t('Глава выше')}
            disabled={props.upDisabled}
            onClick={() => props.onMove(-1)}
          />
          <Button
            icon="arrow-down"
            tooltip={t('Глава ниже')}
            disabled={props.downDisabled}
            onClick={() => props.onMove(1)}
          />
          <Button
            icon="pen"
            tooltip={t('Править главу')}
            onClick={props.onEditChapter}
          />
          <Button.Confirm
            confirmContent={t('Подтвердить')}
            icon="trash"
            color="bad"
            tooltip={t('Удалить главу и статьи')}
            onClick={props.onDelete}
          />
        </Box>
      )}
      {chapter.articles.map((article, index) => (
        <ArticleCard
          key={article.id}
          article={article}
          number={props.offset + index + 1}
          readOnly={readOnly}
          editing={props.editArticle === article.id}
          onEdit={() => props.onEditArticle(article.id)}
          onDone={() => props.onEditArticle(null)}
          onChange={(next) =>
            onChange({
              ...chapter,
              articles: chapter.articles.map((row) =>
                row.id === next.id ? next : row,
              ),
            })
          }
          onMove={(direction) =>
            onChange({
              ...chapter,
              articles: move(chapter.articles, index, direction),
            })
          }
          upDisabled={!index}
          downDisabled={index === chapter.articles.length - 1}
          onDelete={() =>
            onChange({
              ...chapter,
              articles: chapter.articles.filter((row) => row.id !== article.id),
            })
          }
        />
      ))}
      {!readOnly && (
        <Box className="RmhCodex__addArticle">
          <Button
            icon="plus"
            disabled={!props.canAdd}
            onClick={() => {
              const id = newId();
              onChange({
                ...chapter,
                articles: [
                  ...chapter.articles,
                  {
                    id,
                    title: t('Новая статья'),
                    body: '',
                  },
                ],
              });
              props.onEditArticle(id);
              scrollToEntry(id);
            }}
          >
            {t('Добавить статью')}
          </Button>
        </Box>
      )}
    </Box>
  );
}
type ArticleProps = {
  article: Article;
  number: number;
  readOnly: boolean;
  editing: boolean;
  onEdit: () => void;
  onDone: () => void;
  onChange: (article: Article) => void;
  onMove: (direction: number) => void;
  upDisabled: boolean;
  downDisabled: boolean;
  onDelete: () => void;
};
function ArticleCard(props: ArticleProps) {
  const t = useRmhText();
  const { article, readOnly } = props;
  return (
    <Box id={`rmh-entry-${article.id}`} className="RmhCodex__article">
      {!readOnly && props.editing ? (
        <Section
          title={t('Статья {0}', props.number)}
          className="RmhCodex__card"
        >
          <Box className="RmhCodex__fieldLabel">{t('Заголовок статьи')}</Box>
          <Input
            fluid
            maxLength={128}
            value={article.title}
            onChange={(title) => props.onChange({ ...article, title })}
          />
          <Box className="RmhCodex__fieldLabel">{t('Текст статьи')}</Box>
          <TextArea
            fluid
            height={14}
            maxLength={8192}
            value={article.body}
            onChange={(body) => props.onChange({ ...article, body })}
          />
          <Box className="RmhCodex__actions" mt={1}>
            <Button icon="check" onClick={props.onDone}>
              {t('Готово')}
            </Button>
            <Box className="RmhCodex__muted">
              {article.body.length}
              {t('/ 8192 · новая строка: Shift+Enter')}
            </Box>
          </Box>
          <ArticleTools {...props} />
        </Section>
      ) : (
        <>
          <h4>
            <span>
              {t('Статья ')}
              {props.number}.
            </span>{' '}
            {article.title || t('Новая статья')}
          </h4>
          <Prose text={article.body || t('Текст статьи ещё не введён.')} />
          <ArticleTools {...props} />
        </>
      )}
    </Box>
  );
}

function ArticleTools(props: ArticleProps) {
  const t = useRmhText();
  if (props.readOnly) return null;
  return (
    <Box className="RmhCodex__tools">
      <Button
        icon="arrow-up"
        tooltip={t('Статья выше')}
        disabled={props.upDisabled}
        onClick={() => props.onMove(-1)}
      />
      <Button
        icon="arrow-down"
        tooltip={t('Статья ниже')}
        disabled={props.downDisabled}
        onClick={() => props.onMove(1)}
      />
      <Button
        icon="pen"
        tooltip={t('Править статью')}
        selected={props.editing}
        onClick={props.onEdit}
      />
      <Button.Confirm
        confirmContent={t('Подтвердить')}
        icon="trash"
        tooltip={t('Удалить статью')}
        color="bad"
        onClick={props.onDelete}
      />
    </Box>
  );
}
type CodeProps = Navigation &
  DocumentControls & {
    entries: Entry[];
    readOnly: boolean;
    onChange: (entries: Entry[]) => void;
  };
export function CodeEditor(props: CodeProps) {
  const t = useRmhText();
  const { entries, readOnly, onChange } = props;
  const [query, setQuery] = useState('');
  const [english, setEnglish] = useState(false);
  const field = english ? 'text_en' : 'text';
  const displayed = (entry: Entry) =>
    english && entry.text_en?.trim() ? entry.text_en : entry.text;
  const [editing, setEditing] = useState<string | null>(null);
  const found = entries.filter((entry) => matches(query, displayed(entry)));
  const add = () => {
    const id = newId();
    onChange([...entries, { id, text: '', text_en: '' }]);
    setEditing(id);
    scrollToEntry(id);
  };
  return (
    <CodexFrame
      {...props}
      title={t('Законы земель Ривермиста')}
      tag={t('Свод законов')}
      subtitle={t(
        'Краткие формулировки действующих законов. Свод публикуется отдельно от подробной книги.',
      )}
      meters={[
        {
          value: entries.length,
          label: t('законов'),
        },
        {
          value: props.data.code_revision,
          label: t('редакция'),
        },
      ]}
      search={query}
      onSearch={setQuery}
      sidebar={
        <>
          {!readOnly && (
            <Button
              className="RmhCodex__sideAdd"
              icon="plus"
              fluid
              disabled={entries.length >= 64}
              onClick={add}
            >
              {t('Новый закон')}
            </Button>
          )}
          {found.map((entry) => (
            <TocEntry
              key={entry.id}
              id={entry.id}
              number={entries.indexOf(entry) + 1}
              title={displayed(entry).slice(0, 105) || t('Новый закон')}
              selected={editing === entry.id}
              onClick={() => scrollToEntry(entry.id)}
            />
          ))}
          {!found.length && (
            <Box className="RmhCodex__empty">
              {query ? t('Ничего не найдено.') : t('Свод пуст.')}
            </Box>
          )}
        </>
      }
    >
      <DocumentToolbar {...props} />
      <Section
        title={t('Версия текста')}
        className="RmhCodex__card"
        buttons={
          <>
            <Button selected={!english} onClick={() => setEnglish(false)}>
              {t('RU / исходник')}
            </Button>
            <Button selected={english} onClick={() => setEnglish(true)}>
              {t('EN / перевод')}
            </Button>
          </>
        }
      >
        <Box className="RmhCodex__muted">
          {t(
            'Перевод вводится вручную. Публикуются оба языка свода с общей редакцией. Если EN не заполнен, читатель увидит исходный текст. После правки исходника проверьте перевод.',
          )}
        </Box>
      </Section>
      <Section
        title={t('Свод законов')}
        className="RmhCodex__card"
        buttons={
          !readOnly && (
            <Button.Confirm
              confirmContent={t('Подтвердить')}
              color="bad"
              disabled={!entries.length}
              onClick={() => {
                onChange([]);
                setEditing(null);
              }}
            >
              {t('Очистить свод')}
            </Button.Confirm>
          )
        }
      >
        {!entries.length && (
          <Box className="RmhCodex__empty">{t('Законы ещё не внесены.')}</Box>
        )}
        {entries.map((entry, index) => (
          <Box
            key={entry.id}
            id={`rmh-entry-${entry.id}`}
            className="RmhCodex__law"
          >
            <Box className="RmhCodex__number">{index + 1}.</Box>
            <Box className="RmhCodex__lawText">
              {!readOnly && editing === entry.id ? (
                <>
                  <TextArea
                    fluid
                    height={7}
                    value={entry[field] || ''}
                    maxLength={2048}
                    onChange={(text) =>
                      onChange(
                        entries.map((row) =>
                          row.id === entry.id ? { ...row, [field]: text } : row,
                        ),
                      )
                    }
                  />
                  <Box className="RmhCodex__actions" mt={1}>
                    <Button icon="check" onClick={() => setEditing(null)}>
                      {t('Готово')}
                    </Button>
                    <Box className="RmhCodex__muted">
                      {(entry[field] || '').length}
                      {t('/ 2048 · новая строка: Shift+Enter')}
                    </Box>
                  </Box>
                </>
              ) : (
                <Box className="RmhCodex__prose">
                  {displayed(entry) || t('Новый закон — введите текст.')}
                </Box>
              )}
            </Box>
            {!readOnly && (
              <Box className="RmhCodex__tools">
                <Button
                  icon="arrow-up"
                  tooltip={t('Выше')}
                  disabled={!index}
                  onClick={() => onChange(move(entries, index, -1))}
                />
                <Button
                  icon="arrow-down"
                  tooltip={t('Ниже')}
                  disabled={index === entries.length - 1}
                  onClick={() => onChange(move(entries, index, 1))}
                />
                <Button
                  icon="pen"
                  tooltip={t('Править закон')}
                  selected={editing === entry.id}
                  onClick={() => setEditing(entry.id)}
                />
                <Button.Confirm
                  confirmContent={t('Подтвердить')}
                  icon="trash"
                  tooltip={t('Удалить закон')}
                  color="bad"
                  onClick={() =>
                    onChange(entries.filter((row) => row.id !== entry.id))
                  }
                />
              </Box>
            )}
          </Box>
        ))}
        {!readOnly && (
          <Button icon="plus" disabled={entries.length >= 64} onClick={add}>
            {t('Добавить закон')}
          </Button>
        )}
      </Section>
    </CodexFrame>
  );
}
