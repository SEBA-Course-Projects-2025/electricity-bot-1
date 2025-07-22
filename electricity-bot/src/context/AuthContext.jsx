import { createContext, useContext, useState, useEffect } from "react";
import { getAccessToken, getUserId, logout as backendLogout } from "../services/AuthService";

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userId, setUserId] = useState(null);
  const [accessToken, setAccessToken] = useState(null);
  const [user, setUser] = useState(null);

  useEffect(() => {
    const token = getAccessToken();
    console.log("[AuthProvider] Access token on mount:", token);
    setAccessToken(token);
    setIsAuthenticated(!!token);
    const uid = getUserId();
    console.log("[AuthProvider] User ID on mount:", uid);
    setUserId(uid || null);

    const savedUser = localStorage.getItem("user");
    if (savedUser) {
      try {
        const parsedUser = JSON.parse(savedUser);
        setUser(parsedUser);
        console.log("[AuthProvider] Loaded user from localStorage:", parsedUser);
      } catch (e) {
        console.error("[AuthProvider] Failed to parse user from localStorage:", e);
        setUser(null);
      }
    } else {
      console.log("[AuthProvider] No user found in localStorage");
      setUser(null);
    }
  }, []);

  const logout = async () => {
    await backendLogout();
    setIsAuthenticated(false);
    setUserId(null);
    setAccessToken(null);
    setUser(null);
    localStorage.removeItem("user");
    console.log("[AuthProvider] User logged out, cleared storage and state");
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
        user,
        setUser,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
