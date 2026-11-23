/**
 * Admin ghost inventory: the two hands and the bag that belong to the admin for this round.
 */
import { useState } from 'react';
import { Button, DmIcon, Icon, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Thing = {
  ref: string;
  name: string;
  path: string;
  icon: string;
  icon_state: string;
  is_item: boolean;
};

type Data = {
  hands: (Thing | null)[];
  active_hand: number;
  bag: Thing[];
  bag_size: number;
};

const Sprite = (props: { thing: Thing; size: number }) => (
  <DmIcon
    icon={props.thing.icon}
    icon_state={props.thing.icon_state}
    fallback={<Icon name="box" />}
    width={`${props.size}px`}
    height={`${props.size}px`}
  />
);

export const AdminGhostInventory = () => {
  const { act, data } = useBackend<Data>();
  const { hands = [], active_hand, bag = [], bag_size } = data;
  const [armed, setArmed] = useState<string | null>(null);

  const remove = (thing: Thing) => {
    if (armed !== thing.ref) {
      setArmed(thing.ref);
      return;
    }
    setArmed(null);
    act('delete', { ref: thing.ref });
  };

  return (
    <Window title="Admin Inventory" width={560} height={560} theme="vanderlin">
      <Window.Content>
        <div className="GhostInv">
          <div className="GhostInv__hands">
            {[1, 2].map((index) => {
              const thing = hands[index - 1];
              const active = active_hand === index;
              return (
                <div
                  key={index}
                  className={`GhostInv__hand${active ? ' GhostInv__hand--on' : ''}`}
                  onClick={() => !active && act('swap', { hand: index })}
                >
                  <div className="GhostInv__handHead">
                    {index === 1 ? 'Left hand (Q)' : 'Right hand (E)'}
                    {active && <span className="GhostInv__active">active</span>}
                  </div>
                  <div className="GhostInv__handBody">
                    {thing ? (
                      <>
                        <div className="GhostInv__sprite">
                          <Sprite thing={thing} size={48} />
                        </div>
                        <Tooltip content={thing.path}>
                          <div className="GhostInv__name">{thing.name}</div>
                        </Tooltip>
                        <div className="GhostInv__buttons">
                          <Button
                            icon="archive"
                            tooltip="Put it in the bag"
                            onClick={(event) => {
                              event.stopPropagation();
                              act('to_bag', { ref: thing.ref });
                            }}
                          />
                          <Button
                            icon="arrow-down"
                            tooltip="Drop it where you are"
                            onClick={(event) => {
                              event.stopPropagation();
                              act('drop', { ref: thing.ref });
                            }}
                          />
                        </div>
                      </>
                    ) : (
                      <div className="GhostInv__empty">empty</div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>

          <div className="GhostInv__bagHead">
            <Icon name="shopping-bag" /> Bag
            <span className="GhostInv__count">
              {bag.length} / {bag_size}
            </span>
            <Button
              ml="auto"
              icon="box-open"
              disabled={!bag.length}
              tooltip="Drop everything in the bag where you are"
              onClick={() => act('drop_all')}
            >
              Drop all
            </Button>
          </div>
          <div className="GhostInv__bag">
            {bag.length === 0 && (
              <div className="GhostInv__empty GhostInv__empty--bag">
                The bag is empty. Take something with Ctrl + click, then press the bag button
                under its hand.
              </div>
            )}
            <div className="GhostInv__grid">
              {bag.map((thing) => (
                <div className="GhostInv__card" key={thing.ref}>
                  <Tooltip content={thing.path}>
                    <div className="GhostInv__sprite">
                      <Sprite thing={thing} size={40} />
                    </div>
                  </Tooltip>
                  <div className="GhostInv__name">{thing.name}</div>
                  <div className="GhostInv__buttons">
                    <Button
                      icon="hand-paper"
                      tooltip="Take it into a free hand"
                      onClick={() => act('to_hand', { ref: thing.ref })}
                    />
                    <Button
                      icon="arrow-down"
                      tooltip="Drop it where you are"
                      onClick={() => act('drop', { ref: thing.ref })}
                    />
                    <Button
                      icon={armed === thing.ref ? 'exclamation-triangle' : 'trash'}
                      color={armed === thing.ref ? 'bad' : undefined}
                      tooltip={armed === thing.ref ? 'Click again to delete' : 'Delete it'}
                      onClick={() => remove(thing)}
                    />
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="GhostInv__footer">
            Ctrl + click: take / give / put down · Q, E, X: hands · click the active hand slot:
            drop. Kept for this round only.
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
