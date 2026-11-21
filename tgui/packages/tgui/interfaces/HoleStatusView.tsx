import { type ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type EggOption = {
  id: string;
  name: string;
};

type TraitOption = {
  id: string;
  name: string;
};

type ColorPreset = {
  id: string;
  name: string;
  color: string;
};

type EggData = {
  ref: string;
  name: string;
  desc?: string;
  type_name: string;
  display_color: string | null;
  color_hex: string | null;
  has_preg: boolean;
  stage: number;
  max_stage: number;
  progress_pct: number;
  scale?: number;
  traits?: string[];
  can_remove?: boolean;
  can_retch?: boolean;
  is_hatchling?: boolean;
  fertilized?: boolean;
  hatch?: HatchInfo;
  mother_name?: string;
  father_name?: string;
  status: string;
  time_left: number;
};

type OrganSettings = {
  can_configure?: boolean;
  egg_type: string;
  egg_type_name: string;
  clutch_size: number;
  capacity: number;
  max_capacity?: number;
  max_clutch: number;
  custom_name?: string;
  custom_desc?: string;
  custom_organ_desc?: string;
  custom_color?: string | null;
  resource_dependent?: boolean;
  egg_scale: number;
  egg_traits?: string[];
  available_egg_types: EggOption[];
  available_traits: TraitOption[];
  color_presets: ColorPreset[];
  nutrient_cost?: number;
};

type HatchInfo = {
  mode: string;
  chance: number;
  decided?: string | null;
};

type HatchlingData = {
  ref: string;
  name: string;
  word: string;
  can_push: boolean;
  can_retch: boolean;
};

type OrganData = {
  id: string;
  title: string;
  icon: string;
  egg_count: number;
  eggs: EggData[];
  settings?: OrganSettings;
  egg_capacity?: number;
  clutch_size?: number;
  egg_type_name?: string;
  custom_color?: string | null;
  custom_name?: string;
  resource_dependent?: boolean;
  egg_stage?: number;
  is_egg_layer?: boolean;
  hatchling_count?: number;
  hatchlings?: HatchlingData[];
  next_egg_seconds?: number;
  interval_seconds?: number;
};

type WearData = {
  tightness: string | null;
  stretch: string;
  stretch_pct: number;
  lube: string;
  soreness: string | null;
  gaped: boolean;
  gaping_soon: boolean;
  open_frac?: number;
} | null;

type FillData = {
  volume: number;
  capacity: number;
  main_fluid: string | null;
  seed_units: number;
  own_units: number;
};

type ItemData = {
  ref: string;
  name: string;
  layer: 'outer' | 'inner' | 'deep';
  can_remove: boolean;
  can_take: boolean;
  take_seconds: number;
  take_fail_pct: number;
  can_push_deeper: boolean;
};

type InsertData = {
  name: string;
  reason: string | null;
  seconds?: number;
  fail_pct?: number;
  fit?: string | null;
} | null;

type HoleData = {
  id: string;
  name: string;
  wear: WearData;
  fill: FillData;
  can_hold_in: boolean;
  items: ItemData[];
  can_push_out: boolean;
  insert: InsertData;
  eggs: EggData[];
  egg_count: number;
  hatchling_count: number;
  hatchlings?: HatchlingData[];
  size?: number;
};

type WombData = {
  fertile: boolean;
  contraceptive: boolean;
  fill: FillData;
  pregnancy_stage: number;
  max_stage: number;
  organ: OrganData;
} | null;

type LabourData = {
  pushing: boolean;
  contractions: number;
  needed: number;
  births: number;
} | null;

type BirthsData = {
  limit: number;
  births: number;
  growing: number;
  held: number;
  free: number;
  next_free_seconds: number;
  clear_seconds: number;
} | null;

type StatusData = {
  births: BirthsData;
  show_art: boolean;
  nutriment: number;
  holding_in: boolean;
  holes: HoleData[];
  womb: WombData;
  stomach: OrganData | null;
  ovipositor: OrganData | null;
  labour: LabourData;
};

type ActiveTab = 'status' | 'settings' | 'genetics';

export type HoleStatusLocale = {
  windowTitle: string;
  births: {
    title: string;
    ofLimit: string;
    window: string;
    growing: string;
    room: string;
    full: string;
    freeOnHatch: string;
    nextSlot: string;
    clears: string;
    dormant: string;
    min: string;
    sec: string;
  };
  emptyState: string;
  tabs: Record<ActiveTab, string>;
  art: {
    show: string;
    hide: string;
  };
  cards: {
    front: string;
    rear: string;
    breasts: string;
    stomach: string;
    ovipositor: string;
    womb: string;
  };
  wear: {
    title: string;
    tightness: string;
    feels: string;
    lube: string;
    soreness: string;
    fine: string;
    gaping: string;
    gapingSoon: string;
    tightnessWords: Record<string, string>;
    stretchWords: Record<string, string>;
    lubeWords: Record<string, string>;
    sorenessWords: Record<string, string>;
  };
  fill: {
    title: string;
    empty: string;
    mostly: string;
    seed: string;
    own: string;
    holdingIn: string;
  };
  items: {
    title: string;
    none: string;
    outer: string;
    inner: string;
    deep: string;
    stuck: string;
    takeOut: string;
    pushDeeper: string;
    pushOut: string;
    pushOutHint: string;
    insert: string;
    tuckIn: string;
    cleavage: string;
    holding: string;
    fit: string;
    seconds: string;
    failChance: string;
  };
  womb: {
    fertile: string;
    sterile: string;
    contraceptive: string;
    pregnancy: string;
    stage: string;
    seed: string;
    passageEggs: string;
    labour: string;
    contraction: string;
    pushing: string;
  };
  labels: {
    organ: string;
    eggsInside: string;
    stored: string;
    clutch: string;
    capacity: string;
    color: string;
    type: string;
    name: string;
    description: string;
    organDescription: string;
    nutrients: string;
    nutrientCost: string;
    interval: string;
    resourceDependent: string;
    limit: string;
    production: string;
    nextEgg: string;
    hatchlingsInside: string;
    stage: string;
    scale: string;
    traits: string;
    preview: string;
    parents: string;
    mother: string;
    father: string;
    unknown: string;
    defaultColor: string;
    fertilized: string;
    unfertilized: string;
    by: string;
    extract: string;
    extractAll: string;
    retchUp: string;
    layEggs: string;
    edit: string;
    pickColor: string;
    apply: string;
    reset: string;
    profileDefault: string;
    on: string;
    off: string;
    active: string;
    inactive: string;
    yes: string;
    no: string;
    unknownStage: string;
  };
  organNames: Record<string, string>;
  eggTypes: Record<string, string>;
  traitNames: Record<string, string>;
  hatch: {
    inside: string;
    outside: string;
    either: string;
    decidedInside: string;
    decidedOutside: string;
  };
  hatchlingWords: Record<string, string>;
  formatTime: (seconds: number) => string;
  formatFill: (volume: number, capacity: number) => string;
  formatStage: (stage: number, maxStage: number) => string;
  formatStatus: (status: string, timeLeft: number) => string;
};

const statusColor = (status: string): string => {
  if (status === 'ready') {
    return 'good';
  }
  if (status === 'growing') {
    return 'average';
  }
  return 'label';
};

const resolveEggType = (
  locale: HoleStatusLocale,
  typeName?: string | null,
) => {
  if (!typeName) {
    return locale.eggTypes.Hardshell || 'Hardshell';
  }
  return locale.eggTypes[typeName] || typeName;
};

const resolveTraitName = (
  locale: HoleStatusLocale,
  traitName?: string | null,
) => {
  if (!traitName) {
    return locale.labels.unknown;
  }
  return locale.traitNames[traitName] || traitName;
};

const word = (words: Record<string, string>, id?: string | null) =>
  id ? words[id] || id : '';

const normalizeHex = (value?: string | null): string => {
  if (!value) {
    return '#eee3c7';
  }
  const raw = value.startsWith('#') ? value : `#${value}`;
  return /^#[0-9a-fA-F]{6}$/.test(raw) ? raw : '#eee3c7';
};

const clampStep = (value: number, max: number) =>
  Math.max(0, Math.min(max, Math.round(value)));

const fillFraction = (fill?: FillData | null) =>
  fill && fill.capacity > 0 ? Math.min(1, fill.volume / fill.capacity) : 0;

// Picture steps: the vagina has 12 (10 and 11 gape), the anus 5 (4 gapes).
const frontPicture = (hole: HoleData): string[] => {
  const open = hole.wear?.open_frac ?? 0;
  if (hole.wear?.gaped) {
    return [`hole_vagina_${open >= 0.6 ? 11 : 10}.png`];
  }
  return [`hole_vagina_${clampStep(open * 12, 9)}.png`];
};

/** The rear view also shows the vagina above: a closed slit, its gape, or nothing. */
const rearPicture = (hole: HoleData, vagina: HoleData | null): string[] => {
  const open = hole.wear?.open_frac ?? 0;
  const layers = [
    `hole_anus_${hole.wear?.gaped ? 4 : clampStep(open * 6, 3)}.png`,
  ];
  if (vagina) {
    layers.push(
      vagina.wear?.gaped ? 'hole_anus_gaped_vagina.png' : 'hole_anus_slit.png',
    );
  }
  return layers;
};

const breastPicture = (hole: HoleData): string[] => [
  `hole_breasts_${clampStep(hole.size ?? 3, 5)}.png`,
];

/** Pregnancy first, then eggs and hatchlings, else the empty womb with its seed. */
const wombPicture = (womb: NonNullable<WombData>): string[] => {
  if (womb.pregnancy_stage > 0) {
    const share = womb.pregnancy_stage / Math.max(1, womb.max_stage);
    return [`hole_womb_preg_${clampStep(2 + share * 4, 6) || 1}.png`];
  }
  const passengers = womb.organ.egg_count + (womb.organ.hatchling_count || 0);
  if (passengers > 5) {
    return [`hole_womb_stuffed_${Math.min(5, Math.floor((passengers - 6) / 2) + 1)}.png`];
  }
  if (passengers > 0) {
    return [`hole_womb_eggs_${passengers}.png`];
  }
  const fill = fillFraction(womb.fill);
  if (fill <= 0) {
    return ['hole_womb.png'];
  }
  return ['hole_womb.png', `hole_womb_fill_${Math.max(1, Math.ceil(fill * 10))}.png`];
};

/** Stacked organ picture with a thin fill bar under it. */
const OrganPicture = (props: {
  layers: string[];
  width: number;
  height: number;
  fill?: FillData | null;
  pixel?: boolean;
}) => {
  const { layers, width, height, fill, pixel } = props;
  return (
    <Box style={{ width: `${width}px` }}>
      <Box
        style={{
          position: 'relative',
          width: `${width}px`,
          height: `${height}px`,
          borderRadius: '3px',
          overflow: 'hidden',
          background: 'rgba(0, 0, 0, 0.35)',
        }}
      >
        {layers.map((layer) => (
          <img
            key={layer}
            src={resolveAsset(layer)}
            style={{
              position: 'absolute',
              left: 0,
              top: 0,
              width: '100%',
              height: '100%',
              objectFit: 'contain',
              imageRendering: pixel ? 'pixelated' : 'auto',
            }}
          />
        ))}
      </Box>
      {fill && (
        <ProgressBar mt={0.25} value={fillFraction(fill)} color="pink" />
      )}
    </Box>
  );
};

/** A card body with its picture on the right when pictures are on. */
const WithPicture = (props: { picture: ReactNode | null; children: ReactNode }) => {
  if (!props.picture) {
    return <>{props.children}</>;
  }
  return (
    <Stack>
      <Stack.Item grow basis={0} style={{ minWidth: 0 }}>
        {props.children}
      </Stack.Item>
      <Stack.Item>{props.picture}</Stack.Item>
    </Stack>
  );
};

export const HoleStatusView = (props: { locale: HoleStatusLocale }) => {
  const { locale } = props;
  const { act, data } = useBackend<StatusData>();
  const {
    holes = [],
    womb = null,
    stomach = null,
    ovipositor = null,
    nutriment = 0,
    holding_in = false,
    labour = null,
    show_art = false,
    births = null,
  } = data;
  const [activeTab, setActiveTab] = useState<ActiveTab>('status');
  const vagina = holes.find((hole) => hole.id === 'vagina') || null;
  const anus = holes.find((hole) => hole.id === 'anus') || null;
  const breasts = holes.find((hole) => hole.id === 'breasts') || null;
  const nothing = !vagina && !anus && !breasts && !stomach && !ovipositor;

  return (
    <Window
      title={locale.windowTitle}
      width={660}
      height={760}
      theme="vanderlin"
    >
      <Window.Content scrollable>
        <Stack align="center">
          <Stack.Item grow>
            <Tabs textAlign="center">
              {(['status', 'settings', 'genetics'] as ActiveTab[]).map(
                (tab) => (
                  <Tabs.Tab
                    key={tab}
                    selected={activeTab === tab}
                    onClick={() => setActiveTab(tab)}
                  >
                    {locale.tabs[tab]}
                  </Tabs.Tab>
                ),
              )}
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="image"
              color={show_art ? 'good' : 'bad'}
              tooltip={show_art ? locale.art.hide : locale.art.show}
              tooltipPosition="bottom-end"
              onClick={() => act('toggle_art')}
            />
          </Stack.Item>
        </Stack>

        {nothing && (
          <Section>
            <Box textAlign="center" color="label" py={4}>
              <Icon name="circle-notch" size={2} mb={2} />
              <br />
              {locale.emptyState}
            </Box>
          </Section>
        )}

        {activeTab === 'status' && (
          <>
            {births && !nothing && (
              <Section>
                <BirthsLine births={births} locale={locale} />
              </Section>
            )}
            {vagina && (
              <Section
                title={
                  <Box inline>
                    <Icon name="venus" mr={1} />
                    {locale.cards.front}
                  </Box>
                }
              >
                <WithPicture
                  picture={
                    show_art && (
                      <OrganPicture
                        layers={frontPicture(vagina)}
                        width={102}
                        height={69}
                        fill={vagina.fill}
                        pixel
                      />
                    )
                  }
                >
                  <HoleBody
                    act={act}
                    hole={vagina}
                    holdingIn={holding_in}
                    locale={locale}
                  />
                </WithPicture>
                {labour && (
                  <Box bold color="bad" mt={0.5}>
                    <Icon name="heart-pulse" mr={0.5} />
                    {locale.womb.labour}
                    {': '}
                    {labour.pushing
                      ? locale.womb.pushing
                      : `${locale.womb.contraction} ${labour.contractions}/${labour.needed}`}
                  </Box>
                )}
                {womb && (
                  <WombBlock
                    act={act}
                    womb={womb}
                    nutriment={nutriment}
                    showArt={show_art}
                    locale={locale}
                  />
                )}
                <EggList
                  act={act}
                  eggs={vagina.eggs.filter((egg) => !egg.is_hatchling)}
                  title={locale.womb.passageEggs}
                  locale={locale}
                />
              </Section>
            )}
            {anus && (
              <Section
                title={
                  <Box inline>
                    <Icon name="circle" mr={1} />
                    {locale.cards.rear}
                  </Box>
                }
              >
                <WithPicture
                  picture={
                    show_art && (
                      <OrganPicture
                        layers={rearPicture(anus, vagina)}
                        width={102}
                        height={112}
                        fill={anus.fill}
                        pixel
                      />
                    )
                  }
                >
                  <HoleBody
                    act={act}
                    hole={anus}
                    holdingIn={holding_in}
                    locale={locale}
                  />
                </WithPicture>
                <EggBlock act={act} eggs={anus.eggs} locale={locale} />
                <HatchlingList
                  act={act}
                  hatchlings={anus.hatchlings}
                  count={anus.hatchling_count}
                  locale={locale}
                />
              </Section>
            )}
            {breasts && (
              <Section
                title={
                  <Box inline>
                    <Icon name="heart" mr={1} />
                    {locale.cards.breasts}
                  </Box>
                }
              >
                <WithPicture
                  picture={
                    show_art && (
                      <OrganPicture
                        layers={breastPicture(breasts)}
                        width={102}
                        height={92}
                        fill={breasts.fill}
                        pixel
                      />
                    )
                  }
                >
                  <HoleBody
                    act={act}
                    hole={breasts}
                    holdingIn={holding_in}
                    locale={locale}
                  />
                </WithPicture>
              </Section>
            )}
            {stomach && (
              <Section
                title={
                  <Box inline>
                    <Icon name="circle" mr={1} />
                    {locale.cards.stomach}
                  </Box>
                }
              >
                <EggBlock act={act} eggs={stomach.eggs} locale={locale} />
              </Section>
            )}
            {ovipositor && (
              <Section
                title={
                  <Box inline>
                    <Icon name="mars" mr={1} />
                    {locale.cards.ovipositor}
                  </Box>
                }
              >
                <OrganSummary
                  organ={ovipositor}
                  nutriment={nutriment}
                  locale={locale}
                />
                <EggActions act={act} organ={ovipositor} locale={locale} />
              </Section>
            )}
          </>
        )}

        {activeTab === 'settings' && (
          <>
            {womb?.organ.settings?.can_configure && (
              <Section title={locale.cards.womb}>
                <SettingsPanel act={act} organ={womb.organ} locale={locale} />
              </Section>
            )}
            {ovipositor?.settings?.can_configure && (
              <Section title={locale.cards.ovipositor}>
                <SettingsPanel act={act} organ={ovipositor} locale={locale} />
              </Section>
            )}
            {!womb?.organ.settings?.can_configure &&
              !ovipositor?.settings?.can_configure && (
                <Section>
                  <Box color="label">{locale.emptyState}</Box>
                </Section>
              )}
          </>
        )}

        {activeTab === 'genetics' && (
          <>
            {womb && (
              <Section title={locale.cards.womb}>
                <GeneticsPanel act={act} organ={womb.organ} locale={locale} />
              </Section>
            )}
            {vagina && vagina.eggs.length > 0 && (
              <Section title={locale.cards.front}>
                <ParentsList eggs={vagina.eggs} locale={locale} />
              </Section>
            )}
            {anus && anus.eggs.length > 0 && (
              <Section title={locale.cards.rear}>
                <ParentsList eggs={anus.eggs} locale={locale} />
              </Section>
            )}
            {stomach && (
              <Section title={locale.cards.stomach}>
                <ParentsList eggs={stomach.eggs} locale={locale} />
              </Section>
            )}
            {ovipositor && (
              <Section title={locale.cards.ovipositor}>
                <GeneticsPanel act={act} organ={ovipositor} locale={locale} />
              </Section>
            )}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const formatWait = (seconds: number, locale: HoleStatusLocale) =>
  seconds >= 60
    ? `${Math.ceil(seconds / 60)} ${locale.births.min}`
    : `${seconds} ${locale.births.sec}`;

/** How many creature births the body may still carry in the window, and when slots free. */
const BirthsLine = (props: { births: NonNullable<BirthsData>; locale: HoleStatusLocale }) => {
  const { births, locale } = props;
  const t = locale.births;
  const used = births.births + births.growing;
  return (
    <Box color="label">
      <Icon name="egg" mr={0.5} />
      {`${t.title}: ${used} ${t.ofLimit} ${births.limit} ${t.window}`}
      {births.growing > 0 && ` (${births.growing} ${t.growing})`}
      {'. '}
      {births.free > 0 ? `${t.room} ${births.free}.` : t.full}
      {births.free <= 0 && births.births <= 0 && ` ${t.freeOnHatch}`}
      {births.births > 0 &&
        ` ${t.nextSlot} ${formatWait(births.next_free_seconds, locale)}, ${t.clears} ${formatWait(births.clear_seconds, locale)}.`}
      {births.held > 0 && ` ${births.held} ${t.dormant}`}
    </Box>
  );
};

const HoleBody = (props: {
  act: any;
  hole: HoleData;
  holdingIn: boolean;
  locale: HoleStatusLocale;
}) => {
  const { act, hole, holdingIn, locale } = props;
  const wear = hole.wear;
  const cleavage = hole.id === 'breasts';
  return (
    <>
      <LabeledList>
        {wear && (
          <>
            <LabeledList.Item label={locale.wear.tightness}>
              {word(locale.wear.tightnessWords, wear.tightness) ||
                locale.labels.unknown}
            </LabeledList.Item>
            <LabeledList.Item
              label={locale.wear.feels}
              color={wear.gaped ? 'bad' : wear.stretch_pct >= 110 ? 'average' : undefined}
            >
              {word(locale.wear.stretchWords, wear.stretch)}
              {wear.stretch_pct > 100 ? ` (${wear.stretch_pct}%)` : ''}
              {wear.gaping_soon ? ` - ${locale.wear.gapingSoon}` : ''}
            </LabeledList.Item>
            <LabeledList.Item label={locale.wear.lube}>
              {word(locale.wear.lubeWords, wear.lube)}
            </LabeledList.Item>
            <LabeledList.Item
              label={locale.wear.soreness}
              color={wear.soreness ? 'bad' : 'good'}
            >
              {wear.soreness
                ? word(locale.wear.sorenessWords, wear.soreness)
                : locale.wear.fine}
            </LabeledList.Item>
          </>
        )}
        <LabeledList.Item label={locale.fill.title}>
          <FillLine fill={hole.fill} locale={locale} />
          {hole.can_hold_in && holdingIn ? ` - ${locale.fill.holdingIn}` : ''}
        </LabeledList.Item>
        <LabeledList.Item
          label={cleavage ? locale.items.cleavage : locale.items.title}
        >
          <ItemLines
            act={act}
            items={hole.items}
            locale={locale}
            flat={cleavage}
          />
          {hole.can_push_out && (
            <Button
              ml={0.5}
              compact
              icon="hand"
              tooltip={locale.items.pushOutHint}
              onClick={() => act('push_out', { hole: hole.id })}
            >
              {locale.items.pushOut}
            </Button>
          )}
        </LabeledList.Item>
      </LabeledList>
      {hole.insert && (
        <Box mt={0.5}>
          <Button
            icon="arrow-right-to-bracket"
            disabled={!!hole.insert.reason}
            tooltip={
              hole.insert.reason ||
              `${hole.insert.seconds ?? 0}${locale.items.seconds}` +
                (hole.insert.fit ? `, ${locale.items.fit}: ${hole.insert.fit}` : '') +
                (hole.insert.fail_pct
                  ? `, ${hole.insert.fail_pct}% ${locale.items.failChance}`
                  : '')
            }
            onClick={() => act('insert_item', { hole: hole.id })}
          >
            {cleavage ? locale.items.tuckIn : locale.items.insert}:{' '}
            {hole.insert.name}
          </Button>
        </Box>
      )}
    </>
  );
};

const FillLine = (props: { fill: FillData; locale: HoleStatusLocale }) => {
  const { fill, locale } = props;
  if (!fill || fill.volume <= 0) {
    return <>{locale.fill.empty}</>;
  }
  const parts: string[] = [locale.formatFill(fill.volume, fill.capacity)];
  if (fill.main_fluid) {
    parts.push(`${locale.fill.mostly} ${fill.main_fluid}`);
  }
  if (fill.seed_units > 0) {
    parts.push(`${locale.fill.seed} ${fill.seed_units} u`);
  }
  return <>{parts.join(', ')}</>;
};

const ItemLines = (props: {
  act: any;
  items: ItemData[];
  locale: HoleStatusLocale;
  flat?: boolean;
}) => {
  const { act, items, locale, flat } = props;
  if (!items.length) {
    return <>{locale.items.none}</>;
  }
  const layers: ItemData['layer'][] = ['outer', 'inner', 'deep'];
  return (
    <>
      {layers.map((layer) => {
        const entries = items.filter((item) => item.layer === layer);
        if (!entries.length) {
          return null;
        }
        return (
          <Box key={layer}>
            {!flat && (
              <Box inline color="label">
                {locale.items[layer]}
                {': '}
              </Box>
            )}
            {entries.map((item) => (
              <Box key={item.ref} inline mr={1}>
                {item.name}
                {item.can_remove ? '' : ` (${locale.items.stuck})`}
                {item.can_take && (
                  <Button
                    ml={0.5}
                    compact
                    icon="hand"
                    tooltip={
                      `${item.take_seconds}${locale.items.seconds}` +
                      (item.take_fail_pct
                        ? `, ${item.take_fail_pct}% ${locale.items.failChance}`
                        : '')
                    }
                    onClick={() => act('remove_item', { item_ref: item.ref })}
                  >
                    {locale.items.takeOut}
                  </Button>
                )}
                {item.can_push_deeper && (
                  <Button
                    ml={0.5}
                    compact
                    icon="arrow-down"
                    onClick={() => act('push_deeper', { item_ref: item.ref })}
                  >
                    {locale.items.pushDeeper}
                  </Button>
                )}
              </Box>
            ))}
          </Box>
        );
      })}
    </>
  );
};

/** The womb under the front hole: fertility, seed, pregnancy, then its eggs. */
const WombBlock = (props: {
  act: any;
  womb: NonNullable<WombData>;
  nutriment: number;
  showArt: boolean;
  locale: HoleStatusLocale;
}) => {
  const { act, womb, nutriment, showArt, locale } = props;
  const organ = womb.organ;
  return (
    <Section title={locale.cards.womb} mt={1}>
      <WithPicture
        picture={
          showArt && (
            <OrganPicture
              layers={wombPicture(womb)}
              width={112}
              height={112}
              fill={womb.fill}
            />
          )
        }
      >
        <LabeledList>
          <LabeledList.Item
            label={locale.womb.fertile}
            color={womb.fertile ? 'good' : 'label'}
          >
            {womb.fertile ? locale.womb.fertile : locale.womb.sterile}
            {womb.contraceptive ? `, ${locale.womb.contraceptive}` : ''}
          </LabeledList.Item>
          <LabeledList.Item label={locale.womb.seed}>
            <FillLine fill={womb.fill} locale={locale} />
          </LabeledList.Item>
          {womb.pregnancy_stage > 0 && (
            <LabeledList.Item label={locale.womb.pregnancy} color="good">
              {locale.womb.stage}{' '}
              {locale.formatStage(womb.pregnancy_stage, womb.max_stage)}
            </LabeledList.Item>
          )}
        </LabeledList>
      </WithPicture>
      {organ.is_egg_layer && (
        <Box mt={1}>
          <OrganSummary organ={organ} nutriment={nutriment} locale={locale} />
        </Box>
      )}
      <EggActions act={act} organ={organ} locale={locale} />
      <EggBlock act={act} eggs={organ.eggs} locale={locale} />
      <HatchlingList
        act={act}
        hatchlings={organ.hatchlings}
        count={organ.hatchling_count}
        locale={locale}
      />
    </Section>
  );
};

/** The egg kind decides how it hatches; once ripe the roll is made and shown. */
const formatHatch = (locale: HoleStatusLocale, hatch: HatchInfo): string => {
  if (hatch.decided === 'inside') {
    return locale.hatch.decidedInside;
  }
  if (hatch.decided === 'outside') {
    return locale.hatch.decidedOutside;
  }
  if (hatch.mode === 'inside') {
    return locale.hatch.inside;
  }
  if (hatch.mode === 'either') {
    return `${locale.hatch.either}, ${hatch.chance}%`;
  }
  return locale.hatch.outside;
};

/** Hatchlings waiting inside, what each is doing, and a push-out where its kind allows it. */
const HatchlingList = (props: {
  act: any;
  hatchlings?: HatchlingData[];
  count?: number;
  locale: HoleStatusLocale;
}) => {
  const { act, hatchlings, count, locale } = props;
  if (!hatchlings?.length) {
    if (!count) {
      return null;
    }
    return (
      <Box mt={0.5} bold color="bad">
        <Icon name="baby" mr={0.5} />
        {locale.labels.hatchlingsInside}
        {': '}
        {count}
      </Box>
    );
  }
  return (
    <Box mt={0.5}>
      <Box bold color="bad">
        <Icon name="baby" mr={0.5} />
        {locale.labels.hatchlingsInside}
        {': '}
        {hatchlings.length}
      </Box>
      {hatchlings.map((hatchling) => (
        <Box key={hatchling.ref} ml={1} mt={0.2}>
          <Box inline bold>
            {hatchling.name}
          </Box>
          <Box inline color="label" ml={0.5}>
            {locale.hatchlingWords[hatchling.word] || hatchling.word}
          </Box>
          {hatchling.can_push && (
            <Button
              ml={0.5}
              compact
              icon="hand"
              onClick={() => act('push_out_hatchling', { ref: hatchling.ref })}
            >
              {locale.labels.extract}
            </Button>
          )}
          {hatchling.can_retch && (
            <Button
              ml={0.5}
              compact
              icon="arrow-up"
              onClick={() => act('retch_up', { ref: hatchling.ref })}
            >
              {locale.labels.retchUp}
            </Button>
          )}
        </Box>
      ))}
    </Box>
  );
};

const EggBlock = (props: {
  act: any;
  eggs: EggData[];
  locale: HoleStatusLocale;
}) => {
  const { act, eggs, locale } = props;
  const eggItems = (eggs ?? []).filter((egg) => !egg.is_hatchling);
  const hatchlingItems = (eggs ?? []).filter((egg) => egg.is_hatchling);
  return (
    <>
      <EggList
        act={act}
        eggs={eggItems}
        title={locale.labels.eggsInside}
        locale={locale}
      />
      <EggList
        act={act}
        eggs={hatchlingItems}
        title={locale.labels.hatchlingsInside}
        locale={locale}
      />
    </>
  );
};

const ParentsList = (props: { eggs: EggData[]; locale: HoleStatusLocale }) => {
  const { eggs, locale } = props;
  if (!eggs?.length) {
    return null;
  }
  return (
    <Box>
      <Box bold color="label" mb={0.5}>
        {locale.labels.parents}
        {':'}
      </Box>
      {eggs.map((egg, index) => (
        <Box key={egg.ref || index} ml={1} mb={0.5}>
          <Box bold>
            {index + 1}. {egg.name}
          </Box>
          <Box color="label">
            {locale.labels.mother}
            {': '}
            {egg.mother_name || locale.labels.unknown}
            {' | '}
            {locale.labels.father}
            {': '}
            {egg.father_name || locale.labels.unknown}
            {' | '}
            {egg.fertilized
              ? locale.labels.fertilized
              : locale.labels.unfertilized}
          </Box>
        </Box>
      ))}
    </Box>
  );
};

const OrganSummary = (props: {
  organ: OrganData;
  nutriment: number;
  locale: HoleStatusLocale;
}) => {
  const { organ, nutriment, locale } = props;
  const isOvi = organ.id === 'ovipositor';
  const isWomb = organ.id === 'womb';
  const cap = organ.egg_capacity || 0;
  const nxt = organ.next_egg_seconds ?? 0;

  return (
    <>
      {isOvi && (
        <Box mb={0.5}>
          {locale.labels.stored}
          {': '}
          <Box inline bold>
            {organ.egg_count} / {cap || 1}
          </Box>
          {' | '}
          {locale.labels.clutch}
          {': '}
          <Box inline bold>
            {organ.clutch_size || 1}
          </Box>
        </Box>
      )}
      {isWomb && (
        <Box mb={0.5}>
          {cap > 0 && (
            <>
              {locale.labels.limit}
              {': '}
              <Box inline bold>
                {organ.egg_count} / {cap}
              </Box>
              {' | '}
            </>
          )}
          {locale.labels.production}
          {': '}
          <Box inline bold color={organ.is_egg_layer ? 'good' : 'label'}>
            {organ.is_egg_layer ? locale.labels.active : locale.labels.inactive}
          </Box>
        </Box>
      )}
      <Box mb={0.5}>
        {locale.labels.nutrients}
        {': '}
        <Box inline bold>
          {nutriment} u
        </Box>
        {' | '}
        {locale.labels.interval}
        {': '}
        <Box inline bold>
          {organ.interval_seconds
            ? locale.formatTime(organ.interval_seconds)
            : organ.egg_stage !== undefined
              ? `${locale.labels.stage} ${organ.egg_stage}/2`
              : locale.labels.unknownStage}
        </Box>
      </Box>
      {nxt > 0 && (
        <Box mb={0.5}>
          {locale.labels.nextEgg}
          {': '}
          <Box inline bold>
            {locale.formatTime(nxt)}
          </Box>
        </Box>
      )}
    </>
  );
};

const EggActions = (props: {
  act: any;
  organ: OrganData;
  locale: HoleStatusLocale;
}) => {
  const { act, organ, locale } = props;
  const removable = (organ.eggs ?? []).some((egg) => egg.can_remove);
  return (
    <Stack mb={1} style={{ flexWrap: 'wrap' }}>
      {organ.id === 'ovipositor' && (
        <Stack.Item>
          <Button
            icon="egg"
            disabled={organ.egg_count <= 0}
            onClick={() => act('lay_ovipositor_eggs')}
          >
            {locale.labels.layEggs}
          </Button>
        </Stack.Item>
      )}
      {organ.id === 'womb' && removable && (
        <Stack.Item>
          <Button
            icon="hand"
            onClick={() =>
              act('extract_organ_eggs', { organ_id: organ.id })
            }
          >
            {locale.labels.extractAll}
          </Button>
        </Stack.Item>
      )}
    </Stack>
  );
};

const EggList = (props: {
  act: any;
  eggs: EggData[];
  title: string;
  locale: HoleStatusLocale;
}) => {
  const { act, eggs, title, locale } = props;
  if (!eggs?.length) {
    return null;
  }
  return (
    <Box mt={1}>
      <Box bold color="label" mb={0.5}>
        {title}
        {':'}
      </Box>
      {eggs.map((egg, i) => (
        <EggDetail
          key={egg.ref || `${title}-${i}`}
          act={act}
          egg={egg}
          index={i + 1}
          locale={locale}
        />
      ))}
    </Box>
  );
};

const SettingsPanel = (props: {
  act: any;
  organ: OrganData;
  locale: HoleStatusLocale;
}) => {
  const { act, organ, locale } = props;
  const settings = organ.settings;
  if (!settings?.can_configure) {
    return <Box color="label">{locale.emptyState}</Box>;
  }

  return (
    <>
      <Preview settings={settings} locale={locale} />
      <SettingRow label={locale.labels.type}>
        {settings.available_egg_types.map((option) => (
          <Button
            key={option.id}
            selected={settings.egg_type === option.id}
            onClick={() =>
              act('set_organ_setting', {
                organ_id: organ.id,
                field: 'egg_type',
                value: option.id,
              })
            }
          >
            {resolveEggType(locale, option.name)}
          </Button>
        ))}
      </SettingRow>
      <SettingRow label={locale.labels.clutch}>
        <NumberInput
          minValue={1}
          maxValue={settings.max_clutch || 30}
          value={settings.clutch_size || 1}
          step={1}
          format={(value) => `${Math.round(value)}`}
          onChange={(value: number) =>
            act('set_organ_setting', {
              organ_id: organ.id,
              field: 'clutch_size',
              value,
            })
          }
        />
      </SettingRow>
      {organ.id === 'ovipositor' && (
        <SettingRow label={locale.labels.capacity}>
          <NumberInput
            minValue={1}
            maxValue={settings.max_capacity || 30}
            value={settings.capacity || 30}
            step={1}
            format={(value) => `${Math.round(value)}`}
            onChange={(value: number) =>
              act('set_organ_setting', {
                organ_id: organ.id,
                field: 'storage_capacity',
                value,
              })
            }
          />
        </SettingRow>
      )}
      <SettingRow label={locale.labels.scale}>
        <NumberInput
          minValue={50}
          maxValue={200}
          value={Math.round((settings.egg_scale || 1) * 100)}
          step={5}
          format={(value) => `${Math.round(value)}%`}
          onChange={(value: number) =>
            act('set_organ_setting', {
              organ_id: organ.id,
              field: 'egg_scale',
              value: value / 100,
            })
          }
        />
      </SettingRow>
      <TextSetting
        label={locale.labels.name}
        field="custom_name"
        organId={organ.id}
        value={settings.custom_name || ''}
        act={act}
        locale={locale}
      />
      <TextSetting
        label={locale.labels.description}
        field="custom_desc"
        organId={organ.id}
        multiline
        value={settings.custom_desc || ''}
        act={act}
        locale={locale}
      />
      <TextSetting
        label={locale.labels.organDescription}
        field="custom_organ_desc"
        organId={organ.id}
        multiline
        value={settings.custom_organ_desc || ''}
        act={act}
        locale={locale}
      />
      <ColorEditor act={act} organ={organ} settings={settings} locale={locale} />
      <SettingRow label={locale.labels.resourceDependent}>
        <Button.Checkbox
          checked={!!settings.resource_dependent}
          onClick={() =>
            act('set_organ_setting', {
              organ_id: organ.id,
              field: 'resource_dependent',
              value: settings.resource_dependent ? 0 : 1,
            })
          }
        >
          {settings.resource_dependent ? locale.labels.on : locale.labels.off}
        </Button.Checkbox>
        <Box inline color="label" ml={1}>
          {locale.labels.nutrientCost}
          {': '}
          {settings.nutrient_cost ?? 0} u
        </Box>
      </SettingRow>
    </>
  );
};

const GeneticsPanel = (props: {
  act: any;
  organ: OrganData;
  locale: HoleStatusLocale;
}) => {
  const { act, organ, locale } = props;
  const settings = organ.settings;
  const activeTraits = settings?.egg_traits || [];

  return (
    <>
      {settings?.can_configure && (
        <SettingRow label={locale.labels.traits}>
          {settings.available_traits.map((trait) => (
            <Button.Checkbox
              key={trait.id}
              checked={activeTraits.includes(trait.id)}
              onClick={() =>
                act('toggle_organ_trait', {
                  organ_id: organ.id,
                  trait: trait.id,
                })
              }
            >
              {resolveTraitName(locale, trait.name)}
            </Button.Checkbox>
          ))}
        </SettingRow>
      )}
      <ParentsList eggs={organ.eggs} locale={locale} />
    </>
  );
};

const SettingRow = (props: { label: string; children: ReactNode }) => {
  const { label, children } = props;
  return (
    <Box mb={1}>
      <Box bold color="label" mb={0.4}>
        {label}
      </Box>
      {children}
    </Box>
  );
};

const TextSetting = (props: {
  label: string;
  value: string;
  field: string;
  organId: string;
  multiline?: boolean;
  act: any;
  locale: HoleStatusLocale;
}) => {
  const { label, value, field, organId, multiline, act, locale } = props;
  const displayValue = value?.length ? value : locale.labels.profileDefault;

  return (
    <SettingRow label={label}>
      <Stack>
        <Stack.Item grow>
          <Box
            color={value?.length ? undefined : 'label'}
            style={{
              minHeight: multiline ? '48px' : '20px',
              whiteSpace: multiline ? 'pre-wrap' : 'nowrap',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
            }}
          >
            {displayValue}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="pen"
            onClick={() =>
              act('edit_organ_text', {
                organ_id: organId,
                field,
              })
            }
          >
            {locale.labels.edit}
          </Button>
        </Stack.Item>
      </Stack>
    </SettingRow>
  );
};

const ColorEditor = (props: {
  act: any;
  organ: OrganData;
  settings: OrganSettings;
  locale: HoleStatusLocale;
}) => {
  const { act, organ, settings, locale } = props;
  const applyColor = (color: string) =>
    act('set_organ_setting', {
      organ_id: organ.id,
      field: 'custom_color',
      value: normalizeHex(color),
    });

  return (
    <SettingRow label={locale.labels.color}>
      <Stack align="center">
        <Stack.Item>
          <ColorSquares color={normalizeHex(settings.custom_color)} />
        </Stack.Item>
        <Stack.Item grow>
          <Box color="label">
            {settings.custom_color || locale.labels.defaultColor}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="palette"
            onClick={() =>
              act('pick_organ_color', {
                organ_id: organ.id,
              })
            }
          >
            {locale.labels.pickColor}
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            icon="undo"
            onClick={() =>
              act('set_organ_setting', {
                organ_id: organ.id,
                field: 'custom_color',
                value: '',
              })
            }
          >
            {locale.labels.reset}
          </Button>
        </Stack.Item>
      </Stack>
      <Stack mt={0.75} style={{ flexWrap: 'wrap' }}>
        {settings.color_presets.map((preset) => (
          <Stack.Item key={preset.id}>
            <Button
              selected={
                normalizeHex(preset.color) === normalizeHex(settings.custom_color)
              }
              onClick={() => applyColor(preset.color)}
            >
              <Box
                inline
                mr={0.5}
                style={{
                  width: '10px',
                  height: '10px',
                  backgroundColor: preset.color,
                  border: '1px solid rgba(255,255,255,0.3)',
                }}
              />
              {preset.name}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </SettingRow>
  );
};

const Preview = (props: {
  settings: OrganSettings;
  locale: HoleStatusLocale;
}) => {
  const { settings, locale } = props;
  const color = normalizeHex(settings.custom_color);
  const scale = settings.egg_scale || 1;
  return (
    <Box mb={1}>
      <Box bold color="label" mb={0.4}>
        {locale.labels.preview}
      </Box>
      <Stack align="center">
        <Stack.Item>
          <Box
            style={{
              width: `${28 * scale}px`,
              height: `${38 * scale}px`,
              backgroundColor: color,
              border: '2px solid rgba(255,255,255,0.25)',
              borderRadius: '50% 50% 45% 45%',
              boxShadow: 'inset -6px -8px 0 rgba(0,0,0,0.18)',
            }}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold>
            {settings.custom_name || resolveEggType(locale, settings.egg_type_name)}
          </Box>
          <Box color="label">
            {resolveEggType(locale, settings.egg_type_name)}
            {' | '}
            {locale.labels.scale}
            {': '}
            {Math.round(scale * 100)}%
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const EggDetail = (props: {
  act: any;
  egg: EggData;
  index: number;
  locale: HoleStatusLocale;
}) => {
  const { act, egg, index, locale } = props;
  const pct = egg.progress_pct;
  const sLabel = locale.formatStatus(egg.status, egg.time_left);
  const sColor = statusColor(egg.status);

  return (
    <Box
      mb={1}
      ml={1}
      style={{
        borderLeft: '2px solid rgba(255,255,255,0.15)',
        paddingLeft: '8px',
      }}
    >
      <Stack align="center">
        <Stack.Item grow>
          <Box bold>
            {index}. {egg.name} ({resolveEggType(locale, egg.type_name)})
          </Box>
        </Stack.Item>
        <Stack.Item>
          <ColorSquares color={egg.display_color} />
        </Stack.Item>
      </Stack>

      {egg.desc && (
        <Box color="label" fontSize="0.9em" style={{ whiteSpace: 'pre-wrap' }}>
          {egg.desc}
        </Box>
      )}

      <Stack>
        <Stack.Item grow>
          <Box color="label" fontSize="0.9em">
            {locale.labels.color}
            {': '}
            {egg.color_hex || locale.labels.defaultColor}
            {' | '}
            {locale.labels.scale}
            {': '}
            {Math.round((egg.scale || 1) * 100)}%
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box fontSize="0.9em">
            {locale.labels.stage} {egg.stage}/{egg.max_stage}
          </Box>
        </Stack.Item>
      </Stack>

      <Stack align="center" mt={0.3}>
        <Stack.Item grow>
          <ProgressBar
            value={pct}
            maxValue={100}
            ranges={{
              bad: [0, 25],
              average: [25, 75],
              good: [75, 100],
            }}
          />
        </Stack.Item>
        <Stack.Item ml={1}>
          <Box bold color={sColor} fontSize="0.9em">
            {sLabel}
          </Box>
        </Stack.Item>
      </Stack>

      {!!egg.traits?.length && (
        <Box fontSize="0.85em" color="label" mt={0.3}>
          {locale.labels.traits}
          {': '}
          {egg.traits.map((trait) => resolveTraitName(locale, trait)).join(', ')}
        </Box>
      )}
      <Box fontSize="0.85em" color="label" mt={0.3}>
        {locale.labels.mother}
        {': '}
        {egg.mother_name || locale.labels.unknown}
        {' | '}
        {locale.labels.father}
        {': '}
        {egg.father_name || locale.labels.unknown}
      </Box>
      {egg.has_preg && (
        <Box fontSize="0.85em" color={egg.fertilized ? 'average' : 'label'} mt={0.3}>
          <Icon name="heart" mr={0.5} />
          {egg.fertilized ? locale.labels.fertilized : locale.labels.unfertilized}
          {egg.father_name ? ` ${locale.labels.by} ${egg.father_name}` : ''}
        </Box>
      )}
      {egg.hatch && (
        <Box fontSize="0.85em" color="average" mt={0.2} italic>
          {formatHatch(locale, egg.hatch)}
        </Box>
      )}
      <Stack mt={0.5}>
        <Stack.Item>
          <Button
            icon="hand"
            disabled={!egg.can_remove}
            onClick={() => act('extract_egg', { egg_ref: egg.ref })}
          >
            {locale.labels.extract}
          </Button>
        </Stack.Item>
        {egg.can_retch && (
          <Stack.Item>
            <Button
              icon="arrow-up"
              onClick={() => act('retch_up', { ref: egg.ref })}
            >
              {locale.labels.retchUp}
            </Button>
          </Stack.Item>
        )}
      </Stack>
    </Box>
  );
};

const ColorSquares = (props: { color: string | null }) => {
  const { color } = props;
  if (!color) {
    return null;
  }
  return (
    <Stack>
      {[1, 0.65, 0.35].map((opacity, i) => (
        <Stack.Item key={i} mr={i < 2 ? 0.2 : 0}>
          <Box
            inline
            style={{
              width: '10px',
              height: '10px',
              backgroundColor: color,
              opacity,
              border: '1px solid rgba(255,255,255,0.15)',
            }}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};
