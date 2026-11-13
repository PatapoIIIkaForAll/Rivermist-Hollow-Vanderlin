import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  TextArea,
  Tooltip,
} from 'tgui-core/components';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type Booleanish = boolean | number;

type ActionEntry = {
  key: string;
  name: string;
  active: Booleanish;
  can_perform: Booleanish;
  user_zones: number;
  target_zones: number;
  fit_hint?: string;
  category?: string;
  tip?: string | null;
  refusal?: string | null;
};

type ZoneOption = { name: string; value: number };

type ControlsData = {
  speed: number;
  force: number;
  resist: number;
  manual_arousal: number;
  has_penis: Booleanish;
  do_until_finished: Booleanish;
  edging_other: Booleanish;
  finish_outside: Booleanish;
  can_leg_lock: Booleanish;
  leg_lock: Booleanish;
  lying_direction: string | null;
  cmode: Booleanish;
  auto_clench: Booleanish;
  can_hold_it_in: Booleanish;
  hold_it_in: Booleanish;
  reach_under_armor: Booleanish;
  status_follows_examine: Booleanish;
};

type ArousalData = {
  arousal_pct: number;
  orgasm_pct: number;
  pain_pct: number;
};

type BellyActionEntry = {
  key: string;
  name: string;
  selected: Booleanish;
  can_perform: Booleanish;
};

type BellyData = null | { enabled: Booleanish; actions: BellyActionEntry[] };

type CustomOption = { name: string; value: number | string | null };

type CustomSelectorEntry = {
  id: string;
  name: string;
  summary: string;
  selected: Booleanish;
};

type CustomEditorData = null | {
  is_saved: Booleanish;
  name: string;
  scope: number;
  user_part: number;
  target_part: number;
  filter_summary: string;
  require_same_tile: Booleanish;
  require_grab: Booleanish;
  requires_free_hands: Booleanish;
  gags_user: Booleanish;
  gags_target: Booleanish;
  do_time_seconds: number;
  stamina_cost: number;
  user_arousal: number;
  user_pain: number;
  user_orgasm: number;
  target_arousal: number;
  target_pain: number;
  target_orgasm: number;
  message_start: string | null;
  message_tick: string | null;
  message_finish: string | null;
  message_climax_active: string | null;
  message_climax_passive: string | null;
  active_climax_location: string | null;
  passive_climax_location: string | null;
  created_text: string | null;
  modified_text: string | null;
};

type CustomData = {
  templates: CustomSelectorEntry[];
  saved: CustomSelectorEntry[];
  scope_options: CustomOption[];
  part_options: CustomOption[];
  climax_options: CustomOption[];
  editor: CustomEditorData;
};

type ErpFlag = {
  name: string;
  bit: number;
  description: string;
  on: Booleanish;
};

type ErpPrefEntry = {
  type: string;
  name: string;
  description: string;
  kind: 'bool' | 'flags' | 'number' | 'choice';
  value?: unknown;
  flags?: ErpFlag[];
  min?: number;
  max?: number;
  choices?: string[];
};

type ErpCategory = { name: string; prefs: ErpPrefEntry[] };

type KinkEntry = {
  name: string;
  description: string;
  enabled: Booleanish;
  intensity: number;
  notes: string;
};

type KinkCategory = { name: string; kinks: KinkEntry[] };

type IntimacyData = {
  lock_reason: string | null;
  yours: ErpCategory[];
  theirs: ErpCategory[];
  their_kinks: KinkCategory[];
  your_kinks?: KinkCategory[];
};

type KinkEdit = { enabled: boolean; intensity: number; notes: string };

type NoteEntry = { title: string; content: string; meta: string };
type NotesData = { yours: NoteEntry[]; theirs: NoteEntry[] };

type ScenePatternEntry = {
  key: string;
  id: string;
  name: string;
  focus_name: string | null;
  is_focus: Booleanish;
};

type SceneParticipantEntry = {
  ref: string;
  name: string;
  is_self: Booleanish;
  selected: Booleanish;
  action_count: number;
  status_lines: string[];
};

type SceneConnectionEntry = {
  ref: string;
  name: string;
  actor_name: string;
  target_name: string;
  speed: number;
  force: number;
  can_stop: Booleanish;
};

type SceneClaimEntry = {
  action_name: string;
  host_name: string;
  resource_name: string;
  hard: Booleanish;
};

type Data = {
  target_name: string;
  is_self: Booleanish;
  scene_name: string;
  scene_participants: SceneParticipantEntry[];
  scene_connections: SceneConnectionEntry[];
  scene_claims: SceneClaimEntry[];
  status_lines: string[];
  arousal: ArousalData;
  controls: ControlsData;
  zone_options: ZoneOption[];
  actions: ActionEntry[];
  scene_patterns: ScenePatternEntry[];
  bellyriding: BellyData;
  custom: CustomData;
  intimacy: IntimacyData;
  notes: NotesData;
};

const asBool = (value: Booleanish | undefined) => value === true || value === 1;

const SPEED_LABELS = ['Slow', 'Steady', 'Quick', 'Unrelenting', 'Furious'];
const FORCE_LABELS = ['Gentle', 'Firm', 'Rough', 'Brutal', 'Unrelenting'];
const RESIST_LABELS = ['None', 'Low', 'Medium', 'High'];
const AROUSAL_LABELS = ['Natural', 'Unaroused', 'Partial', 'Full'];
const INTENSITY_LABELS = [
  'Very Light',
  'Light',
  'Moderate',
  'Intense',
  'Very Intense',
];

const levelName = (labels: string[], level: number) => labels[level - 1] ?? '?';

const CATEGORY_LABELS: Record<string, string> = {
  mouth: 'Mouth',
  hands: 'Hands',
  sex: 'Penetration',
  grind: 'Grinding',
  breasts: 'Breasts',
  feet: 'Feet and legs',
  toys: 'Toys and items',
  fluids: 'Fluids',
  impact: 'Impact and sensation',
  devices: 'Chastity and clamps',
  tail: 'Tails and tentacles',
  portal: 'Portal',
  body: 'Body',
  custom: 'Custom action',
};

/** Small pixel icon for an action's group. */
const CategoryIcon = (props: { category?: string }) => {
  const category =
    props.category && CATEGORY_LABELS[props.category] ? props.category : 'body';
  return (
    <img
      src={resolveAsset(`sexcat_${category}.png`)}
      width={16}
      height={16}
      style={{
        imageRendering: 'pixelated',
        verticalAlign: 'middle',
        marginRight: '4px',
        marginTop: '-2px',
      }}
    />
  );
};

const actionTooltip = (action: ActionEntry) => (
  <Box>
    <Box bold>{action.name}</Box>
    <Box color="label" fontSize="10px">
      {CATEGORY_LABELS[action.category || 'body'] || 'Body'}
    </Box>
    {action.tip ? <Box mt={0.25}>{action.tip}</Box> : null}
    {action.fit_hint ? (
      <Box mt={0.25} color="average">
        Fit: {action.fit_hint}
      </Box>
    ) : null}
    {action.refusal ? (
      <Box mt={0.25} color="bad">
        {action.refusal}
      </Box>
    ) : null}
  </Box>
);

const paceName = (speed: number, force: number) =>
  `${levelName(SPEED_LABELS, speed)} / ${levelName(FORCE_LABELS, force)}`;

/** Arrows joined to an inset value box; a fixed width keeps stacked steppers lined up. */
const LevelControl = (props: {
  value: number;
  labels: string[];
  disabled?: boolean;
  width?: string;
  onSet: (level: number) => void;
}) => {
  const { value, labels, disabled, width, onSet } = props;
  const level = Math.min(Math.max(value || 1, 1), labels.length);
  const valueWidth =
    width || `${Math.max(...labels.map((name) => name.length)) + 1}ch`;
  return (
    <Box
      inline
      style={{
        display: 'inline-flex',
        alignItems: 'stretch',
        verticalAlign: 'middle',
      }}
    >
      <Button
        compact
        icon="chevron-left"
        disabled={disabled || level <= 1}
        style={{ margin: 0, borderRadius: '2px 0 0 2px' }}
        onClick={() => onSet(level - 1)}
      />
      <Box
        textAlign="center"
        style={{
          width: valueWidth,
          padding: '0 4px',
          lineHeight: '16px',
          background: 'rgba(0, 0, 0, 0.35)',
          borderTop: '1px solid rgba(255, 255, 255, 0.08)',
          borderBottom: '1px solid rgba(255, 255, 255, 0.08)',
          whiteSpace: 'nowrap',
        }}
      >
        {levelName(labels, level)}
      </Box>
      <Button
        compact
        icon="chevron-right"
        disabled={disabled || level >= labels.length}
        style={{ margin: 0, borderRadius: '0 2px 2px 0' }}
        onClick={() => onSet(level + 1)}
      />
    </Box>
  );
};

/** An on/off switch: green with a tick when on, red with a cross when off. */
const SwitchButton = (props: {
  label: string;
  on: Booleanish;
  tooltip: string;
  onClick: () => void;
}) => (
  <Button
    compact
    fluid
    icon={asBool(props.on) ? 'check' : 'xmark'}
    color={asBool(props.on) ? 'good' : 'bad'}
    tooltip={props.tooltip}
    onClick={props.onClick}
  >
    {props.label}
  </Button>
);

/** A caption on a gold strip, for control groups and preference categories. */
const GroupTitle = (props: { children: ReactNode; fontSize?: string }) => (
  <Box
    bold
    style={{
      fontSize: props.fontSize || '9px',
      textTransform: 'uppercase',
      letterSpacing: '1px',
      color: '#ecdcaa',
      padding: '1px 6px',
      background:
        'linear-gradient(90deg, rgba(207, 192, 138, 0.30), rgba(207, 192, 138, 0.06))',
      borderBottom: '1px solid rgba(207, 192, 138, 0.35)',
    }}
  >
    {props.children}
  </Box>
);

/** A small framed box with a title strip, for one group of controls. */
const ControlGroup = (props: { title: string; children: ReactNode }) => (
  <Box
    style={{
      height: '100%',
      border: '1px solid rgba(207, 192, 138, 0.25)',
      borderRadius: '3px',
      overflow: 'hidden',
      background: 'rgba(0, 0, 0, 0.15)',
    }}
  >
    <GroupTitle>{props.title}</GroupTitle>
    <Box style={{ padding: '3px 6px 4px' }}>{props.children}</Box>
  </Box>
);

/** One labelled stepper row; the label column keeps the arrows lined up. */
const StepperRow = (props: {
  label: string;
  tooltip: string;
  value: number;
  labels: string[];
  onSet: (level: number) => void;
}) => (
  <Stack align="center" mb={0.25}>
    <Stack.Item basis="58px" shrink={0}>
      <Tooltip content={props.tooltip} position="top">
        <Box color="label" fontSize="11px">
          {props.label}
        </Box>
      </Tooltip>
    </Stack.Item>
    <Stack.Item>
      <LevelControl
        value={props.value}
        labels={props.labels}
        width="11ch"
        onSet={props.onSet}
      />
    </Stack.Item>
  </Stack>
);

const ZoneFilterRow = (props: {
  title: string;
  options: ZoneOption[];
  value: number;
  onChange: (value: number) => void;
}) => (
  <Stack align="center" mb={0.25}>
    <Stack.Item basis="92px" shrink={0} style={{ minWidth: 0 }}>
      <Box
        bold
        color="label"
        fontSize="11px"
        style={{
          overflow: 'hidden',
          textOverflow: 'ellipsis',
          whiteSpace: 'nowrap',
        }}
      >
        {props.title}
      </Box>
    </Stack.Item>
    {props.options.map((option) => (
      <Stack.Item key={option.value} grow basis={0} style={{ minWidth: 0 }}>
        <Button
          fluid
          compact
          textAlign="center"
          selected={props.value === option.value}
          onClick={() => props.onChange(option.value)}
        >
          {option.name}
        </Button>
      </Stack.Item>
    ))}
  </Stack>
);

const zoneMatches = (mask: number, filter: number) =>
  filter === 0 || (mask & filter) !== 0;

export const SexScene = () => {
  const { act, data } = useBackend<Data>();

  const [tab, setTab] = useState('interactions');
  const [userZone, setUserZone] = useState(0);
  const [targetZone, setTargetZone] = useState(0);
  const [search, setSearch] = useState('');
  const [notesTab, setNotesTab] = useState<'yours' | 'theirs'>('yours');
  const [noteFormOpen, setNoteFormOpen] = useState(false);
  const [noteTitle, setNoteTitle] = useState('');
  const [noteContent, setNoteContent] = useState('');
  const [editingNote, setEditingNote] = useState<string | null>(null);
  const [editContent, setEditContent] = useState('');
  const [sceneOpen, setSceneOpen] = useState(false);
  const [kinkDraft, setKinkDraft] = useState<Record<string, KinkEdit>>({});
  const [kinkNotesOpen, setKinkNotesOpen] = useState<string | null>(null);

  const controls = data.controls || ({} as ControlsData);
  const arousal = data.arousal || ({} as ArousalData);
  const scenePatterns = data.scene_patterns ?? [];
  const hasBelly = !!data.bellyriding;
  const activeTab = tab === 'bellyriding' && !hasBelly ? 'interactions' : tab;

  const renderParticipantTooltip = (participant: SceneParticipantEntry) => (
    <Box>
      <Box bold>{participant.name}</Box>
      <Box color="label" mb={0.5}>
        {asBool(participant.is_self) ? 'You' : 'Scene participant'} ·{' '}
        {participant.action_count} active interaction
        {participant.action_count === 1 ? '' : 's'}
      </Box>
      {(participant.status_lines ?? []).map((line, index) => (
        <Box key={`${participant.ref}-${index}`}>...{line}</Box>
      ))}
    </Box>
  );

  const renderParticipantButton = (participant: SceneParticipantEntry) => (
    <Stack.Item key={participant.ref}>
      <Tooltip
        content={renderParticipantTooltip(participant)}
        position="bottom-start"
      >
        <Box>
          <Button
            fluid
            compact
            selected={asBool(participant.selected)}
            onClick={() => act('select_participant', { ref: participant.ref })}
          >
            <Stack align="center">
              <Stack.Item grow style={{ minWidth: 0 }}>
                <Box
                  bold
                  style={{
                    overflow: 'hidden',
                    textOverflow: 'ellipsis',
                    whiteSpace: 'nowrap',
                  }}
                >
                  {participant.name}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Box as="span" color="label" fontSize="9px">
                  {participant.action_count}
                </Box>
              </Stack.Item>
            </Stack>
          </Button>
        </Box>
      </Tooltip>
    </Stack.Item>
  );

  const renderBar = (label: string, pct: number, color: string) => (
    <ProgressBar value={(pct || 0) / 100} color={color} height="15px" mb={0.25}>
      <Box fontSize="10px" style={{ lineHeight: '13px' }}>
        {label} {Math.round(pct || 0)}%
      </Box>
    </ProgressBar>
  );

  const renderHeader = () => {
    const participants = data.scene_participants ?? [];
    const sceneName = data.scene_name || data.target_name;
    return (
      <Section>
        <Stack align="start">
          <Stack.Item grow style={{ minWidth: 0 }}>
            <Box bold fontSize="13px">
              {asBool(data.is_self)
                ? 'With yourself'
                : `With ${data.target_name}`}
              {sceneName !== data.target_name ? (
                <Box as="span" color="label" fontSize="10px" ml={1}>
                  Scene: {sceneName}
                </Box>
              ) : null}
            </Box>
            {participants.length > 1 ? (
              <Stack wrap mt={0.25}>
                {participants.map(renderParticipantButton)}
              </Stack>
            ) : null}
            <Box color="label" fontSize="10px" mt={0.25}>
              {(data.status_lines ?? []).map((line) => (
                <Box as="span" key={line} mr={1}>
                  …{line}
                </Box>
              ))}
            </Box>
            {scenePatterns.length ? (
              <Box color="pink" fontSize="10px" mt={0.25}>
                <Box as="span" bold>
                  Active scene:{' '}
                </Box>
                {scenePatterns.map((pattern, index) => (
                  <Box as="span" key={pattern.key}>
                    {index ? ', ' : ''}
                    {pattern.name}
                    {asBool(pattern.is_focus)
                      ? ' (centered on you)'
                      : pattern.focus_name
                        ? ` (centered on ${pattern.focus_name})`
                        : ''}
                  </Box>
                ))}
              </Box>
            ) : null}
          </Stack.Item>
          <Stack.Item basis="32%" shrink={0}>
            {renderBar('Arousal', arousal.arousal_pct, 'red')}
            {renderBar('Orgasm', arousal.orgasm_pct, 'pink')}
            {renderBar('Pain', arousal.pain_pct, 'grey')}
          </Stack.Item>
        </Stack>
      </Section>
    );
  };

  const renderActionButton = (action: ActionEntry) => (
    <Stack.Item key={action.key} basis="32%" grow>
      <Stack>
        <Stack.Item grow>
          <Button
            fluid
            compact
            disabled={!asBool(action.can_perform) && !asBool(action.active)}
            selected={asBool(action.active)}
            tooltip={actionTooltip(action)}
            onClick={() =>
              act(asBool(action.active) ? 'stop' : 'action', {
                key: action.key,
              })
            }
          >
            <CategoryIcon category={action.category} />
            {action.name}
            {action.fit_hint ? (
              <Box as="span" color="label" fontSize="9px" ml={0.5}>
                {action.fit_hint}
              </Box>
            ) : null}
          </Button>
        </Stack.Item>
        {asBool(action.active) ? (
          <Stack.Item>
            <Button
              compact
              icon="times"
              color="bad"
              tooltip="Stop action"
              onClick={() => act('stop', { key: action.key })}
            />
          </Stack.Item>
        ) : null}
      </Stack>
    </Stack.Item>
  );

  const renderQuickBar = () => {
    const switches = [
      {
        label: 'Stop at climax',
        on: controls.do_until_finished,
        shown: true,
        tooltip:
          'On: your actions stop when you climax. Off: they go on until you stop them.',
        action: 'toggle_finished',
      },
      {
        label: 'Edge partner',
        on: controls.edging_other,
        shown: !asBool(data.is_self),
        tooltip: 'Try to hold your partner back from the edge.',
        action: 'toggle_edging',
      },
      {
        label: 'Finish outside',
        on: controls.finish_outside,
        shown: asBool(controls.has_penis),
        tooltip:
          'Pull out at the last moment and finish over your partner instead of inside them.',
        action: 'toggle_finish_outside',
      },
      {
        label: 'Leg lock',
        on: controls.leg_lock,
        shown: asBool(controls.can_leg_lock),
        tooltip:
          'Wrap your legs around whoever is inside you. If you are stronger, they will struggle to pull out.',
        action: 'toggle_leg_lock',
      },
      {
        label: 'Keep it in',
        on: controls.hold_it_in,
        shown: asBool(controls.can_hold_it_in),
        tooltip:
          'Clench to keep what is inside your holes from leaking out. Costs a little stamina while you hold something.',
        action: 'toggle_hold_it_in',
      },
      {
        label: 'Auto-clench',
        on: controls.auto_clench,
        shown: asBool(controls.cmode),
        tooltip: 'Automatically resist actions performed on you. Costs stamina.',
        action: 'toggle_auto_clench',
      },
      {
        label: 'Armor reach',
        on: controls.reach_under_armor,
        shown: true,
        tooltip:
          'On: players, you included, can reach under your armor. Off: your armor must come off first. Mobs always strip it.',
        action: 'toggle_reach_under_armor',
      },
      {
        label: 'Status follows examine',
        on: controls.status_follows_examine,
        shown: true,
        tooltip:
          'On: the status lines list what examine shows. Off: they use the older rule, which only reads body coverage and underwear.',
        action: 'toggle_status_follows_examine',
      },
    ].filter((entry) => entry.shown);
    return (
      <Section>
        <Stack align="stretch">
          <Stack.Item>
            <ControlGroup title="Pace">
              <StepperRow
                label="Speed"
                tooltip="How fast your actions go."
                value={controls.speed}
                labels={SPEED_LABELS}
                onSet={(level) => act('set_speed', { value: level })}
              />
              <StepperRow
                label="Force"
                tooltip="How hard your actions go. More force, more pain."
                value={controls.force}
                labels={FORCE_LABELS}
                onSet={(level) => act('set_force', { value: level })}
              />
            </ControlGroup>
          </Stack.Item>
          <Stack.Item>
            <ControlGroup title="You">
              <StepperRow
                label="Hold back"
                tooltip="How hard you fight your own pleasure. Higher slows your climax but costs stamina."
                value={controls.resist}
                labels={RESIST_LABELS}
                onSet={(level) => act('set_resist', { value: level })}
              />
              {asBool(controls.has_penis) ? (
                <StepperRow
                  label="Arousal"
                  tooltip="Natural follows your arousal; the others hold your cock at that state."
                  value={controls.manual_arousal}
                  labels={AROUSAL_LABELS}
                  onSet={(level) => act('set_manual_arousal', { value: level })}
                />
              ) : null}
            </ControlGroup>
          </Stack.Item>
          <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
            <ControlGroup title="Options">
              <Box
                style={{
                  display: 'grid',
                  gridTemplateColumns: 'repeat(auto-fill, minmax(118px, 1fr))',
                  gap: '3px',
                }}
              >
                {switches.map((entry) => (
                  <SwitchButton
                    key={entry.action}
                    label={entry.label}
                    on={entry.on}
                    tooltip={entry.tooltip}
                    onClick={() => act(entry.action)}
                  />
                ))}
                {controls.lying_direction ? (
                  <Button
                    compact
                    fluid
                    icon="rotate"
                    tooltip={`Roll onto your other side (now ${controls.lying_direction})`}
                    onClick={() => act('swap_side')}
                  >
                    Roll over
                  </Button>
                ) : null}
              </Box>
            </ControlGroup>
          </Stack.Item>
        </Stack>
      </Section>
    );
  };

  const renderInteractions = () => {
    const actions = data.actions ?? [];
    const activeActions = actions.filter((action) => asBool(action.active));
    const inactive = actions.filter((action) => !asBool(action.active));
    const available = inactive.filter(
      (action) =>
        zoneMatches(action.user_zones, userZone) &&
        zoneMatches(action.target_zones, targetZone) &&
        (!search || action.name.toLowerCase().includes(search.toLowerCase())),
    );
    const connections = data.scene_connections ?? [];
    const claims = data.scene_claims ?? [];
    return (
      <Stack fill vertical>
        <Stack.Item>
          <ZoneFilterRow
            title="You use"
            options={data.zone_options ?? []}
            value={userZone}
            onChange={setUserZone}
          />
          <ZoneFilterRow
            title={
              asBool(data.is_self) ? 'On yourself' : `On ${data.target_name}`
            }
            options={data.zone_options ?? []}
            value={targetZone}
            onChange={setTargetZone}
          />
          <Stack align="center">
            <Stack.Item grow>
              <Input
                fluid
                expensive
                placeholder="Search interactions…"
                value={search}
                onChange={setSearch}
              />
            </Stack.Item>
            <Stack.Item>
              <Box color="label" fontSize="10px">
                {available.length} / {inactive.length}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                compact
                icon={sceneOpen ? 'chevron-up' : 'chevron-down'}
                tooltip="Who does what to whom in this scene, and which body parts are taken."
                onClick={() => setSceneOpen(!sceneOpen)}
              >
                Scene: {connections.length} acts, {claims.length} claims
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        {sceneOpen ? (
          <Stack.Item>
            <Section fitted>
              <Stack vertical maxHeight="7rem" overflowY="auto">
                {connections.map((connection) => (
                  <Stack.Item key={connection.ref}>
                    <Stack align="center">
                      <Stack.Item grow style={{ minWidth: 0 }}>
                        <Box fontSize="10px">
                          <Box as="span" bold>
                            {connection.actor_name}
                          </Box>{' '}
                          → {connection.target_name}: {connection.name}
                        </Box>
                      </Stack.Item>
                      <Stack.Item>
                        <Box color="label" fontSize="9px">
                          {paceName(connection.speed, connection.force)}
                        </Box>
                      </Stack.Item>
                      {asBool(connection.can_stop) ? (
                        <Stack.Item>
                          <Button
                            compact
                            icon="times"
                            color="bad"
                            tooltip="Stop this act"
                            onClick={() =>
                              act('stop_scene_action', { ref: connection.ref })
                            }
                          />
                        </Stack.Item>
                      ) : null}
                    </Stack>
                  </Stack.Item>
                ))}
                {claims.map((claim, index) => (
                  <Stack.Item
                    key={`${claim.host_name}-${claim.resource_name}-${index}`}
                  >
                    <Box
                      color={asBool(claim.hard) ? 'bad' : 'average'}
                      fontSize="10px"
                    >
                      {claim.host_name}: {claim.resource_name} —{' '}
                      {claim.action_name}
                      {asBool(claim.hard) ? ' (exclusive)' : ' (shared)'}
                    </Box>
                  </Stack.Item>
                ))}
                {!connections.length && !claims.length ? (
                  <Stack.Item>
                    <Box color="label" fontSize="10px" italic>
                      Nothing is going on in this scene yet.
                    </Box>
                  </Stack.Item>
                ) : null}
              </Stack>
            </Section>
          </Stack.Item>
        ) : null}
        <Stack.Item grow>
          <Section fill scrollable>
            {activeActions.length ? (
              <Section title="Active" fitted mb={0.5}>
                <Stack wrap>{activeActions.map(renderActionButton)}</Stack>
              </Section>
            ) : null}
            {available.length ? (
              <Stack wrap>{available.map(renderActionButton)}</Stack>
            ) : (
              <Box color="label" textAlign="center" p={2} italic>
                No interactions match these filters.
              </Box>
            )}
          </Section>
        </Stack.Item>
        <Stack.Item>{renderQuickBar()}</Stack.Item>
      </Stack>
    );
  };

  const renderBellyriding = () => {
    const belly = data.bellyriding;
    if (!belly) {
      return null;
    }
    return (
      <Section fill scrollable>
        <Section title="Harness Controls" fitted mb={1}>
          <Button
            fluid
            mb={0.5}
            selected={asBool(belly.enabled)}
            onClick={() => act('bellyriding_toggle')}
          >
            {asBool(belly.enabled)
              ? 'Disable Bellyriding Interactions'
              : 'Enable Bellyriding Interactions'}
          </Button>
          <Button fluid onClick={() => act('bellyriding_release')}>
            Release From Harness
          </Button>
        </Section>
        <Section title="Harness Actions" fitted>
          {belly.actions.map((action) => (
            <Stack key={action.key} mb={0.5}>
              <Stack.Item grow>
                <Button
                  fluid
                  disabled={!asBool(action.can_perform)}
                  selected={asBool(action.selected)}
                  onClick={() => act('bellyriding_action', { key: action.key })}
                >
                  {action.name}
                </Button>
              </Stack.Item>
              {asBool(action.selected) ? (
                <Stack.Item>
                  <Button
                    icon="times"
                    color="bad"
                    tooltip="Return to automatic bellyriding"
                    onClick={() => act('bellyriding_clear')}
                  />
                </Stack.Item>
              ) : null}
            </Stack>
          ))}
        </Section>
      </Section>
    );
  };

  const customField = (field: string, value: unknown) =>
    act('custom_field', { field, value });

  const renderCustomToggle = (label: string, field: string, on: Booleanish) => (
    <LabeledList.Item label={label}>
      <Button
        compact
        color={asBool(on) ? 'good' : 'bad'}
        onClick={() => customField(field, 1)}
      >
        {asBool(on) ? 'Yes' : 'No'}
      </Button>
    </LabeledList.Item>
  );

  const renderCustomNumber = (
    label: string,
    field: string,
    value: number,
    min: number,
    max: number,
  ) => (
    <LabeledList.Item label={label}>
      <NumberInput
        value={value}
        minValue={min}
        maxValue={max}
        step={0.1}
        width="55px"
        onChange={(next) => customField(field, next)}
      />
    </LabeledList.Item>
  );

  const renderCustomDropdown = (
    label: string,
    field: string,
    value: number | string | null,
    options: CustomOption[],
  ) => {
    // Dropdown values must be string|number; '' stands in for null ("Default")
    // and the backend sanitizer maps any non-enum value back to null.
    const ddOptions = (options ?? []).map((option) => ({
      displayText: option.name,
      value: option.value ?? '',
    }));
    const selected =
      ddOptions.find((option) => option.value === (value ?? '')) ?? null;
    return (
      <LabeledList.Item label={label}>
        <Dropdown
          width="140px"
          options={ddOptions}
          selected={selected}
          onSelected={(next) => customField(field, next === '' ? null : next)}
        />
      </LabeledList.Item>
    );
  };

  const renderCustomText = (
    label: string,
    field: string,
    value: string | null,
  ) => (
    <LabeledList.Item label={label}>
      <TextArea
        value={value || ''}
        height="38px"
        placeholder="Leave blank for a fallback line."
        onBlur={(next) => customField(field, next)}
      />
    </LabeledList.Item>
  );

  const renderCustomEditor = () => {
    const custom = data.custom;
    const editor = custom.editor;
    if (!editor) {
      return (
        <Box color="label" textAlign="center" p={3} italic>
          Pick a template on the left or load one of your saved custom actions.
        </Box>
      );
    }
    return (
      <>
        <Stack align="center" mb={1}>
          <Stack.Item grow>
            <Box bold>
              {asBool(editor.is_saved)
                ? 'Editing Saved Action'
                : 'Editing Draft'}
              : {editor.name}
            </Box>
            {editor.created_text ? (
              <Box color="label" fontSize="10px">
                Saved: {editor.created_text} | Updated:{' '}
                {editor.modified_text || editor.created_text}
              </Box>
            ) : null}
          </Stack.Item>
          <Stack.Item>
            <Button icon="save" color="good" onClick={() => act('custom_save')}>
              {asBool(editor.is_saved) ? 'Save Changes' : 'Create Action'}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button icon="undo" onClick={() => act('custom_reset')}>
              Reset
            </Button>
          </Stack.Item>
          {asBool(editor.is_saved) ? (
            <Stack.Item>
              <Button.Confirm
                icon="trash"
                color="bad"
                confirmContent="Delete?"
                onClick={() =>
                  act('custom_delete', {
                    id: custom.saved.find((entry) => asBool(entry.selected))
                      ?.id,
                  })
                }
              >
                Delete
              </Button.Confirm>
            </Stack.Item>
          ) : null}
        </Stack>
        <Box color="label" fontSize="10px" mb={1}>
          Message tokens: {'{name}'}, {'{user}'}, {'{target}'}, {'{user_their}'}
          , {'{target_their}'}, {'{user_them}'}, {'{target_them}'}, {'{force}'},{' '}
          {'{speed}'}, {'{user_part}'}, {'{target_part}'}.
        </Box>
        <Section title="Basics" fitted mb={1}>
          <LabeledList>
            <LabeledList.Item label="Name">
              <Input
                fluid
                value={editor.name}
                onBlur={(next) => customField('name', next)}
                onEnter={(next) => customField('name', next)}
              />
            </LabeledList.Item>
            {renderCustomDropdown(
              'Scope',
              'scope',
              editor.scope,
              custom.scope_options,
            )}
            {renderCustomDropdown(
              'Acting Part',
              'user_part',
              editor.user_part,
              custom.part_options,
            )}
            {renderCustomDropdown(
              'Receiving Part',
              'target_part',
              editor.target_part,
              custom.part_options,
            )}
            <LabeledList.Item label="Interaction Filters">
              <Box color="label">{editor.filter_summary}</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Rules" fitted mb={1}>
          <LabeledList>
            {renderCustomToggle(
              'Require Same Tile',
              'require_same_tile',
              editor.require_same_tile,
            )}
            {renderCustomToggle(
              'Require Grab',
              'require_grab',
              editor.require_grab,
            )}
            {renderCustomToggle(
              'Requires Free Hands',
              'requires_free_hands',
              editor.requires_free_hands,
            )}
            {renderCustomToggle(
              'Gag Acting Side',
              'gags_user',
              editor.gags_user,
            )}
            {renderCustomToggle(
              'Gag Receiving Side',
              'gags_target',
              editor.gags_target,
            )}
            {renderCustomNumber(
              'Cycle Time (s)',
              'do_time_seconds',
              editor.do_time_seconds,
              0.5,
              10,
            )}
            {renderCustomNumber(
              'Stamina Cost',
              'stamina_cost',
              editor.stamina_cost,
              0,
              10,
            )}
          </LabeledList>
        </Section>
        <Section title="Effects Per Cycle" fitted mb={1}>
          <LabeledList>
            {renderCustomNumber(
              'Actor Arousal',
              'user_arousal',
              editor.user_arousal,
              0,
              10,
            )}
            {renderCustomNumber(
              'Actor Pain',
              'user_pain',
              editor.user_pain,
              0,
              10,
            )}
            {renderCustomNumber(
              'Actor Orgasm Progress',
              'user_orgasm',
              editor.user_orgasm,
              0,
              10,
            )}
            {renderCustomNumber(
              'Receiver Arousal',
              'target_arousal',
              editor.target_arousal,
              0,
              10,
            )}
            {renderCustomNumber(
              'Receiver Pain',
              'target_pain',
              editor.target_pain,
              0,
              10,
            )}
            {renderCustomNumber(
              'Receiver Orgasm Progress',
              'target_orgasm',
              editor.target_orgasm,
              0,
              10,
            )}
          </LabeledList>
        </Section>
        <Section title="Messages" fitted mb={1}>
          <LabeledList>
            {renderCustomText(
              'Start Message',
              'message_start',
              editor.message_start,
            )}
            {renderCustomText(
              'Cycle Message',
              'message_tick',
              editor.message_tick,
            )}
            {renderCustomText(
              'Finish Message',
              'message_finish',
              editor.message_finish,
            )}
          </LabeledList>
        </Section>
        <Section title="Climax Handling" fitted>
          <LabeledList>
            {renderCustomText(
              'Actor Climax Message',
              'message_climax_active',
              editor.message_climax_active,
            )}
            {renderCustomDropdown(
              'Actor Climax Result',
              'active_climax_location',
              editor.active_climax_location,
              custom.climax_options,
            )}
            {renderCustomText(
              'Receiver Climax Message',
              'message_climax_passive',
              editor.message_climax_passive,
            )}
            {renderCustomDropdown(
              'Receiver Climax Result',
              'passive_climax_location',
              editor.passive_climax_location,
              custom.climax_options,
            )}
          </LabeledList>
        </Section>
      </>
    );
  };

  const renderCustomSelector = (entry: CustomSelectorEntry, action: string) => (
    <Button
      key={entry.id}
      fluid
      mb={0.5}
      selected={asBool(entry.selected)}
      tooltip={entry.summary}
      onClick={() => act(action, { id: entry.id })}
    >
      <Box bold>{entry.name}</Box>
      <Box fontSize="10px" style={{ opacity: 0.85 }}>
        {entry.summary}
      </Box>
    </Button>
  );

  const renderCustomActions = () => {
    const custom = data.custom || ({} as CustomData);
    return (
      <Stack fill>
        <Stack.Item basis="230px" shrink={0}>
          <Section fill scrollable>
            <Section title="Templates" fitted mb={1}>
              {(custom.templates ?? []).map((entry) =>
                renderCustomSelector(entry, 'custom_select_template'),
              )}
            </Section>
            <Section title="Saved Actions" fitted>
              {(custom.saved ?? []).length ? (
                custom.saved.map((entry) =>
                  renderCustomSelector(entry, 'custom_select_saved'),
                )
              ) : (
                <Box color="label" fontSize="11px" italic>
                  You have not saved any custom actions yet.
                </Box>
              )}
            </Section>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            {renderCustomEditor()}
          </Section>
        </Stack.Item>
      </Stack>
    );
  };

  const erpAct = (
    prefType: string,
    action: string,
    extra?: Record<string, unknown>,
  ) => {
    act('erp_pref', {
      pref_type: prefType,
      action,
      ...(extra || {}),
    });
  };

  const renderErpControl = (pref: ErpPrefEntry, locked: boolean) => {
    if (pref.kind === 'flags') {
      return (
        <Box style={{ display: 'flex', flexWrap: 'wrap' }}>
          {(pref.flags ?? []).map((flag) => (
            <Button
              key={flag.bit}
              mr={0.5}
              mb={0.5}
              compact
              disabled={locked}
              selected={asBool(flag.on)}
              tooltip={flag.description || flag.name}
              onClick={() =>
                erpAct(pref.type, 'toggle_flag', { flag: flag.bit })
              }
            >
              {flag.name}
            </Button>
          ))}
        </Box>
      );
    }
    if (pref.kind === 'number') {
      return (
        <Stack align="center">
          <Stack.Item>
            <Button
              compact
              icon="chevron-left"
              disabled={locked}
              onClick={() => erpAct(pref.type, 'decrease')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              disabled={locked}
              tooltip={`${pref.min} - ${pref.max}`}
              onClick={() => erpAct(pref.type, 'set')}
            >
              {String(pref.value ?? 0)}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              icon="chevron-right"
              disabled={locked}
              onClick={() => erpAct(pref.type, 'increase')}
            />
          </Stack.Item>
        </Stack>
      );
    }
    if (pref.kind === 'choice') {
      return (
        <Stack align="center">
          <Stack.Item>
            <Button
              compact
              icon="chevron-left"
              disabled={locked}
              onClick={() => erpAct(pref.type, 'prev')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              disabled={locked}
              onClick={() => erpAct(pref.type, 'choose')}
            >
              {String(pref.value ?? 'None')}
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              compact
              icon="chevron-right"
              disabled={locked}
              onClick={() => erpAct(pref.type, 'next')}
            />
          </Stack.Item>
        </Stack>
      );
    }
    return (
      <Button
        compact
        disabled={locked}
        color={asBool(pref.value as Booleanish) ? 'good' : 'bad'}
        onClick={() => erpAct(pref.type, 'toggle')}
      >
        {asBool(pref.value as Booleanish) ? 'Enabled' : 'Disabled'}
      </Button>
    );
  };

  const renderErpValue = (pref: ErpPrefEntry) => {
    if (pref.kind === 'flags') {
      const onFlags = (pref.flags ?? []).filter((flag) => asBool(flag.on));
      return (
        <Box color="label">
          {onFlags.length
            ? onFlags.map((flag) => flag.name).join(', ')
            : 'None'}
        </Box>
      );
    }
    if (pref.kind === 'bool') {
      return (
        <Box bold color={asBool(pref.value as Booleanish) ? 'good' : 'bad'}>
          {asBool(pref.value as Booleanish) ? 'Enabled' : 'Disabled'}
        </Box>
      );
    }
    return <Box bold>{String(pref.value ?? 'None')}</Box>;
  };

  const renderErpColumn = (
    categories: ErpCategory[],
    editable: boolean,
    locked: boolean,
  ) => (
    <>
      {categories.length ? (
        categories.map((category) => (
          <Box key={category.name} mb={1}>
            <GroupTitle fontSize="11px">{category.name}</GroupTitle>
            {(category.prefs ?? []).map((pref) => (
              <Stack key={pref.type} align="baseline" mb={0.75} mt={0.5} px={0.5}>
                <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
                  <Box bold>{pref.name}</Box>
                  <Box color="label" fontSize="11px">
                    {pref.description}
                  </Box>
                </Stack.Item>
                <Stack.Item basis="45%">
                  {editable
                    ? renderErpControl(pref, locked)
                    : renderErpValue(pref)}
                </Stack.Item>
              </Stack>
            ))}
          </Box>
        ))
      ) : (
        <Box color="label" textAlign="center" p={2} italic>
          No preferences available.
        </Box>
      )}
    </>
  );

  const renderPreferences = () => {
    const intimacy = data.intimacy || ({} as IntimacyData);
    const locked = !!intimacy.lock_reason;
    return (
      <Section fill scrollable>
        {intimacy.lock_reason ? (
          <NoticeBox mb={1}>{intimacy.lock_reason}</NoticeBox>
        ) : null}
        <Stack>
          {/* minWidth 0 lets the flex columns shrink below their content's
              min-content width; without it the pane overflows horizontally
              and the left edge scrolls out of view. */}
          <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
            <Section title="Your Preferences" fitted>
              {renderErpColumn(intimacy.yours ?? [], true, locked)}
            </Section>
          </Stack.Item>
          <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
            <Section
              title={
                asBool(data.is_self)
                  ? 'Your Preferences (Partner View)'
                  : `${data.target_name}'s Preferences`
              }
              fitted
            >
              {renderErpColumn(
                asBool(data.is_self)
                  ? (intimacy.yours ?? [])
                  : (intimacy.theirs ?? []),
                false,
                true,
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Section>
    );
  };

  const kinkView = (kink: KinkEntry): KinkEdit =>
    kinkDraft[kink.name] ?? {
      enabled: asBool(kink.enabled),
      intensity: kink.intensity || 1,
      notes: kink.notes || '',
    };

  const editKink = (kink: KinkEntry, change: Partial<KinkEdit>) => {
    const stored = {
      enabled: asBool(kink.enabled),
      intensity: kink.intensity || 1,
      notes: kink.notes || '',
    };
    const next = { ...kinkView(kink), ...change };
    const draft = { ...kinkDraft };
    if (
      next.enabled === stored.enabled &&
      next.intensity === stored.intensity &&
      next.notes === stored.notes
    ) {
      delete draft[kink.name];
    } else {
      draft[kink.name] = next;
    }
    setKinkDraft(draft);
  };

  const saveKinks = () => {
    act('save_kinks', {
      changes: Object.entries(kinkDraft).map(([name, edit]) => ({
        name,
        enabled: edit.enabled,
        intensity: edit.intensity,
        notes: edit.notes,
      })),
    });
    setKinkDraft({});
    setKinkNotesOpen(null);
  };

  const renderOwnKink = (kink: KinkEntry, locked: boolean) => {
    const view = kinkView(kink);
    const edited = !!kinkDraft[kink.name];
    return (
      <Box key={kink.name} mb={0.25}>
        <Stack align="center">
          <Stack.Item>
            <Button
              compact
              icon={view.enabled ? 'check' : 'xmark'}
              color={view.enabled ? 'good' : 'bad'}
              disabled={locked}
              tooltip={view.enabled ? 'Enabled' : 'Disabled'}
              onClick={() => editKink(kink, { enabled: !view.enabled })}
            />
          </Stack.Item>
          <Stack.Item grow style={{ minWidth: 0 }}>
            <Tooltip content={kink.description} position="top">
              <Box
                bold={view.enabled}
                color={view.enabled ? undefined : 'label'}
                style={{
                  overflow: 'hidden',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                }}
              >
                {kink.name}
                {edited ? (
                  <Box as="span" color="average">
                    {' '}
                    *
                  </Box>
                ) : null}
              </Box>
            </Tooltip>
          </Stack.Item>
          {view.enabled ? (
            <>
              <Stack.Item>
                <LevelControl
                  value={view.intensity}
                  labels={INTENSITY_LABELS}
                  disabled={locked}
                  onSet={(level) => editKink(kink, { intensity: level })}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  compact
                  icon="pen"
                  disabled={locked}
                  selected={kinkNotesOpen === kink.name}
                  tooltip={view.notes || 'Add a note'}
                  onClick={() =>
                    setKinkNotesOpen(
                      kinkNotesOpen === kink.name ? null : kink.name,
                    )
                  }
                />
              </Stack.Item>
            </>
          ) : null}
        </Stack>
        {view.enabled && kinkNotesOpen === kink.name ? (
          <Input
            fluid
            mt={0.25}
            maxLength={256}
            placeholder="A note for your partners…"
            value={view.notes}
            onChange={(value) => editKink(kink, { notes: value })}
          />
        ) : null}
      </Box>
    );
  };

  const renderTheirKinks = (categories: KinkCategory[]) =>
    categories.length ? (
      categories.map((category) => (
        <Box key={category.name} mb={0.75}>
          <Box mb={0.25}>
            <GroupTitle fontSize="11px">{category.name}</GroupTitle>
          </Box>
          {category.kinks.map((kink) => (
            <Box key={kink.name} mb={0.5}>
              <Stack align="baseline">
                <Stack.Item grow>
                  <Tooltip content={kink.description} position="top">
                    <Box bold>{kink.name}</Box>
                  </Tooltip>
                </Stack.Item>
                <Stack.Item>
                  <Box color="pink" bold fontSize="11px">
                    {INTENSITY_LABELS[kink.intensity - 1] || 'Unknown'}
                  </Box>
                </Stack.Item>
              </Stack>
              {kink.notes ? (
                <Box color="average" fontSize="11px" italic>
                  Notes: {kink.notes}
                </Box>
              ) : null}
            </Box>
          ))}
        </Box>
      ))
    ) : (
      <Box color="label" textAlign="center" p={2} italic>
        No kinks enabled.
      </Box>
    );

  const renderKinks = () => {
    const intimacy = data.intimacy || ({} as IntimacyData);
    const locked = !!intimacy.lock_reason;
    const yours = intimacy.your_kinks ?? [];
    const editedCount = Object.keys(kinkDraft).length;
    return (
      <Stack fill vertical>
        {intimacy.lock_reason ? (
          <Stack.Item>
            <NoticeBox mb={0}>{intimacy.lock_reason}</NoticeBox>
          </Stack.Item>
        ) : null}
        <Stack.Item grow>
          <Stack fill>
            <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
              <Section
                fill
                scrollable
                title="Your kinks"
                buttons={
                  <>
                    <Button
                      compact
                      icon="undo"
                      disabled={!editedCount}
                      onClick={() => {
                        setKinkDraft({});
                        setKinkNotesOpen(null);
                      }}
                    >
                      Discard
                    </Button>
                    <Button
                      compact
                      icon="save"
                      disabled={!editedCount || locked}
                      tooltip="Saves to your character, so the prefs menu shows it too."
                      onClick={saveKinks}
                    >
                      {editedCount ? `Save (${editedCount})` : 'Save'}
                    </Button>
                  </>
                }
              >
                {yours.length ? (
                  yours.map((category) => (
                    <Box key={category.name} mb={0.75}>
                      <Box mb={0.25}>
                        <GroupTitle fontSize="11px">{category.name}</GroupTitle>
                      </Box>
                      {category.kinks.map((kink) =>
                        renderOwnKink(kink, locked),
                      )}
                    </Box>
                  ))
                ) : (
                  <Box color="label" textAlign="center" p={2} italic>
                    No kinks to set.
                  </Box>
                )}
              </Section>
            </Stack.Item>
            {!asBool(data.is_self) ? (
              <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
                <Section fill scrollable title={`${data.target_name}'s kinks`}>
                  {renderTheirKinks(intimacy.their_kinks ?? [])}
                </Section>
              </Stack.Item>
            ) : null}
          </Stack>
        </Stack.Item>
      </Stack>
    );
  };

  const submitNote = () => {
    if (!noteTitle.trim() || !noteContent.trim()) {
      return;
    }
    act('note_add', { title: noteTitle.trim(), content: noteContent.trim() });
    setNoteTitle('');
    setNoteContent('');
    setNoteFormOpen(false);
  };

  const renderNoteCard = (note: NoteEntry, editable: boolean) => (
    <Section key={note.title} fitted mb={0.75}>
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>{note.title}</Box>
        </Stack.Item>
        {editable ? (
          <>
            <Stack.Item>
              <Button
                compact
                icon="pen"
                onClick={() => {
                  setEditingNote(note.title);
                  setEditContent(note.content);
                }}
              >
                Edit
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                compact
                icon="trash"
                color="bad"
                confirmContent="Remove?"
                onClick={() => act('note_remove', { title: note.title })}
              >
                Remove
              </Button.Confirm>
            </Stack.Item>
          </>
        ) : null}
      </Stack>
      {editable && editingNote === note.title ? (
        <>
          <TextArea
            value={editContent}
            height="70px"
            onChange={setEditContent}
          />
          <Stack mt={0.5}>
            <Stack.Item grow />
            <Stack.Item>
              <Button
                compact
                color="good"
                icon="save"
                onClick={() => {
                  act('note_edit', {
                    title: note.title,
                    content: editContent,
                  });
                  setEditingNote(null);
                }}
              >
                Save
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button compact icon="times" onClick={() => setEditingNote(null)}>
                Cancel
              </Button>
            </Stack.Item>
          </Stack>
        </>
      ) : (
        <Box color="label" style={{ whiteSpace: 'pre-wrap' }}>
          {note.content}
        </Box>
      )}
      <Box color="grey" fontSize="10px" mt={0.5}>
        {note.meta}
      </Box>
    </Section>
  );

  const renderNotes = () => {
    const notes = data.notes || ({ yours: [], theirs: [] } as NotesData);
    const shownNotes = notesTab === 'yours' ? notes.yours : notes.theirs;
    return (
      <Section fill scrollable>
        <Tabs>
          <Tabs.Tab
            selected={notesTab === 'yours'}
            onClick={() => setNotesTab('yours')}
          >
            Your Notes About {data.target_name}
          </Tabs.Tab>
          <Tabs.Tab
            selected={notesTab === 'theirs'}
            onClick={() => setNotesTab('theirs')}
          >
            {asBool(data.is_self)
              ? 'Your Shared Notes'
              : `${data.target_name}'s Shared Notes`}
          </Tabs.Tab>
        </Tabs>
        {notesTab === 'yours' ? (
          <Box mb={1}>
            <Button
              icon={noteFormOpen ? 'times' : 'plus'}
              onClick={() => setNoteFormOpen(!noteFormOpen)}
            >
              {noteFormOpen ? 'Cancel' : `Add Note About ${data.target_name}`}
            </Button>
            {noteFormOpen ? (
              <Section fitted mt={0.5}>
                <Input
                  fluid
                  mb={0.5}
                  placeholder="Note title…"
                  value={noteTitle}
                  onChange={setNoteTitle}
                />
                <TextArea
                  height="70px"
                  placeholder="Write your note here…"
                  value={noteContent}
                  onChange={setNoteContent}
                />
                <Stack mt={0.5}>
                  <Stack.Item grow />
                  <Stack.Item>
                    <Button
                      icon="save"
                      color="good"
                      disabled={!noteTitle.trim() || !noteContent.trim()}
                      onClick={submitNote}
                    >
                      Save Note
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            ) : null}
          </Box>
        ) : null}
        {shownNotes.length ? (
          shownNotes.map((note) => renderNoteCard(note, notesTab === 'yours'))
        ) : (
          <Box color="label" textAlign="center" p={2} italic>
            {notesTab === 'yours'
              ? `You haven't written any notes about ${data.target_name} yet.`
              : 'No shared notes yet.'}
          </Box>
        )}
      </Section>
    );
  };

  const renderActiveTab = () => {
    switch (activeTab) {
      case 'bellyriding':
        return renderBellyriding();
      case 'custom':
        return renderCustomActions();
      case 'preferences':
        return renderPreferences();
      case 'kinks':
        return renderKinks();
      case 'notes':
        return renderNotes();
      default:
        return renderInteractions();
    }
  };

  return (
    <Window title="Sate Desire" width={760} height={520} theme="vanderlin">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>{renderHeader()}</Stack.Item>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="heart"
                selected={activeTab === 'interactions'}
                onClick={() => setTab('interactions')}
              >
                Interactions
              </Tabs.Tab>
              {hasBelly ? (
                <Tabs.Tab
                  icon="person-breastfeeding"
                  selected={activeTab === 'bellyriding'}
                  onClick={() => setTab('bellyriding')}
                >
                  Bellyriding
                </Tabs.Tab>
              ) : null}
              <Tabs.Tab
                icon="pen"
                selected={activeTab === 'custom'}
                onClick={() => setTab('custom')}
              >
                Custom Actions
              </Tabs.Tab>
              <Tabs.Tab
                icon="sliders-h"
                selected={activeTab === 'preferences'}
                onClick={() => setTab('preferences')}
              >
                Preferences
              </Tabs.Tab>
              <Tabs.Tab
                icon="star"
                selected={activeTab === 'kinks'}
                onClick={() => setTab('kinks')}
              >
                Kinks
              </Tabs.Tab>
              <Tabs.Tab
                icon="sticky-note"
                selected={activeTab === 'notes'}
                onClick={() => setTab('notes')}
              >
                Notes
              </Tabs.Tab>
              <Box style={{ marginLeft: 'auto', alignSelf: 'center' }}>
                <Button
                  compact
                  icon="circle-notch"
                  tooltip="Open the holes window"
                  onClick={() => act('view_holes')}
                >
                  View holes
                </Button>
              </Box>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{renderActiveTab()}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

export default SexScene;
