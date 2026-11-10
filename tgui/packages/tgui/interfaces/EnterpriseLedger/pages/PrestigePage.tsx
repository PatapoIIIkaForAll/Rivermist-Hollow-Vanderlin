import {
  Box,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../../../backend';
import type { Data, Locale, PageProps, PrestigeGrade } from '../types';

const getGradeState = (locale: Locale, grade: PrestigeGrade) => {
  if (!grade.unlocked) {
    return { text: locale.prestige.gradeLocked, color: 'label' };
  }
  if (!grade.saved) {
    return { text: locale.prestige.gradeEmpty, color: 'average' };
  }
  if (grade.spent) {
    return { text: locale.prestige.gradeSpent, color: 'label' };
  }
  return { text: locale.prestige.gradeReady, color: 'good' };
};

export const PrestigePage = (props: PageProps) => {
  const { locale } = props;
  const { data } = useBackend<Data>();
  const prestige = data.prestige;

  if (!prestige) {
    return (
      <Section fill title={locale.prestige.title}>
        <NoticeBox>{locale.labels.sectionInProgress}</NoticeBox>
      </Section>
    );
  }

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title={locale.prestige.title}>
          <LabeledList>
            <LabeledList.Item label={locale.prestige.level}>
              {locale.formatLevel(prestige.level, prestige.max_level)}
            </LabeledList.Item>
            <LabeledList.Item label={locale.prestige.earned}>
              {prestige.next ? (
                <ProgressBar
                  value={prestige.earned}
                  minValue={0}
                  maxValue={prestige.next}
                >
                  {prestige.earned} / {prestige.next}
                </ProgressBar>
              ) : (
                prestige.earned
              )}
            </LabeledList.Item>
            <LabeledList.Item label={locale.prestige.next}>
              {prestige.next || locale.prestige.nextNone}
            </LabeledList.Item>
            <LabeledList.Item label={locale.labels.earnedRound}>
              {data.earned_round}
            </LabeledList.Item>
          </LabeledList>
          <Box color="label" mt={1}>
            {locale.prestige.roundNote}
          </Box>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable title={locale.prestige.gradesTitle}>
          <Box color="label" mb={1}>
            {locale.prestige.gradesHint}
          </Box>
          <LabeledList>
            {prestige.grades.map((grade) => {
              const state = getGradeState(locale, grade);
              return (
                <LabeledList.Item
                  key={grade.level}
                  label={`${grade.level} · ${locale.levelNames[grade.level]}`}
                  color={state.color}
                >
                  {state.text}
                </LabeledList.Item>
              );
            })}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
