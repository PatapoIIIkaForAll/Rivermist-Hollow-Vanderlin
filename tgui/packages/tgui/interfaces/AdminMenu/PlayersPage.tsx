/**
 * Players page of the Admin Menu: the player list, and the player panel for the picked player.
 *
 * Every action is sent with the ref and ckey of the player the panel is showing, never with the
 * row that was last clicked. The server checks both again and refuses the action if the player
 * has moved on, so a command cannot land on the previous target after the selection changes.
 */
import { createContext, type ReactNode, useContext, useEffect, useRef, useState } from 'react';
import { Button, Icon, Input, Tooltip } from 'tgui-core/components';

import { useBackend } from '../../backend';
import type { AdminMenuData, PlayerDetail, PlayerEntry } from './types';

type Filter = 'all' | 'living' | 'ghost' | 'lobby' | 'antag' | 'offline' | 'staff';

const FILTERS: [Filter, string, string][] = [
  ['all', 'All', 'Everyone with a key'],
  ['living', 'In game', 'Players in a living body'],
  ['ghost', 'Ghosts', 'Observers and ghosts'],
  ['lobby', 'Lobby', 'Players who have not entered the round'],
  ['antag', 'Antags', 'Players with a special role'],
  ['offline', 'Offline', 'Bodies whose player disconnected'],
  ['staff', 'Staff', 'Admins'],
];

const CONFIRM_MS = 4000;

function matchesFilter(player: PlayerEntry, filter: Filter): boolean {
  switch (filter) {
    case 'living':
      return player.kind === 'living';
    case 'ghost':
      return player.kind === 'ghost';
    case 'lobby':
      return player.kind === 'lobby';
    case 'antag':
      return player.antag;
    case 'offline':
      return !player.connected;
    case 'staff':
      return player.admin;
    default:
      return true;
  }
}

function playerIcon(player: PlayerEntry): string {
  if (player.kind === 'lobby') {
    return 'door-open';
  }
  if (player.kind === 'ghost') {
    return 'ghost';
  }
  if (player.dead) {
    return 'skull';
  }
  return 'user';
}

type ActionProps = {
  action: string;
  icon: string;
  label: string;
  tip?: string;
  danger?: boolean;
  disabled?: boolean;
  selected?: boolean;
  extra?: Record<string, unknown>;
};

type PanelContextValue = {
  target: PlayerDetail;
  busy: boolean;
  armed: string | null;
  run: (target: PlayerDetail, props: ActionProps) => void;
};

const PanelContext = createContext<PanelContextValue | null>(null);

function actionKey(props: ActionProps): string {
  return `${props.action}:${JSON.stringify(props.extra || {})}`;
}

/** One player panel button. Always acts on the player the panel is showing. */
const Action = (props: ActionProps) => {
  const panel = useContext(PanelContext);
  if (!panel) {
    return null;
  }
  const isArmed = panel.armed === actionKey(props);
  return (
    <Button
      icon={isArmed ? 'exclamation-triangle' : props.icon}
      color={isArmed ? 'bad' : props.danger ? 'red' : undefined}
      selected={props.selected}
      disabled={panel.busy || props.disabled}
      tooltip={props.tip}
      onClick={() => panel.run(panel.target, props)}
    >
      {isArmed ? `Confirm: ${props.label}?` : props.label}
    </Button>
  );
};

const Group = (props: { title: string; icon: string; children: ReactNode }) => (
  <div className="AdminMenu__ppGroup">
    <div className="AdminMenu__ppGroupTitle">
      <Icon name={props.icon} /> {props.title}
    </div>
    <div className="AdminMenu__ppButtons">{props.children}</div>
  </div>
);

const Fact = (props: { label: string; children: ReactNode }) => (
  <div className="AdminMenu__fact">
    <span className="AdminMenu__factLabel">{props.label}</span>
    <span className="AdminMenu__factValue">{props.children}</span>
  </div>
);

export const PlayersPage = () => {
  const { act, data } = useBackend<AdminMenuData>();
  const players = data.players || [];
  const selected = data.selected || null;

  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<Filter>('all');
  const [pending, setPending] = useState<string | null>(null);
  const [armed, setArmed] = useState<string | null>(null);
  const [tab, setTab] = useState<'actions' | 'languages' | 'quirks'>('actions');
  const [quirkPick, setQuirkPick] = useState('');
  const armTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  // The server answered: the panel now shows the player that was clicked.
  useEffect(() => {
    setPending(null);
    setArmed(null);
  }, [selected?.ref]);

  // If the pick was refused (the mob is gone), stop waiting for it.
  useEffect(() => {
    if (!pending) {
      return;
    }
    const timer = setTimeout(() => setPending(null), 3000);
    return () => clearTimeout(timer);
  }, [pending]);

  useEffect(
    () => () => {
      if (armTimer.current) {
        clearTimeout(armTimer.current);
      }
    },
    [],
  );

  const query = search.trim().toLowerCase();
  const shown = players.filter((player) => {
    if (!matchesFilter(player, filter)) {
      return false;
    }
    if (!query) {
      return true;
    }
    return [player.name, player.real_name, player.key, player.ckey, player.job, player.old_names]
      .join(' ')
      .toLowerCase()
      .includes(query);
  });

  const pick = (player: PlayerEntry) => {
    if (selected?.ref === player.ref) {
      return;
    }
    setPending(player.ref);
    setArmed(null);
    act('select_player', { ref: player.ref });
  };

  // Buttons stay off while the panel is still showing the previously picked player.
  const busy = !!pending && pending !== selected?.ref;

  const run = (target: PlayerDetail, props: ActionProps) => {
    if (busy || props.disabled) {
      return;
    }
    const key = actionKey(props);
    if (props.danger && armed !== key) {
      setArmed(key);
      if (armTimer.current) {
        clearTimeout(armTimer.current);
      }
      armTimer.current = setTimeout(() => setArmed(null), CONFIRM_MS);
      return;
    }
    setArmed(null);
    act('player_action', {
      action: props.action,
      ref: target.ref,
      ckey: target.ckey || '',
      ...(props.extra || {}),
    });
  };

  const renderDetail = (target: PlayerDetail) => {
    const online = target.connected;
    const muted = target.muted || 0;
    const healthPct =
      target.max_health && target.health !== undefined
        ? Math.max(0, Math.min(100, (target.health / target.max_health) * 100))
        : null;
    return (
      <PanelContext.Provider value={{ target, busy, armed, run }}>
        <div className="AdminMenu__ppHead">
          <div className="AdminMenu__ppTarget">
            <span className="AdminMenu__ppActing">Acting on</span>
            <span className="AdminMenu__ppName">{target.name || '(no name)'}</span>
            <span className="AdminMenu__ppKey">
              {target.key || 'no key'}
              {!online && ' · disconnected'}
              {target.antag && ' · antagonist'}
            </span>
          </div>
          <div className="AdminMenu__ppHeadButtons">
            <Button
              icon="window-restore"
              disabled={busy}
              tooltip="Open the classic player panel window for this mob"
              onClick={() => run(target, { action: 'pp', icon: '', label: '' })}
            >
              Classic panel
            </Button>
            <Button
              icon="times"
              tooltip="Clear the selection"
              onClick={() => act('clear_player')}
            />
          </div>
        </div>

        <div className="AdminMenu__facts">
          <Fact label="Real name">{target.real_name || '—'}</Fact>
          <Fact label="Role">{target.job_title || target.job || '—'}</Fact>
          <Fact label="Mob type">{target.type}</Fact>
          <Fact label="Location">{target.location}</Fact>
          {target.stat !== undefined && (
            <Fact label="Status">
              {target.stat}
              {healthPct !== null && ` · health ${Math.round(target.health || 0)}/${target.max_health}`}
              {target.godmode ? ' · godmode' : ''}
            </Fact>
          )}
          {target.is_new_player && <Fact label="Status">Hasn't entered the game</Fact>}
          {online && (
            <>
              <Fact label="Rank">{target.rank}</Fact>
              {target.playtime !== undefined && <Fact label="Playtime">{target.playtime}</Fact>}
              <Fact label="First seen">{target.first_seen || '—'}</Fact>
              <Fact label="BYOND account">{target.account_date || '—'}</Fact>
              <Fact label="BYOND version">{target.byond_version}</Fact>
              <Fact label="Player Quality">
                {target.pq} ({target.pq_num})
              </Fact>
            </>
          )}
          <Fact label="IP">{target.ip || '—'}</Fact>
          {target.is_living && <Fact label="Patron">{target.patron || 'NA'}</Fact>}
          {target.is_human && <Fact label="Curses">{target.curses || 'NA'}</Fact>}
        </div>

        <div className="AdminMenu__ppTabs">
          <Button selected={tab === 'actions'} icon="hand-pointer" onClick={() => setTab('actions')}>
            Actions
          </Button>
          <Button selected={tab === 'languages'} icon="language" onClick={() => setTab('languages')}>
            Languages
          </Button>
          <Button
            selected={tab === 'quirks'}
            icon="dna"
            disabled={!target.is_human}
            tooltip={target.is_human ? undefined : 'Quirks only exist on human mobs'}
            onClick={() => setTab('quirks')}
          >
            Quirks
          </Button>
        </div>

        {tab === 'actions' && (
          <>
            <Group title="Inspect" icon="search">
              <Action
                action="vv"
                icon="search-plus"
                label="VV"
                disabled={!data.can_varedit}
                tip={data.can_varedit ? 'View Variables' : 'Needs +VAREDIT'}
              />
              {target.has_mind ? (
                <Action action="traitor" icon="mask" label="Traitor panel" tip="Roles and objectives" />
              ) : (
                <Action action="initmind" icon="brain" label="Init Mind" tip="Give this mob a mind" />
              )}
              <Action action="logs" icon="file-alt" label="Logs" tip="Individual logs" />
              <Action action="notes" icon="sticky-note" label="Notes" tip="Notes, messages, watchlist" />
              <Action action="moreinfo" icon="info-circle" label="More info" tip="Print a summary to chat" />
              <Action action="playtime" icon="clock" label="Playtime" disabled={!online} />
              <Action
                action="skills"
                icon="chart-bar"
                label="Skills"
                disabled={!target.has_attributes}
                tip="Attribute and skill editor"
              />
            </Group>

            <Group title="Talk" icon="comments">
              <Action action="pm" icon="envelope" label="Admin PM" disabled={!target.ckey} />
              <Action action="subtle" icon="comment-dots" label="Subtle message" tip="A voice in their head" />
              <Action action="narrate" icon="feather" label="Narrate to" tip="Direct narrate" />
              <Action action="forcespeech" icon="comment" label="Force speech" tip="Needs +FUN" />
            </Group>

            <Group title="Move" icon="location-arrow">
              <Action action="jumpto" icon="location-arrow" label="Jump to" />
              <Action action="follow" icon="eye" label="Follow" tip="Observe-follow as a ghost" />
              <Action action="getmob" icon="people-arrows" label="Get" tip="Bring them to you (asks to confirm)" />
              <Action action="sendmob" icon="share" label="Send to" tip="Send them to an area" />
            </Group>

            <Group title="Game" icon="dice">
              <Action
                action="heal"
                icon="heart"
                label="Heal"
                disabled={target.is_new_player}
                tip="Full heal / revive"
              />
              <Action action="smite" icon="bolt" label="Smite" danger tip="Needs +ADMIN or +FUN" />
              <Action action="patron" icon="pray" label="Patron" disabled={!target.is_human} />
              <Action action="curses" icon="skull-crossbones" label="Curses" disabled={!target.is_human} />
              <Action action="job" icon="briefcase" label="Set job" disabled={!target.has_mind} />
              <Action action="makeanimal" icon="paw" label="Make animal" danger tip="Needs +SPAWN" />
              <Action action="languagemenu" icon="language" label="Language menu" />
              <Action
                action="spells"
                icon="hat-wizard"
                label="Spells"
                disabled={target.is_new_player}
                tip="Spell Library: grant and revoke spells. Needs +FUN"
              />
            </Group>

            <Group title="Player Quality & Triumphs" icon="star">
              <Action action="showpq" icon="star-half-alt" label="Check PQ" disabled={!online} />
              <Action action="editpq" icon="star" label="Modify PQ" disabled={!online} />
              <Action action="showtriumphs" icon="trophy" label="Check Triumphs" disabled={!online} />
              <Action action="edittriumphs" icon="trophy" label="Modify Triumphs" disabled={!target.key} />
            </Group>

            <Group title="Moderation" icon="gavel">
              <Action action="kick" icon="sign-out-alt" label="Kick" danger />
              <Action action="ban" icon="gavel" label="Ban" tip="Open the ban panel for this player" />
              <Action action="roleban" icon="user-slash" label="Role bans" disabled={!online} />
              <Action action="whitelist" icon="key" label="Whitelists" disabled={!target.ckey} />
              <Action action="boost" icon="arrow-up" label="Job boost" disabled={!target.ckey} />
              <Action action="lobby" icon="door-open" label="Send to lobby" danger disabled={!online} />
              <Action action="cryo" icon="snowflake" label="Cryo" danger />
              <Action
                action="rights"
                icon="user-shield"
                label={target.is_admin ? 'Edit rank' : 'Make admin'}
                disabled={!online}
                tip="Needs +PERMISSIONS"
              />
            </Group>

            <Group title="Mute" icon="volume-mute">
              {data.mute_types.map((mute) => (
                <Action
                  key={mute.name}
                  action="mute"
                  icon={muted & mute.flag ? 'volume-mute' : 'volume-up'}
                  label={mute.name}
                  selected={!!(muted & mute.flag)}
                  disabled={!online}
                  extra={{ mute_type: mute.flag }}
                  tip={muted & mute.flag ? 'Muted, click to unmute' : 'Click to mute'}
                />
              ))}
              <Action
                action="mute"
                icon="ban"
                label="Toggle all"
                disabled={!online}
                extra={{ mute_type: 'all' }}
              />
            </Group>

            <Group title="Account" icon="id-card">
              <Action action="related_cid" icon="desktop" label="Related by CID" disabled={!online} />
              <Action action="related_ip" icon="network-wired" label="Related by IP" disabled={!online} />
              <Action
                action="centcom"
                icon="globe"
                label="CentCom ban DB"
                disabled={!target.centcom}
                tip={target.centcom ? 'Search the shared ban database' : 'Disabled in the config'}
              />
            </Group>
          </>
        )}

        {tab === 'languages' && (
          <div className="AdminMenu__ppList">
            {!target.has_mind && (
              <div className="AdminMenu__hint">
                This mob has no mind, so it has no language holder yet.
              </div>
            )}
            {target.languages.map((language) => (
              <div className="AdminMenu__ppRow" key={language.type}>
                <span className={language.known ? 'AdminMenu__good' : ''}>
                  <Icon name={language.known ? 'check' : 'minus'} /> {language.name}
                </span>
                <Action
                  action={language.known ? 'remove_language' : 'add_language'}
                  icon={language.known ? 'minus' : 'plus'}
                  label={language.known ? 'Remove' : 'Grant'}
                  extra={{ language: language.type }}
                />
              </div>
            ))}
          </div>
        )}

        {tab === 'quirks' && (
          <div className="AdminMenu__ppList">
            {(target.quirks || []).length === 0 && <div className="AdminMenu__hint">No quirks.</div>}
            {(target.quirks || []).map((quirk) => (
              <div className="AdminMenu__ppRow" key={quirk.type}>
                <span>
                  {quirk.name} ({quirk.points} pts)
                </span>
                <Action
                  action="remove_quirk"
                  icon="minus"
                  label="Remove"
                  extra={{ quirk: quirk.type }}
                />
              </div>
            ))}
            <div className="AdminMenu__ppRow">
              <select
                className="AdminMenu__select"
                value={quirkPick}
                onChange={(event) => setQuirkPick(event.target.value)}
              >
                <option value="">-- Select quirk --</option>
                {['Boons', 'Vices', 'Peculiarities'].map((group) => (
                  <optgroup label={group} key={group}>
                    {(data.quirk_options || [])
                      .filter((quirk) => quirk.group === group)
                      .map((quirk) => (
                        <option value={quirk.type} key={quirk.type}>
                          {quirk.name} ({quirk.points} pts)
                        </option>
                      ))}
                  </optgroup>
                ))}
              </select>
              <Action
                action="add_quirk"
                icon="plus"
                label="Add quirk"
                disabled={!quirkPick}
                extra={{ quirk: quirkPick }}
              />
            </div>
          </div>
        )}
      </PanelContext.Provider>
    );
  };

  return (
    <div className="AdminMenu__players">
      <div className="AdminMenu__plist">
        <Input
          fluid
          placeholder="Search name, key, role, old names..."
          value={search}
          onChange={setSearch}
        />
        <div className="AdminMenu__filters">
          {FILTERS.map(([id, label, tip]) => (
            <Button
              key={id}
              selected={filter === id}
              tooltip={tip}
              onClick={() => setFilter(id)}
            >
              {label}
            </Button>
          ))}
        </div>
        <div className="AdminMenu__plistScroll">
          {shown.map((player) => (
            <div
              key={player.ref}
              className={[
                'AdminMenu__player',
                selected?.ref === player.ref && 'AdminMenu__player--on',
                pending === player.ref && 'AdminMenu__player--pending',
                !player.connected && 'AdminMenu__player--offline',
              ]
                .filter(Boolean)
                .join(' ')}
              onClick={() => pick(player)}
            >
              <Icon name={playerIcon(player)} className="AdminMenu__playerIcon" />
              <div className="AdminMenu__playerText">
                <div className="AdminMenu__playerName">
                  {player.name || player.real_name || '(no name)'}
                  {player.antag && (
                    <Tooltip content="Antagonist">
                      <Icon name="mask" className="AdminMenu__bad" ml={0.5} />
                    </Tooltip>
                  )}
                  {player.admin && (
                    <Tooltip content="Admin">
                      <Icon name="user-shield" className="AdminMenu__gold" ml={0.5} />
                    </Tooltip>
                  )}
                  {!player.connected && (
                    <Tooltip content="Disconnected">
                      <Icon name="plug" className="AdminMenu__dim" ml={0.5} />
                    </Tooltip>
                  )}
                </div>
                <div className="AdminMenu__playerMeta">
                  {player.key} · {player.job || player.kind}
                </div>
              </div>
            </div>
          ))}
          {shown.length === 0 && (
            <div className="AdminMenu__hint">
              {players.length === 0 ? 'Loading players...' : 'No player matches.'}
            </div>
          )}
        </div>
        <div className="AdminMenu__plistFoot">
          <Button icon="mask" onClick={() => act('global_action', { action: 'check_antagonists' })}>
            Check antagonists
          </Button>
          <Button
            icon="sign-out-alt"
            tooltip="Kick everyone still in the lobby (asks to confirm)"
            onClick={() => act('global_action', { action: 'kick_lobby', afk: false })}
          >
            Kick lobby
          </Button>
          <Button
            icon="user-clock"
            tooltip="Kick AFK players still in the lobby (asks to confirm)"
            onClick={() => act('global_action', { action: 'kick_lobby', afk: true })}
          >
            Kick AFK
          </Button>
        </div>
      </div>

      <div className={`AdminMenu__pp${busy ? ' AdminMenu__pp--busy' : ''}`}>
        {selected ? (
          renderDetail(selected)
        ) : (
          <div className="AdminMenu__empty">
            <Icon name="user" size={3} />
            <br />
            Pick a player on the left to see their details and the actions you can take.
          </div>
        )}
      </div>
    </div>
  );
};
