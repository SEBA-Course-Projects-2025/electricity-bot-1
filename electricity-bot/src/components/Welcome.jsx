import styles from './Welcome.module.css';

const Welcome = ({ onStart }) => {
  return (
    <div className={styles.welcomeScreen}>
      <div className={styles.emojiSmall}>💡</div>
      <h1 className={styles.welcomeText}>
        Welcome to<br />Electricity Bot
      </h1>
      <button className={styles.startButton} onClick={onStart}>
        Start
      </button>
    </div>
  );
};

export default Welcome;
