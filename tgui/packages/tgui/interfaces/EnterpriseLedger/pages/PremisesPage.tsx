import { useEffect, useState } from 'react';
import { ByondUi, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { Data, FloorInfo, Locale, PageProps } from '../types';

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

export const PremisesPage = (props: PageProps) => {
  const { locale } = props;
  const { act, data } = useBackend<Data>();
  const floors = data.floors || [];
  const [selectedZ, setSelectedZ] = useState<number | null>(null);
  const floor =
    floors.find((entry) => entry.z === selectedZ) ||
    floors.find((entry) => !entry.basement) ||
    floors[0];
  const shownZ = floor ? floor.z : null;
  const labels = getFloorLabels(locale, floors);

  // The server puts the floor's screen objects on this client's map control.
  useEffect(() => {
    if (shownZ !== null) {
      act('view_floor', { z: shownZ });
    }
  }, [shownZ]);

  useEffect(() => {
    return () => act('hide_floors');
  }, []);

  return (
    <Section fill title={locale.labels.premises}>
      {!floor && <NoticeBox>{locale.labels.premisesMissing}</NoticeBox>}
      {!!floor && (
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              {floors.map((entry, index) => (
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
          <Stack.Item grow>
            {/* Keyed by the map id alone: another floor is another control. */}
            <ByondUi
              key={floor.map}
              width="100%"
              height="100%"
              phonehome={false}
              params={{
                id: floor.map,
                type: 'map',
                'background-color': '#000000',
              }}
            />
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
