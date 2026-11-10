import { type ComponentType, useState } from 'react';
import { Stack, Tabs } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { OverviewPage } from './pages/OverviewPage';
import { PlaceholderPage } from './pages/PlaceholderPage';
import { PremisesPage } from './pages/PremisesPage';
import type { Data, Locale, PageProps } from './types';

type PageDef = {
  icon: string;
  component: ComponentType<PageProps>;
};

// A page id sent by DM that is not listed here opens the placeholder.
const PAGES: Record<string, PageDef> = {
  overview: { icon: 'book-open', component: OverviewPage },
  premises: { icon: 'map', component: PremisesPage },
};

const PLACEHOLDER: PageDef = {
  icon: 'hourglass-half',
  component: PlaceholderPage,
};

const getPage = (pageId: string) => PAGES[pageId] || PLACEHOLDER;

export const EnterpriseLedgerView = (props: { locale: Locale }) => {
  const { locale } = props;
  const { data } = useBackend<Data>();
  const pages = data.pages || [];
  const [selectedId, setSelectedId] = useState(pages[0]);
  const pageId = pages.includes(selectedId) ? selectedId : pages[0];
  const Page = getPage(pageId).component;
  const enterpriseName = locale.enterpriseNames[data.name] || data.name;

  return (
    <Window
      title={`${locale.windowTitle}: ${enterpriseName}`}
      width={860}
      height={640}
    >
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              {pages.map((id) => (
                <Tabs.Tab
                  key={id}
                  icon={getPage(id).icon}
                  selected={id === pageId}
                  onClick={() => setSelectedId(id)}
                >
                  {locale.pages[id] || id}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Page locale={locale} pageId={pageId} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
