import { Fragment, type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  Input,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import { payloadChunkCount } from '../../events/act';
import { useRmhText } from './locale';
import {
  type Act,
  type Data,
  type DocumentId,
  type Draft,
  emphasisRuns,
  publication,
  rebase,
} from './types';
export type Page = DocumentId | 'drafts' | 'decrees';
export type Navigation = {
  data: Data;
  page: Page;
  onPage: (page: Page) => void;
};
type Props = Navigation & {
  title: string;
  subtitle: string;
  tag: string;
  meters?: {
    value: number;
    label: string;
  }[];
  search?: string;
  onSearch?: (value: string) => void;
  sidebar: ReactNode;
  children: ReactNode;
};
export function matches(query: string, ...text: string[]) {
  return text
    .join(' ')
    .toLocaleLowerCase()
    .includes(query.trim().toLocaleLowerCase());
}
export function scrollToEntry(id: string) {
  requestAnimationFrame(() =>
    document
      .getElementById(`rmh-entry-${id}`)
      ?.scrollIntoView({ block: 'start' }),
  );
}
export function office(role: Data['role']) {
  return role === 'burgmeister'
    ? 'Бургомистр'
    : role === 'councilor'
      ? 'Советник'
      : 'Читатель';
}
const pages: {
  id: Page;
  title: string;
  icon: string;
}[] = [
  { id: 'decrees', title: 'Указы', icon: 'scroll' },
  { id: 'law_code', title: 'Свод', icon: 'landmark' },
  { id: 'lawbook', title: 'Книга', icon: 'book' },
  { id: 'drafts', title: 'Черновики', icon: 'feather-pointed' },
];
export function CodexFrame(props: Props) {
  const t = useRmhText();
  const { data } = props;
  return (
    <Box className="RmhCodex">
      <Box className="RmhCodex__side RmhCodex__frame">
        <Box className="RmhCodex__brand">
          <h1>{t('Книга законов')}</h1>
          <Box>{t('Град Ривермист · стенд писаря')}</Box>
        </Box>
        <nav className="RmhCodex__tabs" aria-label={t('Разделы документов')}>
          {pages
            .filter((page) => page.id !== 'drafts' || data.can_edit)
            .map((page) => (
              <Button
                key={page.id}
                className="RmhCodex__tab"
                selected={page.id === props.page}
                icon={page.icon}
                onClick={() => props.onPage(page.id)}
              >
                {t(page.title)}
              </Button>
            ))}
        </nav>
        {props.onSearch && (
          <Box className="RmhCodex__search">
            <Input
              fluid
              value={props.search || ''}
              placeholder={t('Поиск по разделу')}
              onChange={props.onSearch}
            />
          </Box>
        )}
        <Box className="RmhCodex__contents">{props.sidebar}</Box>
        <Box className="RmhCodex__sideFoot">
          <Box className="RmhCodex__status">
            <Icon name={data.locked ? 'lock' : 'unlock'} />{' '}
            {data.locked ? t('Замок закрыт') : t('Замок открыт')} ·{' '}
            {t(office(data.role))}
          </Box>
          <Box>{data.character || t('Официальные документы')}</Box>
          {!!data.can_edit && (
            <Box className="RmhCodex__muted">
              {t(
                'Черновик сохраняется только по кнопке. Несохранённый текст остаётся в этом окне.',
              )}
            </Box>
          )}
        </Box>
      </Box>
      <Box className="RmhCodex__main RmhCodex__frame">
        <Box className="RmhCodex__head">
          <Box className="RmhCodex__heading">
            <Box className="RmhCodex__tag">{props.tag}</Box>
            <h2>{props.title}</h2>
            <Box className="RmhCodex__subtitle">{props.subtitle}</Box>
          </Box>
          <Box className="RmhCodex__meters">
            {props.meters?.map((meter) => (
              <Box key={meter.label} className="RmhCodex__meter">
                <b>{meter.value}</b>
                <span>{meter.label}</span>
              </Box>
            ))}
          </Box>
        </Box>
        <Box className="RmhCodex__view">{props.children}</Box>
      </Box>
    </Box>
  );
}
export function TocEntry(props: {
  id: string;
  title: string;
  number?: string | number;
  subtitle?: string;
  selected?: boolean;
  sub?: boolean;
  onClick: () => void;
}) {
  return (
    <Button
      className={`RmhCodex__tocEntry${props.sub ? ' RmhCodex__tocEntry--sub' : ''}`}
      selected={props.selected}
      onClick={props.onClick}
    >
      {props.number !== undefined && (
        <span className="RmhCodex__number">{props.number}.</span>
      )}
      <span className="RmhCodex__tocText">
        {props.title}
        {props.subtitle && <small>{props.subtitle}</small>}
      </span>
    </Button>
  );
}
// Paragraph offsets identify stateless prose spans; document records use their own stable IDs.
export function Prose({ text, marks }: { text: string; marks?: number[] }) {
  let offset = 0;
  if (marks?.some(Boolean)) {
    return (
      <Box className="RmhCodex__prose">
        {emphasisRuns(text, marks).map((run) => {
          let content: ReactNode = run.text;
          if (run.style & 1) content = <strong>{content}</strong>;
          if (run.style & 2) content = <em>{content}</em>;
          return <Fragment key={run.offset}>{content}</Fragment>;
        })}
      </Box>
    );
  }
  return (
    <Box className="RmhCodex__prose">
      {text.split(/\n[ \t]*\n/).map((paragraph) => {
        const key = offset;
        offset += paragraph.length + 2;
        return <p key={key}>{paragraph}</p>;
      })}
    </Box>
  );
}
export type DocumentControls = {
  data: Data;
  act: Act;
  id: DocumentId;
  working: Draft;
  preview: boolean;
  onDraft: (draft: Draft) => void;
  onPreview: () => void;
};
export function DocumentToolbar(props: DocumentControls) {
  const t = useRmhText();
  const { data, id, working, preview } = props;
  const current = publication(data, id);
  const stale =
    working.epoch !== data.epoch || working.revision !== current.revision;
  const [sendError, setSendError] = useState(false);
  const [announce, setAnnounce] = useState(id === 'law_code');
  const send = (action: string) => {
    const payload = {
      document: id,
      epoch: data.epoch,
      editor_key: data.editor_key,
      revision: working.revision,
      content: JSON.stringify(working.content),
      announce,
    };
    if (payloadChunkCount(action, payload) > (data.max_action_chunks ?? 64)) {
      setSendError(true);
      return;
    }
    setSendError(false);
    props.act(action, payload);
  };
  return (
    <Section
      className="RmhCodex__toolbar"
      title={
        data.can_edit ? t('Редакция документа') : t('Официальная редакция')
      }
      buttons={
        <Button icon="rotate" onClick={() => props.act('refresh')}>
          {t('Обновить')}
        </Button>
      }
    >
      {!data.can_edit ? (
        <Box className="RmhCodex__muted">
          {t(
            'Доступно чтение. Для правки нужны открытый замок, должность Бургомистра или советника, грамотность и возможность работать со стендом.',
          )}
        </Box>
      ) : (
        <>
          <Box className="RmhCodex__actions">
            <Button
              selected={!preview}
              icon="feather-pointed"
              onClick={() => {
                if (preview) props.onPreview();
              }}
            >
              {t('Рабочая копия')}
            </Button>
            <Button
              selected={preview}
              icon="book-open"
              onClick={() => {
                if (!preview) props.onPreview();
              }}
            >
              {t('Опубликованное')}
            </Button>
            <Button.Confirm
              confirmContent={t('Подтвердить')}
              icon="arrow-rotate-left"
              onClick={() => props.onDraft(publication(data, id))}
            >
              {t('Взять опубликованное')}
            </Button.Confirm>
          </Box>
          {stale && (
            <NoticeBox danger className="RmhCodex__conflict">
              {t(
                'Копия основана на другой редакции или прошлом раунде. Сверьте её с опубликованным документом.',
              )}
              <Button.Confirm
                confirmContent={t('Подтвердить')}
                color="average"
                onClick={() => props.onDraft(rebase(working, current, id))}
              >
                {t('Применить мой текст поверх текущей редакции')}
              </Button.Confirm>
            </NoticeBox>
          )}
          {sendError && (
            <NoticeBox danger>
              {t(
                'Документ слишком велик для отправки. Текст сохранён в окне; сократите его перед повтором.',
              )}
            </NoticeBox>
          )}
          <Button.Checkbox
            checked={announce}
            onClick={() => setAnnounce(!announce)}
          >
            {t('Глобальное оглашение (с перезарядкой)')}
          </Button.Checkbox>
          <Box className="RmhCodex__actions" mt={1}>
            <Button
              icon="floppy-disk"
              disabled={working.epoch !== data.epoch}
              onClick={() => send('save_draft')}
            >
              {t('Сохранить черновик')}
            </Button>
            <Button.Confirm
              confirmContent={t('Подтвердить')}
              color="good"
              icon="stamp"
              disabled={stale || preview}
              onClick={() => send('publish')}
            >
              {id === 'law_code'
                ? t('Опубликовать свод')
                : t('Опубликовать книгу')}
            </Button.Confirm>
            <Box className="RmhCodex__muted">
              {t('Основа: ред. ')}
              {working.revision}
              {t('. Публикация касается только')}{' '}
              {id === 'law_code' ? t('свода') : t('книги')}.
            </Box>
          </Box>
        </>
      )}
    </Section>
  );
}
