import { afterEach, beforeEach, describe, expect, it } from 'bun:test';

import '../__mocks__/byond';

import { createQueue } from './handlers/chunking';
import { bus } from './listeners';
import { chunkingAtom, store } from './store';

describe('tgui chunking listeners', () => {
  const originalSendMessage = Byond.sendMessage;

  beforeEach(() => {
    store.set(chunkingAtom, {});
  });

  afterEach(() => {
    store.set(chunkingAtom, {});
    Byond.sendMessage = originalSendMessage;
  });

  it('handles the legacy chunk acknowledgement event name', () => {
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

    createQueue({
      id: 'payload-1',
      chunks: ['first-chunk', 'second-chunk'],
    });

    bus.dispatch({
      payload: { id: 'payload-1' },
      type: 'acknowlegePayloadChunk',
    });

    expect(store.get(chunkingAtom)).toEqual({
      'payload-1': ['second-chunk'],
    });
    expect(sentMessages).toEqual([
      {
        payload: {
          chunk: 'second-chunk',
          id: 'payload-1',
        },
        type: 'payloadChunk',
      },
    ]);
  });
});
