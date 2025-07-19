import { logout } from "../services/AuthService";

const Dashboard = () => {
  return (
    <div>
      <h1>Dashboard</h1>
      <button onClick={logout}>Logout</button>
    </div>
  );
};

export default Dashboard;
