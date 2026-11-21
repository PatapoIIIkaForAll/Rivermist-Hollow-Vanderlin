// RMH: visual adaptation of PatapoIIIa's Twilight-Axis Throne TGUI, PR #1279.
// Design commit 34fef544c90a21223b6c0c04a93a1f283cc2ea8a; upstream AGPL-3.0.
// Uses RMH's existing THROAT actions and authority checks.
import { type CSSProperties, useState } from 'react';
import {
  Button,
  DmIcon,
  Icon,
  Input,
  Section,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import '../styles/interfaces/RmhThrone.scss';
import { Prose } from './RmhScribeStand/Layout';
import {
  RmhLocaleProvider,
  useRmhLanguage,
  useRmhText,
} from './RmhScribeStand/locale';

export type ThroneData = {
  language?: string;
  wearing_crown: BooleanLike;
  is_ruler: BooleanLike;
  is_regent: BooleanLike;
  worthy: BooleanLike;
  cooldown_ok: BooleanLike;
  can_command: BooleanLike;
  can_announce: BooleanLike;
  ruler_name: string;
  regent_name: string;
  tax_percent: number;
  lord_primary: string | null;
  lord_secondary: string | null;
  flag_icon: string;
  flag_state: string;
  throat_mode: string;
  crown_present: BooleanLike;
  key_present: BooleanLike;
  decree_records: {
    id: string;
    text: string;
    text_en?: string;
    revision: number;
  }[];
  outlaws: string[];
  voice_commands: string[];
};
type Act = (action: string, params?: Record<string, unknown>) => void;
type Text = (russian: string) => string;
type Page =
  | 'overview'
  | 'decrees'
  | 'commands'
  | 'justice'
  | 'heraldry'
  | 'voice';
const pages: { id: Page; ru: string; en: string; icon: string }[] = [
  { id: 'overview', ru: 'Двор', en: 'Court', icon: 'crown' },
  { id: 'decrees', ru: 'Указы', en: 'Decrees', icon: 'scroll' },
  { id: 'commands', ru: 'Управление', en: 'Governance', icon: 'landmark' },
  { id: 'justice', ru: 'Правосудие', en: 'Justice', icon: 'scale-balanced' },
  { id: 'heraldry', ru: 'Геральдика', en: 'Heraldry', icon: 'shield-halved' },
  {
    id: 'voice',
    ru: 'Голосовые команды',
    en: 'Voice commands',
    icon: 'bullhorn',
  },
];
function useCourtText(): Text {
  return useRmhText();
}
export function Throne() {
  const { data, act } = useBackend<ThroneData>();
  const width = Math.min(1180, (window.screen.availWidth || 1280) - 40);
  const height = Math.min(760, (window.screen.availHeight || 900) - 60);
  return (
    <RmhLocaleProvider language={data.language}>
      <Window width={width} height={height} theme="rmh-court">
        <Window.Content>
          <CourtWorkspace data={data} act={act} />
        </Window.Content>
      </Window>
    </RmhLocaleProvider>
  );
}
export function CourtWorkspace({ data, act }: { data: ThroneData; act: Act }) {
  const t = useCourtText();
  const [page, setPage] = useState<Page>('overview');
  const [selected, setSelected] = useState<string | null>(null);
  const [previewEnglish, setPreviewEnglish] = useState(
    useRmhLanguage() === 'en',
  );
  const command = !!data.can_command && !!data.cooldown_ok;
  const announcement = !!data.can_announce && !!data.cooldown_ok;
  const reason = !data.wearing_crown
    ? t('Нужна корона.')
    : !data.worthy
      ? t('Только правитель или регент.')
      : !data.cooldown_ok
        ? t('THROAT набирается сил.')
        : '';
  const records = data.decree_records || [];
  return (
    <div className="RmhThrone">
      <div
        className="RmhThrone__board"
        style={
          {
            '--ducal-primary': data.lord_primary || '#183a56',
            '--ducal-secondary': data.lord_secondary || '#e0cc9b',
          } as CSSProperties
        }
      >
        <CourtHeader data={data} act={act} t={t} />
        <div className="RmhThrone__courtShell">
          <CourtNavigation page={page} onPage={setPage} t={t} />
          <main className="RmhThrone__centerPanel">
            <div className="RmhThrone__statusGrid">
              <CourtStatus
                label={t('Корона')}
                value={data.wearing_crown ? t('Надета') : t('Не надета')}
                icon="crown"
                good={!!data.wearing_crown}
              />
              <CourtStatus
                label={t('Налог')}
                value={`${data.tax_percent}%`}
                icon="coins"
                good
              />
              <CourtStatus
                label={t('Глас трона')}
                value={data.cooldown_ok ? t('Готов') : t('Набирается сил')}
                icon="bullhorn"
                good={!!data.cooldown_ok}
              />
            </div>
            <div className="RmhThrone__contentStack">
              {page === 'overview' && (
                <Section title={t('Положение двора')}>
                  <div className="RmhThrone__overviewFacts">
                    <CourtFact
                      label={t('Действующие указы')}
                      value={String(records.length)}
                    />
                    <CourtFact
                      label={t('Вне закона')}
                      value={String(data.outlaws.length)}
                    />
                    <CourtFact
                      label={t('Корона в землях')}
                      value={data.crown_present ? t('Есть') : t('Не найдена')}
                    />
                    <CourtFact
                      label={t('Ключ правителя')}
                      value={data.key_present ? t('Есть') : t('Не найден')}
                    />
                  </div>
                  <p>
                    {t(
                      'Законы града публикуются на стенде писаря. Здесь издаются и отзываются указы.',
                    )}
                  </p>
                  {!!data.throat_mode && data.throat_mode !== 'None' && (
                    <p>
                      {t('Голосовой режим: ')}
                      <b>{data.throat_mode}</b>
                    </p>
                  )}
                </Section>
              )}
              {page === 'decrees' && (
                <Section
                  title={t('Действующие указы')}
                  buttons={
                    <Button onClick={() => setPreviewEnglish(!previewEnglish)}>
                      {previewEnglish ? 'RU' : 'EN'}
                    </Button>
                  }
                >
                  {!records.length && <p>{t('Действующих указов нет.')}</p>}
                  {records.map((entry, index) => (
                    <div className="RmhThrone__decree" key={entry.id}>
                      <Button
                        className="RmhThrone__decreeHeading"
                        selected={selected === entry.id}
                        onClick={() =>
                          setSelected(selected === entry.id ? null : entry.id)
                        }
                      >
                        {t('Указ')} {index + 1}
                      </Button>
                      {(selected === entry.id || records.length === 1) && (
                        <Prose
                          text={
                            previewEnglish && entry.text_en?.trim()
                              ? entry.text_en
                              : entry.text
                          }
                        />
                      )}
                      <Button.Confirm
                        icon="ban"
                        color="bad"
                        disabled={!command}
                        tooltip={reason}
                        confirmContent={t('Подтвердить')}
                        onClick={() =>
                          act('remove_decree', {
                            index: String(index + 1),
                            id: entry.id,
                            revision: entry.revision,
                          })
                        }
                      >
                        {t('Отозвать')}
                      </Button.Confirm>
                    </div>
                  ))}
                  <CourtTextForm
                    action="make_decree"
                    param="text"
                    title={t('Новый указ')}
                    button={t('Издать указ')}
                    enabled={command}
                    reason={reason}
                    act={act}
                  />
                </Section>
              )}
              {page === 'commands' && (
                <Governance
                  data={data}
                  act={act}
                  command={command}
                  announcement={announcement}
                  reason={reason}
                />
              )}
              {page === 'justice' && (
                <Justice
                  data={data}
                  act={act}
                  enabled={command}
                  reason={reason}
                />
              )}
              {page === 'heraldry' && (
                <Section title={t('Знамя града')}>
                  <div className="RmhThrone__heraldry">
                    <DmIcon
                      icon={data.flag_icon}
                      icon_state={data.flag_state}
                      width="96px"
                      height="96px"
                    />
                    <span
                      style={{ background: data.lord_primary || '#183a56' }}
                    >
                      {t('Основной цвет')}
                    </span>
                    <span
                      style={{ background: data.lord_secondary || '#e0cc9b' }}
                    >
                      {t('Второй цвет')}
                    </span>
                  </div>
                  <CourtAction
                    icon="palette"
                    title={t('Изменить цвета')}
                    description={t(
                      'Выбрать гербовые цвета существующим порядком.',
                    )}
                    enabled={command}
                    reason={reason}
                    onClick={() => act('change_colors')}
                  />
                </Section>
              )}
              {page === 'voice' && (
                <Section title={t('Голосовые команды THROAT')}>
                  <p>
                    {t(
                      'Команды произносятся рядом с троном. Действуют обычные проверки полномочий.',
                    )}
                  </p>
                  <ul className="RmhThrone__voiceList">
                    {(data.voice_commands || []).map((text) => (
                      <li key={text}>
                        <code className="RmhThrone__voiceCommand">{text}</code>
                      </li>
                    ))}
                  </ul>
                  <Button icon="circle-question" onClick={() => act('help')}>
                    {t('Справка THROAT')}
                  </Button>
                </Section>
              )}
            </div>
          </main>
          <CourtRegalia
            data={data}
            act={act}
            command={command}
            announcement={announcement}
            reason={reason}
            t={t}
          />
        </div>
      </div>
    </div>
  );
}
function CourtStatus({
  label,
  value,
  icon,
  good,
}: {
  label: string;
  value: string;
  icon: string;
  good: boolean;
}) {
  return (
    <div
      className={`RmhThrone__statusCard RmhThrone__statusCard--${good ? 'good' : 'warning'}`}
    >
      <span className="RmhThrone__statusIcon">
        <Icon name={icon} />
      </span>
      <div className="RmhThrone__statusBody">
        <div className="RmhThrone__statusLabel">{label}</div>
        <div className="RmhThrone__statusValue">{value}</div>
      </div>
    </div>
  );
}
function CourtFact({ label, value }: { label: string; value: string }) {
  return (
    <div className="RmhThrone__overviewFact">
      <b>{label}</b>
      <span>{value}</span>
    </div>
  );
}
function CourtAction({
  icon,
  title,
  description,
  enabled,
  reason,
  onClick,
}: {
  icon: string;
  title: string;
  description: string;
  enabled: BooleanLike;
  reason?: string;
  onClick: () => void;
}) {
  return (
    <Button
      className="RmhThrone__action"
      disabled={!enabled}
      tooltip={!enabled ? reason : description}
      onClick={onClick}
    >
      <span className="RmhThrone__actionIcon">
        <Icon name={icon} />
      </span>
      <span className="RmhThrone__actionBody">
        <span className="RmhThrone__actionTitle">{title}</span>
        <span className="RmhThrone__actionDesc">{description}</span>
      </span>
    </Button>
  );
}
function CourtTextForm({
  action,
  param,
  title,
  button,
  enabled,
  reason,
  act,
}: {
  action: string;
  param: string;
  title: string;
  button: string;
  enabled: boolean;
  reason: string;
  act: Act;
}) {
  const [text, setText] = useState('');
  return (
    <div className="RmhThrone__desk">
      <h3>{title}</h3>
      <TextArea
        fluid
        height={6}
        maxLength={500}
        value={text}
        onChange={setText}
      />
      <div className="RmhThrone__deskFooter">
        <span>{Array.from(text).length} / 500</span>
        <Button
          icon="stamp"
          disabled={!enabled || !text.trim()}
          tooltip={!enabled ? reason : undefined}
          onClick={() => {
            act(action, { [param]: text });
            setText('');
          }}
        >
          {button}
        </Button>
      </div>
    </div>
  );
}
function Governance({
  data,
  act,
  command,
  announcement,
  reason,
}: {
  data: ThroneData;
  act: Act;
  command: boolean;
  announcement: boolean;
  reason: string;
}) {
  const t = useCourtText();
  return (
    <>
      <Section title={t('Объявления')}>
        <CourtTextForm
          action="make_announcement"
          param="text"
          title={t('Объявить всем землям')}
          button={t('Объявить')}
          enabled={announcement}
          reason={
            !data.wearing_crown
              ? t('Нужна корона.')
              : t('THROAT набирается сил.')
          }
          act={act}
        />
      </Section>
      <Section title={t('Управление градом')}>
        <CourtFact label={t('Текущий налог')} value={`${data.tax_percent}%`} />
        <CourtAction
          icon="coins"
          title={t('Изменить налог')}
          description={t('Открыть существующий выбор налога.')}
          enabled={command}
          reason={reason}
          onClick={() => act('set_taxes')}
        />
      </Section>
    </>
  );
}
function Justice({
  data,
  act,
  enabled,
  reason,
}: {
  data: ThroneData;
  act: Act;
  enabled: boolean;
  reason: string;
}) {
  const t = useCourtText();
  const [outlaw, setOutlaw] = useState(''),
    [pardon, setPardon] = useState('');
  return (
    <Section title={t('Правосудие')}>
      <h3>{t('Объявить вне закона')}</h3>
      <Input fluid value={outlaw} onChange={setOutlaw} maxLength={128} />
      <Button
        color="bad"
        disabled={!enabled || !outlaw.trim()}
        tooltip={reason}
        onClick={() => {
          act('declare_outlaw', { name: outlaw });
          setOutlaw('');
        }}
      >
        {t('Объявить вне закона')}
      </Button>
      <h3>{t('Помиловать')}</h3>
      <Input fluid value={pardon} onChange={setPardon} maxLength={128} />
      <Button
        color="good"
        disabled={!enabled || !pardon.trim()}
        tooltip={reason}
        onClick={() => {
          act('pardon_outlaw', { name: pardon });
          setPardon('');
        }}
      >
        {t('Помиловать')}
      </Button>
      <ul>
        {data.outlaws.map((name) => (
          <li key={name}>{decodeHtmlEntities(name)}</li>
        ))}
      </ul>
    </Section>
  );
}

function CourtHeader({
  data,
  act,
  t,
}: {
  data: ThroneData;
  act: Act;
  t: Text;
}) {
  return (
    <header className="RmhThrone__titleRow">
      <span className="RmhThrone__standard RmhThrone__standard--left">
        <Icon name="crown" />
      </span>
      <div className="RmhThrone__rulerBlock">
        <div>
          <b>{t('Правитель')}</b>
          <span>{data.ruler_name === 'None' ? t('Нет') : data.ruler_name}</span>
        </div>
        <div>
          <b>{t('Регент')}</b>
          <span>
            {data.regent_name === 'None' ? t('Нет') : data.regent_name}
          </span>
        </div>
      </div>
      <div>
        <div className="RmhThrone__eyebrow">Rivermist Hollow</div>
        <h1 className="RmhThrone__title">{t('Двор Ривермиста')}</h1>
        <div className="RmhThrone__subtitle">
          {t('Воля града звучит через THROAT')}
        </div>
      </div>
      <div className="RmhThrone__rulerBlock">
        <div>
          <b>{t('Ваш статус')}</b>
          <span>
            {data.is_ruler
              ? t('Правитель')
              : data.is_regent
                ? t('Регент')
                : t('Подданный')}
          </span>
        </div>
        <Button icon="rotate" onClick={() => act('refresh')}>
          {t('Обновить')}
        </Button>
      </div>
      <span className="RmhThrone__standard RmhThrone__standard--right">
        <Icon name="shield-halved" />
      </span>
    </header>
  );
}

function CourtNavigation({
  page,
  onPage,
  t,
}: {
  page: Page;
  onPage: (page: Page) => void;
  t: Text;
}) {
  return (
    <aside className="RmhThrone__leftRail">
      <div className="RmhThrone__throneEmblem">
        <Icon name="chess-king" />
      </div>
      <nav className="RmhThrone__nav" aria-label={t('Разделы двора')}>
        {pages.map((item) => (
          <Button
            key={item.id}
            className={`RmhThrone__navButton${page === item.id ? ' RmhThrone__navButton--active' : ''}`}
            icon={item.icon}
            onClick={() => onPage(item.id)}
          >
            {t(item.ru)}
          </Button>
        ))}
      </nav>
    </aside>
  );
}

function CourtRegalia({
  data,
  act,
  command,
  announcement,
  reason,
  t,
}: {
  data: ThroneData;
  act: Act;
  command: boolean;
  announcement: boolean;
  reason: string;
  t: Text;
}) {
  return (
    <aside className="RmhThrone__rightRail">
      <Section title={t('Регалии')}>
        <CourtAction
          icon="crown"
          title={t('Призвать корону')}
          description={t('Позвать существующую корону.')}
          enabled
          onClick={() => act('summon_crown')}
        />
        <CourtAction
          icon="key"
          title={t('Призвать ключ')}
          description={t('Нужна надетая корона.')}
          enabled={announcement}
          reason={
            !data.wearing_crown
              ? t('Нужна корона.')
              : t('THROAT набирается сил.')
          }
          onClick={() => act('summon_key')}
        />
      </Section>
      <Section title={t('Приказы двору')}>
        <CourtAction
          icon="user-tie"
          title={t('Назначить регента')}
          description={t('Назначить представителя правителя.')}
          enabled={command}
          reason={reason}
          onClick={() => act('appoint_regent')}
        />
        <CourtAction
          icon="users"
          title={t('Изменить должность')}
          description={t('Изменить службу подданного.')}
          enabled={command}
          reason={reason}
          onClick={() => act('change_position')}
        />
        <CourtAction
          icon="volume-xmark"
          title="SILENCE!!"
          description={t('Потребовать тишины в зале.')}
          enabled={command}
          reason={reason}
          onClick={() => act('silence')}
        />
      </Section>
    </aside>
  );
}
