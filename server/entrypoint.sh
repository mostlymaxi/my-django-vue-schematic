#!/bin/sh

python manage.py migrate --no-input
python manage.py collectstatic --no-input
python manage.py crontab add

gunicorn server.wsgi:application --bind 0.0.0.0:8000
