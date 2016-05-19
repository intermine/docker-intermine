# Intermine on Docker

Docker-compose project to build an intermine container instance.

## Getting Started

### Prerequisities

docker and docker-compose

### Install malariamine demo

This will build the malariamine demo project from 3 containers.

```
git clone https://github.com/intermine/docker-intermine.git
cd docker-intermine
docker-compose -p malariamine up
xdg-open http://localhost:8088/malariamine
```

### Install a Mine from postgres dump

To bootstrap an existing container, you will need a directory that you will mount on the data volume container - as the volumes directive in the docker-compose file shows.

In your `docker-intermine` directory, create a directory for your mine, e.g.:

```
/git/docker-intermine/$ mkdir yeastmine
/git/docker-intermine/$ cd yeastmine
```

#### Properties

Copy your .intermine/yeastmine properties file.

```
/git/docker-intermine/yeastmine$ mkdir .intermine
/git/docker-intermine/yeastmine$ cd .intermine
/git/docker-intermine/yeastmine/.intermine$ cp ~/.intermine/yeastmine.properties .
```

#### Database dump

Copy the dump file to the local directory and make a sym link.

```
/git/docker-intermine/yeastmine$ mkdir intermine-psql-dump
/git/docker-intermine/yeastmine$ cd intermine-psql-dump
/git/docker-intermine/yeastmine/intermine-psql-dump$ cp /data/dump/yeastmine-release.sql .
/git/docker-intermine/yeastmine/intermine-psql-dump$ ln -s yeastmine-release.sql latest-dump 
```

#### Webapp

Copy the InterMine code to the local directory.

```
/git/docker-intermine/yeastmine$ git clone https://github.com/yeastgenome/intermine.git
```

Launch the containers for yeastmine :

```
docker-compose -p yeastmine up
# wait for the postgre database to restore ..
xdg-open http://localhost:8088/yeastmine
```
