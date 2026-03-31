import { Dispatch, SetStateAction, useState } from 'react';
import { Box, Button, Input, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type LoadoutItem = {
  name: string;
  desc: string;
  point_cost: number;
  nobility_check: BooleanLike;
  ref: string;
  typepath: string;
  icon: string;
};

type SelectedSlot = {
  slot: number;
  name: string;
  typepath: string;
};

type Data = {
  current_slot: number;
  total_points: number;
  remaining_points: number;
  slot_budget: number;
  current_item_type?: string;
  selected_slots: SelectedSlot[];
  loadout_items: LoadoutItem[];
};

const SearchBar = (props: {
  search: string;
  setSearch: Dispatch<SetStateAction<string>>;
}) => {
  const { search, setSearch } = props;
  return <Input value={search} onChange={setSearch} fluid />;
};

export const LoadoutMenu = () => {
  const [search, setSearch] = useState('');
  const { act, data } = useBackend<Data>();
  const {
    current_slot,
    total_points,
    remaining_points,
    slot_budget,
    current_item_type,
    selected_slots = [],
    loadout_items = [],
  } = data;

  const loweredSearch = search.trim().toLowerCase();
  const availableItems = loadout_items
    .filter((item) => !!item.nobility_check)
    .filter((item) => {
      if (!loweredSearch) {
        return true;
      }

      return (
        item.name.toLowerCase().includes(loweredSearch) ||
        (item.desc || '').toLowerCase().includes(loweredSearch)
      );
    });

  return (
    <Window
      title={`Loadout Slot ${current_slot || 1}`}
      width={900}
      height={640}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item grow>
                  <Box bold>Choose an item for slot {current_slot || 1}</Box>
                  <Box color="label">
                    Remaining overall: {remaining_points} / {total_points} points
                  </Box>
                  <Box color="label">
                    Available for this slot: {slot_budget} points
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box textAlign="right">
                    <Box bold>{availableItems.length}</Box>
                    <Box color="label">Available choices</Box>
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title="Items"
              fill
              scrollable
              buttons={<SearchBar search={search} setSearch={setSearch} />}>
              {!availableItems.length && (
                <Box color="label">No loadout items match your search.</Box>
              )}
              {availableItems.map((item) => {
                const selectedElsewhere = selected_slots.find(
                  (entry) =>
                    entry.slot !== current_slot && entry.typepath === item.typepath,
                );
                const isCurrent = item.typepath === current_item_type;
                const tooExpensive = item.point_cost > slot_budget;

                let statusText = 'Click to select';
                let statusColor: string = 'good';

                if (isCurrent) {
                  statusText = 'Currently selected in this slot';
                } else if (selectedElsewhere) {
                  statusText = `Already selected in slot ${selectedElsewhere.slot}`;
                  statusColor = 'bad';
                } else if (tooExpensive) {
                  statusText = `Costs ${item.point_cost}, but only ${slot_budget} points fit here`;
                  statusColor = 'average';
                }

                const disabled = !!selectedElsewhere || tooExpensive;

                return (
                  <Box key={item.ref} mb={1}>
                    <Button
                      fluid
                      disabled={disabled}
                      selected={isCurrent}
                      tooltip={disabled ? statusText : null}
                      onClick={() => act('choose_item', { ref: item.ref })}>
                      <Stack align="center">
                        <Stack.Item>
                          <Box
                            style={{
                              width: '40px',
                              height: '40px',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                            }}>
                            <Box className={item.icon} />
                          </Box>
                        </Stack.Item>
                        <Stack.Item grow>
                          <Box bold>{item.name}</Box>
                          <Box color="label">{item.desc || 'No description.'}</Box>
                          <Box color={statusColor}>{statusText}</Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box bold>
                            {item.point_cost} point{item.point_cost === 1 ? '' : 's'}
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Button>
                  </Box>
                );
              })}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
