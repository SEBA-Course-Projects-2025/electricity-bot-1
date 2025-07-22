import { useState, useEffect, useMemo } from "react";
import { useDevice } from "../context/DeviceContext";
import { useAuth } from "../context/AuthContext";
import styles from "./Statistics.module.css";

// ---- utils ----
const toDate = (ts) => (ts ? new Date(ts) : null);
const clamp01 = (n) => (n < 0 ? 0 : n > 1 ? 1 : n);
const HOUR_MS = 60 * 60 * 1000;
const DAY_MS = 24 * HOUR_MS;

const formatDurationHM = (ms) => {
  const mins = Math.floor(ms / 60000);
  const h = Math.floor(mins / 60);
  const m = mins % 60;
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
};

function bucketDailyOnMs(events) {
  const arr = new Array(24).fill(0);
  if (events.length < 2) return arr;

  for (let i = 0; i < events.length - 1; i++) {
    const cur = events[i];
    const next = events[i + 1];
    if (!cur.outgate_status) continue;
    const start = toDate(cur.timestamp);
    const end = toDate(next.timestamp);
    if (!start || !end) continue;

    let cursor = start;
    while (cursor < end) {
      const hourIdx = cursor.getHours();
      const hourEnd = new Date(cursor);
      hourEnd.setMinutes(59, 59, 999);
      const sliceEnd = end < hourEnd ? end : hourEnd;
      const sliceMs = sliceEnd - cursor;
      if (sliceMs > 0) arr[hourIdx] += sliceMs;
      cursor = new Date(hourEnd.getTime() + 1);
    }
  }
  return arr;
}

function bucketWeeklyOnMs(events) {
  const arr = new Array(7).fill(0);
  if (events.length < 2) return arr;
  for (let i = 0; i < events.length - 1; i++) {
    const cur = events[i];
    const next = events[i + 1];
    if (!cur.outgate_status) continue;
    const start = toDate(cur.timestamp);
    const end = toDate(next.timestamp);
    if (!start || !end) continue;
    let cursor = start;
    while (cursor < end) {
      const dayIdx = cursor.getDay();
      const dayEnd = new Date(cursor);
      dayEnd.setHours(23, 59, 59, 999);
      const sliceEnd = end < dayEnd ? end : dayEnd;
      const sliceMs = sliceEnd - cursor;
      if (sliceMs > 0) arr[dayIdx] += sliceMs;
      cursor = new Date(dayEnd.getTime() + 1);
    }
  }
  return arr;
}

function totalOffMs(events) {
  if (events.length < 2) return 0;
  let ms = 0;
  for (let i = 0; i < events.length - 1; i++) {
    const cur = events[i];
    if (cur.outgate_status) continue;
    const start = toDate(cur.timestamp);
    const end = toDate(events[i + 1].timestamp);
    if (start && end) ms += end - start;
  }
  return ms;
}

const WEEK_LABELS_MON_FIRST = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

const Statistics = () => {
  const { selectedDeviceId } = useDevice();
  const { accessToken } = useAuth();

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [events, setEvents] = useState([]);
  const [isWeekly, setIsWeekly] = useState(false);

  useEffect(() => {
    if (!selectedDeviceId || !accessToken) return;

    setLoading(true);
    setError(null);

    const period = isWeekly ? "week" : "day";
    fetch(`https://bot-1.electricity-bot.online/statistics/${period}/${selectedDeviceId}`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    })
      .then((res) => {
        if (!res.ok) throw new Error(`Помилка ${res.status}`);
        return res.json();
      })
      .then((data) => {
        let evs = Array.isArray(data?.events) ? data.events : [];
        evs.sort(
          (a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime()
        );

        const now = new Date();
        const periodStart = new Date(
          now.getTime() - (isWeekly ? 7 * DAY_MS : DAY_MS)
        );
        const periodEnd = now;

        // keep only those inside period *or* straddling start boundary
        evs = evs.filter((e) => {
          const t = new Date(e.timestamp).getTime();
          return t >= periodStart.getTime() && t <= periodEnd.getTime();
        });

        // if we lost leading history (first event starts after periodStart),
        // prepend synthetic boundary event carrying first known state
        if (evs.length > 0) {
          const first = evs[0];
          const firstT = new Date(first.timestamp).getTime();
          if (firstT > periodStart.getTime()) {
            evs.unshift({
              timestamp: periodStart.toISOString(),
              outgate_status: first.outgate_status,
            });
          }
          // append synthetic trailing event at periodEnd w/ last known state
          const last = evs[evs.length - 1];
          const lastT = new Date(last.timestamp).getTime();
          if (lastT < periodEnd.getTime()) {
            evs.push({
              timestamp: periodEnd.toISOString(),
              outgate_status: last.outgate_status,
            });
          }
        }

        setEvents(evs);
      })
      .catch((err) => {
        setError(err.message);
        setEvents([]);
      })
      .finally(() => setLoading(false));
  }, [selectedDeviceId, accessToken, isWeekly]);

  const buckets = useMemo(() => {
    if (!events.length) return [];
    return isWeekly ? bucketWeeklyOnMs(events) : bucketDailyOnMs(events);
  }, [events, isWeekly]);

  const normalized = useMemo(() => {
    if (!buckets.length) return [];
    if (isWeekly) {
      const sunFirst = buckets;
      const monFirst = [
        sunFirst[1],
        sunFirst[2],
        sunFirst[3],
        sunFirst[4],
        sunFirst[5],
        sunFirst[6],
        sunFirst[0],
      ];
      return monFirst.map((ms) => clamp01(ms / DAY_MS));
    } else {
      return buckets.map((ms) => clamp01(ms / HOUR_MS));
    }
  }, [buckets, isWeekly]);

  const columns = useMemo(
    () =>
      normalized.map((v, i) => ({
        v,
        label: isWeekly
          ? WEEK_LABELS_MON_FIRST[i]
          : `${String(i).padStart(2, "0")}:00`,
        tooltip: `${Math.round(v * 100)}% Power ON`,
      })),
    [normalized, isWeekly]
  );

  const offDuration = useMemo(() => formatDurationHM(totalOffMs(events)), [events]);

  return (
    <div className={styles.container}>
      <h1 className={styles.heading}>
        {isWeekly ? "Statistics: Last 7 Days" : "Statistics: Last 24 Hours"}
      </h1>

      <button
        className={styles.toggleBtn}
        onClick={() => setIsWeekly((w) => !w)}
      >
        {isWeekly ? "Show daily statistics" : "Show weekly statistics"}
      </button>

      {loading && <p>Loading...</p>}
      {error && <p className={styles.error}>{error}</p>}
      {!loading && !error && events.length === 0 && (
        <p>No statistics available to display.</p>
      )}

      {!loading && !error && events.length > 0 && (
        <>
          <p className={styles.summary}>
            Power off duration: <strong>{offDuration}</strong>
          </p>

          <div
            className={`${styles.chartScroller} ${
              isWeekly ? styles.weekly : styles.daily
            }`}
          >
            {columns.map((col, i) => (
              <div key={i} className={styles.col} title={col.tooltip}>
                <div
                  className={styles.bar}
                  style={{ height: `${col.v * 240}px` }}
                />
                <div className={styles.labelText}>{col.label}</div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
};

export default Statistics;
