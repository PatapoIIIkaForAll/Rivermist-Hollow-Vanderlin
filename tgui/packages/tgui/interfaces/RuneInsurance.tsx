import type { CSSProperties, ReactNode } from 'react';
import { useEffect, useState } from 'react';
import { RestrictedInput } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ItemStatus = 'insurable' | 'insured' | 'insured_other' | 'refused';
type PolicyPlace = 'carried' | 'vault' | 'elsewhere';

type ItemRow = {
  ref: string;
  name: string;
  value: number;
  premium: number;
  status: ItemStatus;
  note: string | null;
};

type PolicyRow = {
  name: string;
  value: number;
  place: PolicyPlace;
};

type Claim = {
  tier: number;
  ready: BooleanLike;
  seconds_left: number;
};

type Tier = {
  tier: number;
  name: string;
  wait_seconds: number;
  fee: number;
  available: BooleanLike;
};

type Data = {
  rate: number;
  rate_min: number;
  rate_max: number;
  min_premium: number;
  min_premium_arms: number;
  balance: number | null;
  can_set_rate: BooleanLike;
  items: ItemRow[];
  insure_all_cost: number;
  policies: PolicyRow[];
  vault_count: number;
  vault_value: number;
  claims_filed: number;
  claim: Claim | null;
  tiers: Tier[];
};

const SERIF = '"Lora", Georgia, serif';
const INK = 'var(--p-ink)';
const INK_SOFT = 'var(--p-ink-soft)';
const INK_FAINT = 'var(--p-ink-faint)';
const TITLE = 'var(--p-title)';
const TITLE_FONT = 'var(--p-title-font)';
const FONT_SMALL = 'var(--p-font-small)';
const FONT_BODY = 'var(--p-font-body)';
const PARCHMENT_SHADOW = 'var(--p-bg-shadow)';

const PLACE_LABELS: Record<PolicyPlace, string> = {
  carried: 'Carried',
  vault: 'In the vault',
  elsewhere: 'Elsewhere',
};

const pageStyle: CSSProperties = {
  padding: '14px 20px',
  fontFamily: SERIF,
  color: INK,
  fontSize: FONT_BODY,
  lineHeight: 1.4,
};

const headingStyle: CSSProperties = {
  fontFamily: TITLE_FONT,
  color: TITLE,
  fontSize: '17px',
  fontWeight: 'bold',
  margin: '14px 0 4px 0',
  borderBottom: `1px solid ${INK_FAINT}`,
};

const rowStyle: CSSProperties = {
  display: 'flex',
  alignItems: 'center',
  gap: '8px',
  padding: '3px 0',
  borderBottom: `1px dashed ${PARCHMENT_SHADOW}`,
};

const nameCellStyle: CSSProperties = {
  flex: 1,
  minWidth: 0,
  overflow: 'hidden',
  textOverflow: 'ellipsis',
  whiteSpace: 'nowrap',
};

const numberCellStyle: CSSProperties = {
  flex: '0 0 70px',
  textAlign: 'right',
  whiteSpace: 'nowrap',
};

const actionCellStyle: CSSProperties = {
  flex: '0 0 210px',
  textAlign: 'right',
};

const noteStyle: CSSProperties = {
  color: INK_SOFT,
  fontStyle: 'italic',
  fontSize: FONT_SMALL,
  margin: '4px 0',
};

const buttonStyle = (disabled = false): CSSProperties => ({
  fontFamily: SERIF,
  fontSize: FONT_BODY,
  padding: '1px 10px',
  color: disabled ? INK_FAINT : INK,
  background: disabled ? 'transparent' : 'var(--p-button-bg, transparent)',
  border: `1px ${disabled ? 'dashed' : 'solid'} ${disabled ? INK_FAINT : INK_SOFT}`,
  borderRadius: '2px',
  cursor: disabled ? 'default' : 'pointer',
});

const formatTime = (seconds: number) => {
  const minutes = Math.floor(seconds / 60);
  const rest = seconds % 60;
  return `${String(minutes).padStart(2, '0')}:${String(rest).padStart(2, '0')}`;
};

const formatWait = (seconds: number) => (seconds > 0 ? formatTime(seconds) : 'at once');

const formatFee = (fee: number) => (fee > 0 ? `${fee} amna` : 'free');

const InkButton = (props: { disabled?: boolean; title?: string; onClick: () => void; children: ReactNode }) => {
  const { disabled, title, onClick, children } = props;
  return (
    <button type="button" style={buttonStyle(disabled)} disabled={disabled} title={title} onClick={onClick}>
      {children}
    </button>
  );
};

const Heading = (props: { children: ReactNode }) => <div style={headingStyle}>{props.children}</div>;

const AccountSection = (props: { data: Data; act: (action: string, params?: object) => void }) => {
  const { data, act } = props;
  const [rate, setRate] = useState(data.rate);
  const [valid, setValid] = useState(true);
  useEffect(() => setRate(data.rate), [data.rate]);
  const inRange = valid && rate >= data.rate_min && rate <= data.rate_max;

  return (
    <>
      <Heading>Account</Heading>
      <div style={rowStyle}>
        <span style={nameCellStyle}>Balance</span>
        <b>{data.balance === null ? 'No account' : `${data.balance} amna`}</b>
      </div>
      <div style={rowStyle}>
        <span style={nameCellStyle}>
          Premium: {data.rate}% of an item&apos;s value (at least {data.min_premium}; at least {data.min_premium_arms}{' '}
          for armor and weapons)
        </span>
      </div>
      {!!data.can_set_rate && (
        <div style={rowStyle}>
          <span style={nameCellStyle}>
            Set the rate ({data.rate_min}–{data.rate_max}%)
          </span>
          <RestrictedInput
            width="60px"
            value={rate}
            minValue={data.rate_min}
            maxValue={data.rate_max}
            onChange={(value: number) => setRate(value)}
            onValidationChange={(isValid: boolean) => setValid(isValid)}
            onEnter={(value: number) => act('set_rate', { rate: value })}
          />
          <InkButton disabled={!inRange} onClick={() => act('set_rate', { rate })}>
            Set
          </InkButton>
        </div>
      )}
    </>
  );
};

const ItemAction = (props: { item: ItemRow; act: (action: string, params?: object) => void }) => {
  const { item, act } = props;
  switch (item.status) {
    case 'insured':
      return <InkButton disabled onClick={() => undefined}>Insured</InkButton>;
    case 'refused':
      return (
        <InkButton disabled title={item.note || undefined} onClick={() => undefined}>
          Insure
        </InkButton>
      );
    case 'insured_other':
      return (
        <InkButton
          title="Someone else holds a policy on this. Insuring it replaces theirs."
          onClick={() => act('insure', { ref: item.ref })}
        >
          Insure (replaces another&apos;s)
        </InkButton>
      );
    default:
      return <InkButton onClick={() => act('insure', { ref: item.ref })}>Insure</InkButton>;
  }
};

const CarriedSection = (props: { data: Data; act: (action: string, params?: object) => void }) => {
  const { data, act } = props;
  return (
    <>
      <Heading>What you carry</Heading>
      {data.items.length === 0 ? (
        <div style={noteStyle}>You carry nothing the Guild could insure.</div>
      ) : (
        <>
          <div style={{ ...rowStyle, color: INK_SOFT, fontSize: FONT_SMALL }}>
            <span style={nameCellStyle}>Item</span>
            <span style={numberCellStyle}>Value</span>
            <span style={numberCellStyle}>Premium</span>
            <span style={actionCellStyle} />
          </div>
          {data.items.map((item) => (
            <div key={item.ref} style={rowStyle}>
              <span style={nameCellStyle} title={item.note || item.name}>
                {item.name}
              </span>
              <span style={numberCellStyle}>{item.value}</span>
              <span style={numberCellStyle}>{item.premium}</span>
              <span style={actionCellStyle}>
                <ItemAction item={item} act={act} />
              </span>
            </div>
          ))}
          <div style={{ marginTop: '6px', textAlign: 'right' }}>
            <InkButton disabled={data.insure_all_cost <= 0} onClick={() => act('insure_all')}>
              Insure all ({data.insure_all_cost} amna)
            </InkButton>
          </div>
        </>
      )}
    </>
  );
};

const PoliciesSection = (props: { policies: PolicyRow[] }) => {
  const { policies } = props;
  return (
    <>
      <Heading>Your policies</Heading>
      {policies.length === 0 ? (
        <div style={noteStyle}>You hold no policies.</div>
      ) : (
        <>
          <div style={{ ...rowStyle, color: INK_SOFT, fontSize: FONT_SMALL }}>
            <span style={nameCellStyle}>Item</span>
            <span style={numberCellStyle}>Insured at</span>
            <span style={{ ...numberCellStyle, flexBasis: '100px' }}>Where</span>
          </div>
          {policies.map((policy, index) => (
            <div key={index} style={rowStyle}>
              <span style={nameCellStyle}>{policy.name}</span>
              <span style={numberCellStyle}>{policy.value}</span>
              <span style={{ ...numberCellStyle, flexBasis: '100px' }}>{PLACE_LABELS[policy.place]}</span>
            </div>
          ))}
        </>
      )}
    </>
  );
};

const VaultSection = (props: { data: Data; act: (action: string, params?: object) => void }) => {
  const { data, act } = props;
  const { claim, tiers } = data;
  const openTiers = claim ? tiers.filter((tier) => tier.tier > claim.tier) : tiers;

  return (
    <>
      <Heading>Vault and claim</Heading>
      <div style={rowStyle}>
        <span style={nameCellStyle}>In the vault</span>
        <b>
          {data.vault_count} {data.vault_count === 1 ? 'item' : 'items'}, insured at {data.vault_value} amna
        </b>
      </div>
      {claim && !!claim.ready && (
        <div style={rowStyle}>
          <span style={nameCellStyle}>Your claim is ready.</span>
          <InkButton onClick={() => act('collect')}>Collect</InkButton>
        </div>
      )}
      {claim && !claim.ready && (
        <div style={rowStyle}>
          <span style={nameCellStyle}>Claim ready in</span>
          <b>{formatTime(claim.seconds_left)}</b>
        </div>
      )}
      {!claim?.ready &&
        openTiers.map((tier) => (
          <div key={tier.tier} style={rowStyle}>
            <span style={nameCellStyle}>
              {tier.name}: {formatWait(tier.wait_seconds)}
            </span>
            <span style={{ whiteSpace: 'nowrap' }}>{formatFee(tier.fee)}</span>
            <InkButton disabled={!tier.available} onClick={() => act('claim', { tier: tier.tier })}>
              {claim ? 'Speed up' : 'File claim'}
            </InkButton>
          </div>
        ))}
      <div style={noteStyle}>
        {data.claims_filed > 0
          ? 'The Guild has honored your free claim. Every claim now carries a fee.'
          : 'The Guild honors your first claim free of charge at standard speed.'}
      </div>
    </>
  );
};

export const RuneInsurance = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={620} height={720} theme="parchment">
      <Window.Content scrollable>
        <div style={pageStyle}>
          <AccountSection data={data} act={act} />
          <CarriedSection data={data} act={act} />
          <PoliciesSection policies={data.policies} />
          <VaultSection data={data} act={act} />
        </div>
      </Window.Content>
    </Window>
  );
};
