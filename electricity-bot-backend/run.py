from application import app
from application.background_tasks import start_scheduler

start_scheduler()

if __name__ == '__main__':
    app.run(debug=True, port=5000)
