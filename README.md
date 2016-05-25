#Idea in Docker

dockerized [IntelliJ Idea Community Edition](https://www.jetbrains.com/idea/)

****

## Getting started

kickstart your dev environment with a sharable workplace inside a docker container
containing the latest [IntelliJ Idea Community Edition](https://www.jetbrains.com/idea/) and [Java 8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

## Kickstart with Docker

1.   [install docker](https://docs.docker.com/engine/installation/linux/ubuntulinux/)

1.   if you have another [UID](https://en.wikipedia.org/wiki/User_identifier)/[GID](https://en.wikipedia.org/wiki/Group_identifier) than `1000` please change the [Dockerfile](Dockerfile) and replace "export uid=1000 gid=1000" with your user / group id inside the Dockerfile. You might run the following script for that task:
     ```bash
     sed -i "s/export uid=1000 gid=1000/export uid=$UID gid=${GROUPS[0]}/" Dockerfile
     ```
     You might want to change these values evertime you check out the file from git
     and revert the replacement before you checkin the changed Dockerfile.
     Run the following on your host (and adjust the file ```.gitattributes``` if you change the name ```uidfix```) 
     to make that possible:
     ```bash
     git config filter.uidfix.smudge "s/export uid=1000 gid=1000/export uid=$UID gid=${GROUPS[0]}/"
     git config filter.uidfix.clean "s/export uid=$UID gid=${GROUPS[0]}/export uid=1000 gid=1000/"
     ```
     
1.   build the dockerized IntelliJ image:
     ```bash
     docker build -t elasticjava/idea:v1 .
     ```
    
1.   Idea needs a few configuration steps initially to reduce the popup screens. so first start docker via
     ```bash
     docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/usr/local/src --net=host elasticjava/idea:v1
     ```
     and configure IntelliJ your favourite way, install plugins and define codestyles.
     
1.   quit the running Idea and conserve the last image state as new image without popup screens:
     ```bash
     docker commit $(docker ps -a -f ancestor=elasticjava/idea:v1 -n=1 -q) idea
     ```
    
1.   now you can run IntelliJ Idea anywhere inside your favourite source folder with:
     ```bash
     docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/usr/local/src --net=host idea
     ```

##     have happy ideas!
    
    
