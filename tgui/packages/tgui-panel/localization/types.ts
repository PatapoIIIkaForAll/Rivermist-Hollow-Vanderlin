export type Lang = 'ru' | 'en';

export type Cases = {
  nom?: string;
  gen?: string;
  dat?: string;
  acc?: string;
  ins?: string;
  pre?: string;
};

export type CaseKey = keyof Cases;

export type RawPattern = {
  re: string;
  ru: string;
};

export type Dictionary = {
  version: number;
  nouns: Record<string, Cases>;
  honorifics?: Record<string, Cases>;
  fragments: Record<string, string>;
  patterns: RawPattern[];
};

export type CompiledPattern = {
  re: RegExp;
  ru: string;
};
