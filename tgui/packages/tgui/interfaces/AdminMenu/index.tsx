/**
 * Admin Menu: every admin-granted command, the player panel and the controller overview in one
 * window. Layout follows the SS14 admin menu: categories on the left, folders of commands on the
 * right, search on top.
 */
import { useEffect, useMemo, useRef, useState } from 'react';
import { Button, Icon, Input, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import {
  buildCatalog,
  CATEGORIES,
  type CategoryId,
  folderIcon,
  groupByFolder,
  type MenuVerb,
  QUICK_ACCESS,
} from './catalog';
import { LogPage } from './LogPage';
import { PlayersPage } from './PlayersPage';
import type { AdminMenuData } from './types';

type Section = CategoryId | 'home' | 'mc' | 'log';

/** How long a dangerous command stays armed after the first click. */
const CONFIRM_MS = 4000;

export const AdminMenu = () => {
  const { act, data } = useBackend<AdminMenuData>();
  const [section, setSection] = useState<Section>(
    data.page === 'players'
      ? 'players'
      : data.page === 'mc'
        ? 'mc'
        : data.page === 'log'
          ? 'log'
          : 'home',
  );
  const [search, setSearch] = useState('');
  const [collapsed, setCollapsed] = useState<Record<string, boolean>>({});
  const [armed, setArmed] = useState<string | null>(null);
  const armTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const catalog = useMemo(() => buildCatalog(data.verbs || []), [data.verbs]);
  const byPath = useMemo(() => {
    const map = new Map<string, MenuVerb>();
    for (const verb of catalog) {
      map.set(verb.path, verb);
    }
    return map;
  }, [catalog]);
  const counts = useMemo(() => {
    const result: Record<string, number> = {};
    for (const verb of catalog) {
      result[verb.categoryId] = (result[verb.categoryId] || 0) + 1;
    }
    return result;
  }, [catalog]);

  // The server asked for a page (F6 opens Players): follow it even if the window was already open.
  const lastRequest = useRef(data.page_request);
  useEffect(() => {
    if (data.page_request === lastRequest.current) {
      return;
    }
    lastRequest.current = data.page_request;
    setSearch('');
    setSection(
      data.page === 'players'
        ? 'players'
        : data.page === 'mc'
          ? 'mc'
          : data.page === 'log'
            ? 'log'
            : 'home',
    );
  }, [data.page_request, data.page]);

  useEffect(
    () => () => {
      if (armTimer.current) {
        clearTimeout(armTimer.current);
      }
    },
    [],
  );

  const goTo = (next: Section) => {
    setSection(next);
    setSearch('');
    const page =
      next === 'players' || next === 'mc' || next === 'log' ? next : 'commands';
    if (page !== data.page) {
      act('set_page', { page });
    }
  };

  const runVerb = (verb: MenuVerb) => {
    if (verb.dangerous && armed !== verb.path) {
      setArmed(verb.path);
      if (armTimer.current) {
        clearTimeout(armTimer.current);
      }
      armTimer.current = setTimeout(() => setArmed(null), CONFIRM_MS);
      return;
    }
    setArmed(null);
    act('run_verb', { path: verb.path });
  };

  const query = search.trim().toLowerCase();
  const results = query
    ? catalog.filter((verb) =>
        query.split(/\s+/).every((word) => verb.haystack.includes(word)),
      )
    : [];

  const current = CATEGORIES.find((category) => category.id === section);
  const toggleFolder = (key: string) =>
    setCollapsed((old) => ({ ...old, [key]: !old[key] }));

  const favorites = data.favorites || [];
  const renderVerb = (verb: MenuVerb, showPlace?: boolean) => {
    const isArmed = armed === verb.path;
    const starred = favorites.includes(verb.path);
    const tip = (
      <div className="AdminMenu__tip">
        <b>{verb.name}</b>
        {!!verb.desc && <div>{verb.desc}</div>}
        <div className="AdminMenu__tipMeta">
          {CATEGORIES.find((category) => category.id === verb.categoryId)?.name}
          {' › '}
          {verb.folder}
          {verb.rights ? ` · needs ${verb.rights}` : ''}
          {verb.dangerous ? ' · asks to confirm' : ''}
        </div>
      </div>
    );
    return (
      <Tooltip key={verb.path} content={tip} position="bottom">
        <div
          className={[
            'AdminMenu__verb',
            verb.dangerous && 'AdminMenu__verb--danger',
            isArmed && 'AdminMenu__verb--armed',
          ]
            .filter(Boolean)
            .join(' ')}
          onClick={() => runVerb(verb)}
        >
          <Icon name={isArmed ? 'exclamation-triangle' : verb.icon} className="AdminMenu__verbIcon" />
          <div className="AdminMenu__verbText">
            <div className="AdminMenu__verbName">
              {isArmed ? 'Click again to confirm' : verb.name}
            </div>
            {showPlace && (
              <div className="AdminMenu__verbPlace">
                {CATEGORIES.find((category) => category.id === verb.categoryId)?.name}
                {' › '}
                {verb.folder}
              </div>
            )}
          </div>
          <div
            className={`AdminMenu__star${starred ? ' AdminMenu__star--on' : ''}`}
            title={starred ? 'Remove from favourites' : 'Add to favourites'}
            onClick={(event) => {
              event.stopPropagation();
              act('toggle_favorite', { path: verb.path });
            }}
          >
            <Icon name="star" />
          </div>
        </div>
      </Tooltip>
    );
  };

  const renderFolders = (verbs: MenuVerb[], prefix: string) =>
    groupByFolder(verbs).map(([folder, list]) => {
      const key = `${prefix}/${folder}`;
      const closed = !!collapsed[key];
      return (
        <div className="AdminMenu__folder" key={key}>
          <div className="AdminMenu__folderHead" onClick={() => toggleFolder(key)}>
            <Icon name={closed ? 'chevron-right' : 'chevron-down'} />
            <Icon name={folderIcon(folder)} className="AdminMenu__folderIcon" />
            <span className="AdminMenu__folderName">{folder}</span>
            <span className="AdminMenu__count">{list.length}</span>
          </div>
          {!closed && (
            <div className="AdminMenu__grid">{list.map((verb) => renderVerb(verb))}</div>
          )}
        </div>
      );
    });

  const renderHome = () => {
    const quick = QUICK_ACCESS.map((proc) =>
      catalog.find((verb) => verb.proc === proc),
    ).filter((verb): verb is MenuVerb => !!verb);
    const recent = (data.recent || [])
      .map((path) => byPath.get(path))
      .filter((verb): verb is MenuVerb => !!verb);
    const starredVerbs = favorites
      .map((path) => byPath.get(path))
      .filter((verb): verb is MenuVerb => !!verb);
    return (
      <>
        <div className="AdminMenu__folder">
          <div className="AdminMenu__folderHead AdminMenu__folderHead--static">
            <Icon name="star" className="AdminMenu__folderIcon" />
            <span className="AdminMenu__folderName">Favourites</span>
            <span className="AdminMenu__count">{starredVerbs.length}</span>
          </div>
          {starredVerbs.length > 0 ? (
            <div className="AdminMenu__grid">
              {starredVerbs.map((verb) => renderVerb(verb, true))}
            </div>
          ) : (
            <div className="AdminMenu__hint">
              Press the star on any command to keep it here. Favourites are saved for your account.
            </div>
          )}
        </div>
        <div className="AdminMenu__folder">
          <div className="AdminMenu__folderHead AdminMenu__folderHead--static">
            <Icon name="bolt" className="AdminMenu__folderIcon" />
            <span className="AdminMenu__folderName">Quick access</span>
          </div>
          <div className="AdminMenu__grid">
            <div className="AdminMenu__verb" onClick={() => goTo('players')}>
              <Icon name="users" className="AdminMenu__verbIcon" />
              <div className="AdminMenu__verbText">
                <div className="AdminMenu__verbName">Players</div>
                <div className="AdminMenu__verbPlace">{data.player_count} connected</div>
              </div>
            </div>
            <div
              className="AdminMenu__verb"
              onClick={() => act('global_action', { action: 'tickets' })}
            >
              <Icon name="ticket-alt" className="AdminMenu__verbIcon" />
              <div className="AdminMenu__verbText">
                <div className="AdminMenu__verbName">Active tickets</div>
                <div className="AdminMenu__verbPlace">{data.active_tickets} open</div>
              </div>
            </div>
            {!!data.marked && (
              <Tooltip
                content={
                  data.can_varedit
                    ? `Open View Variables on your marked datum: ${data.marked}`
                    : 'Opening the marked datum from here needs +VAREDIT'
                }
              >
                <div
                  className={`AdminMenu__verb${data.can_varedit ? '' : ' AdminMenu__verb--off'}`}
                  onClick={() => data.can_varedit && act('vv_marked')}
                >
                  <Icon name="thumbtack" className="AdminMenu__verbIcon" />
                  <div className="AdminMenu__verbText">
                    <div className="AdminMenu__verbName">VV marked datum</div>
                    <div className="AdminMenu__verbPlace">{data.marked}</div>
                  </div>
                </div>
              </Tooltip>
            )}
            {quick.map((verb) => renderVerb(verb))}
          </div>
        </div>
        {recent.length > 0 && (
          <div className="AdminMenu__folder">
            <div className="AdminMenu__folderHead AdminMenu__folderHead--static">
              <Icon name="history" className="AdminMenu__folderIcon" />
              <span className="AdminMenu__folderName">Recently used</span>
            </div>
            <div className="AdminMenu__grid">
              {recent.map((verb) => renderVerb(verb, true))}
            </div>
          </div>
        )}
        <div className="AdminMenu__folder">
          <div className="AdminMenu__folderHead AdminMenu__folderHead--static">
            <Icon name="th-large" className="AdminMenu__folderIcon" />
            <span className="AdminMenu__folderName">Categories</span>
          </div>
          <div className="AdminMenu__grid AdminMenu__grid--wide">
            {CATEGORIES.filter(
              (category) => category.id === 'players' || counts[category.id],
            ).map((category) => (
              <div
                className="AdminMenu__verb AdminMenu__verb--category"
                key={category.id}
                onClick={() => goTo(category.id)}
              >
                <Icon name={category.icon} className="AdminMenu__verbIcon" />
                <div className="AdminMenu__verbText">
                  <div className="AdminMenu__verbName">{category.name}</div>
                  <div className="AdminMenu__verbPlace">{category.hint}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
        {catalog.length === 0 && (
          <div className="AdminMenu__empty">
            You hold no admin commands right now. If you used "Adminverbs - Hide All", press
            "Adminverbs - Show" on the Admin tab.
          </div>
        )}
      </>
    );
  };

  const renderController = () => {
    const rows = data.mc?.rows || [];
    return (
      <div className="AdminMenu__folder">
        <div className="AdminMenu__folderHead AdminMenu__folderHead--static">
          <Icon name="tachometer-alt" className="AdminMenu__folderIcon" />
          <span className="AdminMenu__folderName">Master Controller</span>
          {!!data.mc?.sdql2 && (
            <Button ml={2} icon="database" onClick={() => act('sdql2_list')}>
              SDQL2 queries ({data.mc.sdql2})
            </Button>
          )}
        </div>
        {!data.can_varedit && (
          <div className="AdminMenu__hint">
            Opening a controller in View Variables needs +VAREDIT.
          </div>
        )}
        <table className="AdminMenu__mc">
          <tbody>
            {rows.map((row, index) => (
              <tr key={`${row.name}-${index}`}>
                <td className="AdminMenu__mcFlag">{row.flag}</td>
                <td className="AdminMenu__mcName">{row.name}</td>
                <td>
                  {row.ref && data.can_varedit ? (
                    <a
                      className="AdminMenu__link"
                      onClick={() => act('vv_controller', { ref: row.ref })}
                    >
                      {row.value}
                    </a>
                  ) : (
                    row.value
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  let body;
  let crumb: string;
  if (query) {
    crumb = `Search: "${search.trim()}"`;
    body =
      results.length > 0 ? (
        <div className="AdminMenu__folder">
          <div className="AdminMenu__folderHead AdminMenu__folderHead--static">
            <Icon name="search" className="AdminMenu__folderIcon" />
            <span className="AdminMenu__folderName">Matching commands</span>
            <span className="AdminMenu__count">{results.length}</span>
          </div>
          <div className="AdminMenu__grid">
            {results.map((verb) => renderVerb(verb, true))}
          </div>
        </div>
      ) : (
        <div className="AdminMenu__empty">
          No command you can use matches "{search.trim()}". Player names are searched on the
          Players page.
        </div>
      );
  } else if (section === 'home') {
    crumb = 'Home';
    body = renderHome();
  } else if (section === 'players') {
    crumb = 'Players';
    body = <PlayersPage />;
  } else if (section === 'mc') {
    crumb = 'Debug › Master Controller';
    body = renderController();
  } else if (section === 'log') {
    crumb = 'Round Log';
    body = <LogPage />;
  } else {
    crumb = current?.name || '';
    const verbs = catalog.filter((verb) => verb.categoryId === section);
    body =
      verbs.length > 0 ? (
        renderFolders(verbs, section)
      ) : (
        <div className="AdminMenu__empty">
          Your rank has no commands in this category.
        </div>
      );
  }

  return (
    <Window title="Admin Menu" width={980} height={680} theme="vanderlin">
      <Window.Content>
        <div className="AdminMenu">
          <div className="AdminMenu__top">
            <Icon name="search" className="AdminMenu__searchIcon" />
            <Input
              className="AdminMenu__search"
              fluid
              autoFocus
              placeholder="Search commands by name, description or category..."
              value={search}
              onChange={setSearch}
            />
            {!!search && (
              <Button icon="times" tooltip="Clear search" onClick={() => setSearch('')} />
            )}
            <Tooltip content={`Your rights: ${data.rights || 'none'}`}>
              <div className="AdminMenu__who">
                <Icon name="user-shield" /> {data.ckey} · {data.rank}
              </div>
            </Tooltip>
            <Button.Checkbox
              checked={data.new_menu}
              tooltip="On: admin commands live in this window and the extra admin tabs are hidden from the right panel. Off: the classic admin tabs come back. This window works either way."
              tooltipPosition="bottom-end"
              onClick={() => act('set_menu_mode', { new_menu: !data.new_menu })}
            >
              New-Adm. menu
            </Button.Checkbox>
          </div>

          {!!data.notice && (
            <div
              className={`AdminMenu__notice AdminMenu__notice--${data.notice_type}`}
              onClick={() => act('dismiss_notice')}
            >
              <Icon
                name={data.notice_type === 'bad' ? 'exclamation-circle' : 'info-circle'}
              />{' '}
              {data.notice}
              <span className="AdminMenu__noticeClose">click to dismiss</span>
            </div>
          )}

          <div className="AdminMenu__main">
            <div className="AdminMenu__side">
              <div
                className={`AdminMenu__nav${section === 'home' && !query ? ' AdminMenu__nav--on' : ''}`}
                onClick={() => goTo('home')}
              >
                <Icon name="home" className="AdminMenu__navIcon" />
                <span>Home</span>
              </div>
              {CATEGORIES.map((category) => {
                const count = counts[category.id] || 0;
                if (category.id !== 'players' && !count) {
                  return null;
                }
                return (
                  <Tooltip key={category.id} content={category.hint} position="right">
                    <div
                      className={`AdminMenu__nav${section === category.id && !query ? ' AdminMenu__nav--on' : ''}`}
                      onClick={() => goTo(category.id)}
                    >
                      <Icon name={category.icon} className="AdminMenu__navIcon" />
                      <span>{category.name}</span>
                      <span className="AdminMenu__count">
                        {category.id === 'players' ? data.player_count : count}
                      </span>
                    </div>
                  </Tooltip>
                );
              })}
              <Tooltip
                content="What players and admins did this round: combat, speech, emotes, OOC, game and admin actions, with filters and jump-to."
                position="right"
              >
                <div
                  className={`AdminMenu__nav${section === 'log' && !query ? ' AdminMenu__nav--on' : ''}`}
                  onClick={() => goTo('log')}
                >
                  <Icon name="clipboard-list" className="AdminMenu__navIcon" />
                  <span>Round Log</span>
                </div>
              </Tooltip>
              <Tooltip
                content="Subsystem status, the old MC tab. Opening entries in VV needs +VAREDIT."
                position="right"
              >
                <div
                  className={`AdminMenu__nav${section === 'mc' && !query ? ' AdminMenu__nav--on' : ''}`}
                  onClick={() => goTo('mc')}
                >
                  <Icon name="tachometer-alt" className="AdminMenu__navIcon" />
                  <span>Master Controller</span>
                </div>
              </Tooltip>
              <div className="AdminMenu__sideFoot">
                Round {data.round_time}
                <br />
                {catalog.length} commands available
              </div>
            </div>

            <div className="AdminMenu__content">
              <div className="AdminMenu__crumb">
                <Icon name="map-marker-alt" /> {crumb}
                {!!current && !query && (
                  <span className="AdminMenu__crumbHint">{current.hint}</span>
                )}
              </div>
              <div className="AdminMenu__scroll">{body}</div>
            </div>
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};
