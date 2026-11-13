import { useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Carving = {
  name: string;
  path: string;
  icon: string | null;
};

type Data = {
  carvings: Carving[];
};

// Pumpkin shell carving menu: pick one lantern design.
export const PumpkinCarving = () => {
  const { act, data } = useBackend<Data>();
  const [search, setSearch] = useState('');

  const query = search.toLowerCase();
  const carvings = (data.carvings || [])
    .filter((carving) => !query || carving.name.toLowerCase().includes(query))
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Window width={320} height={400}>
      <Window.Content>
        <Section
          title="Carvings"
          fill
          scrollable
          buttons={
            <Input
              placeholder="Search..."
              value={search}
              onChange={setSearch}
            />
          }
        >
          {carvings.length === 0 && (
            <Box color="label">There is nothing to carve.</Box>
          )}
          {carvings.map((carving) => (
            <Button
              key={carving.path}
              fluid
              onClick={() => act('choose_carving', { path: carving.path })}
            >
              <Stack align="center">
                <Stack.Item>
                  <Box className={carving.icon || undefined} mr={1} />
                </Stack.Item>
                <Stack.Item grow>{carving.name}</Stack.Item>
              </Stack>
            </Button>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
