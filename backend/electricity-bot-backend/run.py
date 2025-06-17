from dotenv import load_dotenv

load_dotenv()

from application import app
from application.background_tasks import start_scheduler

start_scheduler()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
