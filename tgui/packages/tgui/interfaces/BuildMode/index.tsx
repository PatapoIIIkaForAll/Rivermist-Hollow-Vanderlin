/**
 * Build Mode spawn catalogue (port of Ratwood 2.0 PR 123).
 *
 * Categories on the left, cards in the middle, placement settings for the picked type on the
 * right. Search, filters, paging, favourites and recents all live on the server, so they survive
 * closing the window and are saved between rounds.
 */
import { Button, DmIcon, Icon, Input, NumberInput, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';

type Flag = boolean | number;

type CatalogItem = {
  path: string;
  name: string;
  icon: string;
  icon_state: string;
  favorite: Flag;
  desc?: string;
  is_item?: Flag;
  is_turf?: Flag;
  unlisted?: Flag;
};

type Option = { id: string; name: string; count?: number };

type Data = {
  // static
  categories: Option[];
  counts: Record<string, number>;
  total: number;
  armor_classes: Option[];
  coverage_zones: Option[];
  max_amount: number;
  max_favorites: number;
  max_search_length: number;
  max_offset: number;
  // dynamic
  items: CatalogItem[];
  matches: number;
  page: number;
  pages: number;
  category: string;
  subcategory: string;
  subcategories: Option[];
  armor_class: string;
  coverage: string;
  search: string;
  favorites_count: number;
  recent_count: number;
  selected?: CatalogItem | null;
  amount: number;
  direction: number;
  pixel_x: number;
  pixel_y: number;
  mode: string;
  tool: string;
  tools_open: Flag;
  undo_count: number;
  undo_label?: string | null;
  rmb_delete: Flag;
  copying: Flag;
  placing: Flag;
  can_hands: Flag;
  status?: string | null;
};

const CATEGORY_ICONS: Record<string, string> = {
  all: 'th',
  favorites: 'star',
  recent: 'history',
  turfs: 'border-all',
  objects: 'chair',
  mobs: 'paw',
  items: 'box-open',
  weapons: 'khanda',
  clothing: 'tshirt',
  food: 'drumstick-bite',
  reagents: 'wine-bottle',
  effects: 'magic',
};

/** BYOND dir value, arrow, label; laid out as a 3x3 compass. 0 is the empty centre. */
const DIRECTIONS: [number, string, string][] = [
  [9, 'arrow-up', 'North-west'],
  [1, 'arrow-up', 'North'],
  [5, 'arrow-up', 'North-east'],
  [8, 'arrow-left', 'West'],
  [0, '', ''],
  [4, 'arrow-right', 'East'],
  [10, 'arrow-down', 'South-west'],
  [2, 'arrow-down', 'South'],
  [6, 'arrow-down', 'South-east'],
];

type Tool = {
  id: string;
  name: string;
  icon: string;
  /** Hotkey that does the same thing whatever tool is picked. */
  keys: string;
  tip: string;
  /** Footer hint while this tool is picked. */
  hint: string;
};

const TOOLS: Tool[] = [
  {
    id: 'place',
    name: 'Place',
    icon: 'plus-square',
    keys: 'LMB',
    tip: 'Left click places the selection on the tile you click.',
    hint: 'Left click: place the selection',
  },
  {
    id: 'pixel',
    name: 'Exact pixel',
    icon: 'crosshairs',
    keys: 'Shift+LMB',
    tip: 'Places the selection exactly under the cursor, not centred on the tile. Hold Shift to see where it lands.',
    hint: 'Left click: place at the exact pixel under the cursor',
  },
  {
    id: 'area',
    name: 'Paint area',
    icon: 'th',
    keys: 'MMB drag',
    tip: 'Hold the button on one corner and release on the opposite one: every tile in the rectangle gets the selection. Hold Ctrl while dragging to erase the rectangle instead.',
    hint: 'Hold left button on one corner, release on the other: fill the rectangle (Ctrl + drag: erase it)',
  },
  {
    id: 'erase',
    name: 'Erase area',
    icon: 'eraser',
    keys: 'Ctrl+MMB drag',
    tip: 'Drag a rectangle: objects and mindless mobs in it are deleted. Players, landmarks and turfs are kept. Also works as a left drag with Delete picked, or Ctrl + left drag with Paint area. Ctrl+Z brings them back.',
    hint: 'Hold left button on one corner, release on the other: delete objects in the rectangle',
  },
  {
    id: 'copy',
    name: 'Copy object',
    icon: 'clone',
    keys: 'Ctrl+LMB',
    tip: 'Click an object on the map: it becomes the selection and every placement is an exact copy, variables included.',
    hint: 'Left click an object: copy it exactly, then place copies',
  },
  {
    id: 'pick',
    name: 'Pick type',
    icon: 'eye-dropper',
    keys: 'Alt+LMB',
    tip: 'Click something on the map to select its type (a fresh instance, not a copy).',
    hint: 'Left click something on the map: select its type',
  },
  {
    id: 'delete',
    name: 'Delete',
    icon: 'trash',
    keys: 'Ctrl+RMB',
    tip: 'Left click deletes the clicked object, or strips the top layer of a turf. Drag over several tiles to erase every object in the rectangle. Players are never deleted. Ctrl + right click deletes one object at any time, even when right-click deleting is locked.',
    hint: 'Left click: delete the object, or strip the top turf layer · drag: erase a rectangle',
  },
];

const DIAGONAL_TURN: Record<number, number> = { 9: -45, 5: 45, 10: 45, 6: -45 };

const copyText = (text: string) => {
  const input = document.createElement('textarea');
  input.value = text;
  input.style.position = 'fixed';
  input.style.opacity = '0';
  document.body.appendChild(input);
  input.focus();
  input.select();
  document.execCommand('copy');
  input.remove();
};

const Sprite = (props: { item: CatalogItem; size: number; direction?: number }) => {
  const { item, size, direction } = props;
  const fallback = <Icon name="question" className="BuildCatalog__noSprite" />;
  if (!item.icon || !item.icon_state) {
    return fallback;
  }
  return (
    <DmIcon
      icon={item.icon}
      icon_state={item.icon_state}
      direction={direction}
      fallback={fallback}
      width={`${size}px`}
      height={`${size}px`}
    />
  );
};

const Sidebar = () => {
  const { act, data } = useBackend<Data>();
  const counts: Record<string, number> = {
    ...data.counts,
    all: data.total,
    favorites: data.favorites_count,
    recent: data.recent_count,
  };
  return (
    <div className="BuildCatalog__side">
      <div className="BuildCatalog__categories">
        {data.categories.map(({ id, name }) => (
          <div
            key={id}
            className={`BuildCatalog__nav${data.category === id ? ' BuildCatalog__nav--on' : ''}`}
            onClick={() => act('category', { value: id })}
          >
            <Icon name={CATEGORY_ICONS[id] || 'folder'} className="BuildCatalog__navIcon" />
            <span className="BuildCatalog__navName">{name}</span>
            <span className="BuildCatalog__count">{counts[id] || 0}</span>
          </div>
        ))}
      </div>
      <Tools />
      <Button
        fluid
        icon="undo"
        disabled={!data.undo_count}
        tooltip={data.undo_label ? `Undo: ${data.undo_label}` : 'Nothing to undo'}
        onClick={() => act('undo')}
      >
        Undo (Ctrl+Z){data.undo_count ? ` · ${data.undo_count}` : ''}
      </Button>
      <Button fluid icon="sign-out-alt" onClick={() => act('quit')}>
        Leave build mode
      </Button>
    </div>
  );
};

const Tools = () => {
  const { act, data } = useBackend<Data>();
  const basic = data.mode === 'Basic';
  const open = !!data.tools_open;
  const rmbDelete = !!data.rmb_delete;
  const current = TOOLS.find((tool) => tool.id === data.tool)?.name || 'Place';
  return (
    <div className={`BuildCatalog__tools${open ? '' : ' BuildCatalog__tools--closed'}`}>
      <div
        className="BuildCatalog__toolsHead"
        onClick={() => act('toggle_tools')}
        title={open ? 'Fold the tools' : 'Unfold the tools'}
      >
        <Icon name={open ? 'chevron-down' : 'chevron-right'} />
        <Icon name="tools" /> Tools
        {!open && <span className="BuildCatalog__toolsCurrent">{current}</span>}
        {open && (
          <Tooltip
            content="Click a tool to make it what a plain left click does. The key on the right works at any time, whatever tool is picked."
            position="right"
          >
            <Icon name="question-circle" className="BuildCatalog__toolsHelp" />
          </Tooltip>
        )}
      </div>
      {open && (
        <>
          {!basic && (
            <div className="BuildCatalog__toolsNote">
              {data.mode} mode is on. Picking a tool switches back to Basic.
            </div>
          )}
          {TOOLS.map((tool) => (
            <Tooltip key={tool.id} content={tool.tip} position="right">
              <div
                className={`BuildCatalog__tool${basic && data.tool === tool.id ? ' BuildCatalog__tool--on' : ''}`}
                onClick={() => act('tool', { value: tool.id })}
              >
                <Icon name={tool.icon} className="BuildCatalog__navIcon" />
                <span className="BuildCatalog__toolName">{tool.name}</span>
                <span className="BuildCatalog__kbd">{tool.keys}</span>
              </div>
            </Tooltip>
          ))}
          <Tooltip
            content="On: with nothing selected, a right click deletes what you click. Locked: a right click only clears the selection, so a stray click never deletes. Ctrl + right click always deletes."
            position="right"
          >
            <div className={`BuildCatalog__delete${rmbDelete ? '' : ' BuildCatalog__delete--locked'}`}>
              <Icon name={rmbDelete ? 'unlock' : 'lock'} className="BuildCatalog__navIcon" />
              <span className="BuildCatalog__toolName">RMB delete</span>
              <div className="BuildCatalog__switch">
                <span
                  className={rmbDelete ? 'BuildCatalog__switch--on' : ''}
                  onClick={() => act('rmb_delete', { value: true })}
                >
                  On
                </span>
                <span
                  className={rmbDelete ? '' : 'BuildCatalog__switch--on'}
                  onClick={() => act('rmb_delete', { value: false })}
                >
                  Locked
                </span>
              </div>
            </div>
          </Tooltip>
          <div className="BuildCatalog__toolsExtra">
            <div>
              <span className="BuildCatalog__kbd">RMB</span>{' '}
              {rmbDelete ? 'clear selection, then delete' : 'clear selection only'}
            </div>
            <div className="BuildCatalog__toolsRotate" onClick={() => act('rotate')}>
              <span className="BuildCatalog__kbd">Alt+RMB</span> rotate direction
            </div>
          </div>
        </>
      )}
    </div>
  );
};

const Chips = (props: {
  options: Option[];
  selected: string;
  action: string;
}) => {
  const { act } = useBackend<Data>();
  return (
    <div className="BuildCatalog__chips">
      {props.options.map(({ id, name, count }) => (
        <Button
          key={id}
          selected={props.selected === id}
          onClick={() => act(props.action, { value: id })}
        >
          {name}
          {count !== undefined && <span className="BuildCatalog__chipCount">{count}</span>}
        </Button>
      ))}
    </div>
  );
};

const Pager = () => {
  const { act, data } = useBackend<Data>();
  return (
    <div className="BuildCatalog__pager">
      <span className="BuildCatalog__found">{data.matches} found</span>
      <Button
        icon="angle-double-left"
        tooltip="First page"
        disabled={data.page <= 1}
        onClick={() => act('page', { value: 1 })}
      />
      <Button
        icon="chevron-left"
        disabled={data.page <= 1}
        onClick={() => act('page', { value: data.page - 1 })}
      />
      <NumberInput
        value={data.page}
        minValue={1}
        maxValue={data.pages}
        step={1}
        width="46px"
        onChange={(value) => act('page', { value })}
      />
      <span>/ {data.pages}</span>
      <Button
        icon="chevron-right"
        disabled={data.page >= data.pages}
        onClick={() => act('page', { value: data.page + 1 })}
      />
      <Button
        icon="angle-double-right"
        tooltip="Last page"
        disabled={data.page >= data.pages}
        onClick={() => act('page', { value: data.pages })}
      />
    </div>
  );
};

const Browser = () => {
  const { act, data } = useBackend<Data>();
  const selectedPath = data.selected?.path;
  const emptyText =
    data.category === 'favorites'
      ? 'No favourites yet. Press the star on a card to keep it here.'
      : data.category === 'recent'
        ? 'Nothing picked yet.'
        : 'Nothing matches.';
  return (
    <div className="BuildCatalog__content">
      <div className="BuildCatalog__bar">
        <Icon name="search" className="BuildCatalog__searchIcon" />
        <Input
          className="BuildCatalog__search"
          fluid
          autoFocus
          expensive
          maxLength={data.max_search_length}
          value={data.search}
          placeholder="Search by name or /type/path..."
          onChange={(value) => act('search', { value })}
          onEnter={(value) => act('search', { value })}
        />
        {!!data.search && (
          <Button
            icon="times"
            tooltip="Clear search"
            onClick={() => act('search', { value: '' })}
          />
        )}
      </div>
      {data.subcategories?.length > 1 && (
        <Chips options={data.subcategories} selected={data.subcategory} action="subcategory" />
      )}
      {data.category === 'clothing' && (
        <>
          <Chips options={data.armor_classes} selected={data.armor_class} action="armor_class" />
          <Chips options={data.coverage_zones} selected={data.coverage} action="coverage" />
        </>
      )}
      <div
        className="BuildCatalog__scroll"
        key={`${data.category}:${data.subcategory}:${data.armor_class}:${data.coverage}:${data.page}:${data.search}`}
      >
        {data.items.length > 0 ? (
          <div className="BuildCatalog__grid">
            {data.items.map((item) => (
              <Tooltip key={item.path} content={item.path} position="bottom">
                <div
                  className={`BuildCatalog__card${selectedPath === item.path ? ' BuildCatalog__card--on' : ''}`}
                  onClick={() => act('select', { path: item.path })}
                >
                  <div className="BuildCatalog__sprite">
                    <Sprite item={item} size={56} />
                  </div>
                  <div className="BuildCatalog__name">{item.name}</div>
                  <div className="BuildCatalog__variant">
                    {item.path.split('/').slice(-2).join('/')}
                  </div>
                  <div
                    className={`BuildCatalog__star${item.favorite ? ' BuildCatalog__star--on' : ''}`}
                    onClick={(event) => {
                      event.stopPropagation();
                      act('favorite', { path: item.path });
                    }}
                  >
                    <Icon name="star" />
                  </div>
                </div>
              </Tooltip>
            ))}
          </div>
        ) : (
          <div className="BuildCatalog__empty">
            {emptyText}
            {!!data.search && data.category !== 'all' && (
              <div>
                <Button mt={1} icon="search" onClick={() => act('category', { value: 'all' })}>
                  Search everything
                </Button>
              </div>
            )}
          </div>
        )}
      </div>
      <Pager />
    </div>
  );
};

const Inspector = () => {
  const { act, data } = useBackend<Data>();
  const selected = data.selected;
  if (!selected) {
    return (
      <div className="BuildCatalog__inspector">
        <div className="BuildCatalog__empty">
          <Icon name="hand-pointer" size={2.5} />
          <div>Pick a card, or Alt + left click something on the map to take its type.</div>
        </div>
      </div>
    );
  }
  const isTurf = !!selected.is_turf;
  return (
    <div className="BuildCatalog__inspector">
      <div className="BuildCatalog__preview">
        <Sprite item={selected} size={80} direction={data.direction} />
      </div>
      <div className="BuildCatalog__selName">{selected.name}</div>
      {!!data.copying && (
        <div className="BuildCatalog__copying">
          <Icon name="clone" /> Exact copy of the object you clicked, variables included.
        </div>
      )}
      {!!selected.desc && <div className="BuildCatalog__desc">{selected.desc}</div>}
      <div className="BuildCatalog__path">{selected.path}</div>
      <div className="BuildCatalog__row">
        <Button
          fluid
          icon="star"
          selected={!!selected.favorite}
          disabled={!!selected.unlisted}
          tooltip={selected.unlisted ? 'This type is not listed in the catalogue' : undefined}
          onClick={() => act('favorite', { path: selected.path })}
        >
          {selected.favorite ? 'In favourites' : 'Add to favourites'}
        </Button>
        <Button icon="copy" tooltip="Copy the type path" onClick={() => copyText(selected.path)} />
      </div>

      <div className="BuildCatalog__head">Placement</div>
      <div className="BuildCatalog__field">
        <span>Amount</span>
        <NumberInput
          width="64px"
          value={isTurf ? 1 : data.amount}
          disabled={isTurf}
          minValue={1}
          maxValue={data.max_amount}
          step={1}
          onChange={(value) => act('amount', { value })}
        />
      </div>
      <div className="BuildCatalog__compass">
        {DIRECTIONS.map(([value, icon, label]) =>
          value ? (
            <Button
              key={value}
              tooltip={label}
              selected={data.direction === value}
              onClick={() => act('direction', { value })}
            >
              <Icon name={icon} rotation={DIAGONAL_TURN[value] || 0} />
            </Button>
          ) : (
            <span key="centre" />
          ),
        )}
      </div>
      {!isTurf && (
        <div className="BuildCatalog__field">
          <span>Offset</span>
          {(['x', 'y'] as const).map((axis) => (
            <NumberInput
              key={axis}
              width="62px"
              value={axis === 'x' ? data.pixel_x : data.pixel_y}
              minValue={-data.max_offset}
              maxValue={data.max_offset}
              step={1}
              unit={axis.toUpperCase()}
              onChange={(value) => act(`pixel_${axis}`, { value })}
            />
          ))}
        </div>
      )}
      <Button fluid color="transparent" icon="undo" onClick={() => act('reset')}>
        Reset placement
      </Button>

      <div className="BuildCatalog__head">Spawn</div>
      <Button fluid icon="map-marker-alt" onClick={() => act('spawn_here')}>
        At my feet
      </Button>
      {!!selected.is_item && (
        <Button
          fluid
          icon="hand-paper"
          disabled={!data.can_hands}
          tooltip="Falls to the ground when your hands are full"
          onClick={() => act('spawn_hands')}
        >
          Into my hands
        </Button>
      )}
      <Button fluid color="transparent" icon="times" onClick={() => act('cancel')}>
        Clear selection
      </Button>
    </div>
  );
};

export const BuildMode = () => {
  const { data } = useBackend<Data>();
  let hint: string;
  if (data.mode !== 'Basic') {
    hint = `${data.mode} mode is active: see the ? button for its controls. The selection is shared.`;
  } else {
    const tool = TOOLS.find((entry) => entry.id === data.tool) || TOOLS[0];
    hint = `${tool.name}: ${tool.hint} · RMB: ${
      data.rmb_delete ? 'clear the selection, then delete' : 'clear the selection (deleting locked)'
    }`;
    if (data.copying) {
      hint += ' · copying an exact object';
    }
  }
  return (
    <Window title="Build Mode" width={1120} height={740} theme="vanderlin" rememberSize>
      <Window.Content>
        <div className="BuildCatalog">
          <div className="BuildCatalog__main">
            <Sidebar />
            <Browser />
            <Inspector />
          </div>
          <div className={`BuildCatalog__footer${data.status ? ' BuildCatalog__footer--status' : ''}`}>
            <Icon name={data.status ? 'info-circle' : 'mouse'} /> {data.status || hint}
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
