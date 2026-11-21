import { afterEach, beforeEach, describe, expect, it } from 'bun:test';

import '../__mocks__/byond';

import { __testables__, payloadChunkCount, sendAct } from './act';
import { chunkingAtom, store } from './store';

const MAX_PAYLOAD_CHUNK_MESSAGE_URL_SIZE = 1500;

describe('tgui act chunking', () => {
  const originalSendMessage = Byond.sendMessage;

  beforeEach(() => {
    store.set(chunkingAtom, {});
  });

  afterEach(() => {
    store.set(chunkingAtom, {});
    Byond.sendMessage = originalSendMessage;
  });

  it('queues oversized act payloads instead of sending them directly', () => {
    const sentMessages: Array<{ payload: unknown; type: unknown }> = [];

    Byond.sendMessage = ((typeOrMessage, payload) => {
      if (typeof typeOrMessage === 'string') {
        sentMessages.push({ type: typeOrMessage, payload });
        return;
      }

      const message = typeOrMessage as { type: string };
      sentMessages.push({
        type: message.type,
        payload: message,
      });
    }) as typeof Byond.sendMessage;

    sendAct('submit', { entry: 'a'.repeat(2200) });

    const queues = store.get(chunkingAtom);
    const [id, chunks] = Object.entries(queues)[0] as [string, string[]];

    expect(sentMessages).toEqual([
      {
        type: 'oversizedPayloadRequest',
        payload: {
          type: 'act/submit',
          id,
          chunkCount: chunks.length,
        },
      },
    ]);
    expect(chunks.length).toBeGreaterThan(1);
  });

  it('keeps wrapped payloadChunk messages under the BYOND url limit', () => {
    const entry = '"\n'.repeat(900);

    sendAct('submit', { entry });

    const queues = store.get(chunkingAtom);
    const [id, chunks] = Object.entries(queues)[0] as [string, string[]];

    expect(chunks.length).toBeGreaterThan(1);
    for (const chunk of chunks) {
      expect(
        __testables__.estimateMessageUrlSize('payloadChunk', { id, chunk }),
      ).toBeLessThanOrEqual(MAX_PAYLOAD_CHUNK_MESSAGE_URL_SIZE);
    }
  });
});

describe('law document preflight', () => {
  it('finds the exact 64/65 chunk boundary for a complete Cyrillic action', () => {
    const count = (length: number) =>
      payloadChunkCount('publish', {
        document: 'lawbook',
        epoch: 'round',
        revision: 7,
        editor_key: 'editor',
        content: JSON.stringify({
          title: 'Книга',
          chapters: [{ intro: 'З'.repeat(length) }],
        }),
      });
    let low = 0,
      high = 50000;
    while (low + 1 < high) {
      const middle = Math.floor((low + high) / 2);
      if (count(middle) <= 64) low = middle;
      else high = middle;
    }
    expect(count(low)).toBe(64);
    expect(count(high)).toBe(65);
  });
  it('measures the complete encoded action, including double JSON escaping', () => {
    for (const text of [
      '10% tax A+B & 100%',
      'Закон 😀 '.repeat(7000),
      'x'.repeat(90000),
    ]) {
      const payload = {
        document: 'lawbook',
        epoch: 'round',
        editor_key: 'editor',
        revision: 7,
        content: JSON.stringify({ title: text, chapters: [] }),
      };
      const count = payloadChunkCount('publish', payload);
      if (count)
        expect(count).toBe(
          __testables__.splitPayloadIntoChunks(
            JSON.stringify(payload),
            String(Date.now()),
          ).length,
        );
    }
  });
  it('rejects a large Cyrillic document before the server refuses 64 chunks', () => {
    const payload = {
      content: JSON.stringify({
        title: 'Книга',
        chapters: [{ intro: 'З'.repeat(50000) }],
      }),
    };
    expect(payloadChunkCount('save_draft', payload)).toBeGreaterThan(64);
    expect(payloadChunkCount('save_draft', { content: '[]' })).toBe(0);
  });
});
