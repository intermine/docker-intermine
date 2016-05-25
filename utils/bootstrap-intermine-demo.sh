#!/bin/bash

# change user
#su - interminer << EOF
date=`date --iso-8601`

function postgres_bootstrap {
    echo "Creating postgres database.."

    psql -U postgres -h postgres -p 5432 -c "CREATE USER $PSQL_USER WITH PASSWORD '$PSQL_PWD';"
    psql -U postgres -h postgres -p 5432 -c "ALTER USER $PSQL_USER WITH SUPERUSER;"
    psql -U postgres -h postgres -p 5432 -c "CREATE DATABASE malariamine;"
    psql -U postgres -h postgres -p 5432 -c "CREATE DATABASE \"items-malariamine\";"
    psql -U postgres -h postgres -p 5432 -c "CREATE DATABASE \"userprofile-malariamine\";"
    psql -U postgres -h postgres -p 5432 -c "GRANT ALL PRIVILEGES ON DATABASE malariamine to $PSQL_USER;"
    psql -U postgres -h postgres -p 5432 -c "GRANT ALL PRIVILEGES ON DATABASE \"items-malariamine\" to $PSQL_USER;"
    psql -U postgres -h postgres -p 5432 -c "GRANT ALL PRIVILEGES ON DATABASE \"userprofile-malariamine\" to $PSQL_USER;"
}


#export ANT_OPTS=-Dfile.encoding=utf-8

cd ~

# clone intermine repo
if [ ! -d intermine ]; then
        git clone https://github.com/intermine/intermine.git
        cd intermine
else
        cd intermine
        git pull
fi

# malariamine project dir
./bio/scripts/make_mine MalariaMine
cd ~/intermine/malariamine
cp ../bio/tutorial/project.xml .
sed -i 's/DATA_DIR/\/data/g' project.xml
cd ~

# copy malaria data
cp ./intermine/bio/tutorial/malaria-data.tar.gz .
tar xvf malaria-data.tar.gz

# setup config and postgres
mkdir .intermine/
cp intermine/bio/tutorial/malariamine.properties .intermine/

sed -i "s/=localhost/=$PSQL_HOST/g" .intermine/malariamine.properties
sed -i "s/PSQL_USER/$PSQL_USER/g" .intermine/malariamine.properties
sed -i "s/PSQL_PWD/$PSQL_PWD/g" .intermine/malariamine.properties
sed -i "s/TOMCAT_USER/$TOMCAT_USER/g" .intermine/malariamine.properties
sed -i "s/TOMCAT_PWD/$TOMCAT_PWD/g" .intermine/malariamine.properties

# since intermine will look in /root/ directory (need a fix?)
# even if HOME != /root
cd /root/
ln -s /data/.intermine .
cd /data

# bootstrap postgres
postgres_bootstrap

# build malariamine
cd /data/intermine/malariamine/dbmodel
ant clean build-db
cd ../integrate
ant -Dsource=uniprot-malaria -v
ant -Dsource=malaria-gff -v
ant -Dsource=malaria-chromosome-fasta -v
ant -v -Dsource=entrez-organism
ant -v -Dsource=update-publications
cd ../postprocess
ant -v -Daction=create-search-index
cd ../webapp
ant build-db-userprofile
ant default remove-webapp release-webapp

# create psql dump
mkdir /data/intermine-psql-dump/
pg_dump -c -h localhost -U $PSQL_USER -f /data/intermine-psql-dump/$DB_NAME.$date.dump.final malariamine
cd /data/intermine-psql-dump/
ln -s $DB_NAME.$date.dump.final latest.dump
