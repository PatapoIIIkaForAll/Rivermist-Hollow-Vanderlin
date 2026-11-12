import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RosewallPost = {
  id: string;
  name: string;
  seeking: string;
  text: string;
  date: string;
  is_own: BooleanLike;
  can_remove: BooleanLike;
};

type OwnPost = {
  id: string;
  seeking: string;
  text: string;
};

type Data = {
  posts: RosewallPost[];
  character_name: string;
  can_post: BooleanLike;
  own_post: OwnPost | null;
  own_count: number;
  own_cap: number;
  text_limit: number;
  seeking_limit: number;
};

const OwnNote = () => {
  const { act, data } = useBackend<Data>();
  const own = data.own_post;
  const [seeking, setSeeking] = useState(own?.seeking || '');
  const [text, setText] = useState(own?.text || '');
  const atCap = !own && data.own_count >= data.own_cap;

  return (
    <Section
      title={`My note as ${data.character_name}`}
      buttons={
        !!own && (
          <Button color="bad" onClick={() => act('remove_post', { id: own.id })}>
            Take down
          </Button>
        )
      }
    >
      {atCap ? (
        <NoticeBox>
          You have {data.own_cap} notes up for other characters. Take one down to pin a note
          for this character.
        </NoticeBox>
      ) : (
        <Stack vertical>
          <Stack.Item>
            <Box mb={0.5}>Who are you looking for?</Box>
            <Input
              fluid
              maxLength={data.seeking_limit}
              placeholder="For example: a dance partner, a drinking friend, a spouse"
              value={seeking}
              onChange={setSeeking}
            />
          </Stack.Item>
          <Stack.Item>
            <Box mb={0.5}>
              About your character ({text.length} / {data.text_limit})
            </Box>
            <TextArea
              fluid
              height="9em"
              maxLength={data.text_limit}
              value={text}
              onChange={setText}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              color="good"
              disabled={!text.trim()}
              onClick={() => act('save_post', { seeking, text })}
            >
              {own ? 'Save changes' : 'Pin note'}
            </Button>
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};

const NoteCard = (props: { post: RosewallPost }) => {
  const { act } = useBackend<Data>();
  const { post } = props;
  return (
    <Section
      title={post.name}
      buttons={
        !!post.can_remove && (
          <Button color="bad" onClick={() => act('remove_post', { id: post.id })}>
            Take down
          </Button>
        )
      }
    >
      {!!post.seeking && (
        <Box mb={1}>
          <b>Looking for:</b> {post.seeking}
        </Box>
      )}
      <Box style={{ whiteSpace: 'pre-wrap', wordBreak: 'break-word' }}>{post.text}</Box>
      <Box mt={1} color="label">
        Pinned {post.date}
        {!!post.is_own && ' (your note)'}
      </Box>
    </Section>
  );
};

export const Rosewall = () => {
  const { data } = useBackend<Data>();
  const posts = data.posts || [];

  return (
    <Window title="Rosewall" width={560} height={680}>
      <Window.Content scrollable>
        <NoticeBox info>
          Pin one note for each character: who you are and who you hope to meet. Notes stay up
          between rounds for 30 days after the last edit.
        </NoticeBox>
        {!!data.can_post && <OwnNote key={data.own_post?.id || 'new'} />}
        {posts.length === 0 ? (
          <Section>
            <Box color="label">No notes are pinned yet.</Box>
          </Section>
        ) : (
          posts.map((post) => <NoteCard key={post.id} post={post} />)
        )}
      </Window.Content>
    </Window>
  );
};
