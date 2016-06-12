# Ubuntu 15.04 with Java 8, IntelliJ Idea installed
# Build image with:
#   docker build -t elasticjava/idea:v1 .
#
# Idea need a few configuration step initially
#   so first start docker via
#    docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/usr/local/src --net=host elasticjava/idea:v1
#   and configure IntelliJ your favourite way, install plugins etc. and quit the running Idea. Then conserve the running container as image with
#    docker commit $(docker ps -a -f ancestor=elasticjava/idea:v1 -n=1 -q) idea
#
# now you can run IntelliJ Idea inside your favourite source folder with:
#   docker run -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $PWD:/usr/local/src --net=host idea

# !!! Replace "export uid=1000 gid=1000" with your user / group id
# do so by running
#   sed -i "s/export uid=1000 gid=1000/export uid=X$UID gid=X${GROUPS[0]}/" Dockerfile
# before interacting with this  Dockerfile


FROM ubuntu:15.04
MAINTAINER Holger Bartnick, https://github.com/elasticjava

# installing latest Oracle Java 8
# and setting default $JAVA_HOME variables
RUN apt-get update && \
    apt-get install -y  software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default oracle-java8-unlimited-jce-policy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists && \
    rm -r /var/cache/oracle-jdk8-installer

# install used tools like curl and git sudo and standard dev tools like git
RUN apt-get update && \
    apt-get install -y sudo curl jq git wget tar unzip mercurial cvs && \
    apt-get clean

# install GUI relevant libs
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
        select true | debconf-set-selections && \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    libx11-6 libxext-dev libxrender-dev libxtst-dev ttf-dejavu fonts-dejavu-core libfontconfig1 \
    xauth ttf-kochi-gothic ttf-kochi-mincho  ttf-mscorefonts-installer libgtk2.0 \
    ttf-indic-fonts ttf-dejavu-core fonts-thai-tlwg ubuntu-restricted-extras && \
    apt-get clean

RUN ln -s /etc/fonts/conf.avail/69-language-selector-ja-jp.conf /etc/fonts/conf.d/
#
# !!! Replace 1000 with your user / group id
# do so by running
#   sed -i "s/export uid=1000 gid=1000/export uid=X$UID gid=X${GROUPS[0]}/" Dockerfile
# on this Dockerfile
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

# I don't like RUN command wrapping and like the bash
# this prevents /bin/sh: 1: Syntax error: redirection unexpected
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# installing latest IntelliJ Idea Community Edition
RUN set -x && \
    mkdir -p /usr/local/share/idea && \
    cd /usr/local/share/idea && \
    response=$(curl -s --compressed "https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release" -H "Accept: application/json" -H "Accept-Encoding: gzip, deflate, br") && \
    link=$(jq -r ".IIC[].downloads.linux.link" <<< $response) && \
    echo "downloading $link..." && \
    downloadedFile=$(curl --write-out "%{filename_effective}" -L --remote-header-name --remote-name $link) && \
    #todo: checksum validation does not work yet..?!
    #checksumLink=$(jq -r ".IIC[].downloads.linux.checksumLink" <<< $response) && \
    #echo "downloading $checksumLink..." && \
    #downloadedFileCheck=$(curl --write-out "%{filename_effective}" -L --remote-header-name --remote-name $checksumLink) && \
    #echo "validating ${downloadedFile} with ${downloadedFileCheck}..." && \
    #! sha256sum -c $downloadedFileCheck --status 2>&1 && \
    echo "installing ${downloadedFile}..." && \
    tar --no-overwrite-dir --skip-old-files -x -f $downloadedFile && \
    linkTarget=$(ls -d -v idea-IC-*|tac|head -n 1) && \
    ln -sTf $linkTarget idea-current && \
    echo "updating alternatives for idea ..." && \
    update-alternatives --install /usr/bin/idea idea /usr/local/share/idea/idea-current/bin/idea.sh 1 && \
    echo "cleaning up..." && \
    rm -rf $downloadedFile $downloadedFileCheck && \
    echo "done. have happy ideas!" && \
    set +x

# adding the modified idea64.vmoptions
ADD idea64.vmoptions /usr/local/share/idea/idea-current/bin/idea64.vmoptions

# prepare the virtual src folder
RUN export uid=1000 gid=1000 && \
    mkdir -p /usr/local/src && \
    chown ${uid}:${gid} -R /usr/local/src

# shrink the docker image
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -r /var/cache/

VOLUME ["/usr/local/src"]
WORKDIR /usr/local/src

USER developer
ENV HOME /home/developer
CMD [ "/usr/bin/idea", "/usr/local/src" ]
