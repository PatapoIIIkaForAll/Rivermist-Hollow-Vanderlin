import {
  RmhLocaleProvider,
  useRmhLanguage,
  useRmhText,
} from './RmhScribeStand/locale';
// RMH: board and poster presentation share one route; editing stays server-authorized.
import '../styles/interfaces/RmhScribeStand.scss';
import {
  type CSSProperties,
  type MouseEvent,
  type ReactNode,
  useEffect,
  useState,
} from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { dragStartHandler } from '../drag';
import { suspendStart } from '../events/handlers/suspense';
import { Window } from '../layouts';
import { matches, Prose } from './RmhScribeStand/Layout';
import type { Act, Decree } from './RmhScribeStand/types';

type Skin = 'board' | 'poster';
type Data = {
  language?: string;
  kind: Skin;
  mode: 'read' | 'copy' | 'forge';
  token: number;
  revision: number;
  epoch: string | null;
  busy: BooleanLike;
  forge_max_characters?: number;
  decrees: Decree[];
};
export function RmhDecree() {
  const { data, act } = useBackend<Data>();
  const board = data.kind === 'board';
  const reading = board || data.mode === 'read';
  return (
    <RmhLocaleProvider language={data.language}>
      <Window
        width={reading ? 480 : 760}
        height={reading ? (board ? 680 : 690) : 780}
        theme={reading ? 'rmh-decree' : 'rmh-lawbook'}
      >
        <Window.Content>
          {board ? (
            <DecreeReader decrees={data.decrees} />
          ) : (
            <PosterWorkspace key={data.token} data={data} act={act} />
          )}
        </Window.Content>
      </Window>
    </RmhLocaleProvider>
  );
}
/** Uses the existing TGUI native-window bridge, status checks and close lifecycle. */
export function DecreeFrame({
  kind,
  children,
  onClose = suspendStart,
  onDragStart = dragStartHandler,
}: {
  kind: Skin;
  children: ReactNode;
  onClose?: () => void;
  onDragStart?: (event: MouseEvent<HTMLElement>) => void;
}) {
  const t = useRmhText();
  const [textSize, setTextSize] = useState(18);
  useEffect(() => {
    const key = (event: KeyboardEvent) => {
      if (!event.ctrlKey || event.altKey) return;
      const direction = ['+', '=', 'Add'].includes(event.key)
        ? 2
        : ['-', '_', 'Subtract'].includes(event.key)
          ? -2
          : 0;
      if (!direction && event.key !== '0') return;
      event.preventDefault();
      setTextSize((previous) =>
        event.key === '0'
          ? 18
          : Math.max(12, Math.min(36, previous + direction)),
      );
    };
    const wheel = (event: WheelEvent) => {
      if (!event.ctrlKey || !event.deltaY) return;
      event.preventDefault();
      setTextSize((previous) =>
        Math.max(12, Math.min(36, previous + (event.deltaY < 0 ? 2 : -2))),
      );
    };
    document.addEventListener('keydown', key, true);
    document.addEventListener('wheel', wheel, { passive: false });
    return () => {
      document.removeEventListener('keydown', key, true);
      document.removeEventListener('wheel', wheel);
    };
  }, []);
  useEffect(() => {
    if (kind !== 'poster') return;
    // WebView2 may paint a legacy colour key literally. Clear any key left
    // by an older reader; keep the ribbon over a plain black fallback instead.
    document.documentElement.dataset.rmhPosterReader = '1';
    Byond.winset(Byond.windowId, {
      'is-transparent': false,
      'transparent-color': 'none',
    });
    return () => {
      delete document.documentElement.dataset.rmhPosterReader;
    };
  }, [kind]);
  return (
    <div
      style={{ '--decree-text-size': `${textSize}px` } as CSSProperties}
      className={`RmhDecreeSkin RmhDecreeSkin--${kind}`}
      onKeyDown={(event) => {
        if (event.key === 'Escape') {
          event.preventDefault();
          onClose();
        }
      }}
    >
      <img
        className="RmhDecreeSkin__art"
        alt=""
        draggable={false}
        src={resolveAsset(`rmh-decree-${kind}-main.png`)}
      />
      <button
        type="button"
        className="RmhDecreeSkin__drag"
        aria-label={t('Переместить окно')}
        onMouseDown={(event) => {
          if (event.button === 0) {
            event.stopPropagation();
            onDragStart(event);
          }
        }}
      />
      <button
        type="button"
        className="RmhDecreeSkin__close"
        aria-label={t('Закрыть окно')}
        onClick={onClose}
      />
      <img
        className="RmhDecreeSkin__hover"
        alt=""
        draggable={false}
        src={resolveAsset(`rmh-decree-${kind}-button.png`)}
      />
      <div className="RmhDecreeSkin__content">{children}</div>
    </div>
  );
}
export function DecreeReader({
  decrees,
  kind = 'board',
}: {
  decrees: Decree[];
  kind?: Skin;
}) {
  const t = useRmhText();
  const [query, setQuery] = useState('');
  const language = useRmhLanguage();
  const [english, setEnglish] = useState(language === 'en');
  const visible = decrees.filter((decree) =>
    matches(query, decree.text, decree.text_en || ''),
  );
  return (
    <DecreeFrame kind={kind}>
      <header className="RmhDecreeSkin__header">
        <h2>{kind === 'poster' ? t('Указ') : t('Указы')}</h2>
        <Button
          className="RmhDecreeSkin__language"
          selected={english}
          onClick={() => setEnglish(!english)}
        >
          {english ? 'RU' : 'EN'}
        </Button>
      </header>
      {kind === 'board' && (
        <Input
          className="RmhDecreeSkin__search"
          fluid
          value={query}
          onChange={setQuery}
          placeholder={t('Поиск по указам')}
        />
      )}
      <div className="RmhDecreeSkin__scroll" tabIndex={0}>
        {!decrees.length && <Box>{t('Действующих указов нет.')}</Box>}
        {!!decrees.length && !visible.length && (
          <Box>{t('Совпадений не найдено.')}</Box>
        )}
        {visible.map((decree) => (
          <article key={decree.id} className="RmhDecreeSkin__entry">
            {kind === 'board' && (
              <h3>
                {t('Указ')} {decrees.indexOf(decree) + 1}
              </h3>
            )}
            {english && !decree.text_en?.trim() && (
              <Box className="RmhDecreeSkin__fallback">
                {t('EN не заполнен; показан исходник.')}
              </Box>
            )}
            <Prose
              text={
                english && decree.text_en?.trim() ? decree.text_en : decree.text
              }
              marks={
                english && decree.text_en?.trim()
                  ? decree.marks_en
                  : decree.marks
              }
            />
          </article>
        ))}
      </div>
    </DecreeFrame>
  );
}
export function PosterWorkspace({ data, act }: { data: Data; act: Act }) {
  const t = useRmhText();
  const [text, setText] = useState(() => data.decrees[0]?.text || '');
  const [english, setEnglish] = useState(() => data.decrees[0]?.text_en || '');
  if (data.mode === 'read')
    return <DecreeReader decrees={data.decrees} kind="poster" />;
  const context = { token: data.token, revision: data.revision };
  const characters = Array.from(text).length + Array.from(english).length;
  const maxCharacters = data.forge_max_characters ?? 360;
  const overLimit = characters > maxCharacters;
  const seconds = characters / 2;
  return (
    <Box className="RmhCodex" style={{ display: 'block' }}>
      <Box className="RmhCodex__main RmhCodex__frame" height="100%">
        <Box className="RmhCodex__head">
          <Box className="RmhCodex__heading">
            <h2>
              {data.mode === 'copy'
                ? t('Скопировать указ')
                : t('Переписать постер')}
            </h2>
          </Box>
        </Box>
        <Box className="RmhCodex__view">
          {data.mode === 'copy' ? (
            <>
              {!data.decrees.length && (
                <Box className="RmhCodex__empty">
                  {t('Действующих указов нет.')}
                </Box>
              )}
              {data.decrees.map((decree, index) => (
                <Section key={decree.id} title={t('Указ {0}', index + 1)}>
                  <Prose text={decree.text} />
                  {!!decree.text_en && <Prose text={decree.text_en} />}
                  <Button
                    disabled={
                      Array.from(decree.text).length > 2048 ||
                      Array.from(decree.text_en || '').length > 2048
                    }
                    onClick={() =>
                      act('copy', {
                        ...context,
                        epoch: data.epoch,
                        id: decree.id,
                        decree_revision: decree.revision,
                      })
                    }
                  >
                    {t('Перенести на постер')}
                  </Button>
                </Section>
              ))}
            </>
          ) : (
            <Section title={t('Текст постера')}>
              <fieldset
                disabled={!!data.busy}
                style={{ border: 0, padding: 0, margin: 0 }}
              >
                <Box className="RmhCodex__fieldLabel">
                  {t('Исходный текст')}
                </Box>
                <TextArea
                  fluid
                  height={12}
                  maxLength={2048}
                  value={text}
                  disabled={!!data.busy}
                  onChange={setText}
                />
                <Box className="RmhCodex__fieldLabel">
                  {t('English — необязательный ручной перевод')}
                </Box>
                <TextArea
                  fluid
                  height={8}
                  maxLength={2048}
                  value={english}
                  disabled={!!data.busy}
                  onChange={setEnglish}
                />
              </fieldset>
              <Box className="RmhCodex__muted" my={1}>
                {t('Время переписывания: ')}
                {seconds}
                {t(
                  'сек. Не уходите и держите тату-машинку. Закрытие окна отменяет работу. Официальный указ не изменится.',
                )}
              </Box>
              <Box className="RmhCodex__muted">
                {characters} / {maxCharacters} {t('символов суммарно в RU+EN')}
              </Box>
              {overLimit && (
                <NoticeBox danger>
                  {t('Сократите текст: подделка ограничена 180 секундами.')}
                </NoticeBox>
              )}
              <Button
                disabled={!!data.busy || !text.trim() || overLimit}
                onClick={() =>
                  act('forge', { ...context, text, text_en: english })
                }
              >
                {data.busy ? t('Переписывание…') : t('Переписать')}
              </Button>
            </Section>
          )}
        </Box>
      </Box>
    </Box>
  );
}
