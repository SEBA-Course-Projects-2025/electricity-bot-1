import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import SplashScreen from "./components/SplashScreen";
import Welcome from "./components/Welcome";
import Login from "./components/Login";
import Callback from "./pages/Callback";
import Devices from "./pages/Devices";
import Dashboard from "./pages/Dashboard";
import ProtectedRoute from "./components/ProtectedRoute";
import { DeviceProvider } from "./context/DeviceContext";
import Layout from "./components/Layout";

function App() {
  return (
    <AuthProvider>
      <DeviceProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/" element={<SplashScreen />} />
            <Route path="/welcome" element={<Welcome />} />
            <Route path="/auth" element={<Login />} />
            <Route path="/web-callback" element={<Callback />} />
            <Route
              path="/devices"
              element={
                <ProtectedRoute>
                  <Devices />
                </ProtectedRoute>
              }
            />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <Layout>
                    <Dashboard />
                  </Layout>
                </ProtectedRoute>
              }
            />
          </Routes>
        </BrowserRouter>
      </DeviceProvider>
    </AuthProvider>
  );
}

export default App;
