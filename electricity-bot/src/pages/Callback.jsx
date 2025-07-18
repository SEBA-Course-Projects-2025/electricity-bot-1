// 📁 src/pages/Callback.jsx
import { useEffect, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { exchangeCodeForToken, saveTokens } from "../services/AuthService";
import { AuthContext } from "../context/AuthContext";

const Callback = () => {
  const navigate = useNavigate();
  const { setIsAuthenticated } = useContext(AuthContext);

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");

    console.log("✅ CALLBACK URL:", window.location.href);
    console.log("✅ Extracted code:", code);

    if (!code) {
      console.error("❌ No code in callback URL");
      navigate("/auth");
      return;
    }

    exchangeCodeForToken(code)
      .then((res) => {
        console.log("✅ TOKEN RESPONSE:", res);
        if (res.access_token && res.refresh_token) {
          saveTokens(res.access_token, res.refresh_token);
          setIsAuthenticated(true);
          navigate("/dashboard");
        } else {
          console.error("❌ Missing tokens in response");
          navigate("/auth");
        }
      })
      .catch((err) => {
        console.error("❌ Error exchanging code:", err);
        navigate("/auth");
      });
  }, [navigate, setIsAuthenticated]);

  return <p>Processing login...</p>;
};

export default Callback;
