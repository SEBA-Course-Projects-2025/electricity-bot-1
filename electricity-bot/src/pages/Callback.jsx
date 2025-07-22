import { useEffect, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { exchangeCodeForToken, saveTokens, saveUserId } from "../services/AuthService";
import { getCurrentUser } from "../services/UserService"; // ця функція з вище
import { AuthContext } from "../context/AuthContext";

const Callback = () => {
  const navigate = useNavigate();
  const { setIsAuthenticated, setAccessToken, setUserId, setUser } = useContext(AuthContext);

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");

    console.log("✅ CALLBACK URL:", window.location.href);
    console.log("✅ Extracted code:", code);

    if (!code) {
      console.error("No code in URL");
      navigate("/auth", { replace: true });
      return;
    }

    exchangeCodeForToken(code)
      .then(async ({ access_token, refresh_token, user_id }) => {
        saveTokens(access_token, refresh_token);
        if (user_id) {
          saveUserId(user_id);
          setUserId(user_id);
        }

        setAccessToken(access_token);
        setIsAuthenticated(true);

        try {
          const user = await getCurrentUser(access_token);
          setUser(user);
          localStorage.setItem("user", JSON.stringify(user));
        } catch (err) {
          console.error("Failed to fetch user:", err);
        }
        
        navigate("/devices", { replace: true });
      })
      .catch((err) => {
        console.error("Error exchanging code:", err);
        navigate("/auth", { replace: true });
      });
  }, [navigate, setIsAuthenticated, setAccessToken, setUserId, setUser]);

  return <p>Processing login...</p>;
};

export default Callback;
