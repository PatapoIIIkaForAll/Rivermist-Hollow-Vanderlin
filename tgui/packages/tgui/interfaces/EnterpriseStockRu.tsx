import locale from './EnterpriseLedger/i18n.ru';
import { EnterpriseStockView } from './EnterpriseLedger/StockView';

export const EnterpriseStockRu = () => {
  return <EnterpriseStockView locale={locale} />;
};
