import { beforeEach, describe, expect, it } from 'bun:test';
import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

import {
  isActive,
  loadDeclensions,
  loadDictionary,
  resetDeclensions,
  setLang,
  translateNode,
  translateText,
} from './translate';

const DICTIONARY = {
  version: 1,
  nouns: {
    throat: { nom: 'горло', gen: 'горла', acc: 'горло' },
    'left arm': { nom: 'левая рука', gen: 'левой руки', acc: 'левую руку' },
    sword: { nom: 'меч', gen: 'меча', acc: 'меч', ins: 'мечом' },
    chest: { nom: 'грудь', gen: 'груди', acc: 'грудь' },
    me: { nom: 'я', gen: 'меня', dat: 'мне', acc: 'меня' },
  },
  honorifics: {
    Sir: { nom: 'сир', gen: 'сира', dat: 'сиру', acc: 'сира' },
    Lady: { nom: 'леди', gen: 'леди', dat: 'леди', acc: 'леди' },
    'Lady Herald': {
      nom: 'леди-герольд',
      gen: 'леди-герольд',
      dat: 'леди-герольд',
      acc: 'леди-герольд',
    },
  },
  fragments: {
    'Armor stops the damage.': 'Броня поглощает урон.',
    'SNEAK ATTACK!': 'АТАКА ИСПОДТИШКА!',
    "That's a": 'Это',
  },
  patterns: [
    { re: '^(.+?) slashed themself!$', ru: '$1 ранит себя!' },
    { re: '^I slash myself!$', ru: 'Я раню себя!' },
    { re: '^(.+?) slashed (.+?)!$', ru: '$1 рубит $2|acc!' },
    { re: "^(.+?) bites (.+?)'s (.+?)!$", ru: '$1 кусает $3|acc $2|gen!' },
    { re: "^dodges (.+?)'s attack!$", ru: 'уклоняется от атаки $1|gen!' },
    {
      re: '^(.+?) (?:slashes|chops at|chops) (.+?) in the (.+?) with (.+?)!$',
      ru: '$1 рубит $2|dat $3|acc $4|ins!',
    },
    {
      re: '^(.+?) (?:slashes|chops at|chops) (.+?) in the (.+?)!$',
      ru: '$1 рубит $2|dat $3|acc!',
    },
    {
      re: '^(.+?) (?:slashes|chops at|chops) (.+?) with (.+?)!$',
      ru: '$1 рубит $2|acc $3|ins!',
    },
    { re: '^(.+?) draws (.+?)!$', ru: '$1 достаёт $2|acc!' },
    { re: '^(.+?) is dislocated\\.$', ru: 'Вывихнуло $1|acc.' },
    { re: '^BROKEN(', ru: 'never' },
  ],
};

const ALDRIC = { gen: 'сира Альдрика', acc: 'сира Альдрика' };
const IVAN = { gen: 'Ивана', dat: 'Ивану', acc: 'Ивана' };

describe('chat translation', () => {
  beforeEach(() => {
    resetDeclensions();
    loadDictionary(DICTIONARY as never);
    setLang('ru');
    loadDeclensions({ 'Sir Aldric': ALDRIC, Ivan: IVAN });
  });

  it('is active once a dictionary is loaded and the reader is on Russian', () => {
    expect(isActive()).toBe(true);
  });

  it('translates an exact fragment and keeps its padding', () => {
    expect(translateText('SNEAK ATTACK!')).toBe('АТАКА ИСПОДТИШКА!');
    expect(translateText(' Armor stops the damage.')).toBe(
      ' Броня поглощает урон.',
    );
  });

  it('declines names captured by a pattern, falling back to the raw capture', () => {
    expect(translateText('Sir Aldric slashed Ivan!')).toBe(
      'Sir Aldric рубит Ивана!',
    );
    expect(translateText('Sir Aldric slashed Goblin!')).toBe(
      'Sir Aldric рубит Goblin!',
    );
  });

  it('declines closed-set nouns and reorders captures', () => {
    expect(translateText("Sir Aldric bites Ivan's throat!")).toBe(
      'Sir Aldric кусает горло Ивана!',
    );
  });

  it('matches a fragment a tag split off its subject', () => {
    expect(translateText(" dodges Sir Aldric's attack!")).toBe(
      ' уклоняется от атаки сира Альдрика!',
    );
  });

  it('declines a thing however DM articled it', () => {
    for (const written of ['sword', 'a sword', 'the sword', 'The sword']) {
      expect(translateText(`Sir Aldric draws ${written}!`)).toBe(
        'Sir Aldric достаёт меч!',
      );
    }
  });

  it('never translates a bare noun on its own', () => {
    expect(translateText('sword')).toBe('sword');
    expect(translateText('The door slides open.')).toBe(
      'The door slides open.',
    );
  });

  it('does not let a generic verb pattern shadow the reflexive ones', () => {
    expect(translateText('Sir Aldric slashed themself!')).toBe(
      'Sir Aldric ранит себя!',
    );
    expect(translateText('I slash myself!')).toBe('Я раню себя!');
  });

  it('leaves everything alone for a reader of English', () => {
    setLang('en');
    expect(isActive()).toBe(false);
    expect(translateText('SNEAK ATTACK!')).toBe('SNEAK ATTACK!');
  });

  it('picks up declensions that arrive after a name was rendered', () => {
    expect(translateText('Sir Aldric slashed Bran!')).toBe(
      'Sir Aldric рубит Bran!',
    );
    loadDeclensions({ Bran: { acc: 'Брана' } });
    expect(translateText('Sir Aldric slashed Bran!')).toBe(
      'Sir Aldric рубит Брана!',
    );
  });

  it('keeps the hit location out of the target and lets the weapon shape win', () => {
    expect(translateText('Sir Aldric slashes me in the chest!')).toBe(
      'Sir Aldric рубит мне грудь!',
    );
    expect(translateText('Sir Aldric slashes Ivan in the left arm!')).toBe(
      'Sir Aldric рубит Ивану левую руку!',
    );
    expect(
      translateText('Sir Aldric slashes Ivan in the chest with the sword!'),
    ).toBe('Sir Aldric рубит Ивану грудь мечом!');
    expect(translateText('Sir Aldric chops at Ivan in the chest!')).toBe(
      'Sir Aldric рубит Ивану грудь!',
    );
  });

  it('splits only a title off a name, the longest first', () => {
    expect(translateText('Sir Aldric slashed Lady Herald Ivan!')).toBe(
      'Sir Aldric рубит леди-герольд Ивана!',
    );
    expect(translateText('Sir Aldric slashed Sir Bran!')).toBe(
      'Sir Aldric рубит сира Bran!',
    );
    expect(translateText('Sir Aldric slashed sword of truth!')).toBe(
      'Sir Aldric рубит sword of truth!',
    );
  });

  it('phrases limb states so any gender reads correctly', () => {
    expect(translateText('left arm is dislocated.')).toBe(
      'Вывихнуло левую руку.',
    );
    expect(translateText('throat is dislocated.')).toBe('Вывихнуло горло.');
  });

  it('translates a message node by node, the examine title included', () => {
    const node = document.createElement('div');
    node.innerHTML =
      "<span class='info'>That's a <b>меч</b>.</span><span class='danger'>SNEAK ATTACK!</span>";
    translateNode(node);
    expect(node.textContent).toBe('Это меч.АТАКА ИСПОДТИШКА!');
  });

  it('matches a line with a highlighted word whole and keeps the highlight', () => {
    const node = document.createElement('span');
    node.innerHTML = 'Sir Aldric slashes <b>Ivan</b> in the chest!';
    translateNode(node);
    expect(node.textContent).toBe('Sir Aldric рубит Ивану грудь!');
    expect(node.querySelector('b')?.textContent).toBe('Ивану');
  });
});

const STRINGS = join(
  import.meta.dir,
  '../../../../modular_rmh/modular/localization/strings',
);

function strings(file: string): [string, string][] {
  const pairs: [string, string][] = [];
  for (const raw of readFileSync(join(STRINGS, file), 'utf-8').split('\n')) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const at = line.indexOf(' = ');
    if (at < 0) continue;
    pairs.push([line.slice(0, at).trim(), line.slice(at + 3).trim()]);
  }
  return pairs;
}

describe('the module strings', () => {
  const files = readdirSync(STRINGS).filter((file) => file.endsWith('.txt'));

  it('are there', () => {
    expect(files).toContain('patterns.txt');
    expect(files).toContain('items.txt');
  });

  it('hold patterns the browser compiles, naming only captures they have', () => {
    const broken: string[] = [];
    for (const file of ['rmh_patterns.txt', 'patterns.txt']) {
      for (const [re, ru] of strings(file)) {
        let groups = 0;
        try {
          groups = (new RegExp(`${re}|`).exec('')?.length ?? 1) - 1;
        } catch (error) {
          broken.push(`${file}: ${re} (${error})`);
          continue;
        }
        for (const token of ru.matchAll(/\$(\d+)/g)) {
          if (Number(token[1]) > groups) {
            broken.push(`${file}: ${re} names $${token[1]}`);
          }
        }
      }
    }
    expect(broken).toEqual([]);
  });

  it('decline names in six cases', () => {
    const wrong: string[] = [];
    for (const file of files) {
      if (!/^(rmh_)?(items|titles|nouns|honorifics)\.txt$/.test(file)) continue;
      for (const [key, value] of strings(file)) {
        if (value.split('|').length !== 6) wrong.push(`${file}: ${key}`);
      }
    }
    expect(wrong).toEqual([]);
  });
});
