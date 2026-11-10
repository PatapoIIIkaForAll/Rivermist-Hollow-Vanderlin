import {
  Box,
  Button,
  DmIcon,
  Icon,
  LabeledList,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import type { Locale, StockData, StockEntry } from './types';

const ICON_SIZE = '32px';

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
  const entries = data.entries || [];
  const enterpriseName =
    locale.enterpriseNames[data.enterprise] || data.enterprise;
  const buy = (id: string) => act('buy', { id });

  return (
    <Window
      title={`${locale.stock.title}: ${enterpriseName}`}
      width={520}
      height={480}
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
