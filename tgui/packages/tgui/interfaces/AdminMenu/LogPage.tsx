/**
 * Round Log page: what players and admins did this round, newest first.
 * Filters (categories, player, search) and paging run on the server; new lines arrive on their own.
 */
import { useEffect, useState } from 'react';
import { Button, Icon, Input } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { AdminMenuData } from './types';

const CATEGORY_ICONS: Record<string, string> = {
  attack: 'fist-raised',
  say: 'comment',
  whisper: 'comment-dots',
  emote: 'theater-masks',
  ooc: 'globe',
  looc: 'comments',
  prayer: 'pray',
  game: 'dice',
  dsay: 'skull',
  admin: 'user-shield',
  asay: 'user-secret',
  other: 'ellipsis-h',
};

export const LogPage = () => {
  const { act, data } = useBackend<AdminMenuData>();
  const log = data.log;
  const [search, setSearch] = useState(log?.search || '');

  // Keep the box in step when the server changes the filter.
  useEffect(() => {
    setSearch(log?.search || '');
  }, [log?.search]);

  if (!log) {
    return <div className="AdminMenu__empty">Loading the round log...</div>;
  }

  const selected = log.selected_categories || [];
  const filter = (changes: Record<string, unknown>) => act('log_filter', changes);
  const toggleCategory = (id: string) =>
    filter({
      categories: selected.includes(id)
        ? selected.filter((entry) => entry !== id)
        : [...selected, id],
    });
  const filtered = selected.length > 0 || !!log.player || !!log.search;

  return (
    <div className="AdminMenu__log">
      <div className="AdminMenu__logBar">
        <Input
          fluid
          placeholder="Search the round log (Enter)..."
          value={search}
          onChange={setSearch}
          onEnter={(value) => filter({ search: value })}
        />
        <Button icon="search" onClick={() => filter({ search })} />
        <select
          className="AdminMenu__select"
          value={log.player || ''}
          onChange={(event) => filter({ player: event.target.value })}
        >
          <option value="">All players</option>
          {(data.log_actors || []).map((actor) => (
            <option key={actor} value={actor}>
              {actor}
            </option>
          ))}
        </select>
        {filtered && (
          <Button
            icon="times"
            tooltip="Clear every filter"
            onClick={() => {
              setSearch('');
              filter({ categories: [], player: '', search: '' });
            }}
          />
        )}
      </div>
      <div className="AdminMenu__logCats">
        {log.categories.map((category) => (
          <Button
            key={category.id}
            icon={CATEGORY_ICONS[category.id] || 'circle'}
            selected={selected.includes(category.id)}
            onClick={() => toggleCategory(category.id)}
          >
            {category.name}
            <span className="AdminMenu__logCount">{category.count}</span>
          </Button>
        ))}
      </div>
      <div className="AdminMenu__logInfo">
        {log.matches} of {log.total} lines
        {selected.length === 0 && ' · all categories'}
        <span className="AdminMenu__logPager">
          <Button
            icon="chevron-left"
            disabled={log.page <= 1}
            onClick={() => act('log_page', { page: log.page - 1 })}
          />
          {log.page} / {log.pages}
          <Button
            icon="chevron-right"
            disabled={log.page >= log.pages}
            onClick={() => act('log_page', { page: log.page + 1 })}
          />
        </span>
      </div>
      <div className="AdminMenu__logList">
        {log.entries.map((entry) => (
          <div className={`AdminMenu__logRow AdminMenu__logRow--${entry.cat}`} key={entry.id}>
            <span className="AdminMenu__logTime">{entry.time}</span>
            <Icon
              name={CATEGORY_ICONS[entry.cat] || 'circle'}
              className="AdminMenu__logCat"
            />
            {!!entry.ckey && (
              <span
                className="AdminMenu__logWho"
                title="Show only this player"
                onClick={() => filter({ player: entry.ckey })}
              >
                {entry.ckey}
              </span>
            )}
            <span className="AdminMenu__logText">{entry.text}</span>
            {entry.x !== null && entry.x !== undefined && (
              <span
                className="AdminMenu__logJump"
                title={`Jump to ${entry.x}, ${entry.y}, ${entry.z}`}
                onClick={() => act('log_jump', { x: entry.x, y: entry.y, z: entry.z })}
              >
                <Icon name="location-arrow" />
              </span>
            )}
          </div>
        ))}
        {log.entries.length === 0 && (
          <div className="AdminMenu__empty">Nothing logged that matches.</div>
        )}
      </div>
    </div>
  );
};
