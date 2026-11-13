const formatTime = (seconds: number): string => {
  if (seconds <= 0) {
    return '0 сек.';
  }
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = Math.round(seconds % 60);
  if (minutes > 0) {
    return `${minutes} мин. ${remainingSeconds} сек.`;
  }
  return `${remainingSeconds} сек.`;
};

export default {
  windowTitle: 'Отверстия',
  births: {
    title: 'Роды',
    ofLimit: 'из',
    window: 'за последние 30 минут',
    growing: 'ещё растут',
    room: 'Можно ещё:',
    full: 'Места нет: новые яйца существ лежат в покое.',
    freeOnHatch: 'Места освободятся, когда растущие яйца вылупятся.',
    nextSlot: 'Следующее место через',
    clears: 'все через',
    dormant: 'яйц(а) ждут в покое.',
    min: 'мин',
    sec: 'с',
  },
  emptyState: 'Там нечего ощутить.',
  tabs: {
    status: 'Состояние',
    settings: 'Настройки',
    genetics: 'Генетика',
  },
  art: {
    show: 'Показать рисунки органов',
    hide: 'Скрыть рисунки органов',
  },
  cards: {
    front: 'Спереди',
    rear: 'Сзади',
    breasts: 'Грудь',
    stomach: 'Живот',
    ovipositor: 'Яйцеклад',
    womb: 'Матка',
  },
  wear: {
    title: 'Износ',
    tightness: 'Узость',
    feels: 'Ощущается',
    lube: 'Смазка',
    soreness: 'Боль',
    fine: 'в порядке',
    gaping: 'Зияет',
    gapingSoon: 'Вот-вот начнёт зиять',
    tightnessWords: {
      'Virgin-tight': 'девственно узко',
      Tight: 'узко',
      Average: 'обычно',
      Relaxed: 'расслабленно',
      Loose: 'свободно',
      Gaped: 'разработано',
    },
    stretchWords: {
      gaping: 'зияет',
      wide: 'растянуто',
      loosened: 'разработано',
      tight: 'туго',
      loose: 'свободно',
      snug: 'плотно',
    },
    lubeWords: {
      slick: 'скользко',
      damp: 'влажно',
      dry: 'сухо',
    },
    sorenessWords: {
      sore: 'саднит',
      raw: 'натёрто до крови',
      overused: 'измучено',
    },
  },
  fill: {
    title: 'Наполнение',
    empty: 'пусто',
    mostly: 'в основном',
    seed: 'семя',
    own: 'своё',
    holdingIn: 'Удерживается внутри',
  },
  items: {
    title: 'Внутри',
    none: 'ничего',
    outer: 'У входа',
    inner: 'Внутри',
    deep: 'Глубоко внутри',
    stuck: 'застряло',
    takeOut: 'Достать',
    pushDeeper: 'Протолкнуть глубже',
    pushOut: 'Вытолкнуть',
    pushOutHint: 'Вытолкнуть то, что попадётся. Различать их на ощупь даёт Чувствительность.',
    insert: 'Ввести',
    tuckIn: 'Вложить',
    cleavage: 'В ложбинке',
    holding: 'В руке',
    fit: 'посадка',
    seconds: 'с',
    failChance: 'шанс неудачи',
  },
  womb: {
    fertile: 'Плодородна',
    sterile: 'Бесплодна',
    contraceptive: 'под действием противозачаточного',
    pregnancy: 'Беременность',
    stage: 'стадия живота',
    seed: 'Семя внутри',
    passageEggs: 'Яйца, застрявшие в проходе',
    labour: 'Роды',
    contraction: 'схватка',
    pushing: 'потуги',
  },
  labels: {
    organ: 'ОРГАН',
    eggsInside: 'ЯЙЦА ВНУТРИ',
    stored: 'Запас',
    clutch: 'Кладка',
    capacity: 'Вместимость',
    color: 'Цвет',
    type: 'Тип',
    name: 'Имя',
    description: 'Описание',
    organDescription: 'Описание органа',
    nutrients: 'Питание',
    nutrientCost: 'Затраты',
    interval: 'Интервал',
    resourceDependent: 'Зависит от ресурсов',
    limit: 'Лимит',
    production: 'Производство',
    nextEgg: 'Следующее яйцо',
    hatchlingsInside: 'Детенышей внутри',
    stage: 'Стадия',
    scale: 'Размер',
    traits: 'Свойства',
    preview: 'Предпросмотр',
    parents: 'Родители',
    mother: 'Мать',
    father: 'Отец',
    unknown: 'Неизвестно',
    defaultColor: 'По умолчанию',
    fertilized: 'Оплодотворено',
    unfertilized: 'Не оплодотворено',
    by: 'от',
    extract: 'Вытолкнуть',
    extractAll: 'Вытолкнуть все',
    retchUp: 'Срыгнуть',
    layEggs: 'Отложить яйца',
    edit: 'Изменить',
    pickColor: 'Выбрать цвет',
    apply: 'Применить',
    reset: 'Сброс',
    profileDefault: 'Профиль',
    on: 'ВКЛ',
    off: 'ВЫКЛ',
    active: 'Активно',
    inactive: 'Неактивно',
    yes: 'Да',
    no: 'Нет',
    unknownStage: '-',
  },
  organNames: {
    ovipositor: 'ЯЙЦЕКЛАД',
    womb: 'МАТКА',
    anus: 'АНУС',
    guts: 'ЖИВОТ',
  },
  eggTypes: {
    Hardshell: 'Твердоскорлупное',
    Avian: 'Птичье',
    Softshell: 'Мягкоскорлупное',
    Parasitic: 'Паразитическое',
    Spider: 'Паучье',
    'Bog Bug': 'Болотного жука',
    Harpy: 'Гарпии',
    Embryo: 'Детеныш',
  },
  traitNames: {
    Aphrodisiac: 'Афродизиак',
    Poison: 'Яд',
    Parasite: 'Паразит',
    Accelerated: 'Ускоренное развитие',
    aphrodisiac: 'Афродизиак',
    poison: 'Яд',
    parasite: 'Паразит',
    fast_growth: 'Ускоренное развитие',
  },
  hatch: {
    inside: 'Вылупится внутри',
    outside: 'Вылупится после кладки',
    either: 'Может вылупиться внутри',
    decidedInside: 'Оно вылупится внутри меня.',
    decidedOutside: 'Оно сначала выйдет наружу.',
  },
  hatchlingWords: {
    skittering: 'шевелится',
    feeding: 'кормится',
    writhing: 'извивается',
    kicking: 'толкается',
    stirring: 'ворочается',
  },
  formatTime,
  formatFill: (volume: number, capacity: number): string =>
    `${volume} / ${capacity} ед.`,
  formatStage: (stage: number, maxStage: number): string =>
    `${stage} из ${maxStage}`,
  formatStatus: (status: string, timeLeft: number): string => {
    if (status === 'ready') {
      return 'Готово.';
    }
    if (status === 'growing') {
      if (timeLeft > 0) {
        return `Готово через ${formatTime(timeLeft)}.`;
      }
      return 'Растет.';
    }
    return 'Спит.';
  },
};
