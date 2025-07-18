const API_BASE = "https://bot-1.electricity-bot.online";

export const startKeycloakLogin = () => {
  const clientId = "electricity-web-client";
  const redirectUri = encodeURIComponent("http://localhost:5173/web-callback");
  const realm = "electricity-bot";

  const authUrl = `${API_BASE}/admin/realms/${realm}/protocol/openid-connect/auth?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=openid email profile`;

  window.location.href = authUrl;
};

export const exchangeCodeForToken = async (code) => {
  const response = await fetch(`${API_BASE}/auth/callback`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      code,
      is_web: true,
    }),
  });

  if (!response.ok) throw new Error("Failed to exchange code");
  return await response.json();
};

export const saveTokens = (access, refresh) => {
  localStorage.setItem("access_token", access);
  localStorage.setItem("refresh_token", refresh);
};

export const getAccessToken = () => localStorage.getItem("access_token");

export const logout = () => {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
};
