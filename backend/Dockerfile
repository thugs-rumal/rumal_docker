# This Dockerfile is for creating a fully functional Rumal backend
# with a default user with admin:admin credentials.
# Please ONLY USE THIS FOR TESTING.
FROM ubuntu:15.10
MAINTAINER ali@ikinci.info
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
WORKDIR  /root
RUN  apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    libffi-dev \
    libssl-dev \
    mongodb \
    python-dev \
    python-magic \
    python-ndg-httpsclient \
    python-openssl \
    python-pyasn1 \
    sed \
    sqlite3
RUN curl https://bootstrap.pypa.io/get-pip.py | python
WORKDIR /opt
RUN git clone https://github.com/thugs-rumal/rumal_back.git
WORKDIR rumal_back
ADD start.sh .
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN python manage.py migrate
EXPOSE 8000
RUN echo "from django.contrib.auth.models import User; from tastypie.models import ApiKey; User.objects.create_superuser('admin', 'admin@example.com', 'admin'); key, created = ApiKey.objects.get_or_create(user=User.objects.get(username='admin')); key.key = '4823ef79b9fa1bc0b119e20602dd34b1'; key.save()" | python manage.py shell

CMD ["/bin/bash", "/opt/rumal_back/start.sh"]
