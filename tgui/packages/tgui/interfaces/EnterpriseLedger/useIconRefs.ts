import { useEffect, useState } from 'react';

const ICON_REFS_POLL = 250;

const hasIconRefs = () =>
  !!Byond.iconRefMap && Object.keys(Byond.iconRefMap).length > 0;

export const useIconRefs = () => {
  const [ready, setReady] = useState(hasIconRefs);

  useEffect(() => {
    if (ready) {
      return;
    }
    const timer = setInterval(() => {
      if (hasIconRefs()) {
        clearInterval(timer);
        setReady(true);
      }
    }, ICON_REFS_POLL);
    return () => clearInterval(timer);
  }, [ready]);

  return ready;
};
