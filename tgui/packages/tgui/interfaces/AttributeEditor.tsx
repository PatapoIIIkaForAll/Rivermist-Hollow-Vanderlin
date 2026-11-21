/**
 * Attribute Editor: the attributes and skills of one character.
 *
 * Each row reads left to right as a sum: Base + Admin bonus (+ other modifiers) = Total.
 * Base is permanent. The admin bonus is a modifier of its own, so it never overwrites buffs.
 */
import { useState } from 'react';
import { Button, Icon, Input, NumberInput, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Entry = {
  name: string;
  desc?: string;
  type: string;
  /** Effective value, with every modifier applied. */
  value: number | null;
  /** Permanent base value; null means "use the default". */
  raw_value: number | null;
  /** The bonus set from this window. */
  admin_bonus: number;
  /** Skills only: combat, craft, labor, magic, misc. */
  group?: string;
};

type SkillLevel = { name: string; value: number };

type AttributeEditorData = {
  parent: string;
  attribute_min: number | null;
  attribute_max: number | null;
  attribute_default: number | null;
  skill_min: number | null;
  skill_max: number | null;
  skill_default: number | null;
  cached_diceroll_modifier: number;
  attributes: Entry[];
  skills: Entry[];
  skill_levels: SkillLevel[];
};

const GROUP_NAMES: Record<string, string> = {
  combat: 'Combat',
  craft: 'Crafting',
  labor: 'Labor',
  magic: 'Magic',
  misc: 'Miscellaneous',
  other: 'Other',
};

const GROUP_ORDER = ['combat', 'magic', 'craft', 'labor', 'misc', 'other'];

const signed = (value: number) => (value > 0 ? `+${value}` : `${value}`);

const levelOf = (levels: SkillLevel[], value: number): SkillLevel | undefined => {
  let found: SkillLevel | undefined;
  for (const level of levels) {
    if (value >= level.value) {
      found = level;
    }
  }
  return found;
};

const EntryRow = (props: {
  entry: Entry;
  min: number | null;
  max: number | null;
  fallback: number | null;
  levels?: SkillLevel[];
}) => {
  const { act } = useBackend<AttributeEditorData>();
  const { entry, min, max, fallback, levels } = props;
  const usesDefault = entry.raw_value === null || entry.raw_value === undefined;
  const base = usesDefault ? (fallback ?? 0) : (entry.raw_value as number);
  const total = entry.value ?? base;
  const other = total - base - entry.admin_bonus;
  const level = levels ? levelOf(levels, total) : undefined;
  const setBase = (value: number) =>
    act('change_raw_attribute', { attribute_type: entry.type, new_value: value });
  // Skills move one whole level per chevron click.
  const stepLevel = (direction: 1 | -1) => {
    if (!levels) {
      return;
    }
    const ordered = levels.map((entryLevel) => entryLevel.value);
    const next =
      direction === 1
        ? ordered.find((value) => value > base)
        : [...ordered].reverse().find((value) => value < base);
    if (next !== undefined) {
      setBase(next);
    }
  };

  return (
    <tr className="AttrEdit__row">
      <td className="AttrEdit__name">
        <Tooltip content={entry.desc || entry.type} position="bottom-start">
          <span>{entry.name}</span>
        </Tooltip>
      </td>
      <td className="AttrEdit__cell">
        {!!levels && (
          <Button
            icon="chevron-left"
            tooltip="One skill level down"
            onClick={() => stepLevel(-1)}
          />
        )}
        <NumberInput
          width="52px"
          value={base}
          minValue={min ?? -1000}
          maxValue={max ?? 1000}
          step={1}
          onChange={setBase}
        />
        {!!levels && (
          <Button icon="chevron-right" tooltip="One skill level up" onClick={() => stepLevel(1)} />
        )}
        <Button
          icon="undo"
          disabled={usesDefault}
          tooltip={
            usesDefault
              ? 'Already using the default'
              : `Reset the base to the default (${fallback ?? 0})`
          }
          onClick={() => act('null_raw_attribute', { attribute_type: entry.type })}
        />
      </td>
      <td className="AttrEdit__cell">
        <NumberInput
          width="48px"
          value={entry.admin_bonus}
          minValue={-1000}
          maxValue={1000}
          step={1}
          format={signed}
          onChange={(value) =>
            act('change_attribute', { attribute_type: entry.type, new_value: value })
          }
        />
        <Button
          icon="times"
          disabled={!entry.admin_bonus}
          tooltip="Remove the admin bonus"
          onClick={() => act('null_attribute', { attribute_type: entry.type })}
        />
      </td>
      <td className="AttrEdit__other">
        {other !== 0 && (
          <Tooltip content="Buffs, debuffs and other modifiers that are not set from this window">
            <span className={other > 0 ? 'AttrEdit__good' : 'AttrEdit__bad'}>{signed(other)}</span>
          </Tooltip>
        )}
      </td>
      <td className="AttrEdit__total">
        <span className={total > base ? 'AttrEdit__good' : total < base ? 'AttrEdit__bad' : ''}>
          {total}
        </span>
        {!!level && <span className="AttrEdit__level">{level.name}</span>}
      </td>
    </tr>
  );
};

const EntryTable = (props: {
  entries: Entry[];
  min: number | null;
  max: number | null;
  fallback: number | null;
  levels?: SkillLevel[];
}) => (
  <table className="AttrEdit__table">
    <tbody>
      {props.entries.map((entry) => (
        <EntryRow
          key={entry.type}
          entry={entry}
          min={props.min}
          max={props.max}
          fallback={props.fallback}
          levels={props.levels}
        />
      ))}
    </tbody>
  </table>
);

const ColumnHead = () => (
  <table className="AttrEdit__table AttrEdit__table--head">
    <tbody>
      <tr>
        <td className="AttrEdit__name">Name</td>
        <td className="AttrEdit__cell">Base</td>
        <td className="AttrEdit__cell">Admin bonus</td>
        <td className="AttrEdit__other">Other</td>
        <td className="AttrEdit__total">Total</td>
      </tr>
    </tbody>
  </table>
);

const LimitField = (props: {
  label: string;
  varName: string;
  value: number | null;
}) => {
  const { act } = useBackend<AttributeEditorData>();
  const { label, varName, value } = props;
  const unset = value === null || value === undefined;
  return (
    <div className="AttrEdit__limit">
      <span>{label}</span>
      <NumberInput
        width="56px"
        value={value ?? 0}
        minValue={-1000}
        maxValue={1000}
        step={1}
        onChange={(newValue) => act('change_var', { var_name: varName, var_value: newValue })}
      />
      <Button
        icon="ban"
        selected={unset}
        tooltip={unset ? 'Unset (null): no limit applies' : 'Unset this limit (null)'}
        onClick={() => act('null_var', { var_name: varName })}
      />
    </div>
  );
};

export const AttributeEditor = () => {
  const { act, data } = useBackend<AttributeEditorData>();
  const { parent, attributes = [], skills = [], skill_levels = [] } = data;
  const [search, setSearch] = useState('');
  const [onlyTrained, setOnlyTrained] = useState(false);
  const [showLimits, setShowLimits] = useState(false);

  const query = search.trim().toLowerCase();
  const matches = (entry: Entry) => !query || entry.name.toLowerCase().includes(query);
  const shownAttributes = attributes.filter(matches);
  const shownSkills = skills.filter(
    (skill) =>
      matches(skill) && (!onlyTrained || (skill.value ?? 0) > 0 || skill.admin_bonus !== 0),
  );
  const bonusCount =
    attributes.filter((entry) => entry.admin_bonus).length +
    skills.filter((entry) => entry.admin_bonus).length;

  const groups = GROUP_ORDER.map((id): [string, Entry[]] => [
    id,
    shownSkills.filter((skill) => (skill.group || 'other') === id),
  ]).filter(([, list]) => list.length > 0);

  return (
    <Window
      title={parent ? `${parent} - Attribute Editor` : 'Attribute Editor'}
      width={960}
      height={720}
    >
      <Window.Content>
        <div className="AttrEdit">
          <div className="AttrEdit__top">
            <div className="AttrEdit__who">{parent || 'Character'}</div>
            <Input
              className="AttrEdit__search"
              fluid
              autoFocus
              placeholder="Search attributes and skills..."
              value={search}
              onChange={setSearch}
            />
            <Button.Checkbox
              checked={onlyTrained}
              tooltip="Hide skills that are at zero"
              onClick={() => setOnlyTrained(!onlyTrained)}
            >
              Trained only
            </Button.Checkbox>
            <Button
              icon="eraser"
              disabled={!bonusCount}
              tooltip="Remove every admin bonus set from this window. Base values stay."
              onClick={() => act('reset_bonuses')}
            >
              Clear bonuses ({bonusCount})
            </Button>
            <Button
              icon="sliders-h"
              selected={showLimits}
              tooltip="Minimum, maximum and default values, and the dice roll modifier"
              tooltipPosition="bottom-end"
              onClick={() => setShowLimits(!showLimits)}
            >
              Limits
            </Button>
          </div>

          {showLimits && (
            <div className="AttrEdit__limits">
              <LimitField label="Attribute min" varName="attribute_min" value={data.attribute_min} />
              <LimitField label="Attribute max" varName="attribute_max" value={data.attribute_max} />
              <LimitField
                label="Attribute default"
                varName="attribute_default"
                value={data.attribute_default}
              />
              <LimitField label="Skill min" varName="skill_min" value={data.skill_min} />
              <LimitField label="Skill max" varName="skill_max" value={data.skill_max} />
              <LimitField label="Skill default" varName="skill_default" value={data.skill_default} />
              <div className="AttrEdit__limit">
                <span>Dice roll modifier</span>
                <NumberInput
                  width="56px"
                  value={data.cached_diceroll_modifier ?? 0}
                  minValue={-1000}
                  maxValue={1000}
                  step={1}
                  onChange={(value) => act('change_diceroll_modifier', { new_value: value })}
                />
              </div>
            </div>
          )}

          <div className="AttrEdit__legend">
            <Icon name="info-circle" /> Total = Base + Admin bonus + Other. Base is permanent; the
            admin bonus is a separate modifier and never overwrites buffs. Changes apply at once.
          </div>

          <div className="AttrEdit__main">
            <div className="AttrEdit__panel AttrEdit__panel--attributes">
              <div className="AttrEdit__head">
                Attributes <span className="AttrEdit__count">{shownAttributes.length}</span>
              </div>
              <ColumnHead />
              <div className="AttrEdit__scroll">
                <EntryTable
                  entries={shownAttributes}
                  min={data.attribute_min}
                  max={data.attribute_max}
                  fallback={data.attribute_default}
                />
                {shownAttributes.length === 0 && (
                  <div className="AttrEdit__empty">No attribute matches.</div>
                )}
              </div>
            </div>

            <div className="AttrEdit__panel">
              <div className="AttrEdit__head">
                Skills <span className="AttrEdit__count">{shownSkills.length}</span>
              </div>
              <ColumnHead />
              <div className="AttrEdit__scroll">
                {groups.map(([id, list]) => (
                  <div key={id}>
                    <div className="AttrEdit__group">
                      {GROUP_NAMES[id] || id} <span className="AttrEdit__count">{list.length}</span>
                    </div>
                    <EntryTable
                      entries={list}
                      min={data.skill_min}
                      max={data.skill_max}
                      fallback={data.skill_default}
                      levels={skill_levels}
                    />
                  </div>
                ))}
                {shownSkills.length === 0 && (
                  <div className="AttrEdit__empty">
                    {onlyTrained && !query ? 'No trained skills.' : 'No skill matches.'}
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
