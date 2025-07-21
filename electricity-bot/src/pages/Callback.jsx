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
      navigate("/auth", { replace: true });
      return;
    }

    exchangeCodeForToken(code)
      .then(({ access_token, refresh_token }) => {
        console.log("✅ TOKEN RESPONSE:", { access_token, refresh_token });
        saveTokens(access_token, refresh_token);
        setIsAuthenticated(true);
        navigate("/devices", { replace: true });
      })
      .catch((err) => {
        console.error("❌ Error exchanging code:", err);
        navigate("/auth", { replace: true });
      });
  }, [navigate, setIsAuthenticated]);

  return <p>Processing login...</p>;
};

export default Callback;
