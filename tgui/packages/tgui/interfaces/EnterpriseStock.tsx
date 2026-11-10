import locale from './EnterpriseLedger/i18n.en';
import { EnterpriseStockView } from './EnterpriseLedger/StockView';

export const EnterpriseStock = () => {
  return <EnterpriseStockView locale={locale} />;
};
