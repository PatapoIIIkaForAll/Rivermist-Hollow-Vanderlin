import { createLogger } from 'tgui/logging';
import { loadDeclensions, loadDictionary, setLang } from './translate';
import type { Cases, Dictionary, Lang } from './types';

const logger = createLogger('localization');

type LocalizationConfig = {
  lang?: Lang;
  dictionaryUrl?: string | null;
};

let fetchedUrl: string | null = null;

// The file may not be there yet. Over browse_rsc the server names it before
// the client has received it, and megabytes take a while; a CDN can fail for
// a moment. So a failed load is tried again, for about two minutes in all.
const RETRY_DELAYS_MS = [1000, 2000, 4000, 8000, 15000, 30000, 60000];

async function fetchDictionary(url: string, attempt = 0): Promise<void> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    loadDictionary((await response.json()) as Dictionary);
  } catch (error) {
    if (fetchedUrl !== url) {
      return;
    }
    if (attempt < RETRY_DELAYS_MS.length) {
      setTimeout(
        () => fetchDictionary(url, attempt + 1),
        RETRY_DELAYS_MS[attempt],
      );
      return;
    }
    fetchedUrl = null;
    logger.error(
      'failed to load the chat dictionary, staying in English',
      error,
    );
  }
}

export function localizationConfig(payload: LocalizationConfig): void {
  setLang(payload?.lang === 'ru' ? 'ru' : 'en');
  const url = payload?.dictionaryUrl;
  if (url && url !== fetchedUrl) {
    fetchedUrl = url;
    fetchDictionary(url);
  }
}

export function localizationDeclensions(payload: Record<string, Cases>): void {
  if (payload) {
    loadDeclensions(payload);
  }
}
