import type { Locale } from './types';

const locale: Locale = {
  windowTitle: 'Книга предприятия',
  enterpriseNames: {
    enterprise: 'Предприятие',
    tavern: 'Таверна',
  },
  pages: {
    overview: 'Обзор',
    premises: 'Помещения',
    menu: 'Меню',
    staff: 'Работники',
    zones: 'Отсеки и улучшения',
    commissions: 'Заказы',
  },
  labels: {
    yourRole: 'Ваша роль',
    roleManager: 'Управляющий',
    roleStaff: 'Сотрудник',
    roleOutsider: 'Посторонний',
    shift: 'Смена',
    shiftActive: 'Идёт',
    shiftInactive: 'Не начата',
    startShift: 'Начать смену',
    endShift: 'Закончить смену',
    sectionInProgress: 'Этот раздел книги пока пуст.',
    premises: 'Помещения',
    premisesMissing: 'Не найдены: книга стоит вне помещений.',
    basement: 'Подвал',
    refresh: 'Осмотреть заново',
  },
  cellKinds: {
    wall: 'Стена',
    floor: 'Пол',
    furnished: 'Пол с обстановкой',
    openSpace: 'Проём',
    door: 'Дверь',
    stairs: 'Лестница',
    ledger: 'Книга',
  },
  formatPremises: (floors, basements, tiles) =>
    `Этажей: ${floors}, подвальных уровней: ${basements}, клеток: ${tiles}`,
  formatFloor: (number) => `Этаж ${number}`,
};

export default locale;
