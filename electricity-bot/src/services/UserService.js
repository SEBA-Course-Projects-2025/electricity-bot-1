const API_BASE = "https://bot-1.electricity-bot.online";

export const getCurrentUser = async (accessToken) => {
  if (!accessToken) {
    throw new Error("Missing token");
  }

  const response = await fetch(`${API_BASE}/user`, {
    method: "GET",
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    throw new Error(`Error fetching user: ${response.status}`);
  }

  const user = await response.json();
  console.log("User fetched:", user);
  return user;
};
