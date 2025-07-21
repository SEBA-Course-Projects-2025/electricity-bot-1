import { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../context/AuthContext";
import { getUserDevices, deleteUserDevice } from "../services/DeviceService";
import { useDevice } from "../context/DeviceContext";

import DeviceCard from "../components/DeviceCard";
import styles from "./Devices.module.css";

const Devices = () => {
  const { isAuthenticated, userId, logout } = useContext(AuthContext);
  const [devices, setDevices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [errMsg, setErrMsg] = useState(null);
  const { setSelectedDeviceId } = useDevice();
  const navigate = useNavigate();

  useEffect(() => {
    if (!isAuthenticated) {
      navigate("/auth");
    }
  }, [isAuthenticated, navigate]);

  useEffect(() => {
    if (!userId) return;
    setLoading(true);
    getUserDevices(userId)
      .then((list) => {
        console.log("Loaded devices:", list);
        setDevices(Array.isArray(list) ? list : []);
        setErrMsg(null);
      })
      .catch((err) => {
        console.error(err);
        setErrMsg("Failed to load devices.");
      })
      .finally(() => setLoading(false));
  }, [userId]);

  const handleDelete = async (id) => {
    if (!window.confirm("Delete this device?")) return;
    try {
      await deleteUserDevice(id);
      setDevices((ds) => ds.filter((d) => d.id !== id));
    } catch (err) {
      alert("Delete failed");
    }
  };

  const handleDeviceClick = (device) => {
    console.log("Device clicked:", device);
    setSelectedDeviceId(device.device_id);
    navigate("/dashboard");
  };

  const handleLogout = async () => {
    await logout();
  };

  if (loading) return <p>Loading devices...</p>;
  if (errMsg) return (
    <div className={styles.devicesWrapper}>
      <p>{errMsg}</p>
      <button onClick={handleLogout}>Logout</button>
    </div>
  );

  return (
    <div className={styles.devicesWrapper}>
      <h1>Your Devices</h1>

      {devices.length === 0 ? (
        <div className={styles.emptyState}>
          <div className={styles.icon}>⚡</div>
          <h2>Start your journey with Electricity Bot!</h2>
          <p>
            Download our mobile app and connect your first device to start
            receiving energy consumption data.
          </p>
        </div>
      ) : (
        <div className={styles.devicesList}>
          {devices.map((d) => (
            <DeviceCard
              key={d.device_id}
              device={d}
              onClick={() => handleDeviceClick(d)}
              onDelete={() => handleDelete(d.device_id)}
            />
          ))}
        </div>
      )}

      <div className={styles.actions}>
        <button onClick={handleLogout}>Logout</button>
      </div>
    </div>
  );
};

export default Devices;
