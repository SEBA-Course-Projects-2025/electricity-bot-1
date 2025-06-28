import os
import requests
import jwt
from dotenv import load_dotenv

load_dotenv()


class KeycloakAuthClient:
    def __init__(self):
        self.keycloak_url = os.getenv("KEYCLOAK_URL")
        self.realm = os.getenv("KEYCLOAK_REALM")
        self.client_id_web = os.getenv("KEYCLOAK_CLIENT_ID_WEB")
        self.client_id_mobile = os.getenv("KEYCLOAK_CLIENT_ID_MOBILE")
        self.client_secret_web = os.getenv("KEYCLOAK_CLIENT_SECRET_WEB")
        self.client_secret_mobile = os.getenv("KEYCLOAK_CLIENT_SECRET_MOBILE")

    def exchange_code_for_token(self, code: str, is_web: bool = True) -> dict:
        client_id = self.client_id_web if is_web else self.client_id_mobile
        redirect_uri = (
            "http://localhost:3000/callback"
            if is_web
            else "http://localhost/mobile-callback"  # or com.electricitybot://callback
        )

        data = {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirect_uri,
            "client_id": client_id,
        }

        if is_web:
            data["client_secret"] = self.client_secret_web
        else:
            data["client_secret"] = self.client_secret_mobile

        token_url = (
            f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/token"
        )
        response = requests.post(token_url, data=data)

        print("Token response (raw):", response.text, flush=True)

        if response.status_code != 200:
            raise Exception(f"Token exchange failed: {response.text}")

        tokens = response.json()

        if "access_token" not in tokens:
            raise Exception("Access token missing in response")

        return tokens

    # def get_userinfo_from_token(self, access_token: str) -> dict:
    #     payload = jwt.decode(
    #         access_token, options={"verify_signature": False, "verify_aud": False}
    #     )
    #     issuer = payload["iss"]
    #     userinfo_url = f"{issuer}/protocol/openid-connect/userinfo"
    #     res = requests.get(
    #         userinfo_url, headers={"Authorization": f"Bearer {access_token}"}
    #     )

    #     if res.status_code != 200:
    #         raise Exception(f"Failed to get user info: {res.text}")

    #     return res.json()

    def get_userinfo_from_token(self, access_token: str) -> dict:
        payload = jwt.decode(
            access_token, options={"verify_signature": False, "verify_aud": False}
        )

        issuer = payload["iss"]

        userinfo_url = f"{issuer}/protocol/openid-connect/userinfo"
        res = requests.get(
            userinfo_url, headers={"Authorization": f"Bearer {access_token}"}
        )

        if res.status_code == 200:
            return res.json()

        fallback_issuer = issuer.replace("localhost", "host.docker.internal")
        fallback_url = f"{fallback_issuer}/protocol/openid-connect/userinfo"
        res = requests.get(
            fallback_url, headers={"Authorization": f"Bearer {access_token}"}
        )

        if res.status_code != 200:
            raise Exception(f"Failed to get user info: {res.text}")

        return res.json()

    def google_callback_exchange(self, code: str) -> str:
        return self.exchange_code_for_token(code, is_web=True)["access_token"]

    # def logout(self, refresh_token: str, is_web: bool = True) -> None:
    #     logout_url = (
    #         f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/logout"
    #     )
    #     client_id = self.client_id_web if is_web else self.client_id_mobile
    #     client_secret = self.client_secret_web if is_web else self.client_secret_mobile

    #     data = {
    #         "client_id": client_id,
    #         "client_secret": client_secret,
    #         "refresh_token": refresh_token,
    #     }

    #     response = requests.post(logout_url, data=data)

    #     if response.status_code != 204:
    #         raise Exception(f"Logout failed: {response.text}")

    def logout(self, refresh_token: str, is_web: bool = True) -> None:
        base_url = (
            f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/logout"
        )
        client_id = self.client_id_web if is_web else self.client_id_mobile
        client_secret = self.client_secret_web if is_web else self.client_secret_mobile

        data = {
            "client_id": client_id,
            "client_secret": client_secret,
            "refresh_token": refresh_token,
        }

        response = requests.post(base_url, data=data)

        if response.status_code == 204:
            return

        fallback_url = base_url.replace("localhost", "host.docker.internal")
        response = requests.post(fallback_url, data=data)

        if response.status_code != 204:
            raise Exception(f"Logout failed: {response.text}")

    # def refresh_token(self, refresh_token: str, is_web: bool = True) -> dict:
    #     client_id = self.client_id_web if is_web else self.client_id_mobile

    #     data = {
    #         "grant_type": "refresh_token",
    #         "refresh_token": refresh_token,
    #         "client_id": client_id,
    #     }

    #     if is_web:
    #         data["client_secret"] = self.client_secret_web
    #     else:
    #         data["client_secret"] = self.client_secret_mobile

    #     token_url = (
    #         f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/token"
    #     )
    #     response = requests.post(token_url, data=data)

    #     if response.status_code != 200:
    #         raise Exception(f"Refresh failed: {response.text}")

    #     return response.json()

    def refresh_token(self, refresh_token: str, is_web: bool = True) -> dict:
        client_id = self.client_id_web if is_web else self.client_id_mobile
        client_secret = self.client_secret_web if is_web else self.client_secret_mobile

        data = {
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
            "client_id": client_id,
            "client_secret": client_secret,
        }

        base_url = (
            f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/token"
        )

        response = requests.post(base_url, data=data)
        if response.status_code == 200:
            return response.json()

        fallback_url = base_url.replace("localhost", "host.docker.internal")
        response = requests.post(fallback_url, data=data)

        if response.status_code != 200:
            raise Exception(f"Refresh failed: {response.text}")

        return response.json()
