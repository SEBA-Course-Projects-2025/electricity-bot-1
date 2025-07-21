import { createContext, useContext, useState, useEffect } from "react";
import { getAccessToken, getUserId, logout as backendLogout } from "../services/AuthService";

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userId, setUserId] = useState(null);

  useEffect(() => {
    setIsAuthenticated(!!getAccessToken());
    setUserId(getUserId() || null);
  }, []);

  const logout = async () => {
    await backendLogout();
    setIsAuthenticated(false);
    setUserId(null);
  };

  return (
    <AuthContext.Provider
      value={{ isAuthenticated, setIsAuthenticated, userId, setUserId, logout }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
