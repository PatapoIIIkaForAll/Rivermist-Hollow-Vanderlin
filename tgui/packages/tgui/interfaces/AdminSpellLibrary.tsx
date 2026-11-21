/**
 * Spell Library: browse every grantable spell as a card, filter by power source and by how the
 * spell is delivered, then grant it to or revoke it from one mob. Port of Ratwood 2.0 PR 156.
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { Button, DmIcon, Icon, Input, Tooltip } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Spell = {
  path: string;
  name: string;
  desc: string;
  source: string;
  kind: string;
  school?: string | null;
  icon: string;
  icon_state: string;
  cooldown: number;
  charge_time: number;
  cost: number;
  range: number;
};

type Option = { id: string; name: string };

type Data = {
  spells: Spell[];
  sources: Option[];
  kinds: Option[];
  target_name: string;
  target_key?: string | null;
  target_valid: boolean;
  mindless: boolean;
  known_spells: Record<string, number>;
  status_message?: string | null;
  status_type: 'info' | 'good' | 'bad';
};

type Ownership = 'all' | 'known' | 'unknown';

const PAGE_SIZE = 30;
const CONFIRM_MS = 4000;

const SOURCE_ICONS: Record<string, string> = {
  all: 'book-open',
  '1': 'hat-wizard',
  '2': 'running',
  '3': 'pray',
  '4': 'flask',
  '5': 'tint',
  '6': 'cross',
  '7': 'fire',
  none: 'circle',
};

const seconds = (value: number) =>
  value >= 60 ? `${Math.round(value / 6) / 10} min` : `${Math.round(value * 10) / 10} s`;

export const AdminSpellLibrary = () => {
  const { act, data } = useBackend<Data>();
  const {
    spells = [],
    sources = [],
    kinds = [],
    known_spells = {},
    target_name,
    target_key,
    target_valid,
    mindless,
    status_message,
    status_type,
  } = data;
  const [search, setSearch] = useState('');
  const [source, setSource] = useState('all');
  const [kind, setKind] = useState('all');
  const [ownership, setOwnership] = useState<Ownership>('all');
  const [page, setPage] = useState(1);
  const [armed, setArmed] = useState(false);
  const armTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  useEffect(
    () => () => {
      if (armTimer.current) {
        clearTimeout(armTimer.current);
      }
    },
    [],
  );

  const sorted = useMemo(
    () =>
      [...spells].sort(
        (a, b) => a.name.localeCompare(b.name) || a.path.localeCompare(b.path),
      ),
    [spells],
  );

  // Everything except the source filter, so the rail can show how many each source would give.
  const matched = useMemo(() => {
    const words = search.trim().toLowerCase().split(/\s+/).filter(Boolean);
    return sorted.filter((spell) => {
      const known = !!known_spells[spell.path];
      if (ownership === 'known' ? !known : ownership === 'unknown' && known) {
        return false;
      }
      if (kind !== 'all' && spell.kind !== kind) {
        return false;
      }
      if (!words.length) {
        return true;
      }
      const haystack = `${spell.name} ${spell.desc} ${spell.path}`.toLowerCase();
      return words.every((word) => haystack.includes(word));
    });
  }, [sorted, search, ownership, kind, known_spells]);

  const counts = useMemo(() => {
    const result: Record<string, number> = { all: matched.length };
    for (const spell of matched) {
      result[spell.source] = (result[spell.source] || 0) + 1;
    }
    return result;
  }, [matched]);

  const filtered =
    source === 'all' ? matched : matched.filter((spell) => spell.source === source);
  const pages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const currentPage = Math.min(page, pages);
  const visible = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);
  const knownCount = Object.keys(known_spells).length;
  const kindName = (id: string) => kinds.find((entry) => entry.id === id)?.name || id;
  const sourceName = (id: string) => sources.find((entry) => entry.id === id)?.name || id;

  const change = (apply: () => void) => {
    apply();
    setPage(1);
  };

  const revokeAll = () => {
    if (!armed) {
      setArmed(true);
      if (armTimer.current) {
        clearTimeout(armTimer.current);
      }
      armTimer.current = setTimeout(() => setArmed(false), CONFIRM_MS);
      return;
    }
    setArmed(false);
    act('revoke_all');
  };

  return (
    <Window title="Spell Library" width={1080} height={740} theme="vanderlin">
      <Window.Content>
        <div className="SpellLibrary">
          <div className="SpellLibrary__top">
            <Icon name="hat-wizard" size={1.8} className="SpellLibrary__topIcon" />
            <div className="SpellLibrary__target">
              <div className="SpellLibrary__label">Recipient</div>
              <div className="SpellLibrary__targetName">
                {target_name}
                {target_key ? ` (${target_key})` : ''}
              </div>
            </div>
            <Input
              className="SpellLibrary__search"
              fluid
              autoFocus
              placeholder="Search by name, description or type path..."
              value={search}
              onChange={(value) => change(() => setSearch(value))}
            />
            {!!search && (
              <Button
                icon="times"
                tooltip="Clear search"
                onClick={() => change(() => setSearch(''))}
              />
            )}
            <Button
              icon="trash"
              color={armed ? 'bad' : undefined}
              disabled={!target_valid || !knownCount}
              tooltip="Remove every spell this mob has. Asks for a second click."
              tooltipPosition="bottom-end"
              onClick={revokeAll}
            >
              {armed ? 'Click again to confirm' : `Revoke all (${knownCount})`}
            </Button>
          </div>

          {!target_valid && (
            <div className="SpellLibrary__notice SpellLibrary__notice--bad">
              <Icon name="exclamation-circle" /> The recipient is gone. Close this window and
              open the library on the new mob.
            </div>
          )}
          {!!mindless && (
            <div className="SpellLibrary__notice">
              <Icon name="info-circle" /> This mob has no mind: spells will belong to the body
              and will not follow the player into another one.
            </div>
          )}
          {!!status_message && (
            <div className={`SpellLibrary__notice SpellLibrary__notice--${status_type}`}>
              <Icon name={status_type === 'bad' ? 'exclamation-circle' : 'check-circle'} />{' '}
              {status_message}
            </div>
          )}

          <div className="SpellLibrary__main">
            <div className="SpellLibrary__side">
              <div className="SpellLibrary__sideHead">Power source</div>
              {[{ id: 'all', name: 'All spells' }, ...sources].map((entry) => {
                const count = counts[entry.id] || 0;
                if (entry.id !== 'all' && !count && source !== entry.id) {
                  return null;
                }
                return (
                  <div
                    key={entry.id}
                    className={`SpellLibrary__nav${source === entry.id ? ' SpellLibrary__nav--on' : ''}`}
                    onClick={() => change(() => setSource(entry.id))}
                  >
                    <Icon
                      name={SOURCE_ICONS[entry.id] || 'book'}
                      className="SpellLibrary__navIcon"
                    />
                    <span>{entry.name}</span>
                    <span className="SpellLibrary__count">{count}</span>
                  </div>
                );
              })}
              <div className="SpellLibrary__sideHead">Show</div>
              {(
                [
                  ['all', 'Everything', 'list'],
                  ['known', 'Only owned', 'check'],
                  ['unknown', 'Hide owned', 'eye-slash'],
                ] as [Ownership, string, string][]
              ).map(([id, label, icon]) => (
                <div
                  key={id}
                  className={`SpellLibrary__nav${ownership === id ? ' SpellLibrary__nav--on' : ''}`}
                  onClick={() => change(() => setOwnership(id))}
                >
                  <Icon name={icon} className="SpellLibrary__navIcon" />
                  <span>{label}</span>
                  {id === 'known' && <span className="SpellLibrary__count">{knownCount}</span>}
                </div>
              ))}
            </div>

            <div className="SpellLibrary__content">
              <div className="SpellLibrary__bar">
                <div className="SpellLibrary__chips">
                  {[{ id: 'all', name: 'Any delivery' }, ...kinds].map((entry) => (
                    <Button
                      key={entry.id}
                      selected={kind === entry.id}
                      onClick={() => change(() => setKind(entry.id))}
                    >
                      {entry.name}
                    </Button>
                  ))}
                </div>
                <div className="SpellLibrary__pager">
                  <span className="SpellLibrary__found">{filtered.length} found</span>
                  <Button
                    icon="chevron-left"
                    disabled={currentPage <= 1}
                    onClick={() => setPage(currentPage - 1)}
                  />
                  <span>
                    {currentPage} / {pages}
                  </span>
                  <Button
                    icon="chevron-right"
                    disabled={currentPage >= pages}
                    onClick={() => setPage(currentPage + 1)}
                  />
                </div>
              </div>

              <div
                className="SpellLibrary__scroll"
                key={`${source}:${kind}:${ownership}:${currentPage}:${search}`}
              >
                {visible.length === 0 && (
                  <div className="SpellLibrary__empty">
                    No spell matches. Change the search or the filters.
                  </div>
                )}
                <div className="SpellLibrary__grid">
                  {visible.map((spell) => {
                    const known = !!known_spells[spell.path];
                    return (
                      <div
                        key={spell.path}
                        className={`SpellLibrary__card${known ? ' SpellLibrary__card--known' : ''}`}
                      >
                        <div className="SpellLibrary__cardHead">
                          <div className="SpellLibrary__icon">
                            <DmIcon
                              icon={spell.icon}
                              icon_state={spell.icon_state}
                              fallback={<Icon name="magic" />}
                              width="32px"
                              height="32px"
                            />
                          </div>
                          <div className="SpellLibrary__cardTitle">
                            <div className="SpellLibrary__name">{spell.name}</div>
                            <div className="SpellLibrary__meta">
                              {sourceName(spell.source)} · {kindName(spell.kind)}
                              {spell.school ? ` · ${spell.school}` : ''}
                            </div>
                          </div>
                          {known && (
                            <Tooltip content="The recipient has this spell">
                              <Icon name="check" className="SpellLibrary__owned" />
                            </Tooltip>
                          )}
                        </div>
                        <div className="SpellLibrary__desc">
                          {spell.desc || 'No description.'}
                        </div>
                        <div className="SpellLibrary__stats">
                          {spell.charge_time > 0 && (
                            <span>
                              <Icon name="hourglass-half" /> {seconds(spell.charge_time)}
                            </span>
                          )}
                          {spell.cooldown > 0 && (
                            <span>
                              <Icon name="redo" /> {seconds(spell.cooldown)}
                            </span>
                          )}
                          {spell.cost > 0 && (
                            <span>
                              <Icon name="coins" /> {spell.cost}
                            </span>
                          )}
                          {spell.range > 0 && (
                            <span>
                              <Icon name="ruler" /> {spell.range}
                            </span>
                          )}
                        </div>
                        <div className="SpellLibrary__path">{spell.path}</div>
                        <Button
                          fluid
                          icon={known ? 'minus' : 'plus'}
                          color={known ? 'bad' : 'good'}
                          disabled={!target_valid}
                          onClick={() => act(known ? 'revoke' : 'grant', { path: spell.path })}
                        >
                          {known ? 'Revoke' : 'Grant'}
                        </Button>
                      </div>
                    );
                  })}
                </div>
              </div>
              <div className="SpellLibrary__legend">
                <Icon name="hourglass-half" /> charge time · <Icon name="redo" /> cooldown ·{' '}
                <Icon name="coins" /> cost · <Icon name="ruler" /> range in tiles
              </div>
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
