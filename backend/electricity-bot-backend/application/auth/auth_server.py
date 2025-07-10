import os
import requests
import jwt
from dotenv import load_dotenv

load_dotenv()


class KeycloakAuthClient:
    def __init__(self):
        self.keycloak_url = os.getenv("KEYCLOAK_URL")
        self.public_url = os.getenv("KEYCLOAK_PUBLIC_URL", self.keycloak_url)
        self.realm = os.getenv("KEYCLOAK_REALM")

        self.client_id_web = os.getenv("KEYCLOAK_CLIENT_ID_WEB")
        self.client_id_mobile = os.getenv("KEYCLOAK_CLIENT_ID_MOBILE")
        self.client_secret_web = os.getenv("KEYCLOAK_CLIENT_SECRET_WEB")
        self.client_secret_mobile = os.getenv("KEYCLOAK_CLIENT_SECRET_MOBILE")

        self.redirect_uri_web = os.getenv("KEYCLOAK_REDIRECT_URI_WEB")
        self.redirect_uri_mobile = os.getenv("KEYCLOAK_REDIRECT_URI_MOBILE")

    def _get_redirect_uri(self, is_web: bool) -> str:
        return self.redirect_uri_web if is_web else self.redirect_uri_mobile

    def _get_client_id(self, is_web: bool) -> str:
        return self.client_id_web if is_web else self.client_id_mobile

    def _get_client_secret(self, is_web: bool) -> str:
        return self.client_secret_web if is_web else self.client_secret_mobile

    def _fallback_request(
        self, url: str, data: dict, headers=None
    ) -> requests.Response:
        fallback_url = url.replace("localhost", "host.docker.internal")
        return requests.post(fallback_url, data=data, headers=headers or {})

    def exchange_code_for_token(self, code: str, is_web: bool = True) -> dict:
        data = {
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": self._get_redirect_uri(is_web),
            "client_id": self._get_client_id(is_web),
            "client_secret": self._get_client_secret(is_web),
        }

        token_url = (
            f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/token"
        )
        response = requests.post(token_url, data=data)

        if response.status_code != 200:
            response = self._fallback_request(token_url, data)

        if response.status_code != 200:
            raise Exception(f"Token exchange failed: {response.text}")

        tokens = response.json()
        if "access_token" not in tokens:
            raise Exception("Access token missing in response")

        return tokens

    def get_userinfo_from_token(self, access_token: str) -> dict:
        payload = jwt.decode(
            access_token, options={"verify_signature": False, "verify_aud": False}
        )
        issuer = payload["iss"]
        userinfo_url = f"{issuer}/protocol/openid-connect/userinfo"

        headers = {"Authorization": f"Bearer {access_token}"}
        response = requests.get(userinfo_url, headers=headers)

        if response.status_code != 200:
            fallback_url = userinfo_url.replace("localhost", "host.docker.internal")
            response = requests.get(fallback_url, headers=headers)

        if response.status_code != 200:
            raise Exception(f"Failed to get user info: {response.text}")

        return response.json()

    def refresh_token(self, refresh_token: str, is_web: bool = True) -> dict:
        data = {
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
            "client_id": self._get_client_id(is_web),
            "client_secret": self._get_client_secret(is_web),
        }

        token_url = (
            f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/token"
        )
        response = requests.post(token_url, data=data)

        if response.status_code != 200:
            response = self._fallback_request(token_url, data)

        if response.status_code != 200:
            raise Exception(f"Refresh failed: {response.text}")

        return response.json()

    def logout(self, refresh_token: str, is_web: bool = True) -> None:
        data = {
            "client_id": self._get_client_id(is_web),
            "client_secret": self._get_client_secret(is_web),
            "refresh_token": refresh_token,
        }

        logout_url = (
            f"{self.keycloak_url}/realms/{self.realm}/protocol/openid-connect/logout"
        )
        response = requests.post(logout_url, data=data)

        if response.status_code != 204:
            response = self._fallback_request(logout_url, data)

        if response.status_code != 204:
            raise Exception(f"Logout failed: {response.text}")

    def google_callback_exchange(self, code: str) -> str:
        tokens = self.exchange_code_for_token(code, is_web=True)
        return tokens["access_token"]
