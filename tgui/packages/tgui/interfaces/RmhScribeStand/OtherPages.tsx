import { useState } from 'react';
import { Box, Button, Input, Section, TextArea } from 'tgui-core/components';
import { payloadChunkCount } from '../../events/act';
import {
  CodexFrame,
  matches,
  type Navigation,
  office,
  Prose,
  scrollToEntry,
  TocEntry,
} from './Layout';
import { useRmhText } from './locale';
import {
  type Act,
  currentNotes,
  type Data,
  type Decree,
  type DocumentId,
  type Draft,
  move,
  type Notes,
  newId,
} from './types';
export function DecreePage(
  props: Navigation & {
    act: Act;
  },
) {
  const t = useRmhText();
  const [query, setQuery] = useState('');
  const [english, setEnglish] = useState(false);
  const { data } = props;
  const displayed = (decree: Decree) =>
    english && decree.text_en?.trim() ? decree.text_en : decree.text;
  const found = data.decrees.filter((decree) =>
    matches(query, displayed(decree)),
  );
  return (
    <CodexFrame
      {...props}
      title={t('Указы Бургомистра')}
      tag={t('Глашатай Ривермиста')}
      subtitle={t(
        'Исходные указы объявляются через THROAT. Здесь можно опубликовать их ручной перевод.',
      )}
      meters={[
        {
          value: data.decrees.length,
          label: t('указов'),
        },
      ]}
      search={query}
      onSearch={setQuery}
      sidebar={
        <>
          {found.map((decree) => (
            <TocEntry
              key={decree.id}
              id={decree.id}
              number={data.decrees.indexOf(decree) + 1}
              title={displayed(decree).slice(0, 100)}
              onClick={() => scrollToEntry(`decree-${decree.id}`)}
            />
          ))}
          {!found.length && (
            <Box className="RmhCodex__empty">{t('Указов не найдено.')}</Box>
          )}
        </>
      }
    >
      <Section
        className="RmhCodex__toolbar"
        title={t('Опубликованные указы')}
        buttons={
          <Button icon="rotate" onClick={() => props.act('refresh')}>
            {t('Обновить')}
          </Button>
        }
      >
        <Button selected={!english} onClick={() => setEnglish(false)}>
          {t('RU / исходник')}
        </Button>
        <Button selected={english} onClick={() => setEnglish(true)}>
          {t('EN / перевод')}
        </Button>
        <Box className="RmhCodex__muted">
          {t(
            'Перевод публикуется отдельно для выбранного указа. Пустой EN означает показ исходника.',
          )}
        </Box>
      </Section>
      {data.decrees.map((decree, index) => (
        <Section
          key={decree.id}
          id={`rmh-entry-decree-${decree.id}`}
          title={t('Указ № {0}', index + 1)}
          className="RmhCodex__card"
        >
          <Box className="RmhCodex__prose">{displayed(decree)}</Box>
          {english && !decree.text_en?.trim() && (
            <Box className="RmhCodex__muted">
              {t('EN не заполнен; показан исходник.')}
            </Box>
          )}
          {!!data.can_edit && (
            <DecreeTranslation decree={decree} data={data} act={props.act} />
          )}
        </Section>
      ))}
    </CodexFrame>
  );
}
function DecreeTranslation({
  decree,
  data,
  act,
}: {
  decree: Decree;
  data: Data;
  act: Act;
}) {
  const t = useRmhText();
  const [editing, setEditing] = useState(false);
  const [draft, setDraft] = useState(() => ({
    text: decree.text_en || '',
    revision: decree.revision,
  }));
  const unchanged = draft.text === (decree.text_en || '');
  const revision = unchanged ? decree.revision : draft.revision;
  const stale = revision !== decree.revision;
  return (
    <Box mt={1}>
      <Button
        icon="language"
        selected={editing}
        onClick={() => setEditing(!editing)}
      >
        {t('Редактировать EN')}
      </Button>
      {editing && (
        <>
          <TextArea
            fluid
            height={5}
            maxLength={2048}
            value={draft.text}
            onChange={(text) => setDraft({ text, revision })}
          />
          {stale && (
            <Box color="bad">
              {t(
                'Редакция изменилась. Скопируйте свой текст перед загрузкой текущего EN.',
              )}
            </Box>
          )}
          <Button
            onClick={() =>
              setDraft({
                text: decree.text_en || '',
                revision: decree.revision,
              })
            }
          >
            {t('Взять текущий EN')}
          </Button>
          <Button.Confirm
            confirmContent={t('Подтвердить')}
            color="good"
            disabled={stale || unchanged}
            onClick={() =>
              act('publish_decree_translation', {
                epoch: data.epoch,
                editor_key: data.editor_key,
                id: decree.id,
                revision,
                text_en: draft.text,
              })
            }
          >
            {t('Опубликовать EN этого указа')}
          </Button.Confirm>
        </>
      )}
    </Box>
  );
}
export function DraftLibrary(
  props: Navigation & {
    act: Act;
    notes: Notes | null;
    onNotes: (notes: Notes | null) => void;
    onLoad: (id: DocumentId, draft: Draft) => void;
  },
) {
  const t = useRmhText();
  const [documents, setDocuments] = useState(false);
  if (!documents)
    return <NoteLibrary {...props} onDocuments={() => setDocuments(true)} />;
  const { data, act } = props;
  const savedCount = Object.keys(data.saved || {}).length;
  return (
    <CodexFrame
      {...props}
      title={t('Черновики писаря')}
      tag={t('Личный архив')}
      subtitle={t(
        'Заготовки этого персонажа и должности. Загрузка черновика не публикует документ.',
      )}
      meters={[
        {
          value: savedCount,
          label: t('черновиков'),
        },
      ]}
      sidebar={
        <Box className="RmhCodex__archive">
          <Button onClick={() => setDocuments(false)}>
            {t('Личные записи')}
          </Button>
          <Box className="RmhCodex__tag">{t(office(data.role))}</Box>
          <h3>{data.character}</h3>
          <Box className="RmhCodex__muted">
            {t(
              'По одному своду и одной книге для каждого персонажа и должности. Сохранённые тексты доступны после нового входа в раунд.',
            )}
          </Box>
        </Box>
      }
    >
      {(['law_code', 'lawbook'] as const).map((id) => {
        const draft = data.saved?.[id];
        return (
          <Section
            key={id}
            title={id === 'law_code' ? t('Свод законов') : t('Книга законов')}
            className="RmhCodex__card"
          >
            {draft ? (
              <>
                <Box className="RmhCodex__prose">
                  {t('Основа: редакция ')}
                  {draft.revision}
                  {draft.epoch !== data.epoch ? t(' из прошлого раунда') : ''}.
                </Box>
                <Box className="RmhCodex__actions" mt={2}>
                  <Button.Confirm
                    confirmContent={t('Подтвердить')}
                    icon="folder-open"
                    onClick={() => props.onLoad(id, draft)}
                  >
                    {t('Загрузить в рабочую копию')}
                  </Button.Confirm>
                  <Button.Confirm
                    confirmContent={t('Подтвердить')}
                    icon="trash"
                    color="bad"
                    onClick={() =>
                      act('delete_draft', {
                        document: id,
                        epoch: data.epoch,
                        editor_key: data.editor_key,
                      })
                    }
                  >
                    {t('Удалить черновик')}
                  </Button.Confirm>
                </Box>
                <Box className="RmhCodex__muted" mt={1}>
                  {t(
                    'Текущий текст рабочей копии будет заменён. Перед публикацией проверьте актуальность редакции.',
                  )}
                </Box>
              </>
            ) : (
              <Box className="RmhCodex__muted">
                {t(
                  'Сохранённого черновика нет. Откройте документ и нажмите «Сохранить черновик».',
                )}
              </Box>
            )}
          </Section>
        );
      })}
    </CodexFrame>
  );
}
function NoteLibrary(
  props: Navigation & {
    act: Act;
    notes: Notes | null;
    onNotes: (notes: Notes | null) => void;
    onDocuments: () => void;
  },
) {
  const t = useRmhText();
  const [sendError, setSendError] = useState(false);
  const sendNotes = (payload: Record<string, unknown>) => {
    if (
      payloadChunkCount('save_notes', payload) >
      (props.data.max_action_chunks ?? 64)
    ) {
      setSendError(true);
      return;
    }
    setSendError(false);
    props.act('save_notes', payload);
  };

  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [query, setQuery] = useState('');
  const saved = props.data.notes || { revision: 1, entries: [] };
  const working = currentNotes(saved, props.notes);
  const { entries } = working;
  const oldIndex =
    props.notes?.entries.findIndex((row) => row.id === selectedId) ?? -1;
  const selected =
    entries.find((row) => row.id === selectedId) ||
    entries[oldIndex] ||
    entries[0];
  const index = selected ? entries.indexOf(selected) : -1;
  const editable = !!props.data.can_edit;
  const stale = working.revision !== saved.revision;
  const found = entries.filter((row) => matches(query, row.title, row.body));
  const replace = (next: typeof entries) =>
    props.onNotes({ ...working, entries: next });
  const add = (title = t('Новая запись'), body = '') => {
    const id = newId();
    replace([...entries, { id, title, body }]);
    setSelectedId(id);
  };
  const change = (field: 'title' | 'body', value: string) => {
    if (!selected) return;
    setSelectedId(selected.id);
    replace(
      entries.map((row) =>
        row.id === selected.id ? { ...row, [field]: value } : row,
      ),
    );
  };
  return (
    <CodexFrame
      {...props}
      title={selected?.title || t('Личные записи')}
      tag={t('Черновики писаря')}
      subtitle={t(
        'Личные записи этого персонажа и должности. Сохраняются только по кнопке.',
      )}
      search={query}
      onSearch={setQuery}
      meters={[
        {
          value: entries.length,
          label: t('записей'),
        },
      ]}
      sidebar={
        <>
          <Button
            fluid
            icon="plus"
            disabled={!editable || entries.length >= 32}
            onClick={() => add()}
          >
            {t('Новая запись')}
          </Button>
          {found.map((row) => (
            <TocEntry
              key={row.id}
              id={row.id}
              title={row.title || t('Без названия')}
              number={entries.indexOf(row) + 1}
              subtitle={row.body.slice(0, 70)}
              selected={selected?.id === row.id}
              onClick={() => setSelectedId(row.id)}
            />
          ))}
        </>
      }
    >
      <Section
        className="RmhCodex__toolbar"
        title={t('Личный архив')}
        buttons={
          <Button onClick={props.onDocuments}>
            {t('Черновики документов')}
          </Button>
        }
      >
        <Button
          icon="floppy-disk"
          disabled={!editable || stale || working === saved}
          onClick={() =>
            sendNotes({
              epoch: props.data.epoch,
              editor_key: props.data.editor_key,
              revision: working.revision,
              content: JSON.stringify(entries),
            })
          }
        >
          {t('Сохранить записи')}
        </Button>
        {sendError && (
          <Box color="bad">
            {t(
              'Документ слишком велик для отправки. Текст сохранён в окне; сократите его перед повтором.',
            )}
          </Box>
        )}
        <Button.Confirm
          confirmContent={t('Заменить рабочий текст')}
          onClick={() => props.onNotes(null)}
        >
          {t('Загрузить сохранённые')}
        </Button.Confirm>
        {stale && (
          <Box color="bad">
            {t(
              'Сохранённые записи изменились в другом окне. Скопируйте нужный текст перед загрузкой.',
            )}
          </Box>
        )}
      </Section>
      {selected ? (
        <>
          <Section title={t('Запись')} className="RmhCodex__card">
            <Box className="RmhCodex__fieldLabel">{t('Название')}</Box>
            <Input
              fluid
              value={selected.title}
              maxLength={128}
              disabled={!editable}
              onChange={(value) => change('title', value)}
            />
            <Box className="RmhCodex__fieldLabel">{t('Текст')}</Box>
            <TextArea
              fluid
              height={15}
              maxLength={8192}
              value={selected.body}
              disabled={!editable}
              onChange={(value) => change('body', value)}
            />
            <Box className="RmhCodex__actions" mt={1}>
              <Button
                icon="arrow-up"
                disabled={!editable || index <= 0}
                onClick={() => replace(move(entries, index, -1))}
              />
              <Button
                icon="arrow-down"
                disabled={!editable || index >= entries.length - 1}
                onClick={() => replace(move(entries, index, 1))}
              />
              <Button
                disabled={!editable || entries.length >= 32}
                onClick={() => add(selected.title, selected.body)}
              >
                {t('Дублировать')}
              </Button>
              <Button.Confirm
                color="bad"
                confirmContent={t('Удалить запись')}
                disabled={!editable}
                onClick={() =>
                  replace(entries.filter((row) => row.id !== selected.id))
                }
              >
                {t('Удалить')}
              </Button.Confirm>
            </Box>
          </Section>
          <Section title={t('Как будет выглядеть')} className="RmhCodex__card">
            <Prose text={selected.body} />
          </Section>
        </>
      ) : (
        <Box className="RmhCodex__empty">
          {t('Добавьте первую личную запись.')}
        </Box>
      )}
    </CodexFrame>
  );
}
