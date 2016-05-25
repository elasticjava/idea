#Idea in Docker

dockerized [IntelliJ Idea Community Edition](https://www.jetbrains.com/idea/)

****

## Getting started

this directory contains tools to kickstart your dev environment
installing the latest [IntelliJ Idea Community Edition](https://www.jetbrains.com/idea/)
and Java 8 in a docker container for your sharable workplace

## Kickstart with Docker

1.   [install docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/)
1.   if you have another [UID](https://en.wikipedia.org/wiki/User_identifier)/[GID](https://en.wikipedia.org/wiki/Group_identifier) than `1000` 
please change the [Dockerfile](Dockerfile) or run 
     Replace "export uid=1000 gid=1000" with your user / group id inside the Dockerfile
     or do so by running
```bash
       sed -i "s/export uid=1000 gid=1000/export uid=X$UID gid=X${GROUPS[0]}/" Dockerfile
```
     before interacting with this  Dockerfile

2.  Build image with:
```bash
    docker build -t elasticjava/idea:v1 .
```
    
3.  Idea needs a few configuration step initially
       so first start docker via
```bash
        docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/usr/local/src --net=host elasticjava/idea:v1
```
4.  and configure IntelliJ your favourite way, install plugins etc. and quit the running Idea. Then conserve the running container as image with
```bash
        docker commit $(docker ps -a -f ancestor=elasticjava/idea:v1 -n=1 -q) idea
```
    
5.   now you can run IntelliJ Idea anywhere inside your favourite source folder with:
```bash
       docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/usr/local/src --net=host idea
```
     have happy ideas!
    
    
