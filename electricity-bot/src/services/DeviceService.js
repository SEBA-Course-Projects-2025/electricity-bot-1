import { getAccessToken } from "./AuthService";

const API_BASE = "https://bot-1.electricity-bot.online";


export const getUserDevices = async (userId) => {
  const token = getAccessToken();
  if (!token) throw new Error("Not authenticated");

  const resp = await fetch(`${API_BASE}/users/${userId}/devices`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });
  if (!resp.ok) throw new Error("Failed to load devices");
  return await resp.json();
};

export const deleteUserDevice = async (deviceId) => {
  const token = getAccessToken();
  if (!token) throw new Error("Not authenticated");

  const resp = await fetch(`${API_BASE}/devices/${deviceId}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!resp.ok) {
    const txt = await resp.text();
    throw new Error(`Delete failed: ${txt}`);
  }
  
  try {
    const data = await resp.json();
    return data.msg || "Deleted";
  } catch {
    return "Deleted";
  }
};
