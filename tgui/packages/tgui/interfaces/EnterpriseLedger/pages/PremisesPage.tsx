import { type CSSProperties, useMemo, useState } from 'react';
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { CellKind, Data, FloorPlan, Locale, PageProps } from '../types';

const CELL_SIZE = 16;

// The characters DM writes into a floor's rows.
const CELL_KINDS: Record<string, CellKind> = {
  '#': 'wall',
  '.': 'floor',
  o: 'openSpace',
  D: 'door',
  S: 'stairs',
  L: 'ledger',
};

const CELL_COLORS: Record<CellKind, string> = {
  wall: '#6b6257',
  floor: '#2e3a2e',
  furnished: '#4d6b4d',
  openSpace: '#1c2733',
  door: '#b07a3a',
  stairs: '#4a6f9c',
  ledger: '#c94f4f',
};

const LEGEND: CellKind[] = [
  'wall',
  'floor',
  'furnished',
  'door',
  'stairs',
  'openSpace',
  'ledger',
];

const cellStyle = (kind: CellKind): CSSProperties => ({
  width: `${CELL_SIZE}px`,
  height: `${CELL_SIZE}px`,
  backgroundColor: CELL_COLORS[kind],
});

const CELL_STYLES = Object.fromEntries(
  LEGEND.map((kind) => [kind, cellStyle(kind)]),
) as Record<CellKind, CSSProperties>;

const EMPTY_CELL_STYLE: CSSProperties = {
  width: `${CELL_SIZE}px`,
  height: `${CELL_SIZE}px`,
};

const getFloorLabels = (locale: Locale, plan: FloorPlan[]) => {
  let number = 0;
  return plan.map((floor) => {
    if (floor.basement) {
      return locale.labels.basement;
    }
    number += 1;
    return locale.formatFloor(number);
  });
};

const FloorGrid = (props: { floor: FloorPlan; locale: Locale }) => {
  const { floor, locale } = props;

  const namesByCell = useMemo(() => {
    const names: Record<string, string[]> = {};
    for (const object of floor.objects) {
      const key = `${object.x}_${object.y}`;
      if (!names[key]) {
        names[key] = [];
      }
      names[key].push(object.name);
    }
    return names;
  }, [floor]);

  const cells: React.ReactNode[] = [];
  for (let row = floor.height - 1; row >= 0; row--) {
    const line = floor.rows[row] || '';
    for (let column = 0; column < floor.width; column++) {
      const key = `${column}_${row}`;
      const names = namesByCell[key];
      let kind = CELL_KINDS[line[column]];
      if (!kind) {
        cells.push(<div key={key} style={EMPTY_CELL_STYLE} />);
        continue;
      }
      if (kind === 'floor' && names) {
        kind = 'furnished';
      }
      // A plain div with a native title: a floor is over a thousand cells, and a
      // Tooltip or hover state on each would re-render the whole grid on every move.
      cells.push(
        <div
          key={key}
          style={CELL_STYLES[kind]}
          title={names ? names.join(', ') : locale.cellKinds[kind]}
        />,
      );
    }
  }

  return (
    <Box
      style={{
        display: 'grid',
        gridTemplateColumns: `repeat(${floor.width}, ${CELL_SIZE}px)`,
        gap: '1px',
        width: 'max-content',
        margin: 'auto',
      }}
    >
      {cells}
    </Box>
  );
};

const Legend = (props: { locale: Locale }) => {
  const { locale } = props;

  return (
    <Stack wrap align="center">
      {LEGEND.map((kind) => (
        <Stack.Item key={kind}>
          <Stack align="center">
            <Stack.Item>
              <div style={CELL_STYLES[kind]} />
            </Stack.Item>
            <Stack.Item color="label">{locale.cellKinds[kind]}</Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
    </Stack>
  );
};

export const PremisesPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const plan = data.plan || [];
  const [selectedZ, setSelectedZ] = useState<number | null>(null);
  const floor =
    plan.find((entry) => entry.z === selectedZ) ||
    plan.find((entry) => !entry.basement) ||
    plan[0];
  const labels = getFloorLabels(locale, plan);

  return (
    <Section
      fill
      title={locale.labels.premises}
      buttons={
        <Button
          icon="rotate"
          disabled={!data.is_staff}
          onClick={() => act('refresh_premises')}
        >
          {locale.labels.refresh}
        </Button>
      }
    >
      {!floor && <NoticeBox>{locale.labels.premisesMissing}</NoticeBox>}
      {!!floor && (
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              {plan.map((entry, index) => (
                <Tabs.Tab
                  key={entry.z}
                  selected={entry.z === floor.z}
                  onClick={() => setSelectedZ(entry.z)}
                >
                  {labels[index]}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Legend locale={locale} />
          </Stack.Item>
          <Stack.Item grow style={{ overflow: 'auto', minHeight: 0 }}>
            <FloorGrid floor={floor} locale={locale} />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
