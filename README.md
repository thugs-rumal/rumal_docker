# rumal_docker
A docker container with a ready to run rumal instance


# Installation 

System-wide requirements
* Docker 
* git

    
**Docker:**

You will need docker to be able to build dockefiles, follow the insructions on [this link](https://docs.docker.com/engine/installation/) on your respective system. You will need to be able to run commands like ```docker-compose```.


**Cloning and building Dockerfile**
```sh
$ git clone https://github.com/Dennisparchkov/rumal_docker.git
$ cd rumal_docker
$ docker-compose build 
```

**Run backend**
```sh
docker run -ti --privileged -p 8000:8000 -p 27017:27017 --name back rumaldocker_backend
```
This will start pulling ```thug-docker```. Once its finished you will see:
```
Starting Rumal's backend worker daemon...
Starting Rumal's backend HTTP Server...
Running on: http://hostDockerIP:8000/
Username: admin
Api-Key: 4823ef79b9fa1bc0b119e20602dd34b1
```
Backend is running in a container named ```back```. If you are on Windows or Mac you can see running containers on **Kitematic** or by running ```docker ps -a```

**Run frontend**
```sh
docker run -d -p 8080:8080 --name front rumaldocker_frontend
```
The container running front end is calld ```front```.
```-d``` will run the container in detached mode. Removing this will display:
```
Starting Rumal's HTTP Server...
Starting Rumal's frontend daemon...
Starting Rumal's enrich daemon...
Running on: http://hostDockerIP:8080/
Username: admin
```

**Connection**

Go to [192.168.99.100:8080](192.168.99.100:8080) to access Rumal. This IP address might be different for you, see **Find default IP address** if it doesnt work.

* Default user: admin
* Default password: admin  



**Find default IP address:**

Docker is configured to use the default machine with IP <192.168.99.100>(This is the IP address you use to connect to server)

IP address can be found by running this on your host machine: 
```sh
$ docker-machine ip
```
OR

The IP address displayed at the top of the Docker Quickstart Terminal

# Tests
This has been tested on :
-  Windows 10 / Docker version 1.11.0




