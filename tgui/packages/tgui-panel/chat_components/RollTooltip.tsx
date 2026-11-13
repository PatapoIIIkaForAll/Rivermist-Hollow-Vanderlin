import { sanitizeHTML } from 'tgui/sanitize';
import { Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

const MAX_DICE = 24;
const MAX_SIDES = 99;
const MAX_THROWS = 4;
const MAX_PIP_SIDES = 6;
const MIN_ICOSAHEDRON_SIDES = 20;

type Outcome = 'good' | 'bad' | 'neutral';

const STATS = new Set([
  'strength',
  'perception',
  'intelligence',
  'constitution',
  'endurance',
  'speed',
  'fortune',
  'charisma',
]);

type ChatProp = string | number | undefined;

type RollTooltipProps = {
  dice?: ChatProp;
  labels?: ChatProp;
  sides?: ChatProp;
  outcome?: ChatProp;
  outcomes?: ChatProp;
  stats?: ChatProp;
  footers?: ChatProp;
  html?: ChatProp;
  children?: React.ReactNode;
} & Omit<React.ComponentProps<typeof Tooltip>, 'content' | 'children'>;

const asText = (value: ChatProp): string =>
  value === undefined || value === null ? '' : String(value);

const parseFaces = (dice: string, sides: number): number[] =>
  dice
    .split('-')
    .map((face) => Number.parseInt(face, 10))
    .filter((face) => Number.isInteger(face) && face >= 1 && face <= sides)
    .slice(0, MAX_DICE);

type Throw = {
  label?: string;
  faces: number[];
  outcome?: Outcome;
  stat?: string;
  footer?: string;
};

const parseOutcome = (outcome: string): Outcome =>
  outcome === 'good' || outcome === 'bad' ? outcome : 'neutral';

const parseThrows = (
  dice: string,
  labels: string,
  outcomes: string,
  stats: string,
  footers: string,
  sides: number,
): Throw[] => {
  if (!dice) {
    return [];
  }
  const labelList = labels ? labels.split('|') : [];
  const outcomeList = outcomes ? outcomes.split('|') : [];
  const statList = stats ? stats.split('|') : [];
  const footerList = footers ? footers.split('|') : [];
  return dice
    .split('|')
    .slice(0, MAX_THROWS)
    .map((group, i) => ({
      label: labelList[i] || undefined,
      outcome: outcomeList[i] ? parseOutcome(outcomeList[i]) : undefined,
      stat: STATS.has(statList[i]) ? statList[i] : undefined,
      footer: footerList[i] || undefined,
      faces: parseFaces(group, sides),
    }))
    .filter((roll) => roll.faces.length > 0);
};

const parseSides = (sides: string): number => {
  const parsed = Number.parseInt(sides, 10);
  if (!Number.isInteger(parsed)) {
    return 6;
  }
  return Math.min(Math.max(parsed, 2), MAX_SIDES);
};

export const RollTooltip = (props: RollTooltipProps) => {
  const {
    dice,
    labels,
    sides,
    outcome,
    outcomes,
    stats,
    footers,
    html,
    children,
    ...rest
  } = props;

  const sideCount = parseSides(asText(sides));
  const throws = parseThrows(
    asText(dice),
    asText(labels),
    asText(outcomes),
    asText(stats),
    asText(footers),
    sideCount,
  );
  const outcomeClass = parseOutcome(asText(outcome));
  const extra = asText(html);

  const content = (
    <div className="RollTooltip">
      <div className="RollTooltip__throws">
        {throws.map((roll, i) => (
          <div key={i} className="RollTooltip__throw">
            {roll.label && (
              <div
                className="RollTooltip__label"
                dangerouslySetInnerHTML={{ __html: sanitizeHTML(roll.label) }}
              />
            )}
            <div className="RollTooltip__dice">
              {roll.faces.map((face, j) => (
                <Die
                  key={j}
                  face={face}
                  sides={sideCount}
                  outcome={roll.outcome ?? outcomeClass}
                  stat={roll.stat}
                />
              ))}
            </div>
            {roll.footer && (
              <>
                <div className="RollTooltip__separator" />
                <div
                  className="RollTooltip__footer"
                  dangerouslySetInnerHTML={{
                    __html: sanitizeHTML(roll.footer),
                  }}
                />
              </>
            )}
          </div>
        ))}
      </div>
      {extra && (
        <div
          className="RollTooltip__extra"
          dangerouslySetInnerHTML={{ __html: sanitizeHTML(extra) }}
        />
      )}
    </div>
  );

  return (
    <Tooltip content={content} {...rest}>
      {children}
    </Tooltip>
  );
};

const PIPS: Record<number, [number, number][]> = {
  1: [[50, 50]],
  2: [
    [26, 26],
    [74, 74],
  ],
  3: [
    [26, 26],
    [50, 50],
    [74, 74],
  ],
  4: [
    [26, 26],
    [74, 26],
    [26, 74],
    [74, 74],
  ],
  5: [
    [26, 26],
    [74, 26],
    [50, 50],
    [26, 74],
    [74, 74],
  ],
  6: [
    [26, 26],
    [74, 26],
    [26, 50],
    [74, 50],
    [26, 74],
    [74, 74],
  ],
};

const ICOSAHEDRON_OUTLINE = '50,4 91,27 91,73 50,96 9,73 9,27';
const ICOSAHEDRON_CENTRE_Y = 53;
const ICOSAHEDRON_FRONT = '50,16 82,71 18,71';
const ICOSAHEDRON_EDGES =
  'M50 16 L50 4 M50 16 L9 27 M50 16 L91 27 ' +
  'M18 71 L9 27 M18 71 L9 73 M18 71 L50 96 ' +
  'M82 71 L91 27 M82 71 L91 73 M82 71 L50 96';

type DieProps = {
  face: number;
  sides: number;
  outcome: Outcome;
  stat?: string;
};

const Die = (props: DieProps) => {
  const { face, sides, outcome, stat } = props;
  const icosahedron = sides >= MIN_ICOSAHEDRON_SIDES;
  const pips = sides > MAX_PIP_SIDES ? undefined : PIPS[face];
  const natural = sides === 20 && (face === 20 || face === 1);

  return (
    <svg
      className={classes([
        'RollTooltip__die',
        `RollTooltip__die--${stat ?? outcome}`,
        stat && outcome === 'bad' && 'RollTooltip__die--dim',
        natural &&
          (face === 20
            ? 'RollTooltip__die--natural-high'
            : 'RollTooltip__die--natural-low'),
      ])}
      viewBox="0 0 100 100"
      width={icosahedron ? '76px' : '48px'}
      height={icosahedron ? '76px' : '48px'}
    >
      <title>{face}</title>
      {icosahedron ? (
        <>
          <polygon className="die-bg" points={ICOSAHEDRON_OUTLINE} />
          <polygon className="die-front" points={ICOSAHEDRON_FRONT} />
          <path className="die-edge" d={ICOSAHEDRON_EDGES} />
        </>
      ) : (
        <rect className="die-bg" x="2" y="2" width="96" height="96" />
      )}
      {pips ? (
        pips.map(([x, y]) => (
          <circle key={`${x}-${y}`} className="die-pip" cx={x} cy={y} />
        ))
      ) : (
        <text
          className={classes([
            'die-number',
            icosahedron && 'die-number--icosahedron',
          ])}
          x="50"
          y={icosahedron ? ICOSAHEDRON_CENTRE_Y : 50}
          dy="0.35em"
        >
          {face}
        </text>
      )}
    </svg>
  );
};
