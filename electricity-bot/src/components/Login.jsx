import styles from "./Login.module.css";
import { startKeycloakLogin } from "../services/AuthService";

const Login = () => {
  const handleLogin = () => {
    startKeycloakLogin();
  };

  return (
    <div className={styles.loginScreen}>
      <div className={styles.emoji}>⚡️</div>
      <h1 className={styles.loginTitle}>Let’s light things up</h1>
      <p className={styles.loginSubtitle}>
        Log in to keep an eye on your power status
      </p>
      <button className={styles.loginBtn} onClick={handleLogin}>
        Login now
      </button>
    </div>
  );
};

export default Login;
