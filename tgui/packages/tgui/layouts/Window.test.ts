import { describe, expect, it } from 'bun:test';

import { resolveWindowTheme } from './Window';

describe('resolveWindowTheme', () => {
  it('gives windows without a theme the player style', () => {
    expect(resolveWindowTheme(undefined, 'vanderlin-classic')).toBe(
      'vanderlin-classic',
    );
  });

  it('gives house-theme windows the player style', () => {
    expect(resolveWindowTheme('vanderlin', 'vanderlin-classic')).toBe(
      'vanderlin-classic',
    );
    expect(resolveWindowTheme('vanderlin', 'vanderlin')).toBe('vanderlin');
  });

  it('keeps windows with their own look', () => {
    for (const own of [
      'parchment',
      'grimoire',
      'rmh-lawbook',
      'rmh-decree',
      'rmh-court',
    ]) {
      expect(resolveWindowTheme(own, 'vanderlin-classic')).toBe(own);
    }
  });

  it('falls back to the requested theme without a config', () => {
    expect(resolveWindowTheme('vanderlin', undefined)).toBe('vanderlin');
  });
});
