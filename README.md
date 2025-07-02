# Electricity Bot Mock Server

This is a simple Flask-based mock backend server designed to simulate API endpoints for the Electricity Bot app. It helps develop and test the frontend without triggering a backend.

---
### What does it have? 
#### ❗️TO BE UPDATED❗️Authentification Endpoints 
- `POST /api/auth/login` - accepts an id_token, got from Google, and returns user name, email and id.
- `GET /api/auth/logout` - returns a mock logout URL.

#### Get Status
- `GET /api/status/<device_id>` - returns a random power status (outgate_status) with a timestamp within the last 24 hours.

#### Get Statistics for Last 24 hours / 7 days
- `GET /api/statistics/day/<device_id>` - returns a random events within last day (outage statuses with their duration).
- `GET /api/statistics/week/<device_id>` - returns the same randomized events, but for last 7 days.

---
### How it works?
The mock server generates random data and sends it. 

For example: 
```python
now = datetime.utcnow()
random_seconds = random.uniform(0, 24 * 3600) 
random_time = now - timedelta(seconds=random_seconds)
timestamp = random_time.isoformat(timespec="milliseconds") + "Z"
```
Here, `now` is current time in worldwide standard.
`random_seconds` picks random amount of seconds from 0 to 24 hours.
`random_time` subtracts this random amount of seconds from current time, we get random timestamp in the last 24 hours.
`timestamp` transform that random time into correct format to send.

---
### How to use it locally?
1. Install dependencies (Flask, Flask-CORS): 
`pip install flask flask-cors`
2. Run the server:
`python main.py`
3. Server listens on port **5050**, use it in your project. Use such running addresses as given.
For example: 
``` python
* Running on http://127.0.0.1:5050
* Running on http://192.168.0.102:5050
```
