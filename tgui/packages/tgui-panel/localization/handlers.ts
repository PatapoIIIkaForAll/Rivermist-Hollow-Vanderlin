import { createLogger } from 'tgui/logging';
import { loadDeclensions, loadDictionary, setLang } from './translate';
import type { Cases, Dictionary, Lang } from './types';

const logger = createLogger('localization');

type LocalizationConfig = {
  lang?: Lang;
  dictionaryUrl?: string | null;
};

let fetchedUrl: string | null = null;

async function fetchDictionary(url: string): Promise<void> {
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    loadDictionary((await response.json()) as Dictionary);
  } catch (error) {
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
