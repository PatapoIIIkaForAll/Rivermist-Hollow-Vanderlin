import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type { KegData, KegDrink, Locale, StockData, StockEntry } from './types';
import { useIconRefs } from './useIconRefs';

const ICON_SIZE = '32px';

const getDrinkCost = (amount: number, price: number, share: number) =>
  price > 0 ? Math.max(Math.ceil((amount * price * share) / 100 - 0.01), 0) : 0;

type KegRowProps = {
  locale: Locale;
  drink: KegDrink;
  canDraw: boolean;
  share: number;
  funds: number;
  kegVolume: number;
  onPour: (id: string, amount: number) => void;
};

const KegRow = (props: KegRowProps) => {
  const { locale, drink, canDraw, share, funds, kegVolume, onPour } = props;
  const limit = Math.max(1, Math.floor(Math.min(drink.amount, kegVolume)));
  const [amount, setAmount] = useState(limit);
  const shown = Math.min(amount, limit);
  const cost = getDrinkCost(shown, drink.price, share);

  return (
    <Stack align="center" mb={0.5}>
      <Stack.Item grow>
        {drink.name}
        {!!drink.custom && (
          <Box inline color="label" ml={1}>
            ({locale.kegs.other})
          </Box>
        )}
      </Stack.Item>
      <Stack.Item color="label">{locale.formatUnits(drink.amount)}</Stack.Item>
      {canDraw && (
        <>
          <Stack.Item>
            <NumberInput
              value={shown}
              minValue={1}
              maxValue={limit}
              step={1}
              width="4.5em"
              onChange={(value) => setAmount(value)}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon={cost ? 'coins' : 'fill-drip'}
              disabled={cost > funds}
              onClick={() => onPour(drink.id, shown)}
            >
              {cost ? locale.formatDrinkCost(cost) : locale.kegs.fill}
            </Button>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

type KegSectionProps = {
  locale: Locale;
  kegs: KegData;
  level: number;
};

const KegSection = (props: KegSectionProps) => {
  const { locale, kegs, level } = props;
  const { act } = useBackend<StockData>();
  const drinks = kegs.drinks || [];
  const staff = !!kegs.staff;
  const pour = (id: string, amount: number) => act('fill_keg', { id, amount });
  const water: KegDrink = {
    id: kegs.water_id,
    name: locale.kegs.water,
    amount: kegs.water,
    custom: 0,
    price: 0,
  };
  const rowProps = {
    locale,
    share: kegs.share,
    funds: kegs.funds,
    kegVolume: kegs.keg_volume,
    onPour: pour,
  };

  return (
    <Section
      fill
      scrollable
      title={locale.kegs.title}
      buttons={
        <>
          <Button icon="arrow-down" onClick={() => act('store_keg')}>
            {locale.kegs.store}
          </Button>
          <Button
            icon="arrow-up"
            disabled={!kegs.stored}
            onClick={() => act('take_keg')}
          >
            {locale.kegs.takeEmpty}
          </Button>
        </>
      }
    >
      <Box color="label" mb={1}>
        {locale.kegs.hint}
      </Box>
      <LabeledList>
        <LabeledList.Item label={locale.room.level}>
          {locale.levelNames[level] || level}
        </LabeledList.Item>
        <LabeledList.Item label={locale.kegs.stored}>
          {kegs.keg_cap
            ? `${kegs.stored} / ${kegs.keg_cap}`
            : locale.kegs.noKegs}
        </LabeledList.Item>
        <LabeledList.Item label={locale.kegs.volume}>
          {`${kegs.volume} / ${kegs.volume_cap}`}
        </LabeledList.Item>
        <LabeledList.Item label={locale.kegs.custom}>
          {`${kegs.custom} / ${kegs.custom_cap}`}
        </LabeledList.Item>
        <LabeledList.Item label={locale.kegs.water}>
          {`${kegs.water} / ${kegs.water_cap}`}
        </LabeledList.Item>
        {staff && (
          <LabeledList.Item label={locale.kegs.share}>
            {locale.formatShare(kegs.share)}
          </LabeledList.Item>
        )}
        {staff && (
          <LabeledList.Item label={locale.kegs.funds}>
            {kegs.funds}
          </LabeledList.Item>
        )}
      </LabeledList>
      <Box mt={1}>
        {!!kegs.water && (
          <KegRow key={water.id} drink={water} canDraw {...rowProps} />
        )}
        {!drinks.length && <Box color="label">{locale.kegs.empty}</Box>}
        {drinks.map((drink) => (
          <KegRow key={drink.id} drink={drink} canDraw={staff} {...rowProps} />
        ))}
      </Box>
    </Section>
  );
};

type StockRowProps = {
  locale: Locale;
  entry: StockEntry;
  cap: number;
  canBuy: boolean;
  funds: number;
  onBuy: (id: string) => void;
};

const StockRow = (props: StockRowProps) => {
  const { locale, entry, cap, canBuy, funds, onBuy } = props;
  const fallback = <Icon name="cube" size={1.5} />;

  return (
    <Stack align="center" mb={0.5}>
      <Stack.Item>
        <Box
          width={ICON_SIZE}
          height={ICON_SIZE}
          textAlign="center"
          style={{ lineHeight: ICON_SIZE }}
        >
          {entry.icon ? (
            <DmIcon
              icon={entry.icon}
              icon_state={entry.icon_state || ''}
              width={ICON_SIZE}
              height={ICON_SIZE}
              fallback={fallback}
            />
          ) : (
            fallback
          )}
        </Box>
      </Stack.Item>
      <Stack.Item grow>{entry.name}</Stack.Item>
      <Stack.Item color="label">
        {entry.amount} / {cap}
      </Stack.Item>
      <Stack.Item color="label">
        {locale.stock.price}: {entry.price}
      </Stack.Item>
      {canBuy && (
        <Stack.Item>
          <Button
            icon="coins"
            disabled={funds < entry.buyout}
            onClick={() => onBuy(entry.id)}
          >
            {locale.formatBuy(entry.buyout)}
          </Button>
        </Stack.Item>
      )}
    </Stack>
  );
};

const GoodsView = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<StockData>();
  const entries = data.entries || [];
  const buy = (id: string) => act('buy', { id });

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title={locale.stock.title}>
          <Box color="label" mb={1}>
            {locale.stock.hint}
          </Box>
          <LabeledList>
            <LabeledList.Item label={locale.room.level}>
              {locale.levelNames[data.level] || data.level}
            </LabeledList.Item>
            <LabeledList.Item label={locale.stock.capacity}>
              {locale.formatCapacity(data.cap)}
            </LabeledList.Item>
            {!!data.can_buy && (
              <LabeledList.Item label={locale.stock.funds}>
                {data.funds}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          {!entries.length && <Box color="label">{locale.stock.empty}</Box>}
          {entries.map((entry) => (
            <StockRow
              key={entry.id}
              locale={locale}
              entry={entry}
              cap={data.cap}
              canBuy={!!data.can_buy}
              funds={data.funds}
              onBuy={buy}
            />
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const EnterpriseStockView = (props: { locale: Locale }) => {
  const { locale } = props;
  const { data } = useBackend<StockData>();
  useIconRefs();
  const kegs = data.kegs;
  const enterpriseName =
    locale.enterpriseNames[data.enterprise] || data.enterprise;

  return (
    <Window
      title={`${locale.stock.title}: ${enterpriseName}`}
      width={560}
      height={kegs ? 640 : 480}
    >
      <Window.Content>
        {kegs ? (
          <KegSection locale={locale} kegs={kegs} level={data.level} />
        ) : (
          <GoodsView locale={locale} />
        )}
      </Window.Content>
    </Window>
  );
};
