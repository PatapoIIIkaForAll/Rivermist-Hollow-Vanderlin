import type { ReactNode } from 'react';
import { Box, TimeDisplay } from 'tgui-core/components';

export type BoardOrder = {
  id: string;
  guest: string;
  place: string | null;
  dish: string;
  drink: string;
  portion: number;
  wish: boolean;
  state: 'wait' | 'meal';
  time_left: number | null;
  drunk: boolean;
  morning: boolean;
};

export type BoardOrderEntry = {
  id: number;
  guest: string;
  dish: string;
  drink: string;
  drunk: boolean;
  served: boolean;
  paid: number;
  time: string;
};

const STRINGS = {
  en: {
    empty: 'No guest is waiting for an order.',
    logTitle: 'Settled orders',
    logEmpty: 'No order has been settled yet.',
    place: 'Table',
    dish: 'Dish',
    drink: 'Drink',
    state: 'State',
    result: 'Result',
    units: 'units',
    wish: 'only if the house has any',
    going: 'Going to the table',
    waiting: 'Waiting',
    eating: 'Eating',
    morning: 'morning order',
    noDrink: 'not served',
    failed: 'Nobody brought it',
    left: (minutes: number) => `${minutes} min left`,
    served: (paid: number) => `Served, paid ${paid}`,
  },
  ru: {
    empty: 'Сейчас никто не ждёт заказ.',
    logTitle: 'Закрытые заказы',
    logEmpty: 'Пока ни один заказ не закрыт.',
    place: 'Стол',
    dish: 'Блюдо',
    drink: 'Напиток',
    state: 'Состояние',
    result: 'Итог',
    units: 'ед.',
    wish: 'по желанию, если найдётся',
    going: 'Идёт за свой стол',
    waiting: 'Ждёт заказ',
    eating: 'Ест',
    morning: 'утренний заказ',
    noDrink: 'не подали',
    failed: 'Никто не принёс',
    left: (minutes: number) => `ещё ${minutes} мин`,
    served: (paid: number) => `Выполнен, оплачено ${paid}`,
  },
};

type Locale = (typeof STRINGS)['en'];

const Row = (props: {
  label: string;
  children: ReactNode;
  className?: string;
}) => (
  <div className="QuestBoard__CardRow">
    <span className="QuestBoard__CardLabel">{props.label}:</span>
    <span className={`QuestBoard__CardValue ${props.className || ''}`}>
      {props.children}
    </span>
  </div>
);

const getState = (t: Locale, order: BoardOrder) => {
  if (order.state === 'meal') {
    return t.eating;
  }
  if (order.time_left === null) {
    return t.going;
  }
  return (
    <>
      {t.waiting} (
      <TimeDisplay
        auto="down"
        value={order.time_left}
        format={(value) => t.left(Math.ceil(value / 600))}
      />
      )
    </>
  );
};

const OrderCard = (props: { t: Locale; order: BoardOrder }) => {
  const { t, order } = props;
  return (
    <div className="QuestBoard__HistoryRow">
      <div className="QuestBoard__HistoryTitle">
        {order.guest}
        {order.morning ? `, ${t.morning}` : ''}
      </div>
      {!!order.place && <Row label={t.place}>{order.place}</Row>}
      <Row label={t.dish}>{order.dish}</Row>
      <Row label={t.drink}>
        {`${order.drink}, ${order.portion} ${t.units}`}
        {order.wish ? ` (${t.wish})` : ''}
      </Row>
      <Row label={t.state}>{getState(t, order)}</Row>
    </div>
  );
};

const EntryCard = (props: { t: Locale; entry: BoardOrderEntry }) => {
  const { t, entry } = props;
  return (
    <div className="QuestBoard__HistoryRow">
      <div className="QuestBoard__HistoryTitle">
        {entry.guest}, {entry.time}
      </div>
      <Row label={t.dish}>{entry.dish}</Row>
      <Row label={t.drink}>
        {entry.drink}
        {entry.served && !entry.drunk ? `, ${t.noDrink}` : ''}
      </Row>
      <Row
        label={t.result}
        className={
          entry.served ? 'QuestBoard__OrderServed' : 'QuestBoard__OrderFailed'
        }
      >
        {entry.served ? t.served(entry.paid) : t.failed}
      </Row>
    </div>
  );
};

export const BoardOrders = (props: {
  lang: 'en' | 'ru';
  orders: BoardOrder[];
  log: BoardOrderEntry[];
}) => {
  const t = STRINGS[props.lang === 'ru' ? 'ru' : 'en'];
  return (
    <div className="QuestBoard__HistoryList">
      {props.orders.length === 0 && (
        <Box className="QuestBoard__Empty">{t.empty}</Box>
      )}
      {props.orders.map((order) => (
        <OrderCard key={order.id} t={t} order={order} />
      ))}
      <div className="QuestBoard__HistoryTitle">{t.logTitle}</div>
      {props.log.length === 0 && (
        <Box className="QuestBoard__Empty">{t.logEmpty}</Box>
      )}
      {props.log.map((entry) => (
        <EntryCard key={entry.id} t={t} entry={entry} />
      ))}
    </div>
  );
};
