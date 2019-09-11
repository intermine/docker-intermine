# Intermine on Docker (deprecated, use docker-intermine-gradle instead)

Docker-compose project to build an intermine container instance.

## Getting Started

### Prerequisities

docker and docker-compose

### Install MalariaMine demo

This will build the MalariaMine demo project from 3 containers.

```
/git$ git clone https://github.com/intermine/docker-intermine.git
/git$ cd docker-intermine
/git/docker-intermine$ docker-compose -p malariamine up
/git/docker-intermine$ xdg-open http://localhost:8088/malariamine
```

Once you have verified you can access the webapp and run a template, please shutdown the instance. This webapp is not meant to be public. 

### Install a Mine from PostgreSQL dump

For all the instructions below, replace "yeastmine" with the name of your mine. Assume everything is case-sensitive. The userprofile is built everytime, so this is not suitable (yet) for production InterMines.

To bootstrap an existing container, you will need a directory that you will mount on the data volume container - as the volumes directive in the docker-compose file shows.

In your `docker-intermine` directory (that you created in the MalariaMine demo step above), create a directory for your mine, e.g.:

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

Update your properties to look like this:

```
db.production.datasource.serverName=localhost
db.production.datasource.databaseName=PSQL_DB_NAME
db.production.datasource.user=PSQL_USER
db.production.datasource.password=PSQL_PWD

db.userprofile-production.datasource.serverName=localhost
db.userprofile-production.datasource.databaseName=userprofile-PSQL_DB_NAME
db.userprofile-production.datasource.user=PSQL_USER
db.userprofile-production.datasource.password=PSQL_PWD



webapp.manager=TOMCAT_USER
webapp.password=TOMCAT_PWD

```


#### Database dump

##### Make the directory

 This is where the script will be looking for the dump file. Everything is case sensitive.

```
/git/docker-intermine/yeastmine$ mkdir intermine-psql-dump
```

##### Move the database dump 

Copy the dump file to the `intermine-psql-dump` directory, you can use `scp` or `rsync`. The filename of the dump file does not matter. Here's the command I used:

```
rsync /data/flymine/release-43.0-29-june-2016.final ubuntu@52.203.55.22:/home/ubuntu/git/docker-intermine/flymine/intermine-psql-dump/release-43.0-29-june-2016.final -e 'ssh -i MY_NAME.pem' -av -h --progress 
```

##### Make a sym link

Make a sym link called `latest.dump`.

```
/git/docker-intermine/yeastmine$ cd intermine-psql-dump
/git/docker-intermine/yeastmine/intermine-psql-dump$ ln -s yeastmine-release.sql latest.dump 
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

Make sure you are deploy and base URLs are set to be `localhost:8080` in your properties file.

#### Update docker-compose.yml

Replace `malariamine` with the name of your mine `yeastmine` in docker-compose.yml. Case sensitive.

```
# docker-compose.yml

   - TOMCAT_PORT=8080
   - PSQL_DB_NAME=malariamine
   - DB_NAME=malariamine
  volumes_from:
   - data
  links:
   - postgres
data:
  image: centos:centos7
  volumes:
    - ./malariamine:/data
    
```

Change the tomcat and postgres passwords. Use a strong password, and one that you don't use anywhere else.

```
# docker-compose.yml

  environment:
   - PSQL_USER=interminer
   - PSQL_PWD=interminer0312 
   - TOMCAT_USER=tomcat
   - TOMCAT_PWD=tomcat0312 

```

#### Summary

In your $mine directory you should have your data dump, properties file and git checkout.

```
# in /git/docker-intermine/yeastmine

   intermine-psql-dump/latest.dump --> yeastmine.dump.final
   .intermine/yeastmine.properties
   intermine
      bio/...
      imbuild/...
      intermine/...
      yeastmine/...
      ...
```

#### Launch the containers for YeastMine

```
docker-compose -p yeastmine up -d
# wait for the postgre database to restore ..
xdg-open http://localhost:8088/yeastmine
```
#### Help!

1. You will need lots of space free in `/tmp`. That's where the search index, etc. is unpacked. I needed > 6 GB.
2. The keyword search fails until the index is loaded into memory. 
3. If you make a change, you have to destroy your docker containers and relaunch your images. Below is the command I use but there are probably better ways to do this.

```
# You have to stop the containers before you can remove them.
docker ps -a |xargs docker rm
# Remove the images too, if you have made changes.
docker images -q |xargs docker rmi
# someone reported they even had to restart docker. I don't know why.
```
# This repo is deprecated, use docker-intermine-gradle instead
