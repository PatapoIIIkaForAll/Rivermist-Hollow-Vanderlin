// RMH: law-document editor.
import { useState } from 'react';
import { RmhLocaleProvider } from './RmhScribeStand/locale';
import '../styles/interfaces/RmhScribeStand.scss';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BookEditor, CodeEditor } from './RmhScribeStand/BookEditor';
import type { Page } from './RmhScribeStand/Layout';
import { DecreePage, DraftLibrary } from './RmhScribeStand/OtherPages';
import {
  type Act,
  currentDraft,
  type Data,
  type DocumentId,
  type Draft,
  type Entry,
  type Lawbook,
  loadedDraft,
  type Notes,
  publication,
} from './RmhScribeStand/types';
export function RmhScribeStand() {
  const { act, data } = useBackend<Data>();
  return (
    <RmhLocaleProvider language={data.language}>
      <Window width={1220} height={850} theme="rmh-lawbook">
        <Window.Content>
          <Workspace key={data.editor_key} data={data} act={act} />
        </Window.Content>
      </Window>
    </RmhLocaleProvider>
  );
}
type WorkspaceState = {
  page: Page;
  preview: boolean;
  law_code: Draft;
  lawbook: Draft;
  notes: Notes | null;
};
function Workspace({ data, act }: { data: Data; act: Act }) {
  // Published pushes never replace unsaved working copies.
  const [workspace, setWorkspace] = useState<WorkspaceState>(() => ({
    page: 'law_code',
    notes: null,
    preview: false,
    law_code: publication(data, 'law_code'),
    lawbook: publication(data, 'lawbook'),
  }));
  const updateDraft = (id: DocumentId, draft: Draft) =>
    setWorkspace((previous) => ({ ...previous, [id]: draft }));
  const onPage = (page: Page) =>
    setWorkspace((previous) => ({ ...previous, page, preview: false }));
  const navigation = { data, page: workspace.page, onPage };
  if (workspace.page === 'drafts')
    return (
      <DraftLibrary
        {...navigation}
        act={act}
        notes={workspace.notes}
        onNotes={(notes) =>
          setWorkspace((previous) => ({ ...previous, notes }))
        }
        onLoad={(id, draft) =>
          setWorkspace((previous) => ({
            ...previous,
            [id]: loadedDraft(draft),
            page: id,
            preview: false,
          }))
        }
      />
    );
  if (workspace.page === 'decrees')
    return <DecreePage {...navigation} act={act} />;
  const id = workspace.page;
  const working = currentDraft(publication(data, id), workspace[id]);
  const readOnly = !data.can_edit || workspace.preview;
  const displayed = readOnly ? publication(data, id).content : working.content;
  const controls = {
    ...navigation,
    act,
    id,
    working,
    preview: workspace.preview,
    readOnly,
    onDraft: (draft: Draft) => updateDraft(id, draft),
    onPreview: () =>
      setWorkspace((previous) => ({ ...previous, preview: !previous.preview })),
  };
  return id === 'law_code' ? (
    <CodeEditor
      {...controls}
      entries={displayed as Entry[]}
      onChange={(content) => updateDraft(id, { ...working, content })}
    />
  ) : (
    <BookEditor
      {...controls}
      book={displayed as Lawbook}
      onChange={(content) => updateDraft(id, { ...working, content })}
    />
  );
}
