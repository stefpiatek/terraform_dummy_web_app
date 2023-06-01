FROM python:3.11-slim-buster

EXPOSE 8000

RUN apt-get update\
    && apt-get install -y --no-install-recommends curl gnupg2

# Install ODBC driver
RUN apt-get update \
    && apt-get install -y --no-install-recommends locales apt-transport-https \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install unixodbc-dev libodbc1 \
    && ACCEPT_EULA=Y apt-get -y --no-install-recommends install msodbcsql18

# install python requirements
RUN pip install --upgrade pip
COPY django/requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt

# copy app
COPY django /app

# Make migrations and run the app
CMD python /app/dummy/manage.py makemigrations && python /app/dummy/manage.py migrate && python /app/dummy/manage.py runserver 0.0.0.0:8000
