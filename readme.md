# Intermine on Docker

Docker-compose project to build an intermine container instance.

## Getting Started

### Prerequisities

docker and docker-compose

### Install MalariaMine demo

This will build the MalariaMine demo project from 3 containers.

```
git clone https://github.com/intermine/docker-intermine.git
cd docker-intermine
docker-compose -p malariamine up
xdg-open http://localhost:8088/malariamine
```

### Install a Mine from PostgreSQL dump

To bootstrap an existing container, you will need a directory that you will mount on the data volume container - as the volumes directive in the docker-compose file shows.

For all the instructions below, replace "YeastMine" with the name of your mine.

In your `docker-intermine` directory, create a directory for your mine, e.g.:

```
/git/docker-intermine/$ mkdir yeastmine
/git/docker-intermine/$ cd yeastmine
```

#### Properties

Copy your `.intermine/yeastmine` properties file in the new `.intermine` directory.

```
/git/docker-intermine/yeastmine$ mkdir .intermine
/git/docker-intermine/yeastmine$ cd .intermine
/git/docker-intermine/yeastmine/.intermine$ cp ~/.intermine/yeastmine.properties .
```

#### Database dump

Copy the dump file to the `intermine-psql-dump` directory and make a sym link called `latest.dump`. The filename of the dump file does not matter.

```
/git/docker-intermine/yeastmine$ mkdir intermine-psql-dump
/git/docker-intermine/yeastmine$ cd intermine-psql-dump
/git/docker-intermine/yeastmine/intermine-psql-dump$ cp /data/dump/yeastmine-release.sql .
/git/docker-intermine/yeastmine/intermine-psql-dump$ ln -s yeastmine-release.sql latest-dump 
```

Here's an example command to get a dump file:

```
pg_dump -Fc -h localhost -U yeastmine -f /data/dump/yeastmine-release.sql yeastmine
```

#### Webapp

Copy the InterMine code to the local directory. Below is an example of checking out the code for yeastmine, but you could also just copy the repository if you have it checked out locally.

```
/git/docker-intermine/yeastmine$ git clone https://github.com/yeastgenome/intermine.git
```

Must start with `/intermine` directory and include your mine's webapp, e.g. `/git/docker-intermine/intermine/yeastmine/webapp` is the directory from which docker will deploy the webapp.

#### Launch the containers for YeastMine

```
docker-compose -p yeastmine up
# wait for the postgre database to restore ..
xdg-open http://localhost:8088/yeastmine
```
