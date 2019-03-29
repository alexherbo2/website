---
title: Docker Notes
description: First experiment with Docker
date: 2015-07-20
---

My first experiment with [Docker] after reading [Jessie’s Docker Containers on the Desktop].

{{< table-of-contents >}}

## The Console

Try [Ubuntu image]:

``` sh
docker pull ubuntu
docker run ubuntu # Runs Ubuntu and exits
```

``` sh
docker run [--interactive -i] [--tty -t] ubuntu
```

Install [Kakoune] inside the Docker container:

``` sh
apt update
apt install git pkg-config libncursesw5-dev
git clone https://github.com/mawww/kakoune repositories/github.com/mawww/kakoune
cd repositories/github.com/mawww/kakoune/src
make install
kak
exit
```

Exited Ubuntu.

``` sh
docker run --interactive --tty ubuntu
```

Ubuntu:

``` sh
kak
# bash: kak: command not found
```

Kakoune is not installed??

### Docker’s like Git

https://stackoverflow.com/questions/19585028/i-lose-my-data-when-the-container-exits

> When you use `docker run` to start a container, it actually creates a new container
> based on the image you have specified.

> You need to commit the changes you make to the container and then run it.

Exited Ubuntu.

``` sh
docker ps [--all -a]
# CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
# dbf27ffc058d ubuntu "/bin/bash" About an hour ago Exited (0) About a minute ago shinichi
```

``` sh
docker attach shinichi
# You cannot attach to a stopped container, start it first
```

``` sh
docker start shinichi
docker attach shinichi
```

Exited Ubuntu.

``` sh
docker commit shinichi shinichi
```

Just testing:

``` sh
docker run --interactive --tty shinichi
```

Exited Ubuntu.

``` sh
docker ps [--latest -l]
# CONTAINER ID IMAGE COMMAND CREATED STATUS PORTS NAMES
# 15529bec5b53 shinichi "/bin/bash" About a minute ago Exited (0) About a minute ago tashigi
```

## Dockerfile

https://docs.docker.com/engine/reference/builder/

`dockers/ubuntu/kakoune/Dockerfile`

``` dockerfile
FROM ubuntu
RUN apt update
RUN apt install git pkg-config libncursesw5-dev --assume-yes
RUN git clone https://github.com/mawww/kakoune repositories/github.com/mawww/kakoune
RUN cd repositories/github.com/mawww/kakoune/src; make install
ENTRYPOINT kak
```

``` sh
docker build dockers/ubuntu/kakoune
# Successfully built d02682b6d01a
```

Build and tag:

``` sh
docker build [--tag -t] ubuntu/kakoune dockers/ubuntu/kakoune
```

Tag after build:

``` sh
docker tag d02682b6d01a ubuntu/kakoune
```

Just testing:

``` sh
docker run --interactive --tty ubuntu/kakoune
```

Exited Ubuntu / Kakoune.

### Kakoune support

Added support for Kakoune: https://github.com/mawww/kakoune/pull/326

## Cleaning

Remove all containers:

``` sh
docker rm $(docker ps --no-trunc --all --quiet)
```

[Docker]: https://docker.com
[Ubuntu image]: https://hub.docker.com/_/ubuntu
[Kakoune]: https://kakoune.org
[Jessie’s Docker Containers on the Desktop]: https://blog.jessfraz.com/post/docker-containers-on-the-desktop/
