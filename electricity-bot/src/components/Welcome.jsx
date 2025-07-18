import { useNavigate } from "react-router-dom";
import styles from "./Welcome.module.css";

const Welcome = () => {
  const navigate = useNavigate();

  const handleStart = () => {
    navigate("/auth");
  };

  return (
    <div className={styles.welcomeScreen}>
      <div className={styles.emojiSmall}>💡</div>
      <h1 className={styles.welcomeText}>
        Welcome to<br />Electricity Bot
      </h1>
      <button className={styles.startButton} onClick={handleStart}>
        Start
      </button>
    </div>
  );
};

export default Welcome;
