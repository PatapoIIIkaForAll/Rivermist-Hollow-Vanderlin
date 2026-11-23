import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BackendState = 'ok' | 'down' | 'checking' | 'off';
type Direction = 'ru_en' | 'en_ru';
type ProviderChoice = 'configured' | 'fake' | 'none';

type Data = {
  running: boolean;
  stopped_by: string | null;
  provider: string;
  provider_mode: string;
  backend_state: BackendState;
  backend_note: string | null;
  endpoint: string | null;
  can_debug: boolean;
  load: {
    world_cpu: number;
    map_cpu: number;
    time_dilation: number;
    ss_cost_ms: number;
    ss_tick_usage: number;
    ss_tick_overrun: number;
    cpu_ms_last_min: number;
    cpu_ms_total: number;
    share_percent: number;
  };
  traffic: {
    in_flight: number;
    queue_limit: number;
    dispatched: number;
    deduplicated: number;
    cache_hits: number;
    cache_misses: number;
    failed: number;
    timed_out: number;
    rejected: number;
    chars_sent: number;
    latency_last_ms: number;
    latency_avg_ms: number;
    latency_max_ms: number;
  };
  memory: {
    cache_entries: number;
    cache_limit: number;
    cache_chars: number;
    live_lines: number;
  };
  players: { total: number; to_english: number; to_russian: number };
  channels: { name: string; count: number }[];
  errors: { time: string; text: string }[];
  test: {
    status: 'idle' | 'running' | 'done' | 'failed';
    source_text: string | null;
    direction: Direction | null;
    result: string | null;
    latency_ms: number | null;
  };
};

const STATE_COLORS: Record<BackendState, string> = {
  ok: 'good',
  down: 'bad',
  checking: 'average',
  off: 'label',
};

const PROVIDER_CHOICES: { value: ProviderChoice; label: string }[] = [
  { value: 'configured', label: 'Configured' },
  { value: 'fake', label: 'Fake (debug)' },
  { value: 'none', label: 'None' },
];

const DIRECTIONS: { value: Direction; label: string }[] = [
  { value: 'ru_en', label: 'Russian to English' },
  { value: 'en_ru', label: 'English to Russian' },
];

const ms = (value: number) => `${value.toFixed(1)} ms`;
const pct = (value: number) => `${value.toFixed(1)}%`;

export function TranslationControl(props) {
  return (
    <Window title="Translation Control" width={560} height={720}>
      <Window.Content scrollable>
        <StatusSection />
        <BackendSection />
        <LoadSection />
        <Stack>
          <Stack.Item grow basis={0}>
            <TrafficSection />
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <MemorySection />
            <PlayersSection />
          </Stack.Item>
        </Stack>
        <ChannelsSection />
        <ErrorsSection />
        <TestSection />
      </Window.Content>
    </Window>
  );
}

function StatusSection(props) {
  const { act, data } = useBackend<Data>();
  const { running, stopped_by } = data;

  if (running) {
    return (
      <Section>
        <Button.Confirm
          fluid
          color="bad"
          icon="power-off"
          fontSize={1.5}
          textAlign="center"
          confirmContent="Confirm emergency stop"
          onClick={() => act('emergency_stop')}
        >
          EMERGENCY STOP
        </Button.Confirm>
      </Section>
    );
  }

  return (
    <Section>
      <NoticeBox danger>
        Translation is stopped. Stopped by {stopped_by || 'unknown'}.
      </NoticeBox>
      <Button fluid color="good" icon="play" onClick={() => act('resume')}>
        Resume
      </Button>
    </Section>
  );
}

function BackendSection(props) {
  const { act, data } = useBackend<Data>();
  const {
    provider,
    provider_mode,
    backend_state,
    backend_note,
    endpoint,
    can_debug,
  } = data;

  return (
    <Section
      title="Backend"
      buttons={
        <Button icon="sync" onClick={() => act('probe')}>
          Check backend now
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Provider">{provider}</LabeledList.Item>
        <LabeledList.Item label="State" color={STATE_COLORS[backend_state]}>
          {backend_state.toUpperCase()}
        </LabeledList.Item>
        <LabeledList.Item label="Endpoint">
          {endpoint || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Last error">
          {backend_note || 'None'}
        </LabeledList.Item>
        {can_debug && (
          <LabeledList.Item label="Set provider">
            {PROVIDER_CHOICES.map((choice) => (
              <Button
                key={choice.value}
                selected={provider_mode === choice.value}
                onClick={() => act('set_provider', { provider: choice.value })}
              >
                {choice.label}
              </Button>
            ))}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}

function LoadSection(props) {
  const { data } = useBackend<Data>();
  const { load } = data;

  return (
    <Section title="Server load">
      <LabeledList>
        <LabeledList.Item label="Translation share">
          <ProgressBar
            value={load.share_percent}
            maxValue={10}
            ranges={{
              good: [-Infinity, 1],
              average: [1, 5],
              bad: [5, Infinity],
            }}
          >
            {pct(load.share_percent)} of server time
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="World CPU">
          <ProgressBar
            value={load.world_cpu}
            maxValue={100}
            ranges={{
              good: [-Infinity, 60],
              average: [60, 90],
              bad: [90, Infinity],
            }}
          >
            {pct(load.world_cpu)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="CPU last minute">
          {ms(load.cpu_ms_last_min)}
        </LabeledList.Item>
        <LabeledList.Item label="CPU this round">
          {ms(load.cpu_ms_total)}
        </LabeledList.Item>
        <LabeledList.Item label="Map CPU">{pct(load.map_cpu)}</LabeledList.Item>
        <LabeledList.Item label="Time dilation">
          {pct(load.time_dilation)}
        </LabeledList.Item>
        <LabeledList.Item label="Subsystem cost">
          {ms(load.ss_cost_ms)}
        </LabeledList.Item>
        <LabeledList.Item label="Subsystem tick usage">
          {pct(load.ss_tick_usage)}
        </LabeledList.Item>
        <LabeledList.Item label="Subsystem overrun">
          {pct(load.ss_tick_overrun)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

function TrafficSection(props) {
  const { data } = useBackend<Data>();
  const { traffic } = data;
  const lookups = traffic.cache_hits + traffic.cache_misses;
  const hitRate = lookups > 0 ? (traffic.cache_hits / lookups) * 100 : 0;

  return (
    <Section title="Traffic">
      <LabeledList>
        <LabeledList.Item label="In flight">
          {traffic.in_flight} / {traffic.queue_limit}
        </LabeledList.Item>
        <LabeledList.Item label="Sent">{traffic.dispatched}</LabeledList.Item>
        <LabeledList.Item label="Deduplicated">
          {traffic.deduplicated}
        </LabeledList.Item>
        <LabeledList.Item label="Cache hit rate">
          {lookups > 0 ? pct(hitRate) : 'No lookups'}
        </LabeledList.Item>
        <LabeledList.Item label="Cache hits">
          {traffic.cache_hits}
        </LabeledList.Item>
        <LabeledList.Item label="Cache misses">
          {traffic.cache_misses}
        </LabeledList.Item>
        <LabeledList.Item label="Failed">{traffic.failed}</LabeledList.Item>
        <LabeledList.Item label="Timed out">
          {traffic.timed_out}
        </LabeledList.Item>
        <LabeledList.Item label="Rejected">{traffic.rejected}</LabeledList.Item>
        <LabeledList.Item label="Characters sent">
          {traffic.chars_sent}
        </LabeledList.Item>
        <LabeledList.Item label="Latency last">
          {ms(traffic.latency_last_ms)}
        </LabeledList.Item>
        <LabeledList.Item label="Latency average">
          {ms(traffic.latency_avg_ms)}
        </LabeledList.Item>
        <LabeledList.Item label="Latency max">
          {ms(traffic.latency_max_ms)}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

function MemorySection(props) {
  const { act, data } = useBackend<Data>();
  const { memory } = data;

  return (
    <Section
      title="Memory"
      buttons={
        <Button icon="trash" onClick={() => act('clear_cache')}>
          Clear cache
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Cache entries">
          {memory.cache_entries} / {memory.cache_limit}
        </LabeledList.Item>
        <LabeledList.Item label="Cache characters">
          {memory.cache_chars}
        </LabeledList.Item>
        <LabeledList.Item label="Waiting lines">
          {memory.live_lines}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

function PlayersSection(props) {
  const { data } = useBackend<Data>();
  const { players } = data;

  return (
    <Section title="Players">
      <LabeledList>
        <LabeledList.Item label="Using translation">
          {players.total}
        </LabeledList.Item>
        <LabeledList.Item label="To English">
          {players.to_english}
        </LabeledList.Item>
        <LabeledList.Item label="To Russian">
          {players.to_russian}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
}

function ChannelsSection(props) {
  const { data } = useBackend<Data>();
  const channels = [...data.channels].sort((a, b) => b.count - a.count);

  return (
    <Section title="Channels">
      {channels.length === 0 ? (
        <Box color="label">No translated lines yet.</Box>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Channel</Table.Cell>
            <Table.Cell textAlign="right">Lines</Table.Cell>
          </Table.Row>
          {channels.map((channel) => (
            <Table.Row key={channel.name}>
              <Table.Cell>{channel.name}</Table.Cell>
              <Table.Cell textAlign="right">{channel.count}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}

function ErrorsSection(props) {
  const { data } = useBackend<Data>();
  const { errors } = data;

  return (
    <Section title="Recent errors">
      {errors.length === 0 ? (
        <Box color="label">No errors.</Box>
      ) : (
        <Table>
          {errors.map((error, index) => (
            // Entries carry no id, and the same text can repeat in one second.
            <Table.Row key={index}>
              <Table.Cell collapsing color="label" pr={1}>
                {error.time}
              </Table.Cell>
              <Table.Cell color="bad">{error.text}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
}

function TestSection(props) {
  const { act, data } = useBackend<Data>();
  const { test } = data;
  const [text, setText] = useState('');
  const [direction, setDirection] = useState<Direction>('ru_en');

  const send = () => {
    if (text.trim()) {
      act('test', { text, direction });
    }
  };

  return (
    <Section title="Test translation">
      <Stack vertical>
        <Stack.Item>
          <Input
            fluid
            placeholder="Text to translate"
            value={text}
            onChange={setText}
            onEnter={send}
          />
        </Stack.Item>
        <Stack.Item>
          {DIRECTIONS.map((choice) => (
            <Button
              key={choice.value}
              selected={direction === choice.value}
              onClick={() => setDirection(choice.value)}
            >
              {choice.label}
            </Button>
          ))}
          <Button
            icon="language"
            disabled={!text.trim() || test.status === 'running'}
            onClick={send}
          >
            Translate
          </Button>
        </Stack.Item>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Status">{test.status}</LabeledList.Item>
            {test.source_text !== null && (
              <LabeledList.Item label="Source">
                {test.source_text}
              </LabeledList.Item>
            )}
            {test.result !== null && (
              <LabeledList.Item
                label="Result"
                color={test.status === 'failed' ? 'bad' : undefined}
              >
                {test.result}
              </LabeledList.Item>
            )}
            {test.latency_ms !== null && (
              <LabeledList.Item label="Latency">
                {ms(test.latency_ms)}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
}
