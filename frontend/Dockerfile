# This is a Dockerfile for creating a Thug https://github.com/buffer/thug Container from the latest
# Ubuntu base image. This is known bo be working on Ubuntu 14.04. It should work on any later version
# This is a full installation of Thug including all optional packages used for distributed operation
# Excluding Androguard
FROM ubuntu:15.10
MAINTAINER ali@ikinci.info
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
WORKDIR  /root/
RUN  apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    python-dev \
    python-magic \
    python-ndg-httpsclient \
    python-openssl \
    python-pyasn1
RUN curl https://bootstrap.pypa.io/get-pip.py |python
RUN git clone https://github.com/thugs-rumal/rumal.git
WORKDIR /root/rumal/
RUN pip install --no-cache-dir --upgrade pip
RUN apt-get -y install --no-install-recommends sed
RUN pip install --no-cache-dir -r requirements.txt
RUN mkdir /root/rumal/logs/
RUN python manage.py migrate
EXPOSE 8000
RUN python manage.py createsuperuser --username=rumal --email=rumal@honeynet.org
CMD python manage.py runserver 0.0.0.0:8000
