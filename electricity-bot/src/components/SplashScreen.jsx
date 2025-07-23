import { useEffect, useState } from 'react';
import Welcome from './Welcome';
import styles from './SplashScreen.module.css';

const SplashScreen = () => {
  const [active, setActive] = useState(false);
  const [scale, setScale] = useState(0.8);

  useEffect(() => {
    const t1 = setTimeout(() => setScale(1), 100);
    const t2 = setTimeout(() => setActive(true), 2400);
    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
    };
  }, []);

  return active ? (
    <Welcome />
  ) : (
    <div className={styles.splashScreen}>
      <div
        className={styles.emoji}
        style={{ transform: `scale(${scale})` }}
      >
        💡
      </div>
    </div>
  );
};

export default SplashScreen;
