# This Dockerfile is for creating a fully functional Rumal backend
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
    mongodb-org \
    python-dev \
    python-magic \
    python-openssl \
    python-pyasn1 \
    sed \
    sqlite3 \ 
	apt-transport-https \
	ca-certificates \
    curl \
    lxc \
    iptables \ 
	net-tools \ 
	sudo \
	expect-dev
	
VOLUME ["/data/db"]
	
# Install Docker from Docker Inc. repositories.
RUN \
	sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
	echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
RUN  apt-get update && apt-get -y dist-upgrade
RUN  apt-get -y install docker-engine
	

RUN curl https://bootstrap.pypa.io/get-pip.py | python
WORKDIR /opt
RUN git clone https://github.com/Dennisparchkov/rumal_back.git
WORKDIR rumal_back
ADD start.sh .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN python manage.py makemigrations
RUN python manage.py migrate
EXPOSE 8000
EXPOSE 27017
EXPOSE 28017
RUN echo "from django.contrib.auth.models import User; from tastypie.models import ApiKey; User.objects.create_superuser('admin', 'admin@example.com', 'admin'); key, created = ApiKey.objects.get_or_create(user=User.objects.get(username='admin')); key.key = '4823ef79b9fa1bc0b119e20602dd34b1'; key.save()" | python manage.py shell

CMD ["/bin/bash", "/opt/rumal_back/start.sh"]
