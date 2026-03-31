import { afterEach, beforeEach, describe, expect, it } from 'bun:test';

import '../__mocks__/byond';

import { __testables__, sendAct } from './act';
import { chunkingAtom, store } from './store';

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
      ).toBeLessThanOrEqual(2048);
    }
  });
});
