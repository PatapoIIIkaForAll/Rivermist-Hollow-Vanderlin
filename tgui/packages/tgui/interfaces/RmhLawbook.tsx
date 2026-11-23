import {
  RmhLocaleProvider,
  useRmhLanguage,
  useRmhText,
} from './RmhScribeStand/locale';
import '../styles/interfaces/RmhScribeStand.scss';
import { useState } from 'react';
import { Box, Button, Input } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  matches,
  Prose,
  scrollToEntry,
  TocEntry,
} from './RmhScribeStand/Layout';
import { type Lawbook, lawbookLanguage } from './RmhScribeStand/types';

type Data = {
  language?: string;
  revision: number;
  lawbook: Lawbook;
};
export function RmhLawbook() {
  const { data } = useBackend<Data>();
  return (
    <RmhLocaleProvider language={data.language}>
      <Window width={1120} height={820} theme="rmh-lawbook">
        <Window.Content>
          <LawbookReader book={data.lawbook} revision={data.revision} />
        </Window.Content>
      </Window>
    </RmhLocaleProvider>
  );
}
// This view has no act callback or editor state: every copy reads the publication.
export function LawbookReader({
  book: source,
  revision,
}: {
  book: Lawbook;
  revision: number;
}) {
  const t = useRmhText();
  const language = useRmhLanguage();
  const [english, setEnglish] = useState(language === 'en');
  const book = lawbookLanguage(source, english);
  const [query, setQuery] = useState('');
  const [selected, setSelected] = useState<string | null>(null);
  // Deleted chapters fall back to the complete current edition.
  const active = book.chapters.some((chapter) => chapter.id === selected)
    ? selected
    : null;
  const count = book.chapters.reduce(
    (total, chapter) => total + chapter.articles.length,
    0,
  );
  const matching = book.chapters.filter((chapter) =>
    matches(
      query,
      chapter.title,
      chapter.intro,
      ...chapter.articles.flatMap((article) => [article.title, article.body]),
    ),
  );
  let articleNumber = 0;
  return (
    <Box className="RmhCodex">
      <Box className="RmhCodex__side RmhCodex__frame">
        <Box className="RmhCodex__brand">
          <h1>{t('Книга законов')}</h1>
          <Box>{t('Град Ривермист · Tome of Justice')}</Box>
        </Box>
        <Box className="RmhCodex__search">
          <Input
            fluid
            value={query}
            placeholder={t('Поиск по главам и статьям')}
            onChange={setQuery}
          />
        </Box>
        <Box className="RmhCodex__contents">
          <TocEntry
            id="all"
            title={t('Вся книга')}
            selected={!active}
            onClick={() => setSelected(null)}
          />
          {matching.map((chapter) => (
            <Box key={chapter.id}>
              <TocEntry
                id={chapter.id}
                title={chapter.title}
                number={book.chapters.indexOf(chapter) + 1}
                selected={active === chapter.id}
                onClick={() => setSelected(chapter.id)}
              />
              {chapter.articles
                .filter((article) =>
                  matches(query, article.title, article.body, chapter.title),
                )
                .map((article) => (
                  <TocEntry
                    key={article.id}
                    id={article.id}
                    title={article.title}
                    sub
                    onClick={() => {
                      setSelected(chapter.id);
                      scrollToEntry(article.id);
                    }}
                  />
                ))}
            </Box>
          ))}
          {!matching.length && (
            <Box className="RmhCodex__empty">{t('Совпадений не найдено.')}</Box>
          )}
        </Box>
      </Box>
      <Box className="RmhCodex__main RmhCodex__frame">
        <Box className="RmhCodex__head">
          <Box className="RmhCodex__heading">
            <Box className="RmhCodex__tag">{t('ОФИЦИАЛЬНОЕ ИЗДАНИЕ')}</Box>
            <h2>{book.title}</h2>
            <Box className="RmhCodex__subtitle">
              {t('Опубликованная книга законов · редакция ')}
              {revision}
            </Box>
          </Box>
          <Box className="RmhCodex__meters">
            <Button onClick={() => setEnglish(!english)} selected={english}>
              {english ? 'RU' : 'EN'}
            </Button>
            <Box className="RmhCodex__meter">
              <b>{book.chapters.length}</b>
              <span>{t('глав')}</span>
            </Box>
            <Box className="RmhCodex__meter">
              <b>{count}</b>
              <span>{t('статей')}</span>
            </Box>
          </Box>
        </Box>
        <Box className="RmhCodex__view">
          {book.chapters.map((chapter, chapterIndex) => {
            const offset = articleNumber;
            articleNumber += chapter.articles.length;
            if (active && active !== chapter.id) return null;
            return (
              <Box key={chapter.id} className="RmhCodex__chapter">
                <Box className="RmhCodex__chapterHead">
                  <Box className="RmhCodex__tag">
                    {t('ГЛАВА ')}
                    {chapterIndex + 1}
                  </Box>
                  <h3>{chapter.title}</h3>
                  {!!chapter.intro && <Prose text={chapter.intro} />}
                  <Box className="RmhCodex__ornament">◆</Box>
                </Box>
                {chapter.articles.map((article, index) => (
                  <Box
                    key={article.id}
                    id={`rmh-entry-${article.id}`}
                    className="RmhCodex__article"
                  >
                    <h4>
                      <span>
                        {t('Статья ')}
                        {offset + index + 1}.
                      </span>{' '}
                      {article.title}
                    </h4>
                    <Prose text={article.body} />
                  </Box>
                ))}
              </Box>
            );
          })}
          {!book.chapters.length && (
            <Box className="RmhCodex__empty">
              {t('В опубликованной книге пока нет глав.')}
            </Box>
          )}
        </Box>
      </Box>
    </Box>
  );
}
