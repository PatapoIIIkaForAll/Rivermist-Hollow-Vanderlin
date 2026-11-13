import { useBackend } from '../backend';
import { Btn, Ornament, Select, Tip } from './CharacterCreator';
import { characterCreatorStrings } from './CharacterCreator.i18n';

type BadgeOption = {
  name: string;
  value: number;
  description: string;
  icon_class: string;
};

type BadgeCategory = {
  id: string;
  name: string;
  description: string;
  multiple: boolean | number;
  value: number;
  label: string;
  icon_class: string | null;
  small_icon_class: string | null;
  options: BadgeOption[];
};

type BadgeData = {
  show: boolean | number;
  overhead: string;
  categories: BadgeCategory[];
};

// Uncomment a category to restore its selector and overhead dropdown option.
// Its saved values, display code and sprites remain available on the backend.
const visibleBadgeCategories = [
  'free_use',
  // 'role',
  // 'scene_access',
  // 'looking_for',
  // 'scene_tone',
  // 'willingness',
  // 'partner',
  'pvp',
  'futa',
];

export const PreferencesBadges = () => {
  const { act, data } = useBackend<{
    preference_badges: BadgeData;
    cc_lang?: string;
  }>();
  const L = characterCreatorStrings[data.cc_lang === 'ru' ? 'ru' : 'en'].badges;
  const badges = data.preference_badges;
  if (!badges) {
    return null;
  }
  const allCategories = badges.categories ?? [];
  const categories = allCategories.filter((category) =>
    visibleBadgeCategories.includes(category.id),
  );
  // Keep a previously saved overhead selection readable until it is changed.
  const overhead = allCategories.find(
    (category) => category.id === badges.overhead,
  );
  const setValue = (category: string, value: string | number) =>
    act('pref_badge', { task: 'set', category, value });
  // The backend label is English, so an unset category shows the translated word.
  const labelOf = (category: BadgeCategory) =>
    category.value ? category.label : L.disabled;

  return (
    <>
      <Ornament>{L.title}</Ornament>
      <div className="cc-kv">
        <div className="cc-kv-label">{L.show}</div>
        <Btn
          className={badges.show ? 'on' : 'off'}
          icon={badges.show ? 'eye' : 'eye-slash'}
          title={L.showHint}
          onClick={() => act('pref_badge', { task: 'toggle_view' })}
        >
          {badges.show ? L.on : L.off}
        </Btn>
        <div className="cc-kv-label">{L.overhead}</div>
        <div className="cc-row">
          {overhead?.small_icon_class ? (
            <Tip
              className="cc-pb-icon"
              title={`${overhead.name}: ${labelOf(overhead)}`}
              body={overhead.description}
            >
              <div className={overhead.small_icon_class} />
            </Tip>
          ) : null}
          <Select
            value={overhead?.id ?? 'none'}
            placeholder={overhead?.name ?? L.none}
            title={L.overheadHint}
            options={[
              { value: 'none', label: L.none },
              ...categories.map((category) => ({
                value: category.id,
                label: category.name,
              })),
            ]}
            onChange={(value) => setValue('overhead', value)}
          />
        </div>
      </div>
      {overhead && !overhead.value ? (
        <div className="cc-hint">
          {L.enableToShow.replace('{name}', overhead.name)}
        </div>
      ) : null}
      <div className="cc-hint">{L.oocNotes}</div>
      <div className="cc-info-grid cc-pb-grid">
        {categories.map((category) => {
          const selected = category.options.find(
            (option) => option.value === category.value,
          );
          return (
            <div className="cc-info-block" key={category.id}>
              <div className="cc-info-title cc-pb-title">
                {category.icon_class ? (
                  <Tip
                    className="cc-pb-icon"
                    title={category.name}
                    body={labelOf(category)}
                  >
                    <div className={category.icon_class} />
                  </Tip>
                ) : null}
                {category.name}
              </div>
              <div className="cc-muted cc-pb-text">{category.description}</div>
              {category.multiple ? (
                <div className="cc-chips cc-pb-chips">
                  <Btn
                    className={category.value ? '' : 'gold'}
                    onClick={() => setValue(category.id, 0)}
                  >
                    {L.disabled}
                  </Btn>
                  {category.options.map((option) => (
                    <Btn
                      key={option.value}
                      className={category.value & option.value ? 'gold' : ''}
                      title={option.description || undefined}
                      onClick={() =>
                        setValue(category.id, category.value ^ option.value)
                      }
                    >
                      {option.name}
                    </Btn>
                  ))}
                </div>
              ) : (
                <Select
                  value={String(category.value || 0)}
                  placeholder={labelOf(category)}
                  options={[
                    { value: '0', label: L.disabled },
                    ...category.options.map((option) => ({
                      value: String(option.value),
                      label: option.name,
                    })),
                  ]}
                  onChange={(value) => setValue(category.id, Number(value))}
                />
              )}
              {selected?.description ? (
                <div className="cc-muted cc-pb-text">
                  {selected.description}
                </div>
              ) : null}
            </div>
          );
        })}
      </div>
    </>
  );
};
