import { useEffect, useState } from 'react';
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
import { getPurposeIcon, getPurposeLabel } from '../purposes';
import type { Data, FloorInfo, Locale, PageProps, RoomInfo } from '../types';

const LEGEND_WIDTH = '17em';
const LEGEND_HOVER_COLOR = 'rgba(255, 217, 160, 0.16)';

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

type LegendRowProps = {
  locale: Locale;
  enterprise: string;
  room: RoomInfo;
  highlighted: boolean;
  onHover: (id: number) => void;
  onOpen: (id: number) => void;
};

const LegendRow = (props: LegendRowProps) => {
  const { locale, enterprise, room, highlighted, onHover, onOpen } = props;
  const details = [getPurposeLabel(locale, enterprise, room.purpose)];
  if (room.beds) {
    details.push(locale.formatBeds(room.beds));
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
          <Box bold>{room.name}</Box>
          <Box color="label">{details.join(' · ')}</Box>
        </Stack.Item>
      </Stack>
    </div>
  );
};

const Legend = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const [hoveredId, setHoveredId] = useState(0);
  const rooms = (data.rooms || []).filter((room) => room.z === data.viewed_z);

  const hover = (id: number) => {
    setHoveredId(id);
    act('hover_room', { room: id });
  };
  const open = (id: number) => act('open_room', { room: id });

  return (
    <Section fill scrollable title={locale.labels.legend}>
      <Box color="label" mb={1}>
        {locale.labels.legendHint}
      </Box>
      {!rooms.length && <Box color="label">{locale.labels.legendEmpty}</Box>}
      {rooms.map((room) => (
        <LegendRow
          key={room.id}
          locale={locale}
          enterprise={data.name}
          room={room}
          highlighted={room.id === hoveredId}
          onHover={hover}
          onOpen={open}
        />
      ))}
    </Section>
  );
};

export const PremisesPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const floors = data.floors || [];
  const labels = getFloorLabels(locale, floors);

  useEffect(() => {
    act('open_premises');
    return () => act('hide_floors');
  }, []);

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
                <ByondUi
                  key={data.map}
                  width="100%"
                  height="100%"
                  phonehome={false}
                  params={{
                    id: data.map,
                    type: 'map',
                    'background-color': '#000000',
                  }}
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
