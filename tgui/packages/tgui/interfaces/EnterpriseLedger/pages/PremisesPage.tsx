import { useEffect, useRef, useState } from 'react';
import {
  Box,
  Button,
  ByondUi,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import { UI_INTERACTIVE } from '../../../constants';
import { getPurposeIcon, getPurposeLabel } from '../purposes';
import type { Data, FloorInfo, Locale, PageProps, RoomInfo } from '../types';

const LEGEND_WIDTH = '17em';
const LEGEND_HOVER_COLOR = 'rgba(255, 217, 160, 0.16)';
const HOVER_DELAY = 250;
const HOVER_BUDGET = 40;
const HOVER_BUDGET_WINDOW = 60000;
const ICON_PIXELS = 32;

const useHoverSender = (send: (id: number) => void) => {
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const sentId = useRef(0);
  const budget = useRef({ since: 0, used: 0 });

  useEffect(() => () => clearTimeout(timer.current), []);

  return (id: number) => {
    clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      if (sentId.current === id) {
        return;
      }
      const now = Date.now();
      if (now - budget.current.since > HOVER_BUDGET_WINDOW) {
        budget.current = { since: now, used: 0 };
      }
      if (budget.current.used >= HOVER_BUDGET) {
        return;
      }
      budget.current.used += 1;
      sentId.current = id;
      send(id);
    }, HOVER_DELAY);
  };
};

const getFloorLabels = (locale: Locale, floors: FloorInfo[]) => {
  let number = 0;
  return floors.map((floor) => {
    if (floor.basement) {
      return locale.labels.basement;
    }
    number += 1;
    return locale.formatFloor(number);
  });
};

type LegendEntry = {
  room: RoomInfo;
  grouped: boolean;
  beds: number;
  damaged: number;
};

const getLegendEntries = (
  rooms: RoomInfo[],
  z: number | null,
  damaged: Record<string, number>,
) => {
  const teams: Record<number, RoomInfo[]> = {};
  for (const room of rooms) {
    teams[room.group] = teams[room.group] || [];
    teams[room.group].push(room);
  }
  const shown: Record<number, boolean> = {};
  const entries: LegendEntry[] = [];
  for (const room of rooms) {
    if (room.z !== z || shown[room.group]) {
      continue;
    }
    shown[room.group] = true;
    const team = teams[room.group];
    entries.push({
      room,
      grouped: team.length > 1,
      beds: team.reduce((sum, member) => sum + member.beds, 0),
      damaged: team.reduce((sum, member) => sum + (damaged[member.id] || 0), 0),
    });
  }
  return entries;
};

type LegendRowProps = {
  locale: Locale;
  enterprise: string;
  entry: LegendEntry;
  occupant: string | undefined;
  highlighted: boolean;
  onHover: (id: number) => void;
  onOpen: (id: number) => void;
};

const LegendRow = (props: LegendRowProps) => {
  const { locale, enterprise, entry, occupant, highlighted, onHover, onOpen } =
    props;
  const { room, grouped, beds, damaged } = entry;
  const purpose = getPurposeLabel(locale, enterprise, room.purpose);
  const details = grouped ? [] : [purpose];
  details.push(locale.levelNames[room.level] || `${room.level}`);
  if (beds) {
    details.push(locale.formatBeds(beds));
  }
  if (occupant) {
    details.push(occupant);
  }

  return (
    <div
      style={{
        cursor: 'pointer',
        padding: '0.4em 0.5em',
        marginBottom: '0.25em',
        borderRadius: '0.25em',
        backgroundColor: highlighted ? LEGEND_HOVER_COLOR : undefined,
      }}
      onMouseEnter={() => onHover(room.id)}
      onMouseLeave={() => onHover(0)}
      onClick={() => onOpen(room.id)}
    >
      <Stack align="center">
        <Stack.Item width="1.75em" textAlign="center">
          <Icon name={getPurposeIcon(room.purpose)} />
        </Stack.Item>
        <Stack.Item grow>
          <Box bold>{grouped ? purpose : room.name}</Box>
          <Box color="label">{details.join(' · ')}</Box>
          {!!damaged && <Box color="bad">{locale.formatDamaged(damaged)}</Box>}
        </Stack.Item>
      </Stack>
    </div>
  );
};

const Legend = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const [hoveredId, setHoveredId] = useState(0);
  const occupants = data.occupants || {};
  const damaged = data.damaged || {};
  const entries = getLegendEntries(data.rooms || [], data.viewed_z, damaged);
  const sendHover = useHoverSender((id) => act('hover_room', { room: id }));

  const hover = (id: number) => {
    setHoveredId(id);
    sendHover(id);
  };
  const open = (id: number) => act('open_room', { room: id });

  return (
    <Section fill scrollable title={locale.labels.legend}>
      <Box color="label" mb={1}>
        {locale.labels.legendHint}
      </Box>
      {!entries.length && <Box color="label">{locale.labels.legendEmpty}</Box>}
      {entries.map((entry) => (
        <LegendRow
          key={entry.room.id}
          locale={locale}
          enterprise={data.name}
          entry={entry}
          occupant={occupants[entry.room.id]}
          highlighted={entry.room.id === hoveredId}
          onHover={hover}
          onOpen={open}
        />
      ))}
    </Section>
  );
};

type MapViewProps = {
  mapId: string;
  frame: number[] | null;
  scale: number;
};

const MapView = (props: MapViewProps) => {
  const { mapId, frame, scale } = props;
  const box = useRef<HTMLDivElement>(null);
  const frameWidth = frame?.[0] || 0;
  const frameHeight = frame?.[1] || 0;

  useEffect(() => {
    const apply = () => {
      const rect = box.current?.getBoundingClientRect();
      if (!rect || !frameWidth || !frameHeight || scale <= 1) {
        Byond.winset(mapId, { zoom: 0, 'zoom-mode': 'normal' });
        return;
      }
      const ratio = window.devicePixelRatio || 1;
      const fit = Math.min(
        (rect.width * ratio) / (frameWidth * ICON_PIXELS),
        (rect.height * ratio) / (frameHeight * ICON_PIXELS),
      );
      Byond.winset(mapId, {
        zoom: fit > 0 ? fit * scale : 0,
        'zoom-mode': 'distort',
      });
    };
    apply();
    window.addEventListener('resize', apply);
    return () => window.removeEventListener('resize', apply);
  }, [mapId, scale, frameWidth, frameHeight]);

  return (
    <div ref={box} style={{ width: '100%', height: '100%' }}>
      <ByondUi
        width="100%"
        height="100%"
        phonehome={false}
        params={{
          id: mapId,
          type: 'map',
          'background-color': '#000000',
        }}
      />
    </div>
  );
};

export const PremisesPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data, config } = useBackend<Data>();
  const floors = data.floors || [];
  const labels = getFloorLabels(locale, floors);
  const interactive = config.status >= UI_INTERACTIVE;
  const wasInteractive = useRef(interactive);

  useEffect(() => {
    act('open_premises');
    return () => act('hide_floors');
  }, []);

  useEffect(() => {
    if (interactive && !wasInteractive.current) {
      act('open_premises');
    }
    wasInteractive.current = interactive;
  }, [interactive]);

  if (!floors.length) {
    return (
      <Section fill title={locale.labels.premises}>
        <NoticeBox>{locale.labels.premisesMissing}</NoticeBox>
      </Section>
    );
  }

  return (
    <Stack fill>
      <Stack.Item grow basis={0}>
        <Section
          fill
          title={locale.labels.premises}
          buttons={
            <>
              <Button icon="expand" onClick={() => act('reset_view')}>
                {locale.labels.resetView}
              </Button>
              <Button icon="rotate" onClick={() => act('survey_again')}>
                {locale.labels.surveyAgain}
              </Button>
            </>
          }
        >
          <Stack vertical fill>
            <Stack.Item>
              <Tabs>
                {floors.map((entry, index) => (
                  <Tabs.Tab
                    key={entry.z}
                    selected={entry.z === data.viewed_z}
                    onClick={() => act('view_floor', { z: entry.z })}
                  >
                    {labels[index]}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Stack.Item>
            <Stack.Item grow>
              {!!data.map && (
                <MapView
                  key={data.map}
                  mapId={data.map}
                  frame={data.frame}
                  scale={data.map_scale || 1}
                />
              )}
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item width={LEGEND_WIDTH}>
        <Legend locale={locale} />
      </Stack.Item>
    </Stack>
  );
};
