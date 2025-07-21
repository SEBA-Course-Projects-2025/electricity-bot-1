import { useState, useEffect } from "react";
import { useDevice } from "../context/DeviceContext";
import { useAuth } from "../context/AuthContext";
import styles from "./Statistics.module.css";

const Statistics = () => {
  const { selectedDeviceId } = useDevice();
  const { accessToken } = useAuth();

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [stats, setStats] = useState([]);
  const [isWeekly, setIsWeekly] = useState(false);

  useEffect(() => {
    if (!selectedDeviceId || !accessToken) return;

    setLoading(true);
    setError(null);

    const period = isWeekly ? "week" : "day";
    fetch(`https://bot-1.electricity-bot.online/statistics/${period}/${selectedDeviceId}`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    })
      .then(res => {
        if (!res.ok) throw new Error(`Помилка ${res.status}`);
        return res.json();
      })
      .then(data => {
        setStats(data.events || []);
      })
      .catch(err => {
        setError(err.message);
        setStats([]);
      })
      .finally(() => setLoading(false));
  }, [selectedDeviceId, accessToken, isWeekly]);

  const processStats = () => {
    if (!stats.length) return [];

    if (!isWeekly) {
      const hours = Array(24).fill(0);
      
      if (stats.length < 2) return hours.map(() => 0);

      const sorted = [...stats].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));

      for (let i = 0; i < sorted.length - 1; i++) {
        const current = sorted[i];
        const next = sorted[i + 1];
        const start = new Date(current.timestamp);
        const end = new Date(next.timestamp);
        const durationMs = end - start;
        const startHour = start.getHours();
        const endHour = end.getHours();

        if (startHour === endHour) {
          if (current.outgate_status) hours[startHour] += durationMs;
        } else {

          if (current.outgate_status) hours[startHour] += durationMs;
        }
      }

      const maxDuration = 3600000;
      return hours.map(ms => Math.min(ms / maxDuration, 1));
    } else {
      
      const days = Array(7).fill(0);

      
      if (stats.length < 2) return days.map(() => 0);

      const sorted = [...stats].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));

      for (let i = 0; i < sorted.length - 1; i++) {
        const current = sorted[i];
        const next = sorted[i + 1];
        const start = new Date(current.timestamp);
        const end = new Date(next.timestamp);
        const durationMs = end - start;
        const startDay = start.getDay();

        if (current.outgate_status) days[startDay] += durationMs;
      }

      const maxDuration = 24 * 3600000;
      return days.map(ms => Math.min(ms / maxDuration, 1));
    }
  };

  const powerOnFragments = processStats();

  const totalOffDuration = () => {
    if (!stats.length) return "0 minutes";

    let totalOffMs = 0;
    const sorted = [...stats].sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
    for (let i = 0; i < sorted.length - 1; i++) {
      const current = sorted[i];
      const next = sorted[i + 1];
      if (!current.outgate_status) {
        totalOffMs += new Date(next.timestamp) - new Date(current.timestamp);
      }
    }
    const minutes = Math.floor(totalOffMs / 60000);
    return `${minutes} minutes`;
  };

  return (
    <div className={styles.container}>
      <h1>Statistics for {isWeekly ? "Week" : "Day"}</h1>

      <button
        className={styles.toggleBtn}
        onClick={() => setIsWeekly(w => !w)}
      >
        {isWeekly ? "Show daily statistics" : "Show weekly statistics"}
      </button>

      {loading && <p>Loading...</p>}
      {error && <p className={styles.error}>{error}</p>}

      {!loading && !error && stats.length === 0 && (
        <p>No statistics available to display.</p>
      )}

      {!loading && !error && stats.length > 0 && (
        <>
          <p>Power off duration: {totalOffDuration()}</p>
          <div className={styles.chartContainer}>
            {powerOnFragments.map((frag, i) => (
              <div
                key={i}
                className={styles.bar}
                style={{
                  height: `${frag * 80}px`,
                  backgroundColor: "green",
                  borderRadius: "6px",
                }}
              >
                <div
                  className={styles.barOff}
                  style={{
                    height: `${(1 - frag) * 80}px`,
                    backgroundColor: "#ccc",
                    borderRadius: "6px 6px 0 0",
                  }}
                />
              </div>
            ))}
          </div>
          <div className={styles.labels}>
            {powerOnFragments.map((_, i) => (
              <div key={i} className={styles.labelText}>
                {!isWeekly
                  ? `${i}:00`
                  : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i]}
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
};

export default Statistics;
