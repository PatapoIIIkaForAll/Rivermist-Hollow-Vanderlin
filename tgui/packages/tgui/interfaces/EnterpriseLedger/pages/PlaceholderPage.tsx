import { NoticeBox, Section } from 'tgui-core/components';

import type { PageProps } from '../types';

export const PlaceholderPage = (props: PageProps) => {
  const { locale, pageId } = props;

  return (
    <Section fill title={locale.pages[pageId] || pageId}>
      <NoticeBox>{locale.labels.sectionInProgress}</NoticeBox>
    </Section>
  );
};
