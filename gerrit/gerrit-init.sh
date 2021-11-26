#!/bin/sh

echo "Setting file ownership..."
chown -R gerrit:gerrit ${GERRIT_HOME}

echo "Reindexing site..."
su gerrit -c "java -jar ${GERRIT_SITE}/bin/gerrit.war reindex \
 -d ${GERRIT_SITE}"

echo "Starting gerrit..."
su gerrit -c "java -jar ${GERRIT_SITE}/bin/gerrit.war daemon \
 --enable-httpd -d ${GERRIT_SITE}"