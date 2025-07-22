import styles from "./DeviceCard.module.css";

const DeviceCard = ({ device, onClick, onDelete }) => {
  const { device_id, lastSeen } = device;

  return (
    <div className={styles.card} onClick={onClick}>
      <div className={styles.icon}>⚡</div>
      <div className={styles.info}>
        <div className={styles.title}>Device ID: {device_id}</div>
        {lastSeen && (
          <div className={styles.subtitle}>Last seen: {lastSeen}</div>
        )}
      </div>
      <button
        className={styles.deleteBtn}
        onClick={(e) => {
          e.stopPropagation();
          onDelete();
        }}
      >
        ✖
      </button>
    </div>
  );
};

export default DeviceCard;
