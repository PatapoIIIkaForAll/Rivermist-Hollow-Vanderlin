import { createContext, type ReactNode, useContext } from 'react';
export type RmhLanguage = 'ru' | 'en';
const Language = createContext<RmhLanguage>('ru');
export const englishTexts: Record<string, string> = {
  'символов суммарно в RU+EN': 'characters across RU+EN',
  'Сократите текст: подделка ограничена 180 секундами.':
    'Shorten the text: forgery is limited to 180 seconds.',
  '. Публикация касается только': '. Publication affects only',
  '/ 2048 · новая строка: Shift+Enter': '/ 2048 · new line: Shift+Enter',
  '/ 8192 · новая строка: Shift+Enter': '/ 8192 · new line: Shift+Enter',
  'EN / перевод': 'EN / translation',
  'EN не заполнен; показан исходник.':
    'No English translation; showing the original.',
  'English — необязательный ручной перевод':
    'English — optional manual translation',
  'RU / исходник': 'RU / source',
  '{0} глав · {1} статей': '{0} chapters · {1} articles',
  'Без названия': 'Untitled',
  Бургомистр: 'Burgmeister',
  'В книге ещё нет глав.': 'The book has no chapters yet.',
  'В опубликованной книге пока нет глав.':
    'The published book has no chapters yet.',
  'Версия книги': 'Book language',
  'Версия текста': 'Text language',
  'Взять опубликованное': 'Use published version',
  'Взять текущий EN': 'Use current English',
  'Время переписывания:': 'Rewriting time:',
  Вступление: 'Introduction',
  'Вся книга': 'Entire book',
  Выше: 'Move up',
  ГЛАВА: 'CHAPTER',
  'Глава {0}': 'Chapter {0}',
  'Глава выше': 'Move chapter up',
  'Глава ниже': 'Move chapter down',
  'Глашатай Ривермиста': 'Herald of Rivermist',
  Готово: 'Done',
  'Град Ривермист · Tome of Justice': 'Rivermist · Tome of Justice',
  'Град Ривермист · стенд писаря': "Rivermist · scribe's stand",
  'Действующих указов нет.': 'There are no active decrees.',
  'Добавить закон': 'Add law',
  'Добавить статью': 'Add article',
  'Добавьте первую главу книги.': 'Add the first chapter.',
  'Добавьте первую личную запись.': 'Add your first private note.',
  'Доступно чтение. Для правки нужны открытый замок, должность Бургомистра или советника, грамотность и возможность работать со стендом.':
    'Read only. Editing requires an unlocked stand, the Burgmeister or Councilor office, literacy and the ability to work at the stand.',
  Дублировать: 'Duplicate',
  'Заголовок статьи': 'Article heading',
  'Заготовки этого персонажа и должности. Загрузка черновика не публикует документ.':
    'Drafts for this character and office. Loading a draft does not publish it.',
  'Загрузить в рабочую копию': 'Load working copy',
  'Загрузить сохранённые': 'Load saved notes',
  'Законы ещё не внесены.': 'No laws have been entered yet.',
  'Законы земель Ривермиста': 'Laws of Rivermist',
  'Закрыть окно': 'Close window',
  'Заменить рабочий текст': 'Replace working text',
  'Замок закрыт': 'Locked',
  'Замок открыт': 'Unlocked',
  Запись: 'Note',
  'Исходные указы объявляются через THROAT. Здесь можно опубликовать их ручной перевод.':
    'Source decrees are issued through THROAT. Their manual translations can be published here.',
  'Исходный текст': 'Source text',
  'Как будет выглядеть': 'Preview',
  Книга: 'Book',
  'Книга законов': 'Lawbook',
  'Книга законов · Ривермист': 'Lawbook · Rivermist',
  'Копия основана на другой редакции или прошлом раунде. Сверьте её с опубликованным документом.':
    'This copy is based on another revision or an earlier round. Compare it with the published document.',
  'Краткие формулировки действующих законов. Свод публикуется отдельно от подробной книги.':
    'Concise statements of the current laws. The code is published independently of the detailed book.',
  'Личные записи': 'Private notes',
  'Личные записи этого персонажа и должности. Сохраняются только по кнопке.':
    'Private notes for this character and office. Saved only when you press Save.',
  'Личный архив': 'Private archive',
  Название: 'Title',
  'Название главы': 'Chapter title',
  'Название книги': 'Book title',
  Ниже: 'Move down',
  'Ничего не найдено.': 'Nothing found.',
  'Новая глава': 'New chapter',
  'Новая запись': 'New note',
  'Новая статья': 'New article',
  'Новый закон': 'New law',
  'Новый закон — введите текст.': 'New law — enter its text.',
  'ОФИЦИАЛЬНОЕ ИЗДАНИЕ': 'OFFICIAL EDITION',
  Обновить: 'Refresh',
  'Опубликованная книга законов · редакция': 'Published lawbook · revision',
  Опубликованное: 'Published version',
  'Опубликованные указы': 'Published decrees',
  'Опубликовать EN этого указа': "Publish this decree's English translation",
  'Опубликовать книгу': 'Publish book',
  'Опубликовать свод': 'Publish code',
  'Основа: ред.': 'Based on rev.',
  'Основа: редакция': 'Based on revision',
  'Официальная редакция': 'Official edition',
  'Официальные документы': 'Official documents',
  'Очистить свод': 'Clear code',
  'Перевод вводится вручную для тех же глав и статей. Публикуются оба языка. Если перевод поля отсутствует, читатель увидит исходник. Добавление и удаление глав или статей меняет общую структуру книги.':
    'Enter translations for the same chapters and articles. Both languages are published together. Missing fields fall back to the original. Adding or deleting chapters and articles changes the shared book structure.',
  'Перевод вводится вручную. Публикуются оба языка свода с общей редакцией. Если EN не заполнен, читатель увидит исходный текст. После правки исходника проверьте перевод.':
    'Translations are entered manually. Both languages share one code revision. Missing English falls back to the original. Review translations after editing the source.',
  'Перевод публикуется отдельно для выбранного указа. Пустой EN означает показ исходника.':
    'Translations are published separately for each decree. Empty English falls back to the original.',
  'Переместить окно': 'Move window',
  'Перенести на постер': 'Copy to poster',
  Переписать: 'Rewrite',
  'Переписать постер': 'Rewrite poster',
  'Переписывание…': 'Rewriting…',
  'По одному своду и одной книге для каждого персонажа и должности. Сохранённые тексты доступны после нового входа в раунд.':
    'One code and one book per character and office. Saved texts remain available after joining another round.',
  'Подробные законы града, разделённые по главам. Книга публикуется независимо от краткого свода.':
    'Detailed town laws arranged in chapters. The book is published independently of the concise code.',
  Подтвердить: 'Confirm',
  'Поиск по главам и статьям': 'Search chapters and articles',
  'Поиск по разделу': 'Search this section',
  'Поиск по указам': 'Search decrees',
  'Править главу': 'Edit chapter',
  'Править закон': 'Edit law',
  'Править статью': 'Edit article',
  'Применить мой текст поверх текущей редакции':
    'Apply my text over the current revision',
  'Рабочая копия': 'Working copy',
  'Разделы документов': 'Document sections',
  'Редактировать EN': 'Edit English',
  'Редакция документа': 'Document revision',
  'Редакция изменилась. Скопируйте свой текст перед загрузкой текущего EN.':
    'The revision changed. Copy your text before loading the current English version.',
  Свод: 'Code',
  'Свод законов': 'Law code',
  'Свод пуст.': 'The code is empty.',
  'Скопировать указ': 'Copy decree',
  Советник: 'Councilor',
  'Совпадений не найдено.': 'No matches.',
  'Сохранить записи': 'Save notes',
  'Сохранить черновик': 'Save draft',
  'Сохранённого черновика нет. Откройте документ и нажмите «Сохранить черновик».':
    'No saved draft. Open a document and press Save draft.',
  'Сохранённые записи изменились в другом окне. Скопируйте нужный текст перед загрузкой.':
    'Saved notes changed in another window. Copy any text you need before reloading.',
  Статья: 'Article',
  'Статья {0}': 'Article {0}',
  'Статья выше': 'Move article up',
  'Статья ниже': 'Move article down',
  Текст: 'Text',
  'Текст постера': 'Poster text',
  'Текст статьи': 'Article text',
  'Текст статьи ещё не введён.': 'The article text has not been entered yet.',
  'Текущий текст рабочей копии будет заменён. Перед публикацией проверьте актуальность редакции.':
    'This replaces your current working text. Check the publication revision before publishing.',
  Удалить: 'Delete',
  'Удалить главу и статьи': 'Delete chapter and articles',
  'Удалить закон': 'Delete law',
  'Удалить запись': 'Delete note',
  'Удалить статью': 'Delete article',
  'Удалить черновик': 'Delete draft',
  Указ: 'Decree',
  'Указ {0}': 'Decree {0}',
  'Указ № {0}': 'Decree No. {0}',
  'Указов не найдено.': 'No decrees found.',
  Указы: 'Decrees',
  'Указы Бургомистра': "Burgmeister's decrees",
  'Черновик сохраняется только по кнопке. Несохранённый текст остаётся в этом окне.':
    'Drafts are saved only when you press Save. Unsaved text stays in this window.',
  Черновики: 'Drafts',
  'Черновики документов': 'Document drafts',
  'Черновики писаря': "Scribe's drafts",
  Читатель: 'Reader',
  глав: 'chapters',
  законов: 'laws',
  записей: 'notes',
  'из прошлого раунда': 'from an earlier round',
  книги: 'book',
  редакция: 'revision',
  свода: 'code',
  'сек. Не уходите и держите тату-машинку. Закрытие окна отменяет работу. Официальный указ не изменится.':
    'sec. Stay nearby and hold the tattoo machine. Closing this window cancels the work. The official decree will not change.',
  статей: 'articles',
  указов: 'decrees',
  черновиков: 'drafts',
};
// Court and document labels use the same locale dictionary.
Object.assign(englishTexts, {
  Двор: 'Court',
  Указы: 'Decrees',
  Управление: 'Governance',
  Правосудие: 'Justice',
  Геральдика: 'Heraldry',
  'Голосовые команды': 'Voice commands',
  'Нужна корона.': 'The crown is required.',
  'Только правитель или регент.': 'Ruler or regent required.',
  'THROAT набирается сил.': 'THROAT is gathering strength.',
  Корона: 'Crown',
  Надета: 'Worn',
  'Не надета': 'Not worn',
  Налог: 'Tax',
  'Глас трона': 'Throne voice',
  Готов: 'Ready',
  'Набирается сил': 'Gathering strength',
  'Положение двора': 'Court standing',
  'Действующие указы': 'Active decrees',
  'Вне закона': 'Outlaws',
  'Корона в землях': 'Crown in the realm',
  Есть: 'Present',
  'Не найдена': 'Not registered',
  'Ключ правителя': 'Ruler key',
  'Не найден': 'Not registered',
  'Законы града публикуются на стенде писаря. Здесь издаются и отзываются указы.':
    'Town laws are published at the scribe stand. Issue and revoke decrees here.',
  'Голосовой режим: ': 'Voice mode: ',
  'Действующих указов нет.': 'There are no active decrees.',
  Указ: 'Decree',
  Подтвердить: 'Confirm',
  Отозвать: 'Revoke',
  'Новый указ': 'New decree',
  'Издать указ': 'Issue decree',
  'Знамя града': 'Town standard',
  'Основной цвет': 'Primary',
  'Второй цвет': 'Secondary',
  'Изменить цвета': 'Change colours',
  'Выбрать гербовые цвета существующим порядком.':
    'Choose heraldic colours through the existing selectors.',
  'Голосовые команды THROAT': 'THROAT voice commands',
  'Команды произносятся рядом с троном. Действуют обычные проверки полномочий.':
    'Speak commands beside the throne. The normal authority checks apply.',
  'Справка THROAT': 'THROAT help',
  Объявления: 'Announcements',
  'Объявить всем землям': 'Address the realm',
  Объявить: 'Announce',
  'Управление градом': 'Town governance',
  'Текущий налог': 'Current tax',
  'Изменить налог': 'Set taxes',
  'Открыть существующий выбор налога.': 'Open the existing tax selector.',
  'Объявить вне закона': 'Declare outlaw',
  Помиловать: 'Pardon',
  Правитель: 'Ruler',
  Нет: 'None',
  Регент: 'Regent',
  'Двор Ривермиста': 'Court of Rivermist',
  'Воля града звучит через THROAT':
    'The voice of the town speaks through THROAT',
  'Ваш статус': 'Your standing',
  Подданный: 'Subject',
  Обновить: 'Refresh',
  'Разделы двора': 'Court sections',
  Регалии: 'Regalia',
  'Призвать корону': 'Summon crown',
  'Позвать существующую корону.': 'Call the existing crown.',
  'Призвать ключ': 'Summon key',
  'Нужна надетая корона.': 'Requires the worn crown.',
  'Приказы двору': 'Court orders',
  'Назначить регента': 'Appoint regent',
  'Назначить представителя правителя.': 'Appoint the ruler’s representative.',
  'Изменить должность': 'Change position',
  'Изменить службу подданного.': 'Change a subject’s office.',
  'Потребовать тишины в зале.': 'Demand silence in the hall.',
  'Документ слишком велик для отправки. Текст сохранён в окне; сократите его перед повтором.':
    'The document is too large to send. Your text is still in this window; shorten it before retrying.',
  'Глобальное оглашение (с перезарядкой)':
    'Global announcement (subject to cooldown)',
});
export function rmhText(
  language: RmhLanguage,
  text: string,
  ...values: (string | number)[]
) {
  const key = text.trim();
  let result = language === 'ru' ? key : englishTexts[key] || key;
  result = result.replace(/\{(\d+)\}/g, (_, index) =>
    String(values[Number(index)] ?? ''),
  );
  const lead = text.match(/^\s*/)?.[0] || '',
    tail = text.match(/\s*$/)?.[0] || '';
  return lead + result + tail;
}
export function RmhLocaleProvider({
  language,
  children,
}: {
  language?: string;
  children: ReactNode;
}) {
  return (
    <Language.Provider value={language === 'ru' ? 'ru' : 'en'}>
      {children}
    </Language.Provider>
  );
}
export function useRmhLanguage() {
  return useContext(Language);
}
export function useRmhText() {
  const language = useRmhLanguage();
  return (text: string, ...values: (string | number)[]) =>
    rmhText(language, text, ...values);
}
