const API_BASE = "https://bot-1.electricity-bot.online";

export const startKeycloakLogin = () => {
  const clientId = "electricity-web-client";
  const redirectUri = encodeURIComponent("https://bot-1.electricity-bot.online/web-callback");
  //const redirectUri = encodeURIComponent("http://localhost:5173/web-callback");
  const realm = "electricity-bot";

  const authUrl = `${API_BASE}/admin/realms/${realm}/protocol/openid-connect/auth?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code&scope=openid email profile`;

  window.location.href = authUrl;
};

export const exchangeCodeForToken = async (code) => {
  const response = await fetch(`${API_BASE}/api/auth/callback`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      code,
      is_web: true,
      is_custom_mobile: false,
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
export const getRefreshToken = () => localStorage.getItem("refresh_token");

export const saveUserId = (userId) => {
  if (userId) localStorage.setItem("user_id", userId);
};
export const getUserId = () => localStorage.getItem("user_id");

export const logout = async () => {
  const access = getAccessToken();
  const refresh = getRefreshToken();

  if (!access || !refresh) {
    console.warn("No tokens found, redirecting to login");
    redirectToLogin();
    return;
  }

  try {
    await fetch(`${API_BASE}/api/auth/logout`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${access}`,
      },
      body: JSON.stringify({
        refresh_token: refresh,
        is_web: true,
      }),
    });
  } catch (err) {
    console.error("Logout request failed", err);
  }

  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  localStorage.removeItem("user");

  redirectToLogin();
};

const redirectToLogin = () => {
  const realm = "electricity-bot";
  const clientId = "electricity-web-client";
  const redirectUri = encodeURIComponent("https://bot-1.electricity-bot.online/api/auth");
  //const redirect = encodeURIComponent("http://localhost:5173/auth");
};

export const saveUserInfo = (user) => {
  if (user) localStorage.setItem("user", JSON.stringify(user));
};

export const getUserInfo = () => {
  const userStr = localStorage.getItem("user");
  if (!userStr) return null;
  try {
    return JSON.parse(userStr);
  } catch {
    return null;
  }
};
