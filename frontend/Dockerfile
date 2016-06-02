# This Dockerfile is for creating a fully functional Rumal frontend
# with a default user with admin:admin credentials.
# Please ONLY USE THIS FOR TESTING.
FROM ubuntu:14.04
MAINTAINER ali@ikinci.info
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
WORKDIR  /root

#Mongo
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  echo 'deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse' > /etc/apt/sources.list.d/mongodb.list
  

RUN  apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    mongodb-org  \
    python-dev \
    python-magic \
    python-openssl \
    python-pyasn1 \
    sed \
    sqlite3
	
VOLUME ["/data/db"]	

RUN curl https://bootstrap.pypa.io/get-pip.py | python
WORKDIR /opt
RUN git clone https://github.com/thugs-rumal/rumal.git
WORKDIR rumal
ADD start.sh .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN mkdir -p /opt/rumal/logs/
RUN python manage.py makemigrations
RUN python manage.py migrate
EXPOSE 8080
RUN echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@example.com', 'admin')" | python manage.py shell
CMD ["/bin/bash", "/opt/rumal/start.sh"]
