/**
 * Admin mob picker: Players / Nearby / All tabs, a search box, one click to pick.
 */
import { useMemo, useState } from 'react';
import { Button, Icon, Input } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Entry = {
  ref: string;
  name: string;
  real_name?: string | null;
  key?: string | null;
  online: boolean;
  job: string;
  kind: 'npc' | 'ghost' | 'dead';
  area: string;
  distance: number;
};

type Tab = 'players' | 'nearby' | 'all';

type Data = {
  title: string;
  message: string;
  default_tab: Tab;
  near: number;
  mobs: Entry[];
};

const TABS: [Tab, string, string][] = [
  ['players', 'Players', 'users'],
  ['nearby', 'Nearby', 'street-view'],
  ['all', 'All', 'globe'],
];

/** The All tab can hold thousands of mobs; only this many rows are drawn. */
const ROW_LIMIT = 300;

const entryIcon = (entry: Entry) => {
  if (entry.kind === 'ghost') {
    return 'ghost';
  }
  if (entry.kind === 'dead') {
    return 'skull';
  }
  return entry.key ? 'user' : 'paw';
};

export const AdminMobPicker = () => {
  const { act, data } = useBackend<Data>();
  const { mobs = [], near, message } = data;
  const [tab, setTab] = useState<Tab>(data.default_tab || 'players');
  const [search, setSearch] = useState('');

  const lists = useMemo(() => {
    const byName = (a: Entry, b: Entry) => a.name.localeCompare(b.name);
    const players = mobs.filter((entry) => !!entry.key).sort(byName);
    const nearby = mobs
      .filter((entry) => entry.distance >= 0 && entry.distance <= near)
      .sort((a, b) => a.distance - b.distance || byName(a, b));
    const all = [...mobs].sort(byName);
    return { players, nearby, all };
  }, [mobs, near]);

  const words = search.trim().toLowerCase().split(/\s+/).filter(Boolean);
  const shown = lists[tab].filter((entry) => {
    if (!words.length) {
      return true;
    }
    const haystack =
      `${entry.name} ${entry.real_name || ''} ${entry.key || ''} ${entry.job} ${entry.area}`.toLowerCase();
    return words.every((word) => haystack.includes(word));
  });
  const visible = shown.slice(0, ROW_LIMIT);

  return (
    <Window title={data.title || 'Pick a mob'} width={520} height={600} theme="vanderlin">
      <Window.Content>
        <div className="MobPicker">
          {!!message && <div className="MobPicker__message">{message}</div>}
          <div className="MobPicker__tabs">
            {TABS.map(([id, label, icon]) => (
              <Button
                key={id}
                icon={icon}
                selected={tab === id}
                onClick={() => setTab(id)}
              >
                {label} <span className="MobPicker__count">{lists[id].length}</span>
              </Button>
            ))}
          </div>
          <Input
            fluid
            autoFocus
            placeholder="Search name, key, job or area... (Enter picks the first)"
            value={search}
            onChange={setSearch}
            onEnter={() => visible[0] && act('pick', { ref: visible[0].ref })}
          />
          <div className="MobPicker__list">
            {visible.map((entry) => (
              <div
                key={entry.ref}
                className={`MobPicker__row${entry.key && !entry.online ? ' MobPicker__row--offline' : ''}`}
                onClick={() => act('pick', { ref: entry.ref })}
              >
                <Icon name={entryIcon(entry)} className="MobPicker__icon" />
                <div className="MobPicker__text">
                  <div className="MobPicker__name">
                    {entry.name}
                    {!!entry.real_name && (
                      <span className="MobPicker__dim"> [{entry.real_name}]</span>
                    )}
                    {!!entry.key && (
                      <span className="MobPicker__key">
                        {' '}
                        {entry.key}
                        {!entry.online && ' (offline)'}
                      </span>
                    )}
                  </div>
                  <div className="MobPicker__meta">
                    {entry.job ? `${entry.job} · ` : ''}
                    {entry.area}
                  </div>
                </div>
                {entry.distance >= 0 && (
                  <span className="MobPicker__distance">{entry.distance} tiles</span>
                )}
              </div>
            ))}
            {visible.length === 0 && (
              <div className="MobPicker__empty">
                {tab === 'nearby'
                  ? `No mob within ${near} tiles of where you are looking.`
                  : 'Nothing matches.'}
              </div>
            )}
            {shown.length > ROW_LIMIT && (
              <div className="MobPicker__empty">
                {shown.length - ROW_LIMIT} more: narrow the search.
              </div>
            )}
          </div>
          <div className="MobPicker__footer">
            <Button icon="times" onClick={() => act('cancel')}>
              Cancel
            </Button>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
