from apscheduler.schedulers.background import BackgroundScheduler
from application.measurement.measurement_service import MeasurementService

# background job for checking independently from main tread (Flask program) whether some devices (Raspberry Pies)
# are not active anymore
def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(
        func=lambda: run_periodic_check(),
        trigger="interval",
        seconds=60
    )
    scheduler.start()

def run_periodic_check():
    with MeasurementService() as service:
        service.check_for_disconnected_devices()