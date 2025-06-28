import os
import requests
from dotenv import load_dotenv
from flask import jsonify

from application.auth.auth_service import generate_jwt
from application.email_utils.email_sender import send_welcome_email

load_dotenv()

KEYCLOAK_URL = os.getenv("KEYCLOAK_URL")
KEYCLOAK_REALM = os.getenv("KEYCLOAK_REALM")
CLIENT_ID_WEB = os.getenv("KEYCLOAK_CLIENT_ID_WEB")
CLIENT_ID_MOBILE = os.getenv("KEYCLOAK_CLIENT_ID_MOBILE")
CLIENT_SECRET = os.getenv("KEYCLOAK_CLIENT_SECRET")


def google_callback_exchange(code: str):
    data = {
        "code": code,
        "client_id": CLIENT_ID_WEB,
        "client_secret": CLIENT_SECRET,
        "redirect_uri": "http://localhost:3000/callback",
        "grant_type": "authorization_code",
    }

    response = requests.post(
        f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}/protocol/openid-connect/token",
        data=data,
    )

    if response.status_code != 200:
        raise Exception(f"Error exchanging code for token: {response.text}")

    return response.json()["access_token"]


import jwt, requests


def get_userinfo_from_token(access_token: str) -> dict:
    payload = jwt.decode(
        access_token, options={"verify_signature": False, "verify_aud": False}
    )
    issuer = payload["iss"]
    userinfo_url = f"{issuer}/protocol/openid-connect/userinfo"
    res = requests.get(
        userinfo_url, headers={"Authorization": f"Bearer {access_token}"}
    )
    if res.status_code != 200:
        raise Exception(f"Failed to get user info: {res.text}")
    return res.json()


def exchange_code_for_token(code: str, is_web: bool = True) -> dict:
    client_id = CLIENT_ID_WEB if is_web else CLIENT_ID_MOBILE
    redirect_uri = (
        "http://localhost:3000/callback" if is_web else "com.electricitybot://callback"
    )

    data = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirect_uri,
        "client_id": client_id,
        "client_secret": CLIENT_SECRET,
    }

    token_url = f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}/protocol/openid-connect/token"
    response = requests.post(token_url, data=data)

    print("Token response (raw):", response.text, flush=True)

    if response.status_code != 200:
        raise Exception(f"Token exchange failed: {response.text}")

    tokens = response.json()

    if "access_token" not in tokens:
        raise Exception("Access token missing in response")

    return tokens
