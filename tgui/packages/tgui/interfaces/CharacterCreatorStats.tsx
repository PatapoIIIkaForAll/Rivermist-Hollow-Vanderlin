// Stat editor of the Character Creator: a point budget spent on the eight stats,
// two bonuses, and the examine lines for the impression Charisma gives.

import { Fragment, useState } from 'react';
import { DmIcon } from 'tgui-core/components';

import { Btn, Ornament, Tip } from './CharacterCreator';
import type { CharacterCreatorStrings } from './CharacterCreator.i18n';

export type StatRow = {
  key: string;
  name: string;
  desc?: string;
  icon?: string | null;
  icon_state?: string | null;
  label: string;
  /** Bought with points, before anything is added. */
  value: number;
  bonus: number;
  origin: number;
  age: number;
  total: number;
  cost: number;
  /** Points the next step up costs; null at the top value. */
  raise_cost: number | null;
};
export type StatPoints = {
  budget: number;
  spent: number;
  left: number;
  /** Extra points the chosen race gives. */
  species: number;
  major: string | null;
  minor: string | null;
  text_strong: string;
  text_ordinary: string;
  text_poor: string;
  /** Unspent points and bonuses are spread at random at spawn. */
  auto: boolean | number;
};
export type StatRules = {
  floor: number;
  free: number;
  max: number;
  /** Steps above this value cost two points. */
  steep: number;
  bonus_major: number;
  bonus_minor: number;
  poor_max: number;
  strong_min: number;
  text_max: number;
};

/** Save key of the stat the examine lines belong to. */
const CHARISMA = 'charisma';

/** The impression a character gives, from Charisma. */
type Band = 'strong' | 'ordinary' | 'poor';

const signed = (amount: number) => (amount > 0 ? `+${amount}` : `${amount}`);

/** Puts numbers into a string with {name} slots. */
const fill = (template: string, values: Record<string, number>) =>
  template.replace(/\{(\w+)\}/g, (slot, name: string) =>
    name in values ? String(values[name]) : slot,
  );

/** Tooltip body: the stat's description and what its total is made of. */
export const StatParts = (props: {
  stat: StatRow;
  labels: CharacterCreatorStrings;
}) => {
  const { stat } = props;
  const L = props.labels;
  return (
    <>
      {stat.desc ? <div style={{ marginBottom: 6 }}>{stat.desc}</div> : null}
      <div className="cc-tip-label">{L.statParts}:</div>
      <div>
        {stat.value} {L.statBought}
      </div>
      {stat.bonus ? (
        <div>
          {signed(stat.bonus)} {L.statBonus}
        </div>
      ) : null}
      {stat.origin ? (
        <div>
          {signed(stat.origin)} {L.statOrigin}
        </div>
      ) : null}
      {stat.age ? (
        <div>
          {signed(stat.age)} {L.statAge}
        </div>
      ) : null}
    </>
  );
};

/** One line of text, saved when the field loses focus or Enter is pressed. */
const LineEditor = (props: {
  value: string;
  maxLength: number;
  placeholder: string;
  onSave: (value: string) => void;
}) => {
  // The parent remounts this field (key = saved value) whenever the saved text changes.
  const [draft, setDraft] = useState(props.value);
  const save = () => {
    const next = draft.trim();
    setDraft(next);
    if (next !== props.value) {
      props.onSave(next);
    }
  };
  return (
    <input
      className="cc-se-line"
      type="text"
      value={draft}
      maxLength={props.maxLength}
      placeholder={props.placeholder}
      onChange={(event) => setDraft(event.target.value)}
      onBlur={save}
      onKeyDown={(event) => {
        if (event.key === 'Enter') {
          event.currentTarget.blur();
        }
      }}
    />
  );
};

export const StatEditor = (props: {
  stats: StatRow[];
  points: StatPoints;
  rules: StatRules;
  labels: CharacterCreatorStrings;
  onSet: (stat: string, value: number) => void;
  onBonus: (slot: 'major' | 'minor', stat: string) => void;
  onReset: () => void;
  onAuto: () => void;
  onText: (band: Band, value: string) => void;
}) => {
  const { stats, points, rules } = props;
  const L = props.labels;
  const [linesOpen, setLinesOpen] = useState(false);

  const charisma = stats.find((stat) => stat.key === CHARISMA)?.total;
  const band: Band =
    charisma === undefined
      ? 'ordinary'
      : charisma <= rules.poor_max
        ? 'poor'
        : charisma >= rules.strong_min
          ? 'strong'
          : 'ordinary';
  const bandLabels: Record<Band, string> = {
    poor: L.impressionPoor,
    ordinary: L.impressionOrdinary,
    strong: L.impressionStrong,
  };
  const lines: {
    band: Band;
    label: string;
    value: string;
    placeholder: string;
  }[] = [
    {
      band: 'strong',
      label: fill(L.impressionTextStrong, { value: rules.strong_min }),
      value: points.text_strong,
      placeholder: L.impressionTextEmpty,
    },
    {
      band: 'ordinary',
      label: fill(L.impressionTextOrdinary, {
        low: rules.poor_max + 1,
        high: rules.strong_min - 1,
      }),
      value: points.text_ordinary,
      placeholder: L.impressionTextNone,
    },
    {
      band: 'poor',
      label: fill(L.impressionTextPoor, { value: rules.poor_max }),
      value: points.text_poor,
      placeholder: L.impressionTextEmpty,
    },
  ];

  return (
    <>
      <div className="cc-se-head">
        <span className="cc-muted">{L.statPointsLeft}</span>
        <span className={`cc-se-left ${points.left > 0 ? 'unspent' : ''}`}>
          {points.left}
        </span>
        <span className="cc-muted">/ {points.budget}</span>
        {points.species ? (
          <span className="cc-chip good">
            {signed(points.species)} {L.statFromRace}
          </span>
        ) : null}
        <div className="cc-grow" />
        <Btn icon="undo" onClick={props.onReset}>
          {L.statReset}
        </Btn>
      </div>
      <Btn
        className={`fluid ${points.auto ? 'selected' : ''}`}
        icon="dice"
        onClick={props.onAuto}
      >
        {points.auto ? L.statAutoOn : L.statAutoOff}
      </Btn>
      <div className="cc-hint">
        {points.auto ? L.statAutoHintOn : L.statAutoHintOff}
      </div>
      <div className="cc-se-grid">
        {stats.map((stat) => {
          const canRaise =
            stat.raise_cost !== null && stat.raise_cost <= points.left;
          const canLower = stat.value > rules.floor;
          return (
            <Fragment key={stat.key}>
              <div className="cc-se-name">
                <Tip
                  className="cc-se-name-tip"
                  title={`${stat.name} (${stat.total})`}
                  subtitle={L.ability}
                  body={<StatParts stat={stat} labels={L} />}
                >
                  {stat.icon && stat.icon_state ? (
                    <DmIcon
                      icon={stat.icon}
                      icon_state={stat.icon_state}
                      width="18px"
                      height="18px"
                      fallback={<span />}
                    />
                  ) : null}
                  {stat.name}
                </Tip>
                {stat.key === CHARISMA ? (
                  <Btn
                    className={`square ${linesOpen ? 'selected' : ''}`}
                    icon="comment-dots"
                    title={L.impressionEdit}
                    onClick={() => setLinesOpen(!linesOpen)}
                  />
                ) : null}
              </div>
              <div className="cc-se-step">
                <Btn
                  className="square"
                  icon="minus"
                  disabled={!canLower}
                  title={stat.value <= rules.free ? L.statNoRefund : undefined}
                  onClick={() => props.onSet(stat.key, stat.value - 1)}
                />
                <span
                  className={`cc-se-value ${stat.value < rules.free ? 'low' : ''}`}
                >
                  {stat.value}
                </span>
                <Btn
                  className="square"
                  icon="plus"
                  disabled={!canRaise}
                  title={
                    stat.raise_cost === null
                      ? undefined
                      : `${L.statStepCost}: ${stat.raise_cost}`
                  }
                  onClick={() => props.onSet(stat.key, stat.value + 1)}
                />
              </div>
              <div className="cc-se-bonus">
                <Btn
                  className={`cc-se-pip ${points.major === stat.key ? 'on' : ''}`}
                  title={L.statBonusTip}
                  onClick={() => props.onBonus('major', stat.key)}
                >
                  {signed(rules.bonus_major)}
                </Btn>
                <Btn
                  className={`cc-se-pip ${points.minor === stat.key ? 'on' : ''}`}
                  title={L.statBonusTip}
                  onClick={() => props.onBonus('minor', stat.key)}
                >
                  {signed(rules.bonus_minor)}
                </Btn>
              </div>
              <div className="cc-stat-value cc-se-total">{stat.total}</div>
            </Fragment>
          );
        })}
      </div>
      <div className="cc-hint">
        {fill(L.statRulesHint, {
          free: rules.free,
          max: rules.max,
          steep: rules.steep,
          major: rules.bonus_major,
          minor: rules.bonus_minor,
        })}
      </div>
      <Ornament>{L.impressionTitle}</Ornament>
      <div className="cc-se-impression">
        {L.impressionNow}:{' '}
        <span className={`cc-se-band ${band}`}>{bandLabels[band]}</span>
      </div>
      <div className="cc-hint">{L.impressionHint}</div>
      <Btn
        className={`fluid ${linesOpen ? 'selected' : ''}`}
        icon="comment-dots"
        onClick={() => setLinesOpen(!linesOpen)}
      >
        {L.impressionEdit}
      </Btn>
      {linesOpen
        ? lines.map((line) => (
            <Fragment key={line.band}>
              <div
                className={`cc-field-label ${line.band === band ? 'cc-se-now' : ''}`}
              >
                {line.label}
                {line.band === band ? ` · ${L.impressionActive}` : ''}
              </div>
              <LineEditor
                key={`${line.band}:${line.value}`}
                value={line.value}
                maxLength={rules.text_max}
                placeholder={line.placeholder}
                onSave={(value) => props.onText(line.band, value)}
              />
            </Fragment>
          ))
        : null}
    </>
  );
};
