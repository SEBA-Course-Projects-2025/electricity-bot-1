import { createContext, useContext, useState, useEffect } from "react";
import { getAccessToken, getUserId, logout as backendLogout } from "../services/AuthService";

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userId, setUserId] = useState(null);
  const [accessToken, setAccessToken] = useState(null);

  useEffect(() => {
    const token = getAccessToken();
    setAccessToken(token);
    setIsAuthenticated(!!token);
    setUserId(getUserId() || null);
  }, []);

  const logout = async () => {
    await backendLogout();
    setIsAuthenticated(false);
    setUserId(null);
    setAccessToken(null);
  };

  return (
    <AuthContext.Provider
      value={{
        isAuthenticated,
        setIsAuthenticated,
        userId,
        setUserId,
        accessToken,
        setAccessToken,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
