import { logger } from '../logging';
import { createQueue } from './handlers/chunking';

const MAX_BYOND_MESSAGE_URL_SIZE = 2048;
const PAYLOAD_CHUNK_MESSAGE_TYPE = 'payloadChunk';

/**
 * Sends an action to `ui_act` on `src_object` that this tgui window
 * is associated with.
 */
export function sendAct(
  action: string,
  payload: Record<string, unknown> = {},
): void {
  // Validate that payload is an object
  const isObject =
    typeof payload === 'object' && payload !== null && !Array.isArray(payload);
  if (!isObject) {
    logger.error(`Payload for act() must be an object, got this:`, payload);
    return;
  }

  const stringifiedPayload = JSON.stringify(payload);
  const urlSize = estimateMessageUrlSize(`act/${action}`, payload);

  if (urlSize > MAX_BYOND_MESSAGE_URL_SIZE) {
    const id = `${Date.now()}`;
    const chunks = splitPayloadIntoChunks(stringifiedPayload, id);
    createQueue({ id, chunks });
    Byond.sendMessage('oversizedPayloadRequest', {
      type: `act/${action}`,
      id,
      chunkCount: chunks.length,
    });
    return;
  }

  Byond.sendMessage(`act/${action}`, payload);
}

function estimateMessageUrlSize(type: string, payload: unknown): number {
  return Object.entries({
    type,
    payload: JSON.stringify(payload),
    tgui: 1,
    windowId: Byond.windowId,
  }).reduce(
    (url, [key, value], i) =>
      url +
      `${i > 0 ? '&' : '?'}${encodeURIComponent(key)}=${encodeURIComponent(value)}`,
    '',
  ).length;
}

function splitPayloadIntoChunks(payload: string, id: string): string[] {
  const chars = Array.from(payload);
  const chunks: string[] = [];
  let startIndex = 0;

  while (startIndex < chars.length) {
    const endIndex = findLargestSafeChunkEnd(chars, startIndex, id);
    chunks.push(chars.slice(startIndex, endIndex).join(''));
    startIndex = endIndex;
  }

  return chunks;
}

function findLargestSafeChunkEnd(
  chars: string[],
  startIndex: number,
  id: string,
): number {
  let low = startIndex + 1;
  let high = chars.length;
  let bestEnd = low;

  while (low <= high) {
    const mid = Math.floor((low + high) / 2);
    const chunk = chars.slice(startIndex, mid).join('');
    const urlSize = estimateMessageUrlSize(PAYLOAD_CHUNK_MESSAGE_TYPE, {
      id,
      chunk,
    });

    if (urlSize <= MAX_BYOND_MESSAGE_URL_SIZE) {
      bestEnd = mid;
      low = mid + 1;
    } else {
      high = mid - 1;
    }
  }

  return bestEnd;
}

export const __testables__ = {
  estimateMessageUrlSize,
  splitPayloadIntoChunks,
};
