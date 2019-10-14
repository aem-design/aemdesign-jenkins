#!/bin/bash

while getopts s:h:o:u:p:r:f:c: option
do
case "${option}"
in
s) SCHEMA=${OPTARG};;
h) SOURCE_HOST=${OPTARG};;
o) SOURCE_PORT=${OPTARG};;
u) SOURCE_AEM_USER=${OPTARG};;
p) SOURCE_AEM_PASSWORD=${OPTARG};;
r) ROOT_CONTENT_FOLDER=${OPTARG};;
f) VLT_FLAGS=${OPTARG};;
c) VLT_CMD=${OPTARG};;
esac
done
echo "SCHEMA: $SCHEMA"
echo "SOURCE_HOST: $SOURCE_HOST"
echo "SOURCE_PORT: $SOURCE_PORT"
echo "SOURCE_AEM_USER: $SOURCE_AEM_USER"
echo "ROOT_CONTENT_FOLDER: $ROOT_CONTENT_FOLDER"
echo "VLT_FLAGS: $VLT_FLAGS"
echo "VLT_CMD: $VLT_CMD"

# Sample command to export data from localhost to local filesystem
# ./vlt-export-to-disk.sh -s http -h localhost -o 4502 -u admin -p admin -r local-vlt-export -c vlt -r localhost-vlt-export

# Host that SOURCE_CQ runs on
#SOURCE_HOST=host.docker.internal  #equivalent of using localhost in docker container
# TCP port SOURCE_CQ listens on
#SOURCE_PORT=4502
# AEM Admin user for SOURCE_HOST
#SOURCE_AEM_USER=admin
# AEM Admin password for SOURCE_HOST
#SOURCE_AEM_PASSWORD=admin
# Root folder name for placing content
#SOURCE_CONTENT_FOLDER=localhost-author-export
#SCHEMA=http
#VLT_FLAGS = --insecure #to set additional flags if required
#VLT_CMD=./bin/vault-cli-3.2.9-SNAPSHOT/bin/vlt

## for testing
#echo $VLT_CMD $VLT_FLAGS --credentials $SOURCE_AEM_USER:****** export -v $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/-/jcr:root/content/swinburne-showcase/en/component/details/page-details $ROOT_CONTENT_FOLDER/content/swinburne-showcase/en/component/details/page-details
#$VLT_CMD $VLT_FLAGS --credentials $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD export -v $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/-/jcr:root/content/swinburne-showcase/en/component/details/page-details $ROOT_CONTENT_FOLDER/content/swinburne-showcase/en/component/details/page-details

# Paths defined in META-INF/vault/filter.xml
echo ------- START Exporting content ----------
echo $VLT_CMD $VLT_FLAGS --credentials $SOURCE_AEM_USER:****** export -v $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/-/jcr:root $ROOT_CONTENT_FOLDER

$VLT_CMD $VLT_FLAGS --credentials $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD export -v $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/-/jcr:root $ROOT_CONTENT_FOLDER

echo ------- END Exporting content ----------
