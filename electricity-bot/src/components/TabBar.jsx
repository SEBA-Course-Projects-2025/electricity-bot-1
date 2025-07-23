import styles from "./TabBar.module.css";

const tabs = [
  { id: "statistics", label: "Statistics", icon: "📊" },
  { id: "dashboard", label: "Dashboard", icon: "🏠" },
  { id: "settings", label: "Settings", icon: "⚙️" },
];

const TabBar = ({ activeTab, onTabChange }) => {
  return (
    <nav className={styles.tabBar}>
      {tabs.map((tab) => {
        const isActive = tab.id === activeTab;
        return (
          <button
            key={tab.id}
            className={`${styles.tabButton} ${isActive ? styles.active : ""}`}
            onClick={() => onTabChange(tab.id)}
          >
            <span className={styles.icon}>{tab.icon}</span>
            <span className={styles.label}>{tab.label}</span>
          </button>
        );
      })}
    </nav>
  );
};

export default TabBar;
