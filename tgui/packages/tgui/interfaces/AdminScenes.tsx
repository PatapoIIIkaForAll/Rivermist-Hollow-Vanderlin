/**
 * Scenes: build a list of steps, then run it here, after a delay, or from a trigger.
 * Steps: spawn groups (picked from a searchable list or captured from the map), narration, sound,
 * doors, teleports (with a line from the trigger to point B), effects and buffs, waits, cleanup.
 */
import { useEffect, useMemo, useState } from 'react';
import {
  Button,
  DmIcon,
  Icon,
  Input,
  NumberInput,
  TextArea,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Step = { type: string } & Record<string, any>;
type SpawnItem = { path: string; dx: number; dy: number; dir: number; amount: number };
type Scene = { id: string; name: string; owner?: string | null; shared: boolean; steps: Step[] };
type CatalogResult = { path: string; name: string; icon: string; icon_state: string };
type StatusEffect = {
  type: string;
  name: string;
  desc: string;
  kind: 'buff' | 'debuff';
  duration: number;
};

type Data = {
  // static
  effects: { id: string; name: string }[];
  status_effects: StatusEffect[];
  max_steps: number;
  max_items: number;
  // dynamic
  scenes: {
    id: string;
    name: string;
    steps: number;
    owner?: string | null;
    shared: boolean;
    mine: boolean;
  }[];
  selected?: Scene | null;
  can_edit: boolean;
  icons: Record<string, [string, string, string]>;
  triggers: {
    ref: string;
    scene: string;
    where: string;
    radius: number;
    mode: string;
    cooldown: number;
    /** "each" mode: how many players have set it off. */
    players: number;
    armed: boolean;
    fired: number;
  }[];
  runs: { ref: string; scene: string; step: number; steps: number }[];
  players: { ckey: string; name: string }[];
  build_selection?: string | null;
  search_query: string;
  search_results: CatalogResult[];
  status?: string | null;
  here?: [number, number, number] | null;
};

const STEP_TYPES: [string, string, string, string][] = [
  ['spawn', 'Spawn group', 'cubes', 'Several objects and mobs at once, each at its own offset'],
  ['teleport', 'Teleport', 'route', 'Move a player, an area, or everyone near A to point B'],
  ['effect', 'Effect', 'magic', 'Shake, ringing, darkness, stun, sleep, heal, damage, buffs and debuffs'],
  ['explosion', 'Explosion', 'bomb', 'A blast at point A, or on each target'],
  ['narrate', 'Narrate', 'feather', 'Text to everyone in view, in the area, or the world'],
  ['sound', 'Sound', 'music', 'A sound file played where the scene runs'],
  ['doors', 'Doors', 'door-open', 'Open, close, lock or unlock doors nearby'],
  ['wait', 'Wait', 'hourglass-half', 'Pause before the next step'],
  ['cleanup', 'Cleanup', 'broom', 'Delete everything this run has spawned so far'],
];

const EFFECT_ICONS: Record<string, string> = {
  shake: 'house-damage',
  ring: 'bell',
  darken: 'moon',
  blackout: 'eye-slash',
  flash: 'sun',
  stun: 'bolt',
  knockdown: 'arrow-down',
  sleep: 'bed',
  heal: 'heart',
  damage: 'tint',
  buff: 'arrow-up',
  unbuff: 'times-circle',
  message: 'envelope',
};

const DIRS: [number, string][] = [
  [1, 'N'],
  [2, 'S'],
  [4, 'E'],
  [8, 'W'],
];

const Choice = (props: {
  value: string;
  options: [string, string][];
  onPick: (value: string) => void;
}) => (
  <span className="Scenes__choice">
    {props.options.map(([value, label]) => (
      <Button key={value} selected={props.value === value} onClick={() => props.onPick(value)}>
        {label}
      </Button>
    ))}
  </span>
);

const Num = (props: {
  value: number;
  min: number;
  max: number;
  step?: number;
  unit?: string;
  width?: string;
  onChange: (value: number) => void;
}) => (
  <NumberInput
    width={props.width || '48px'}
    value={props.value}
    minValue={props.min}
    maxValue={props.max}
    step={props.step || 1}
    unit={props.unit}
    onChange={props.onChange}
  />
);

/** Who a teleport or effect reaches. */
const TargetPicker = (props: { step: Step; edit: (field: string, value: any) => void }) => {
  const { data } = useBackend<Data>();
  const { step, edit } = props;
  return (
    <>
      <div className="Scenes__field">
        <span>Who</span>
        <Choice
          value={step.who}
          options={[
            ['near', 'Near A'],
            ['trigger', 'In trigger'],
            ['area', 'Area of A'],
            ['player', 'One player'],
            ['everyone', 'Everyone'],
          ]}
          onPick={(value) => edit('who', value)}
        />
        {(step.who === 'near' || step.who === 'trigger') && (
          <Num value={step.range} min={0} max={15} unit="t" onChange={(value) => edit('range', value)} />
        )}
      </div>
      {step.who === 'player' && (
        <div className="Scenes__field">
          <span>Player</span>
          <select
            className="Scenes__select"
            value={step.player}
            onChange={(event) => edit('player', event.target.value)}
          >
            <option value="">-- pick a player --</option>
            {!!step.player && !data.players.some((player) => player.ckey === step.player) && (
              <option value={step.player}>{step.player} (offline)</option>
            )}
            {data.players.map((player) => (
              <option key={player.ckey} value={player.ckey}>
                {player.name} ({player.ckey})
              </option>
            ))}
          </select>
        </div>
      )}
      {step.who !== 'player' && (
        <div className="Scenes__field">
          <span>Include</span>
          <Choice
            value={step.include}
            options={[
              ['players', 'Players only'],
              ['living', 'Any living mob'],
            ]}
            onPick={(value) => edit('include', value)}
          />
        </div>
      )}
    </>
  );
};

const SpawnEditor = (props: { step: Step; index: number }) => {
  const { act, data } = useBackend<Data>();
  const { step, index } = props;
  const [picking, setPicking] = useState(false);
  const [query, setQuery] = useState('');
  const items: SpawnItem[] = step.items || [];
  const editItem = (item: number, field: string, value: any) =>
    act('edit_item', { index: index + 1, item: item + 1, field, value });

  return (
    <div className="Scenes__fields Scenes__fields--column">
      {items.length === 0 && (
        <div className="Scenes__hint">
          Empty group. Add objects below, or use Capture to copy what is around you on the map.
        </div>
      )}
      <div className="Scenes__items">
        {items.map((item, itemIndex) => {
          const icon = data.icons[item.path];
          return (
            <div className="Scenes__itemRow" key={`${item.path}-${itemIndex}`}>
              <div className="Scenes__itemIcon">
                {icon ? (
                  <DmIcon
                    icon={icon[0]}
                    icon_state={icon[1]}
                    direction={item.dir}
                    width="28px"
                    height="28px"
                    fallback={<Icon name="cube" />}
                  />
                ) : (
                  <Icon name="cube" />
                )}
              </div>
              <Tooltip content={item.path}>
                <span className="Scenes__itemName">{icon?.[2] || item.path}</span>
              </Tooltip>
              <span className="Scenes__dim">×</span>
              <Num
                value={item.amount}
                min={1}
                max={50}
                width="40px"
                onChange={(value) => editItem(itemIndex, 'amount', value)}
              />
              <span className="Scenes__dim">X</span>
              <Num value={item.dx} min={-30} max={30} width="42px" onChange={(value) => editItem(itemIndex, 'dx', value)} />
              <span className="Scenes__dim">Y</span>
              <Num value={item.dy} min={-30} max={30} width="42px" onChange={(value) => editItem(itemIndex, 'dy', value)} />
              <Choice
                value={String(item.dir)}
                options={DIRS.map(([dir, label]) => [String(dir), label])}
                onPick={(value) => editItem(itemIndex, 'dir', value)}
              />
              <Button
                icon="times"
                color="bad"
                onClick={() => act('remove_item', { index: index + 1, item: itemIndex + 1 })}
              />
            </div>
          );
        })}
      </div>
      <div className="Scenes__field">
        <Button
          icon={picking ? 'chevron-up' : 'plus'}
          selected={picking}
          disabled={items.length >= data.max_items}
          onClick={() => setPicking(!picking)}
        >
          Add objects
        </Button>
        {!!data.build_selection && (
          <Button
            icon="hammer"
            tooltip={`Add the build mode selection: ${data.build_selection}`}
            onClick={() => act('add_item', { index: index + 1, path: data.build_selection })}
          >
            From build mode
          </Button>
        )}
        <span className="Scenes__dim">
          {items.length} / {data.max_items} · X/Y are tiles from point A
        </span>
      </div>
      {picking && (
        <div className="Scenes__picker">
          <Input
            fluid
            autoFocus
            placeholder="Search objects and mobs by name or /type/path, then Enter"
            value={query}
            onChange={setQuery}
            onEnter={(value) => act('catalog_search', { query: value })}
          />
          <div className="Scenes__pickerGrid">
            {data.search_results.map((result) => (
              <Tooltip key={result.path} content={result.path}>
                <div
                  className="Scenes__pickerCard"
                  onClick={() => act('add_item', { index: index + 1, path: result.path })}
                >
                  <DmIcon
                    icon={result.icon}
                    icon_state={result.icon_state}
                    width="32px"
                    height="32px"
                    fallback={<Icon name="cube" />}
                  />
                  <span>{result.name}</span>
                </div>
              </Tooltip>
            ))}
            {!data.search_results.length && (
              <div className="Scenes__hint">
                {data.search_query ? 'Nothing found.' : 'Type and press Enter to search.'}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

const StatusPicker = (props: { value: string; onPick: (value: string) => void }) => {
  const { data } = useBackend<Data>();
  const [query, setQuery] = useState('');
  const [kind, setKind] = useState<'all' | 'buff' | 'debuff'>('all');
  const current = data.status_effects.find((effect) => effect.type === props.value);
  const shown = useMemo(() => {
    const words = query.trim().toLowerCase().split(/\s+/).filter(Boolean);
    return data.status_effects
      .filter((effect) => kind === 'all' || effect.kind === kind)
      .filter((effect) => {
        const haystack = `${effect.name} ${effect.type}`.toLowerCase();
        return words.every((word) => haystack.includes(word));
      })
      .slice(0, 60);
  }, [data.status_effects, query, kind]);

  return (
    <div className="Scenes__status">
      <div className="Scenes__field">
        <span>Effect</span>
        {current ? (
          <span className={`Scenes__statusPicked Scenes__statusPicked--${current.kind}`}>
            <Icon name={current.kind === 'buff' ? 'arrow-up' : 'arrow-down'} /> {current.name}
            {current.duration > 0 ? ` · ${current.duration} s by default` : ''}
          </span>
        ) : (
          <span className="Scenes__dim">none picked</span>
        )}
      </div>
      <div className="Scenes__field">
        <Choice
          value={kind}
          options={[
            ['all', 'All'],
            ['buff', 'Buffs'],
            ['debuff', 'Debuffs'],
          ]}
          onPick={(value) => setKind(value as 'all' | 'buff' | 'debuff')}
        />
        <Input placeholder="Filter..." value={query} onChange={setQuery} />
      </div>
      <div className="Scenes__statusList">
        {shown.map((effect) => (
          <Tooltip key={effect.type} content={effect.desc || effect.type}>
            <div
              className={`Scenes__statusItem Scenes__statusItem--${effect.kind}${effect.type === props.value ? ' Scenes__statusItem--on' : ''}`}
              onClick={() => props.onPick(effect.type)}
            >
              <Icon name={effect.kind === 'buff' ? 'arrow-up' : 'arrow-down'} /> {effect.name}
            </div>
          </Tooltip>
        ))}
      </div>
    </div>
  );
};

const SCREEN_COLORS: [string, string][] = [
  ['#eee69c', 'Parchment'],
  ['#ffffff', 'White'],
  ['#d04a3a', 'Blood'],
  ['#9fb861', 'Moss'],
  ['#7db7e6', 'Frost'],
  ['#c49be0', 'Arcane'],
];

const NarrateEditor = (props: { step: Step; edit: (field: string, value: any) => void }) => {
  const { step, edit } = props;
  // The text is sent when the field loses focus (or on Enter), not on every keystroke: each edit
  // saves every scene to disk and resends the window. The draft keeps the preview live meanwhile.
  const [draft, setDraft] = useState<string>(step.text);
  useEffect(() => setDraft(step.text), [step.text]);
  const screen = step.display !== 'chat';
  const previewFont =
    step.font === 'pixel' ? "'Pixelify Sans', 'Pterra', sans-serif" : "'Pterra', sans-serif";
  return (
    <div className="Scenes__fields Scenes__fields--column">
      <TextArea
        fluid
        height="54px"
        placeholder="What the players read"
        value={step.text}
        onChange={setDraft}
        onBlur={(value) => value !== step.text && edit('text', value)}
      />
      <div className="Scenes__field">
        <span>To</span>
        <Choice
          value={step.scope}
          options={[
            ['view', 'In view'],
            ['trigger', 'In trigger'],
            ['area', 'Area'],
            ['world', 'Everyone'],
          ]}
          onPick={(value) => edit('scope', value)}
        />
        {(step.scope === 'view' || step.scope === 'trigger') && (
          <Tooltip
            content={
              step.scope === 'trigger'
                ? 'Used only when the scene is started by hand; a trigger uses its own radius.'
                : 'How far from point A'
            }
          >
            <span>
              <Num value={step.range} min={1} max={30} unit="t" onChange={(value) => edit('range', value)} />
            </span>
          </Tooltip>
        )}
      </div>
      <div className="Scenes__field">
        <span>Show</span>
        <Choice
          value={step.display}
          options={[
            ['chat', 'In chat'],
            ['screen', 'On screen'],
            ['both', 'Both'],
          ]}
          onPick={(value) => edit('display', value)}
        />
        {step.display !== 'screen' && (
          <>
            <span>Chat style</span>
            <Choice
              value={step.style}
              options={[
                ['plain', 'Plain'],
                ['notice', 'Notice'],
                ['warning', 'Warning'],
                ['big', 'Big'],
              ]}
              onPick={(value) => edit('style', value)}
            />
          </>
        )}
      </div>
      {screen && (
        <div className="Scenes__screenBox">
          <div className="Scenes__field">
            <span>Font</span>
            <Choice
              value={step.font}
              options={[
                ['pixel', 'Pixel'],
                ['normal', 'Normal'],
              ]}
              onPick={(value) => edit('font', value)}
            />
            <span>Size</span>
            <Num value={step.size} min={8} max={48} unit="px" width="52px" onChange={(value) => edit('size', value)} />
          </div>
          <div className="Scenes__field">
            <span>Where</span>
            <Choice
              value={step.position}
              options={[
                ['top', 'Top'],
                ['center', 'Center'],
                ['bottom', 'Bottom'],
              ]}
              onPick={(value) => edit('position', value)}
            />
            <span>Hold</span>
            <Num value={step.duration} min={1} max={60} unit="s" width="48px" onChange={(value) => edit('duration', value)} />
            <Choice
              value={step.animation}
              options={[
                ['fade', 'Fade in'],
                ['type', 'Typewriter'],
              ]}
              onPick={(value) => edit('animation', value)}
            />
          </div>
          <div className="Scenes__field">
            <span>Colour</span>
            {SCREEN_COLORS.map(([color, label]) => (
              <Tooltip key={color} content={label}>
                <span
                  className={`Scenes__swatch${step.color === color ? ' Scenes__swatch--on' : ''}`}
                  style={{ background: color }}
                  onClick={() => edit('color', color)}
                />
              </Tooltip>
            ))}
          </div>
          <div
            className={`Scenes__screenPreview Scenes__screenPreview--${step.position}`}
            style={{ fontFamily: previewFont, fontSize: `${step.size}px`, color: step.color }}
          >
            {draft || 'Preview of the text on screen'}
          </div>
        </div>
      )}
    </div>
  );
};

/** Damage kinds of the Damage effect: the server's damage type strings (BRUTE, BURN, TOX, OXY). */
const DAMAGE_TYPES: [string, string][] = [
  ['brute', 'Brute'],
  ['fire', 'Burn'],
  ['toxin', 'Toxin'],
  ['oxygen', 'Suffocation'],
];

/** Explosion ranges as explosion() takes them: a tile is hit while its distance is below the range. */
const BLAST_FIELDS: [string, string, number, string][] = [
  ['devastation', 'Devastation', 3, 'Wrecks walls and structures, kills outright'],
  ['heavy', 'Heavy', 5, 'Heavy wounds, breaks most objects'],
  ['light', 'Light', 7, 'Light wounds, knocks people over'],
  ['flash', 'Flash', 10, 'Blinds those who see it'],
  ['flame', 'Fire', 7, 'Sets the area on fire'],
];

const BLAST_PRESETS: [string, Record<string, number>][] = [
  ['Tiny', { devastation: 0, heavy: 0, light: 1, flash: 3, flame: 0 }],
  ['Small', { devastation: 0, heavy: 1, light: 3, flash: 4, flame: 0 }],
  ['Medium', { devastation: 1, heavy: 2, light: 4, flash: 6, flame: 0 }],
  ['Large', { devastation: 2, heavy: 4, light: 6, flash: 8, flame: 2 }],
];

const ExplosionEditor = (props: { step: Step; edit: (field: string, value: any) => void }) => {
  const { step, edit } = props;
  const onTargets = step.where === 'targets';
  return (
    <div className="Scenes__fields Scenes__fields--column">
      <div className="Scenes__field">
        <span>Where</span>
        <Choice
          value={step.where}
          options={[
            ['a', 'Point A'],
            ['targets', 'On each target'],
          ]}
          onPick={(value) => edit('where', value)}
        />
        {!onTargets && (
          <>
            <span>X</span>
            <Num value={step.dx} min={-30} max={30} onChange={(value) => edit('dx', value)} />
            <span>Y</span>
            <Num value={step.dy} min={-30} max={30} onChange={(value) => edit('dy', value)} />
          </>
        )}
      </div>
      {onTargets && <TargetPicker step={step} edit={edit} />}
      <div className="Scenes__field">
        <span>Size</span>
        {BLAST_PRESETS.map(([label, sizes]) => (
          <Button
            key={label}
            selected={Object.keys(sizes).every((field) => step[field] === sizes[field])}
            onClick={() =>
              Object.keys(sizes).forEach((field) => step[field] !== sizes[field] && edit(field, sizes[field]))
            }
          >
            {label}
          </Button>
        ))}
      </div>
      <div className="Scenes__field">
        {BLAST_FIELDS.map(([field, label, max, tip]) => (
          <Tooltip key={field} content={tip}>
            <span className="Scenes__field">
              <span>{label}</span>
              <Num value={step[field]} min={0} max={max} unit="t" onChange={(value) => edit(field, value)} />
            </span>
          </Tooltip>
        ))}
      </div>
      <div className="Scenes__dim">
        A tile is hit while its distance is below the range: 0 = none, 1 = the centre tile only.
        {onTargets ? ' At most 10 targets get one each.' : ''} Every explosion is announced to the admins.
      </div>
    </div>
  );
};

const StepEditor = (props: { step: Step; index: number; count: number }) => {
  const { act, data } = useBackend<Data>();
  const { step, index, count } = props;
  const edit = (field: string, value: any) => act('edit_step', { index: index + 1, field, value });
  const meta = STEP_TYPES.find(([id]) => id === step.type);

  return (
    <div className={`Scenes__step Scenes__step--${step.type}`}>
      <div className="Scenes__stepHead">
        <span className="Scenes__stepNo">{index + 1}</span>
        <Icon name={meta?.[2] || 'circle'} />
        <b>{meta?.[1] || step.type}</b>
        <span className="Scenes__stepButtons">
          <Button
            icon="arrow-up"
            disabled={index === 0}
            onClick={() => act('move_step', { index: index + 1, direction: 'up' })}
          />
          <Button
            icon="arrow-down"
            disabled={index === count - 1}
            onClick={() => act('move_step', { index: index + 1, direction: 'down' })}
          />
          <Button icon="trash" color="bad" onClick={() => act('remove_step', { index: index + 1 })} />
        </span>
      </div>

      {step.type === 'spawn' && <SpawnEditor step={step} index={index} />}

      {step.type === 'teleport' && (
        <div className="Scenes__fields Scenes__fields--column">
          <TargetPicker step={step} edit={edit} />
          <div className="Scenes__field">
            <span>Point B</span>
            <Choice
              value={step.dest}
              options={[
                ['offset', 'Offset from A'],
                ['fixed', 'Fixed spot'],
              ]}
              onPick={(value) => edit('dest', value)}
            />
            {step.dest === 'offset' ? (
              <>
                <span>X</span>
                <Num value={step.dx} min={-30} max={30} onChange={(value) => edit('dx', value)} />
                <span>Y</span>
                <Num value={step.dy} min={-30} max={30} onChange={(value) => edit('dy', value)} />
              </>
            ) : (
              <span className="Scenes__coords">
                {step.x}, {step.y}, {step.z}
              </span>
            )}
            <Button
              icon="map-pin"
              tooltip="Make point B the spot where you stand now"
              onClick={() => act('set_dest_here', { index: index + 1 })}
            >
              B = here
            </Button>
          </div>
          <div className="Scenes__field">
            <span>Scatter</span>
            <Num value={step.scatter} min={0} max={5} unit="t" onChange={(value) => edit('scatter', value)} />
            <span className="Scenes__dim">so a crowd does not land on one tile</span>
          </div>
          <Input
            fluid
            placeholder="Message shown to whoever is moved (optional)"
            value={step.message}
            onBlur={(value) => value !== step.message && edit('message', value)}
          />
        </div>
      )}

      {step.type === 'effect' && (
        <div className="Scenes__fields Scenes__fields--column">
          <div className="Scenes__effects">
            {data.effects.map((effect) => (
              <Button
                key={effect.id}
                icon={EFFECT_ICONS[effect.id] || 'magic'}
                selected={step.effect === effect.id}
                onClick={() => edit('effect', effect.id)}
              >
                {effect.name}
              </Button>
            ))}
          </div>
          <TargetPicker step={step} edit={edit} />
          {!['heal', 'ring', 'message', 'unbuff', 'damage'].includes(step.effect) && (
            <div className="Scenes__field">
              <span>{step.effect === 'buff' ? 'Duration (0 = default)' : 'Seconds'}</span>
              <Num
                value={step.seconds}
                min={0}
                max={600}
                width="56px"
                unit="s"
                onChange={(value) => edit('seconds', value)}
              />
              {step.effect === 'shake' && (
                <>
                  <span>Strength</span>
                  <Num value={step.strength} min={1} max={5} onChange={(value) => edit('strength', value)} />
                </>
              )}
            </div>
          )}
          {(step.effect === 'buff' || step.effect === 'unbuff') && (
            <StatusPicker value={step.status} onPick={(value) => edit('status', value)} />
          )}
          {step.effect === 'damage' && (
            <div className="Scenes__field">
              <span>Amount</span>
              <Num
                value={step.damage}
                min={1}
                max={200}
                step={5}
                width="56px"
                onChange={(value) => edit('damage', value)}
              />
              <Choice
                value={step.damage_type}
                options={DAMAGE_TYPES}
                onPick={(value) => edit('damage_type', value)}
              />
              <span className="Scenes__dim">spread over the body, no critical wounds</span>
            </div>
          )}
          {step.effect === 'message' && (
            <>
              <TextArea
                fluid
                height="48px"
                placeholder="What the targets read (only they see it)"
                value={step.text}
                onBlur={(value) => value !== step.text && edit('text', value)}
              />
              <div className="Scenes__field">
                <span>Style</span>
                <Choice
                  value={step.style}
                  options={[
                    ['plain', 'Plain'],
                    ['notice', 'Notice'],
                    ['warning', 'Warning'],
                    ['big', 'Big'],
                  ]}
                  onPick={(value) => edit('style', value)}
                />
              </div>
            </>
          )}
        </div>
      )}

      {step.type === 'explosion' && <ExplosionEditor step={step} edit={edit} />}

      {step.type === 'narrate' && <NarrateEditor step={step} edit={edit} />}

      {step.type === 'sound' && (
        <div className="Scenes__fields">
          <div className="Scenes__field Scenes__field--wide">
            <span>File</span>
            <Input
              fluid
              placeholder="sound/..../something.ogg"
              value={step.path}
              onBlur={(value) => value !== step.path && edit('path', value)}
            />
          </div>
          <div className="Scenes__field">
            <span>Volume</span>
            <Num value={step.volume} min={1} max={100} step={5} onChange={(value) => edit('volume', value)} />
            <span>Extra range</span>
            <Num value={step.range} min={0} max={15} onChange={(value) => edit('range', value)} />
          </div>
        </div>
      )}

      {step.type === 'doors' && (
        <div className="Scenes__fields">
          <div className="Scenes__field">
            <Choice
              value={step.action}
              options={[
                ['open', 'Open'],
                ['close', 'Close'],
                ['lock', 'Lock'],
                ['unlock', 'Unlock'],
              ]}
              onPick={(value) => edit('action', value)}
            />
            <span>within</span>
            <Num value={step.range} min={0} max={15} unit="t" onChange={(value) => edit('range', value)} />
          </div>
        </div>
      )}

      {step.type === 'wait' && (
        <div className="Scenes__fields">
          <div className="Scenes__field">
            <span>Seconds</span>
            <Num value={step.seconds} min={0.5} max={900} width="60px" onChange={(value) => edit('seconds', value)} />
          </div>
        </div>
      )}

      {step.type === 'cleanup' && (
        <div className="Scenes__hint">Deletes everything this run has spawned so far.</div>
      )}
    </div>
  );
};

export const AdminScenes = () => {
  const { act, data } = useBackend<Data>();
  const { scenes = [], selected, triggers = [], runs = [] } = data;
  const [showShared, setShowShared] = useState(true);
  const listed = scenes.filter((scene) => scene.mine || !scene.owner || showShared);
  const readOnly = !!selected && !data.can_edit;
  const [delay, setDelay] = useState(0);
  const [radius, setRadius] = useState(2);
  const [mode, setMode] = useState('once');
  const [cooldown, setCooldown] = useState(60);
  // "Each player" counts its pause per player; 0 = once for every player.
  const [eachCooldown, setEachCooldown] = useState(0);
  const [triggerDelay, setTriggerDelay] = useState(0);
  const [who, setWho] = useState('players');
  const [captureRadius, setCaptureRadius] = useState(3);
  const [deleteArmed, setDeleteArmed] = useState(false);

  return (
    <Window title="Scenes" width={1040} height={760} theme="vanderlin">
      <Window.Content>
        <div className="Scenes">
          <div className="Scenes__side">
            <div className="Scenes__sideHead">
              <Icon name="theater-masks" /> Scenes
              <Button.Checkbox
                ml="auto"
                checked={showShared}
                tooltip="Also list the scenes other admins shared"
                onClick={() => setShowShared(!showShared)}
              >
                Shared
              </Button.Checkbox>
              <Button icon="plus" onClick={() => act('new_scene')}>
                New
              </Button>
            </div>
            <div className="Scenes__list">
              {listed.map((scene) => (
                <div
                  key={scene.id}
                  className={`Scenes__item${selected?.id === scene.id ? ' Scenes__item--on' : ''}`}
                  onClick={() => {
                    setDeleteArmed(false);
                    act('select', { id: scene.id });
                  }}
                >
                  {!!scene.shared && (
                    <Tooltip
                      content={scene.mine ? 'Shared with all admins' : `Shared by ${scene.owner || 'an old save'}`}
                    >
                      <Icon name="users" className="Scenes__sharedIcon" />
                    </Tooltip>
                  )}
                  <span className="Scenes__itemName">{scene.name}</span>
                  {!scene.mine && !!scene.owner && <span className="Scenes__owner">{scene.owner}</span>}
                  <span className="Scenes__count">{scene.steps}</span>
                </div>
              ))}
              {listed.length === 0 && (
                <div className="Scenes__hint">No scenes yet. Press New to make one.</div>
              )}
            </div>

            <div className="Scenes__sideHead">
              <Icon name="crosshairs" /> Triggers
            </div>
            <div className="Scenes__list Scenes__list--small">
              {triggers.map((trigger) => (
                <div key={trigger.ref} className="Scenes__trigger">
                  <div>
                    <b>{trigger.scene}</b>
                    <div className="Scenes__dim">
                      {trigger.where} · r{trigger.radius} ·{' '}
                      {trigger.mode === 'each'
                        ? `each player${trigger.cooldown ? `, every ${trigger.cooldown}s` : ', once'} · ${trigger.players} players`
                        : trigger.mode}{' '}
                      · fired {trigger.fired}
                    </div>
                  </div>
                  <div className="Scenes__triggerButtons">
                    <Button
                      icon={trigger.armed ? 'toggle-on' : 'toggle-off'}
                      selected={trigger.armed}
                      tooltip={trigger.armed ? 'Armed: click to disarm' : 'Disarmed: click to arm'}
                      onClick={() => act('trigger_action', { ref: trigger.ref, do: 'toggle' })}
                    />
                    <Button
                      icon="play"
                      tooltip="Fire it now"
                      onClick={() => act('trigger_action', { ref: trigger.ref, do: 'fire' })}
                    />
                    <Button
                      icon="location-arrow"
                      tooltip="Jump to it"
                      onClick={() => act('trigger_action', { ref: trigger.ref, do: 'jump' })}
                    />
                    <Button
                      icon="trash"
                      color="bad"
                      tooltip="Remove it"
                      onClick={() => act('trigger_action', { ref: trigger.ref, do: 'remove' })}
                    />
                  </div>
                </div>
              ))}
              {triggers.length === 0 && <div className="Scenes__hint">No triggers placed.</div>}
            </div>

            {runs.length > 0 && (
              <>
                <div className="Scenes__sideHead">
                  <Icon name="spinner" spin /> Running
                </div>
                <div className="Scenes__list Scenes__list--small">
                  {runs.map((run) => (
                    <div key={run.ref} className="Scenes__trigger">
                      <div>
                        <b>{run.scene}</b>
                        <div className="Scenes__dim">
                          step {run.step} / {run.steps}
                        </div>
                      </div>
                      <Button icon="stop" color="bad" onClick={() => act('stop_run', { ref: run.ref })}>
                        Stop
                      </Button>
                    </div>
                  ))}
                </div>
              </>
            )}
          </div>

          <div className="Scenes__main">
            {!!data.status && (
              <div className="Scenes__status-line">
                <Icon name="info-circle" /> {data.status}
              </div>
            )}
            {!selected ? (
              <div className="Scenes__empty">
                <Icon name="theater-masks" size={3} />
                <div>
                  Pick a scene on the left or make a new one. A scene runs from one spot (point A):
                  it can spawn whole groups of things at once, move players to point B, shake,
                  darken, stun or put people to sleep, give buffs and debuffs, narrate, play sounds,
                  work the doors, wait, and clean up after itself.
                </div>
              </div>
            ) : (
              <>
                <div className="Scenes__titleBar">
                  <Input
                    fluid
                    disabled={readOnly}
                    value={selected.name}
                    onBlur={(value) => value !== selected.name && act('rename', { name: value })}
                  />
                  <Button.Checkbox
                    checked={!!selected.shared}
                    disabled={readOnly}
                    tooltip="Shared: every admin sees this scene and can run, trigger or copy it. Only you can change it."
                    onClick={() => act('toggle_shared')}
                  >
                    Shared with all
                  </Button.Checkbox>
                  <Button
                    icon="eye"
                    tooltip="Show around you for 10 seconds where the scene puts things"
                    onClick={() => act('preview')}
                  >
                    Preview
                  </Button>
                  <Button icon="copy" tooltip="Duplicate" onClick={() => act('duplicate')} />
                  <Button
                    icon={deleteArmed ? 'exclamation-triangle' : 'trash'}
                    disabled={readOnly}
                    color={deleteArmed ? 'bad' : undefined}
                    tooltip={deleteArmed ? 'Click again to delete this scene' : 'Delete this scene'}
                    onClick={() => {
                      if (!deleteArmed) {
                        setDeleteArmed(true);
                        return;
                      }
                      setDeleteArmed(false);
                      act('delete_scene');
                    }}
                  />
                </div>

                {readOnly && (
                  <div className="Scenes__readOnly">
                    <Icon name="lock" /> Shared by {selected.owner}: you can run it, place triggers and
                    preview it. Press <Icon name="copy" /> to make your own copy to edit.
                  </div>
                )}
                <div className={`Scenes__steps${readOnly ? ' Scenes__steps--locked' : ''}`}>
                  {selected.steps.map((step, index) => (
                    <StepEditor key={index} step={step} index={index} count={selected.steps.length} />
                  ))}
                  {selected.steps.length === 0 && (
                    <div className="Scenes__hint">No steps yet: add some below.</div>
                  )}
                </div>

                <div className="Scenes__add">
                  <span className="Scenes__dim">Add step:</span>
                  {STEP_TYPES.map(([id, label, icon, tip]) => (
                    <Button
                      key={id}
                      icon={icon}
                      tooltip={tip}
                      disabled={readOnly || selected.steps.length >= data.max_steps}
                      onClick={() => act('add_step', { type: id })}
                    >
                      {label}
                    </Button>
                  ))}
                  <span className="Scenes__capture">
                    <Button
                      icon="object-group"
                      tooltip="Copy everything around you (objects and NPCs) into a new spawn group. Build it with build mode first."
                      disabled={readOnly || selected.steps.length >= data.max_steps}
                      onClick={() => act('capture', { radius: captureRadius })}
                    >
                      Capture around me
                    </Button>
                    <Num value={captureRadius} min={0} max={7} unit="t" onChange={setCaptureRadius} />
                  </span>
                </div>

                <div className="Scenes__run">
                  <div className="Scenes__runBlock">
                    <div className="Scenes__runHead">Run from where you are</div>
                    <div className="Scenes__field">
                      <span>Delay</span>
                      <Num value={delay} min={0} max={3600} step={5} unit="s" width="56px" onChange={setDelay} />
                      <Button
                        icon="play"
                        color="good"
                        disabled={!selected.steps.length}
                        onClick={() => act('run_here', { delay })}
                      >
                        {delay ? `Run in ${delay} s` : 'Run now'}
                      </Button>
                    </div>
                    {!!data.here && (
                      <div className="Scenes__dim">
                        You are at {data.here[0]}, {data.here[1]}, {data.here[2]}: that is point A.
                      </div>
                    )}
                  </div>
                  <div className="Scenes__runBlock">
                    <div className="Scenes__runHead">
                      Place a trigger where you are
                      <Tooltip content="An invisible marker (only admins and ghosts see it). When someone comes within the radius, the scene runs from the marker. Teleports draw a line from it to their point B.">
                        <Icon name="question-circle" ml={0.5} />
                      </Tooltip>
                    </div>
                    <div className="Scenes__field">
                      <span>Radius</span>
                      <Num value={radius} min={0} max={10} unit="t" onChange={setRadius} />
                      {mode !== 'each' && (
                        <Choice
                          value={who}
                          options={[
                            ['players', 'Players'],
                            ['living', 'Any living'],
                          ]}
                          onPick={setWho}
                        />
                      )}
                    </div>
                    <div className="Scenes__field">
                      <Choice
                        value={mode}
                        options={[
                          ['once', 'Once'],
                          ['repeat', 'Repeat'],
                          ['each', 'Each player'],
                        ]}
                        onPick={setMode}
                      />
                      {mode === 'repeat' && (
                        <>
                          <span>every</span>
                          <Num value={cooldown} min={5} max={3600} step={5} unit="s" width="56px" onChange={setCooldown} />
                        </>
                      )}
                      {mode === 'each' && (
                        <>
                          <span>again after</span>
                          <Num
                            value={eachCooldown}
                            min={0}
                            max={3600}
                            step={5}
                            unit="s"
                            width="56px"
                            onChange={setEachCooldown}
                          />
                        </>
                      )}
                      <span>delay</span>
                      <Num value={triggerDelay} min={0} max={3600} unit="s" width="52px" onChange={setTriggerDelay} />
                    </div>
                    {mode === 'each' && (
                      <div className="Scenes__dim">
                        Every player who comes in range sets it off for themselves
                        {eachCooldown ? `, and again ${eachCooldown}s later` : ', once'}. Steps aimed at
                        "In trigger" reach only that player; other targets work as usual.
                      </div>
                    )}
                    <Button
                      icon="crosshairs"
                      disabled={!selected.steps.length}
                      onClick={() =>
                        act('place_trigger', {
                          radius,
                          mode,
                          cooldown: mode === 'each' ? eachCooldown : cooldown,
                          delay: triggerDelay,
                          who: mode === 'each' ? 'players' : who,
                        })
                      }
                    >
                      Place trigger
                    </Button>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
