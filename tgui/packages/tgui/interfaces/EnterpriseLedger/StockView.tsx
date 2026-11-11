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
const DRINKS_HEIGHT = '12em';

type KegRowProps = {
  locale: Locale;
  drink: KegDrink;
  canUse: boolean;
  kegVolume: number;
  onPour: (id: string, amount: number) => void;
};

const KegRow = (props: KegRowProps) => {
  const { locale, drink, canUse, kegVolume, onPour } = props;
  const limit = Math.max(1, Math.floor(Math.min(drink.amount, kegVolume)));
  const [amount, setAmount] = useState(limit);
  const shown = Math.min(amount, limit);

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
      {canUse && (
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
            <Button icon="fill-drip" onClick={() => onPour(drink.id, shown)}>
              {locale.kegs.fill}
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
};

const KegSection = (props: KegSectionProps) => {
  const { locale, kegs } = props;
  const { act } = useBackend<StockData>();
  const drinks = kegs.drinks || [];
  const canUse = !!kegs.can_use;
  const pour = (id: string, amount: number) => act('fill_keg', { id, amount });

  return (
    <Section
      title={locale.kegs.title}
      buttons={
        canUse && (
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
        )
      }
    >
      <Box color="label" mb={1}>
        {locale.kegs.hint}
      </Box>
      <LabeledList>
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
      </LabeledList>
      <Box mt={1} style={{ maxHeight: DRINKS_HEIGHT, overflowY: 'auto' }}>
        {!drinks.length && <Box color="label">{locale.kegs.empty}</Box>}
        {drinks.map((drink) => (
          <KegRow
            key={drink.id}
            locale={locale}
            drink={drink}
            canUse={canUse}
            kegVolume={kegs.keg_volume}
            onPour={pour}
          />
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

export const EnterpriseStockView = (props: { locale: Locale }) => {
  const { locale } = props;
  const { act, data } = useBackend<StockData>();
  useIconRefs();
  const entries = data.entries || [];
  const kegs = data.kegs;
  const enterpriseName =
    locale.enterpriseNames[data.enterprise] || data.enterprise;
  const buy = (id: string) => act('buy', { id });

  return (
    <Window
      title={`${locale.stock.title}: ${enterpriseName}`}
      width={560}
      height={kegs ? 760 : 480}
    >
      <Window.Content>
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
          {!!kegs && (
            <Stack.Item>
              <KegSection locale={locale} kegs={kegs} />
            </Stack.Item>
          )}
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
      </Window.Content>
    </Window>
  );
};
