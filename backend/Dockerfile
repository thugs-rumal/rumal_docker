# This is a Dockerfile for creating a Thug https://github.com/buffer/thug Container from the latest
# Ubuntu base image. This is known bo be working on Ubuntu 14.04. It should work on any later version
# This is a full installation of Thug including all optional packages used for distributed operation
# Excluding Androguard
FROM honeynet/thug:latest
MAINTAINER ali@ikinci.info
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
WORKDIR  /root/
RUN  apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends \
    build-essential \
    git \
    libffi-dev \
    libssl-dev \
    mongodb \
    python-dev
# enable mongodb
RUN sed -i '/^[[:blank:]]*\[mongodb\]$/{n;s/False/True/g;}' /opt/thug/src/Logging/logging.conf
RUN git clone https://github.com/thugs-rumal/rumal_back.git
WORKDIR /root/rumal_back/
RUN pip install --upgrade pip ndg-httpsclient
RUN pip install -r requirements.txt
RUN python manage.py migrate
EXPOSE 8000
RUN python manage.py createsuperuser --username=root --email="rumal@example.com" --noinput
CMD python manage.py runserver 0.0.0.0:8000
