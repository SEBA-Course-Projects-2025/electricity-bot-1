import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useDevice } from "../context/DeviceContext";
import styles from "./Settings.module.css";

const Settings = () => {
  const navigate = useNavigate();
  const { user, logout } = useAuth();
  const { setSelectedDeviceId } = useDevice();

  const getInitials = (fullName) => {
    if (!fullName) return "NA";
    const names = fullName.trim().split(" ");
    return (
      names[0]?.[0]?.toUpperCase() + (names[1]?.[0]?.toUpperCase() || "")
    );
  };

  const handleChangeUser = () => {
    logout();
    navigate("/auth");
  };

  const handleResetDevice = () => {
    setSelectedDeviceId(null);
    alert("Device deleted. Please select a new device.");
  };

  return (
    <div className={styles.container}>
      <h1 className={styles.greeting}>Hello, {user?.fullName || "User"}!</h1>

      <div className={styles.accountCard}>
        <div className={styles.initials}>{getInitials(user?.fullName)}</div>
        <div className={styles.accountInfo}>
          <div className={styles.email}>{user?.email || "noname@gmail.com"}</div>
          <button className={styles.changeUserBtn} onClick={handleChangeUser}>
            Change user
          </button>
        </div>
      </div>

      <div className={styles.resetDevice}>
        <h2>Want to remove this device?</h2>
        <button className={styles.resetBtn} onClick={handleResetDevice}>
          Reset
        </button>
      </div>

      <div className={styles.logoutSection}>
        <button className={styles.logoutBtn} onClick={logout}>
          Logout
        </button>
      </div>
    </div>
  );
};

export default Settings;
