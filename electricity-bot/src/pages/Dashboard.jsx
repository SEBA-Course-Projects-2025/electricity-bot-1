import { useDevice } from "../context/DeviceContext"; 
import { useEffect, useState } from "react";
import { useAuth } from "../context/AuthContext";
import powerOnImg from "../assets/PowerOn.png";
import powerOffImg from "../assets/PowerOff.png";
import styles from "./Dashboard.module.css";

const Dashboard = () => {
  const { selectedDeviceId } = useDevice();
  const { accessToken } = useAuth();

  const [status, setStatus] = useState(null);
  const [durationFormatted, setDurationFormatted] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!selectedDeviceId || !accessToken) return;

    setLoading(true);
    setError(null);

    fetch(`https://bot-1.electricity-bot.online/api/status/${selectedDeviceId}`, {
      headers: {
        Authorization: `Bearer ${accessToken}`,
      },
    })
    .then(res => {
      if (!res.ok) throw new Error(`Error ${res.status}`);
      return res.json();
    })
    .then(data => {
      setStatus(data.outgate_status);

      if (data.timestamp) {
        const lastChange = new Date(data.timestamp);
        const now = new Date();
        const diffSec = Math.floor((now - lastChange) / 1000);
        const h = Math.floor(diffSec / 3600);
        const m = Math.floor((diffSec % 3600) / 60);
        setDurationFormatted(`${h} hours ${m} mins`);
      } else {
        setDurationFormatted("-");
      }
    })
    .catch(err => {
      setError(err.message);
      setStatus(null);
      setDurationFormatted("");
    })
    .finally(() => setLoading(false));
  }, [selectedDeviceId, accessToken]);

  if (!selectedDeviceId) return <p>Choose a device.</p>;
  if (loading) return <p>Loading status...</p>;
  if (error) return <p style={{ color: "red" }}>{error}</p>;

  return (
    <div className={styles.statusCard}>
      <h1>Current status</h1>

      <img
        src={status ? powerOnImg : powerOffImg}
        alt={status ? "Power On" : "Power Off"}
        className={styles.statusImage}
      />
      <div className={styles.statusText}>
        <div className={styles.statusTitle}>
          {status ? "Power is on!" : "Power is off!"}
        </div>
        <div className={styles.statusSubtitle}>
          Power is {status ? "on" : "off"} for {durationFormatted}.
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
