# rumal_docker
A docker container with a ready to run rumal instance


# Installation 

System-wide requirements
* Docker 
* git

    
**Docker:**

You will need docker to be able to build dockefiles, follow the instructions on [this link](https://docs.docker.com/engine/installation/) on your respective system. You will need to be able to run the command ```docker-compose```.


**Cloning and building Dockerfile**

For windows you will need to run ```git config --global core.autocrlf input``` before pulling the rumal docker git repository so that the files are in the write file format. 

```sh
$ git clone  https://github.com/thugs-rumal/rumal_docker.git
$ cd rumal_docker
$ docker-compose build 
```

**Run**

The following command will create ```rumaldocker_backend_1``` and ```rumaldocker_frontend_1``` and run the two containers
```sh
$ docker-compose up 
```
Your instance of rumal-thug is now ready to use. 

Rumal backend is running on (IP):8000/admin.  
Rumal front end will be running on (IP):8080.

# Connection

* **Windows:**  
    Go to [192.168.99.100:8080](http://192.168.99.100:8080) to access Rumal. This IP address might be different for you, see **Find default IP address** if it doesn’t work.

* **Ubuntu:**  
    [127.0.0.1:8080](http://127.0.0.1:8080) should work to access Rumal.  

* **Login:**    
    *Default user*: admin  
    *Default password*: admin  




**Find default IP address:**

Docker is configured to use the default machine with IP <192.168.99.100>(This is the IP address you use to connect to server).  
IP address can be found by running this on your host machine: 
```sh
$ docker-machine ip
```  
OR  
The IP address displayed at the top of the Docker Quick start Terminal

# Tests
This has been tested on :  
-  Windows 10 / Docker version 1.11.0
-  Ubuntu 16.04 Desktop / Docker version 1.11.0




