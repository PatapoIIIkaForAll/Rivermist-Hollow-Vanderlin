import { type ReactNode, useMemo, useRef, useState } from 'react';
import { Box, Icon } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Btn, Frame, Select, Swatch, Tip } from './CharacterCreator';
import {
  type CharacterCreatorStrings,
  characterCreatorStrings,
} from './CharacterCreator.i18n';

// Loadout tab of the Character Creator (modular_rmh/modular/character_creator).
// Items: pick up to 10 loadout items. Equip Items: wear them in paper doll slots.
// Stash: items left unworn wait in the stash or, if marked, go into the bags.

type Booleanish = boolean | number;

type ItemInfo = {
  desc?: string;
  weight?: number;
  armorClassLabel?: string;
  weaponDamage?: { force: number };
  weaponCategory?: string;
  intents?: { name: string; grip: string }[];
  specialAttack?: { name: string; desc: string };
  tags?: string[];
};

type CatalogItem = {
  name: string;
  desc: string;
  point_cost: number;
  typepath: string;
  icon: string;
  category: string;
  fits: string[];
  info: ItemInfo;
};

type LoadoutSlot = {
  slot: number;
  item_name: string | null;
  typepath: string | null;
  point_cost: number;
  custom_name: string | null;
  custom_desc: string | null;
  custom_hex: string | null;
};

type Preset = {
  slot: number;
  name: string | null;
  role: string | null;
  empty: Booleanish;
  summary: string;
};

type LoadoutState = {
  slots: LoadoutSlot[];
  points: { total: number; spent: number; remaining: number };
  presets: Preset[];
  equip: Record<string, string>;
  bag: string[];
};

/** Keys of the Character Creator data this panel reads. */
type LoadoutPanelData = {
  cc_lang?: string;
  cc_loadout_catalog?: CatalogItem[];
  cc_loadout_roles?: string[];
  cc_loadout_locked?: string[];
  cc_loadout?: LoadoutState;
};

type Page = 'items' | 'equip' | 'stash';

/** Shared fallbacks keep memoized lookups stable while data is missing. */
const NO_ITEMS: CatalogItem[] = [];
const NO_PATHS: string[] = [];

const CATEGORIES = [
  'all',
  'head',
  'face',
  'accessories',
  'cloaks',
  'armor',
  'clothing',
  'weapons',
  'misc',
];

/** Catalog tiles per page; drawing all 1000+ items at once makes scrolling lag. */
const ITEMS_PER_PAGE = 48;

/** Paper doll layout from the plan, three columns. */
const DOLL: string[] = [
  'mask',
  'head',
  'mouth',
  'backr',
  'cloak',
  'backl',
  'neck',
  'armor',
  'wrists',
  'ring',
  'shirt',
  'gloves',
  'beltr',
  'belt',
  'beltl',
  'rhand',
  'pants',
  'lhand',
  'undies',
  'shoes',
  'piercing',
];
const UNDIES = [
  'under_top',
  'under_bottom',
  'undershirt',
  'socks',
  'garter',
  'armsleeves',
];
const PIERCINGS = ['earring_l', 'earring_r', 'choker'];
const HANDS = ['rhand', 'lhand'];

const iconBox = (item: CatalogItem | undefined, small?: boolean) => (
  <div className={`ccl-icon ${small ? 'small' : ''}`}>
    {item?.icon ? <Box className={item.icon} /> : <Icon name="box" />}
  </div>
);

/** Tooltip body shaped like the Examine Closer item tooltip. */
const itemTipBody = (
  item: CatalogItem,
  L: CharacterCreatorStrings,
  custom?: LoadoutSlot,
) => {
  const info = item.info || {};
  return (
    <>
      {info.weaponDamage ? (
        <div className="ccl-tip-damage">
          {info.weaponDamage.force} {L.damage}
        </div>
      ) : null}
      {info.intents?.length ? (
        <div className="ccl-tip-line ccl-tip-meta">
          <Icon name="award" mr={0.5} />
          {info.intents.map((intent) => intent.name.toUpperCase()).join(' · ')}
        </div>
      ) : null}
      <div className="ccl-tip-line">
        {custom?.custom_desc || info.desc || item.desc}
      </div>
      {info.armorClassLabel || info.weaponCategory || info.tags?.length ? (
        <div className="ccl-tip-line ccl-tip-meta">
          {[info.armorClassLabel, info.weaponCategory, ...(info.tags || [])]
            .filter(Boolean)
            .join(' · ')}
        </div>
      ) : null}
      {info.specialAttack ? (
        <div className="ccl-tip-line" style={{ color: '#c9a76f' }}>
          <Icon name="burst" mr={0.5} />
          {info.specialAttack.name}: {info.specialAttack.desc}
        </div>
      ) : null}
      <div className="ccl-tip-line cc-muted">
        {L.cost}: {item.point_cost} {L.points}
        {info.weight ? ` · ${L.weight}: ${info.weight}` : ''}
      </div>
      {custom?.custom_hex ? (
        <div className="ccl-tip-line">
          <Swatch color={custom.custom_hex} /> {L.dyed}
        </div>
      ) : null}
    </>
  );
};

export const LoadoutPanel = () => {
  const { act, data } = useBackend<LoadoutPanelData>();
  const L = characterCreatorStrings[data.cc_lang === 'ru' ? 'ru' : 'en'];
  const [page, setPage] = useState<Page>('items');
  const [category, setCategory] = useState('all');
  const [search, setSearch] = useState('');
  const [itemPage, setItemPage] = useState(0);
  const itemsScrollRef = useRef<HTMLDivElement>(null);
  const [presetSlot, setPresetSlot] = useState(1);
  const [activeSlot, setActiveSlot] = useState<string | null>(null);
  const [miniWindow, setMiniWindow] = useState<'undies' | 'piercing' | null>(
    null,
  );

  const catalog = data.cc_loadout_catalog || NO_ITEMS;
  const lockedPaths = data.cc_loadout_locked || NO_PATHS;
  const roles = data.cc_loadout_roles || NO_PATHS;
  const loadout = data.cc_loadout;
  const slots = loadout?.slots || [];
  const equip = loadout?.equip || {};
  const bag = loadout?.bag || [];
  const points = loadout?.points || { total: 0, spent: 0, remaining: 0 };
  const presets = loadout?.presets || [];
  // The catalog is static data, so these lookups survive the frequent data pushes.
  const byPath = useMemo(
    () => new Map(catalog.map((item) => [item.typepath, item])),
    [catalog],
  );
  const locked = useMemo(() => new Set(lockedPaths), [lockedPaths]);
  const chosen = slots.filter((slot) => slot.typepath);
  const firstEmpty = slots.find((slot) => !slot.typepath)?.slot;
  const loadoutAct = (task: string, extra?: Record<string, unknown>) =>
    act('cc_loadout', { task, ...(extra || {}) });

  const slotOfEquip = (slotId: string) =>
    chosen.find((slot) => equip[String(slot.slot)] === slotId);
  const fitsSlot = (slot: LoadoutSlot, slotId: string) => {
    if (HANDS.includes(slotId)) {
      return true;
    }
    return !!byPath.get(slot.typepath || '')?.fits?.includes(slotId);
  };
  const unequipped = chosen.filter((slot) => !equip[String(slot.slot)]);

  const itemName = (slot: LoadoutSlot) =>
    slot.custom_name || slot.item_name || '';

  // ---- Items page ----

  const renderChosenList = () => (
    <div className="cc-scroll" style={{ flex: 1, minHeight: 0 }}>
      {chosen.length ? (
        chosen.map((slot) => {
          const item = byPath.get(slot.typepath || '');
          return (
            <div className="ccl-slot-card" key={slot.slot}>
              <div className="cc-row" style={{ marginBottom: 4 }}>
                {item ? (
                  <Tip
                    title={itemName(slot)}
                    subtitle={L.loadoutCategories[item.category]}
                    body={itemTipBody(item, L, slot)}
                  >
                    {iconBox(item, true)}
                  </Tip>
                ) : null}
                <div className="cc-grow" style={{ fontWeight: 'bold' }}>
                  {itemName(slot)}
                </div>
                <span className="cc-muted">{slot.point_cost}</span>
              </div>
              <div className="cc-row" style={{ flexWrap: 'wrap' }}>
                <Btn
                  icon="pen"
                  onClick={() => loadoutAct('rename', { slot: slot.slot })}
                >
                  {L.rename}
                </Btn>
                <Btn
                  icon="align-left"
                  onClick={() => loadoutAct('describe', { slot: slot.slot })}
                >
                  {L.describe}
                </Btn>
                <Btn
                  icon="palette"
                  onClick={() => act('cc_loadout_dye', { slot: slot.slot })}
                >
                  {slot.custom_hex ? <Swatch color={slot.custom_hex} /> : null}
                  {L.color}
                </Btn>
                <Btn
                  icon="times"
                  className="danger"
                  onClick={() => loadoutAct('clear', { slot: slot.slot })}
                >
                  {L.remove}
                </Btn>
              </div>
            </div>
          );
        })
      ) : (
        <div className="cc-hint">{L.noLoadout}</div>
      )}
    </div>
  );

  const renderItemsPage = () => {
    const lowered = search.trim().toLowerCase();
    // Searching looks through every item, whatever category is open.
    const shown = catalog.filter((item) =>
      lowered
        ? item.name.toLowerCase().includes(lowered) ||
          (item.desc || '').toLowerCase().includes(lowered)
        : category === 'all' || item.category === category,
    );
    const pageCount = Math.max(1, Math.ceil(shown.length / ITEMS_PER_PAGE));
    const currentPage = Math.min(itemPage, pageCount - 1);
    const isFirstPage = currentPage === 0;
    const isLastPage = currentPage === pageCount - 1;
    const pageItems = shown.slice(
      currentPage * ITEMS_PER_PAGE,
      (currentPage + 1) * ITEMS_PER_PAGE,
    );
    const goToPage = (next: number) => {
      setItemPage(next);
      if (itemsScrollRef.current) {
        itemsScrollRef.current.scrollTop = 0;
      }
    };
    return (
      <div className="ccl-body">
        <Frame className="ccl-pane">{renderChosenList()}</Frame>
        <Frame className="ccl-pane">
          {pageCount > 1 ? (
            <div className="ccl-pager">
              <Btn
                className="square"
                icon="angle-double-left"
                title={L.firstPage}
                disabled={isFirstPage}
                onClick={() => goToPage(0)}
              />
              <Btn
                icon="angle-left"
                disabled={isFirstPage}
                onClick={() => goToPage(currentPage - 1)}
              >
                {L.prevPage}
              </Btn>
              <div className="ccl-page">
                {L.page} {currentPage + 1} / {pageCount}
              </div>
              <Btn
                disabled={isLastPage}
                onClick={() => goToPage(currentPage + 1)}
              >
                {L.nextPage}
                <Icon name="angle-right" />
              </Btn>
              <Btn
                className="square"
                icon="angle-double-right"
                title={L.lastPage}
                disabled={isLastPage}
                onClick={() => goToPage(pageCount - 1)}
              />
            </div>
          ) : null}
          <div
            className="cc-scroll"
            ref={itemsScrollRef}
            style={{ flex: 1, minHeight: 0 }}
          >
            <div className="ccl-items">
              {pageItems.map((item) => {
                const chosenSlot = chosen.find(
                  (slot) => slot.typepath === item.typepath,
                );
                const blocked =
                  locked.has(item.typepath) ||
                  (!chosenSlot &&
                    (item.point_cost > points.remaining || !firstEmpty));
                return (
                  <Tip
                    key={item.typepath}
                    className={`ccl-item ${chosenSlot ? 'chosen' : ''} ${blocked ? 'blocked' : ''}`}
                    title={item.name}
                    subtitle={L.loadoutCategories[item.category]}
                    body={itemTipBody(item, L)}
                    onClick={() => {
                      if (chosenSlot) {
                        loadoutAct('clear', { slot: chosenSlot.slot });
                      } else if (!blocked && firstEmpty) {
                        loadoutAct('select', {
                          slot: firstEmpty,
                          typepath: item.typepath,
                        });
                      }
                    }}
                  >
                    <span className="ccl-cost">{item.point_cost}</span>
                    {iconBox(item)}
                    <div className="ccl-name">{item.name}</div>
                  </Tip>
                );
              })}
            </div>
            {!shown.length ? (
              <div className="cc-hint">{L.noMatches}</div>
            ) : null}
          </div>
        </Frame>
      </div>
    );
  };

  // ---- Equip page ----

  const renderEquipSlot = (slotId: string) => {
    if (slotId === 'undies' || slotId === 'piercing') {
      const subs = slotId === 'undies' ? UNDIES : PIERCINGS;
      const worn = subs.filter((sub) => slotOfEquip(sub)).length;
      return (
        <div
          key={slotId}
          className={`ccl-eq ${miniWindow === slotId ? 'active' : ''}`}
          onClick={() => {
            setMiniWindow(slotId);
            setActiveSlot(null);
          }}
        >
          <span className="ccl-eq-label">{L.equipSlots[slotId]}</span>
          <Icon name={slotId === 'undies' ? 'tshirt' : 'ring'} size={1.5} />
          {worn ? <span className="ccl-eq-count">{worn}</span> : null}
        </div>
      );
    }
    const worn = slotOfEquip(slotId);
    const wornItem = worn ? byPath.get(worn.typepath || '') : undefined;
    const fitCount = unequipped.filter((slot) => fitsSlot(slot, slotId)).length;
    const body = (
      <>
        {wornItem ? (
          <span className="ccl-eq-label">{L.equipSlots[slotId]}</span>
        ) : null}
        {wornItem ? (
          iconBox(wornItem, true)
        ) : (
          <span style={{ opacity: 0.6 }}>{L.equipSlots[slotId]}</span>
        )}
        {wornItem ? <span className="ccl-eq-tag">EQ</span> : null}
        {!wornItem && fitCount ? (
          <span className="ccl-eq-count">{fitCount}</span>
        ) : null}
        {wornItem && worn?.custom_hex ? (
          <span className="ccl-eq-tagl">
            <Swatch color={worn.custom_hex} />
          </span>
        ) : null}
      </>
    );
    const className = `ccl-eq ${fitCount ? 'has-fit' : ''} ${activeSlot === slotId ? 'active' : ''}`;
    const open = () => setActiveSlot(activeSlot === slotId ? null : slotId);
    return wornItem && worn ? (
      <Tip
        key={slotId}
        className={className}
        title={itemName(worn)}
        subtitle={`${L.equipSlots[slotId]} · ${L.equipped}`}
        body={
          <>
            {itemTipBody(wornItem, L, worn)}
            <div className="ccl-tip-line cc-muted">{L.equipMouseHint}</div>
          </>
        }
        onClick={open}
      >
        <div
          style={{ position: 'absolute', inset: 0 }}
          onContextMenu={(event) => {
            event.preventDefault();
            act('cc_loadout_dye', { slot: worn.slot });
          }}
        />
        {body}
      </Tip>
    ) : (
      <div key={slotId} className={className} onClick={open}>
        {body}
      </div>
    );
  };

  const renderSlotPopup = () => {
    if (!activeSlot) {
      return null;
    }
    const worn = slotOfEquip(activeSlot);
    const options = unequipped.filter((slot) => fitsSlot(slot, activeSlot));
    return (
      <div className="ccl-pop">
        <div className="ccl-pop-head">
          <div className="cc-grow">
            <div className="ccl-pop-title">{L.equipSlots[activeSlot]}</div>
            <div className="cc-muted" style={{ fontSize: 11 }}>
              {options.length} {L.compatibleItems}
            </div>
          </div>
          <Btn
            disabled={!worn}
            onClick={() =>
              worn && act('cc_loadout_equip', { slot: worn.slot, equip: null })
            }
          >
            {L.clearSlot}
          </Btn>
          <Btn onClick={() => setActiveSlot(null)}>{L.close}</Btn>
        </div>
        <div className="cc-scroll" style={{ minHeight: 0 }}>
          <div className="ccl-pop-grid">
            {[...(worn ? [worn] : []), ...options].map((slot) => {
              const item = byPath.get(slot.typepath || '');
              if (!item) {
                return null;
              }
              const isWorn = slot === worn;
              return (
                <Tip
                  key={slot.slot}
                  className={`ccl-item ${isWorn ? 'chosen' : ''}`}
                  title={itemName(slot)}
                  subtitle={isWorn ? L.equipped : L.inBackpack}
                  body={itemTipBody(item, L, slot)}
                  onClick={() => {
                    if (!isWorn) {
                      act('cc_loadout_equip', {
                        slot: slot.slot,
                        equip: activeSlot,
                      });
                    }
                    setActiveSlot(null);
                  }}
                >
                  {iconBox(item)}
                  <div className="ccl-name">{itemName(slot)}</div>
                </Tip>
              );
            })}
          </div>
        </div>
        <div className="cc-hint">{L.equipPopupHint}</div>
      </div>
    );
  };

  const renderMiniWindow = () => {
    if (!miniWindow) {
      return null;
    }
    const subs = miniWindow === 'undies' ? UNDIES : PIERCINGS;
    return (
      <div className="ccl-pop" style={{ top: 'auto', bottom: 8 }}>
        <div className="ccl-pop-head">
          <div className="ccl-pop-title cc-grow">
            {L.equipSlots[miniWindow]}
          </div>
          <Btn onClick={() => setMiniWindow(null)}>{L.close}</Btn>
        </div>
        <div className="ccl-mini">{subs.map(renderEquipSlot)}</div>
      </div>
    );
  };

  const selectedPreset = presets.find((preset) => preset.slot === presetSlot);

  const roleOptions = [
    { value: '', label: L.anyRole },
    ...roles.map((role) => ({ value: role, label: role })),
  ];
  const setPresetRole = (value: string) =>
    act('cc_loadout_preset_role', { preset: presetSlot, role: value || null });

  const renderEquipPage = () => (
    <div className="ccl-body equip">
      <Frame className="ccl-pane" style={{ padding: 0 }}>
        <div className="ccl-doll cc-scroll">
          {DOLL.map(renderEquipSlot)}
          {renderSlotPopup()}
          {renderMiniWindow()}
        </div>
      </Frame>
      <Frame className="ccl-pane">
        <div className="cc-row" style={{ marginBottom: 8 }}>
          <Select
            value={selectedPreset?.role || ''}
            placeholder={L.chooseRole}
            options={roleOptions}
            onChange={setPresetRole}
          />
          <Btn
            className="square primary"
            icon="save"
            title={L.saveForRole}
            onClick={() => loadoutAct('preset_save', { slot: presetSlot })}
          />
        </div>
        <div className="cc-hint" style={{ textAlign: 'left' }}>
          {L.equipHint}
        </div>
        <div className="cc-scroll" style={{ flex: 1, minHeight: 0 }}>
          {unequipped.length ? (
            unequipped.map((slot) => {
              const item = byPath.get(slot.typepath || '');
              return (
                <div className="ccl-row-item" key={slot.slot}>
                  {item ? (
                    <Tip
                      title={itemName(slot)}
                      subtitle={L.loadoutCategories[item.category]}
                      body={itemTipBody(item, L, slot)}
                    >
                      {iconBox(item, true)}
                    </Tip>
                  ) : null}
                  <div className="cc-grow">
                    <div style={{ fontWeight: 'bold' }}>{itemName(slot)}</div>
                    <div className="cc-muted" style={{ fontSize: 10 }}>
                      {(item?.fits || [])
                        .map((fit) => L.equipSlots[fit])
                        .filter(Boolean)
                        .join(', ') || L.handsOnly}
                    </div>
                  </div>
                </div>
              );
            })
          ) : (
            <div className="cc-hint">{L.allEquipped}</div>
          )}
        </div>
      </Frame>
    </div>
  );

  // ---- Stash page ----

  const renderStashPage = () => (
    <Frame className="ccl-pane">
      <div className="cc-hint">{L.stashHint}</div>
      <div className="cc-scroll" style={{ flex: 1, minHeight: 0 }}>
        <div className="ccl-items">
          {unequipped.map((slot) => {
            const item = byPath.get(slot.typepath || '');
            if (!item) {
              return null;
            }
            const inBag = bag.includes(String(slot.slot));
            return (
              <Tip
                key={slot.slot}
                className={`ccl-item ${inBag ? 'chosen' : ''}`}
                title={itemName(slot)}
                subtitle={inBag ? L.goesToBags : L.goesToStash}
                body={
                  <>
                    {itemTipBody(item, L, slot)}
                    <div className="ccl-tip-line cc-muted">
                      {L.bagToggleHint}
                    </div>
                  </>
                }
                onClick={() => act('cc_loadout_bag', { slot: slot.slot })}
              >
                <span className="ccl-cost">
                  <Icon name={inBag ? 'shopping-bag' : 'archive'} />
                </span>
                {iconBox(item)}
                <div className="ccl-name">{itemName(slot)}</div>
              </Tip>
            );
          })}
        </div>
        {!unequipped.length ? (
          <div className="cc-hint">{L.allEquipped}</div>
        ) : null}
      </div>
    </Frame>
  );

  let body: ReactNode;
  if (page === 'equip') {
    body = renderEquipPage();
  } else if (page === 'stash') {
    body = renderStashPage();
  } else {
    body = renderItemsPage();
  }

  const presetLabel = (preset: Preset) =>
    `${preset.name || `${L.preset} ${preset.slot}`}${preset.role ? ` · ${preset.role}` : ''}${preset.empty ? ` (${L.empty})` : ''}`;

  return (
    <div className="ccl">
      <div className="ccl-head">
        <div className="ccl-title">{L.loadoutTitle}</div>
        {page === 'items' ? (
          <>
            <Select
              value={category}
              style={{ width: 170, flexShrink: 0 }}
              options={CATEGORIES.map((entry) => ({
                value: entry,
                label: L.loadoutCategories[entry],
              }))}
              onChange={(value) => {
                setCategory(value);
                setItemPage(0);
              }}
            />
            <div className="cc-search">
              <Icon className="cc-search-icon" name="search" />
              <input
                value={search}
                placeholder={L.searchItems}
                onChange={(event) => {
                  setSearch(event.target.value);
                  setItemPage(0);
                }}
              />
            </div>
          </>
        ) : (
          <div className="cc-grow" />
        )}
        <div className="ccl-title">
          {points.spent} / {points.total} {L.points}
        </div>
      </div>
      <div className="ccl-main">{body}</div>
      <div className="ccl-foot">
        <div className="ccl-foot-presets">
          <Select
            value={String(presetSlot)}
            style={{ flex: '1 1 220px', minWidth: 120, maxWidth: 260 }}
            options={presets.map((preset) => ({
              value: String(preset.slot),
              label: presetLabel(preset),
            }))}
            onChange={(value) => {
              setPresetSlot(Number(value));
              const preset = presets.find(
                (entry) => entry.slot === Number(value),
              );
              if (preset && !preset.empty) {
                loadoutAct('preset_load', { slot: Number(value) });
              }
            }}
          />
          {page === 'items' ? (
            <Select
              value={selectedPreset?.role || ''}
              placeholder={L.chooseRole}
              style={{ flex: '1 1 170px', minWidth: 110, maxWidth: 200 }}
              options={roleOptions}
              onChange={setPresetRole}
            />
          ) : null}
          <Btn
            icon="pen"
            disabled={!!selectedPreset?.empty}
            title={selectedPreset?.empty ? L.saveFirst : undefined}
            onClick={() =>
              act('cc_loadout_preset_rename', { preset: presetSlot })
            }
          >
            {L.rename}
          </Btn>
          <Btn
            icon="save"
            onClick={() => loadoutAct('preset_save', { slot: presetSlot })}
          >
            {L.save}
          </Btn>
          <Btn
            icon="undo"
            title={L.undoPresetHint}
            disabled={!!selectedPreset?.empty}
            onClick={() => loadoutAct('preset_load', { slot: presetSlot })}
          >
            {L.undo}
          </Btn>
          <Btn
            icon="trash"
            className="danger"
            title={L.clearAllHint}
            onClick={() => act('cc_loadout_clear_all')}
          >
            {L.clear}
          </Btn>
        </div>
        <div className="ccl-foot-pages">
          {page !== 'items' ? (
            <Btn icon="arrow-left" onClick={() => setPage('items')}>
              {L.back}
            </Btn>
          ) : null}
          {page !== 'equip' ? (
            <Btn className="on" icon="tshirt" onClick={() => setPage('equip')}>
              {L.equipItems}
            </Btn>
          ) : null}
          {page !== 'stash' ? (
            <Btn
              className="on"
              icon="archive"
              onClick={() => setPage('stash')}
            >
              {L.checkStash}
            </Btn>
          ) : null}
        </div>
      </div>
    </div>
  );
};
