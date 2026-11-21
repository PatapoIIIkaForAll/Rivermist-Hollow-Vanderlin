// Prosthetics window of the Character Creator: an artificer's schematic of the body
// on the left, the parts drawer for the selected socket on the right.

import { useState } from 'react';
import { Icon } from 'tgui-core/components';

import type { CharacterCreatorStrings } from './CharacterCreator.i18n';

type Booleanish = boolean | number;

type ProstheticStat = { name: string; value: number };
type ProstheticOption = {
  id: string;
  name: string;
  desc: string;
  points: number;
  tint: string;
  missing: Booleanish;
  stats: ProstheticStat[];
};
type ImplantOption = {
  id: string;
  name: string;
  desc: string;
  points: number;
  effect: string;
};
type ProstheticSlot = {
  id: string;
  name: string;
  kind: string;
  available: Booleanish;
  choice: string;
  implant: string;
};
export type ProstheticData = {
  slots: ProstheticSlot[];
  options: Record<string, ProstheticOption[]>;
  balance: number;
  points: number;
  locked: Booleanish;
  implants: Record<string, ImplantOption[]>;
};

const NATURAL = 'natural';
const asOff = (value: Booleanish) => !value;
/** Slot groups of the list, top to bottom, and the icon each slot kind shows. */
const SLOT_GROUPS: { key: string; kinds: string[] }[] = [
  { key: 'head', kinds: ['eye', 'tongue'] },
  { key: 'chest', kinds: ['heart', 'lungs'] },
  { key: 'arms', kinds: ['arm'] },
  { key: 'legs', kinds: ['leg'] },
];
const KIND_ICONS: Record<string, string> = {
  eye: 'eye',
  tongue: 'face-grin-tongue',
  heart: 'heart',
  lungs: 'lungs',
  arm: 'hand',
  leg: 'shoe-prints',
};

const pointLabel = (points: number) =>
  points > 0 ? `+${points}` : points < 0 ? `${points}` : '0';

export const ProstheticsPanel = (props: {
  data: ProstheticData;
  labels: CharacterCreatorStrings;
  onPick: (slot: string, option: string) => void;
  onImplant: (slot: string, implant: string) => void;
}) => {
  const { data, onPick, onImplant } = props;
  const L = props.labels;
  const [selected, setSelected] = useState('l_arm');

  if (data.locked) {
    return <div className="cc-pros-locked">{L.prosLocked}</div>;
  }

  const slotById: Record<string, ProstheticSlot> = {};
  for (const slot of data.slots) {
    slotById[slot.id] = slot;
  }
  const optionFor = (slot: ProstheticSlot | undefined) =>
    slot && slot.choice !== NATURAL
      ? (data.options[slot.kind] || []).find((o) => o.id === slot.choice)
      : undefined;

  const current = slotById[selected];
  const currentOption = optionFor(current);
  const choices = current ? data.options[current.kind] || [] : [];

  const implantName = (slot: ProstheticSlot) =>
    slot.implant
      ? (data.implants[slot.kind] || []).find((i) => i.id === slot.implant)
          ?.name
      : undefined;
  const groupLabels: Record<string, string> = {
    head: L.prosGroupHead,
    chest: L.prosGroupChest,
    arms: L.prosGroupArms,
    legs: L.prosGroupLegs,
  };

  const slotRow = (slot: ProstheticSlot) => {
    const option = optionFor(slot);
    const implant = implantName(slot);
    const points = (option?.points || 0) +
      ((data.implants[slot.kind] || []).find((i) => i.id === slot.implant)
        ?.points || 0);
    return (
      <div
        key={slot.id}
        className={`cc-pros-slot ${selected === slot.id ? 'active' : ''} ${asOff(slot.available) ? 'off' : ''} ${option ? 'changed' : ''}`}
        onClick={() => setSelected(slot.id)}
      >
        <span className="cc-pros-slot-icon">
          <Icon name={KIND_ICONS[slot.kind] || 'cog'} />
        </span>
        <span className="cc-pros-slot-text">
          <span className="cc-pros-slot-name">{slot.name}</span>
          <span className="cc-pros-slot-choice">
            <span
              className={`cc-pros-swatch small ${option?.missing ? 'missing' : ''}`}
              style={{
                background: option
                  ? option.missing
                    ? 'transparent'
                    : option.tint
                  : '#d9b38c',
              }}
            />
            {option ? option.name : L.prosNatural}
            {implant ? (
              <span className="cc-pros-slot-implant" title={implant}>
                <Icon name="microchip" /> {implant}
              </span>
            ) : null}
          </span>
        </span>
        {points ? (
          <span
            className={`cc-pros-points ${points > 0 ? 'gives' : 'costs'}`}
            title={L.prosPointsHint}
          >
            {pointLabel(points)}
          </span>
        ) : null}
      </div>
    );
  };

  const card = (
    id: string,
    name: string,
    desc: string,
    points: number,
    tint: string,
    stats: ProstheticStat[],
    missing: boolean,
  ) => {
    const active = current?.choice === id;
    const usable = current && current.available;
    return (
      <div
        key={id}
        className={`cc-pros-card ${active ? 'active' : ''} ${usable ? '' : 'disabled'}`}
        onClick={usable && !active ? () => onPick(selected, id) : undefined}
      >
        <div className="cc-pros-card-head">
          <span
            className={`cc-pros-swatch ${missing ? 'missing' : ''}`}
            style={{ background: missing ? 'transparent' : tint }}
          />
          <span className="cc-grow">{name}</span>
          <span
            className={`cc-pros-points ${points > 0 ? 'gives' : points < 0 ? 'costs' : ''}`}
            title={L.prosPointsHint}
          >
            {pointLabel(points)}
          </span>
        </div>
        <div className="cc-pros-desc">{desc}</div>
        {stats.length ? (
          <div className="cc-pros-stats">
            {stats.map((stat) => (
              <div className="cc-pros-stat" key={stat.name}>
                <span className="cc-pros-stat-name">{stat.name}</span>
                <span className="cc-pros-pips">
                  {[1, 2, 3, 4, 5].map((pip) => (
                    <span
                      key={pip}
                      className={`cc-pros-pip ${pip <= stat.value ? 'on' : ''}`}
                    />
                  ))}
                </span>
              </div>
            ))}
          </div>
        ) : null}
      </div>
    );
  };

  return (
    <div className="cc-pros">
      <div className="cc-pros-slots">
        {SLOT_GROUPS.map((group) => {
          const slots = data.slots.filter((slot) =>
            group.kinds.includes(slot.kind),
          );
          if (!slots.length) {
            return null;
          }
          return (
            <div className="cc-pros-group" key={group.key}>
              <div className="cc-pros-group-title">{groupLabels[group.key]}</div>
              {slots.map(slotRow)}
            </div>
          );
        })}
      </div>
      <div className="cc-pros-drawer">
        <div className="cc-pros-title">
          <Icon name="cog" /> {current ? current.name : L.prosPick}
          <span className="cc-grow" />
          <span className="cc-muted">
            {currentOption ? currentOption.name : L.prosNatural}
          </span>
        </div>
        {current && !current.available ? (
          <div className="cc-pros-missing">{L.prosUnavailable}</div>
        ) : null}
        <div className="cc-pros-cards">
          {current
            ? [
                card(NATURAL, L.prosNatural, L.prosNaturalDesc, 0, '#d9b38c', [], false),
                ...choices.map((option) =>
                  card(
                    option.id,
                    option.name,
                    option.desc,
                    option.points,
                    option.tint,
                    option.stats,
                    !!option.missing,
                  ),
                ),
              ]
            : null}
        </div>
        {current && currentOption && !currentOption.missing ? (
          <div className="cc-pros-socketbox">
            <div className="cc-pros-subtitle">
              <Icon name="microchip" /> {L.prosSocket}
            </div>
            {(data.implants[current.kind] || []).length ? (
              [
                { id: '', name: L.prosSocketEmpty, desc: '', points: 0, effect: '' },
                ...(data.implants[current.kind] || []),
              ].map((implant) => {
                const active = (current.implant || '') === implant.id;
                return (
                  <div
                    key={implant.id || 'empty'}
                    className={`cc-pros-implant ${active ? 'active' : ''}`}
                    title={implant.desc}
                    onClick={
                      active ? undefined : () => onImplant(selected, implant.id)
                    }
                  >
                    <span className={`cc-pros-rivet ${active ? 'on' : ''}`} />
                    <span className="cc-grow">
                      {implant.name}
                      {implant.effect ? (
                        <span className="cc-muted"> - {implant.effect}</span>
                      ) : null}
                    </span>
                    {implant.id ? (
                      <span
                        className={`cc-pros-points ${implant.points > 0 ? 'gives' : implant.points < 0 ? 'costs' : ''}`}
                      >
                        {pointLabel(implant.points)}
                      </span>
                    ) : null}
                  </div>
                );
              })
            ) : (
              <div className="cc-muted">{L.prosSocketNone}</div>
            )}
          </div>
        ) : null}
        <div className="cc-pros-foot">
          <span>
            {L.prosBalance}:{' '}
            <b className={data.balance < 0 ? 'cc-pros-neg' : ''}>
              {data.balance}
            </b>
          </span>
          <span className="cc-muted">
            {L.prosFromParts}: {pointLabel(data.points)}
          </span>
        </div>
      </div>
    </div>
  );
};

