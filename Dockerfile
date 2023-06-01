FROM python:3.11-slim-buster

EXPOSE 8000

# install python requirements
COPY django/requirements.txt /app
RUN pip install --upgrade pip
RUN pip install -r /app/requirements.txt

# copy app and make migrations
COPY django /app
RUN python /app/dummy/manage.py makemigrations

# Run the app
CMD python /app/dummy/manage.py migrate && python /app/dummy/manage.py runserver 0.0.0.0:8000
