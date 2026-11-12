import { useEffect, useRef } from 'react';
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
const HOVER_DELAY = 250;
const HOVER_BUDGET = 40;
const HOVER_BUDGET_WINDOW = 60000;
const ICON_PIXELS = 32;
const FIT_DELAY = 250;
const FIT_EPSILON = 0.001;

const useHoverSender = (send: (id: number) => void) => {
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const wantedId = useRef(0);
  const sentId = useRef(0);
  const budget = useRef({ since: 0, used: 0 });

  useEffect(() => () => clearTimeout(timer.current), []);

  return (id: number) => {
    if (wantedId.current === id) {
      return;
    }
    wantedId.current = id;
    clearTimeout(timer.current);
    timer.current = setTimeout(() => {
      if (sentId.current === id) {
        return;
      }
      if (id) {
        const now = Date.now();
        if (now - budget.current.since > HOVER_BUDGET_WINDOW) {
          budget.current = { since: now, used: 0 };
        }
        if (budget.current.used >= HOVER_BUDGET) {
          return;
        }
        budget.current.used += 1;
      }
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
  onHover: (id: number) => void;
  onOpen: (id: number) => void;
};

const LegendRow = (props: LegendRowProps) => {
  const { locale, enterprise, entry, occupant, onHover, onOpen } = props;
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
    <Button
      fluid
      color="transparent"
      px={1}
      py={0.8}
      lineHeight={1.25}
      style={{ whiteSpace: 'normal' }}
      onMouseOver={() => onHover(room.id)}
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
    </Button>
  );
};

const Legend = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const occupants = data.occupants || {};
  const damaged = data.damaged || {};
  const entries = getLegendEntries(data.rooms || [], data.viewed_z, damaged);
  const hover = useHoverSender((id) => act('hover_room', { room: id }));
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
  onFit: (fit: number) => void;
};

const MapView = (props: MapViewProps) => {
  const { mapId, frame, onFit } = props;
  const box = useRef<HTMLDivElement>(null);
  const frameWidth = frame?.[0] || 0;
  const frameHeight = frame?.[1] || 0;

  useEffect(() => {
    let sent = 0;
    let timer: ReturnType<typeof setTimeout> | undefined;
    const report = () => {
      const rect = box.current?.getBoundingClientRect();
      if (!rect || !frameWidth || !frameHeight) {
        return;
      }
      const ratio = window.devicePixelRatio || 1;
      const fit = Math.min(
        (rect.width * ratio) / (frameWidth * ICON_PIXELS),
        (rect.height * ratio) / (frameHeight * ICON_PIXELS),
      );
      if (fit > 0 && Math.abs(fit - sent) > FIT_EPSILON) {
        sent = fit;
        onFit(fit);
      }
    };
    const onResize = () => {
      clearTimeout(timer);
      timer = setTimeout(report, FIT_DELAY);
    };
    report();
    window.addEventListener('resize', onResize);
    return () => {
      clearTimeout(timer);
      window.removeEventListener('resize', onResize);
    };
  }, [mapId, frameWidth, frameHeight]);

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
              {!!data.map && interactive && (
                <MapView
                  key={data.map}
                  mapId={data.map}
                  frame={data.frame}
                  onFit={(fit) => act('map_fit', { fit })}
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
