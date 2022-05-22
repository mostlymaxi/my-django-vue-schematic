import time
from .celery import app


@app.task
def example_task(x):
    time.sleep(x * .01)
    return True