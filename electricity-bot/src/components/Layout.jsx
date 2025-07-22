import { useNavigate } from "react-router-dom";
import { useState } from "react";
import TabBar from "./TabBar";

const Layout = ({ children }) => {
  const navigate = useNavigate();
  
  const [activeTab, setActiveTab] = useState(() => {
    const path = window.location.pathname;
    if (path.startsWith("/statistics")) return "statistics";
    if (path.startsWith("/dashboard")) return "dashboard";
    if (path.startsWith("/settings")) return "settings";
    return "dashboard";
  });

  const onTabChange = (tabId) => {
    setActiveTab(tabId);
    if (tabId === "statistics") navigate("/statistics");
    else if (tabId === "dashboard") navigate("/dashboard");
    else if (tabId === "settings") navigate("/settings");
  };

  return (
    <>
      <div style={{ paddingBottom: "60px" }}>
        {children}
      </div>
      <TabBar activeTab={activeTab} onTabChange={onTabChange} />
    </>
  );
};

export default Layout;
