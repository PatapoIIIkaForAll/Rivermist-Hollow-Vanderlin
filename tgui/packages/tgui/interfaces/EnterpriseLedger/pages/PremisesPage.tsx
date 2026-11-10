import { useEffect, type WheelEvent } from 'react';
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
  // Which floor is open is the server's to say: the wheel over the map changes it there.
  const floor = floors.find((entry) => entry.z === data.viewed_z);
  const labels = getFloorLabels(locale, floors);

  useEffect(() => {
    act('open_premises');
    return () => act('hide_floors');
  }, []);

  // Over the map itself the wheel goes to BYOND, not to the browser; this covers the tabs.
  const stepFloor = (event: WheelEvent) => {
    if (event.deltaY) {
      act('step_floor', { direction: event.deltaY < 0 ? 1 : -1 });
    }
  };

  return (
    <Section fill title={locale.labels.premises}>
      {!floors.length && <NoticeBox>{locale.labels.premisesMissing}</NoticeBox>}
      {!!floors.length && (
        <Stack vertical fill>
          <Stack.Item>
            <div onWheel={stepFloor}>
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
            </div>
          </Stack.Item>
          <Stack.Item grow>
            {!!floor && (
              // Keyed by the map id alone: another floor is another control.
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
            )}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
