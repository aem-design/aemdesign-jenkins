#!/bin/bash

while getopts s:h:o:u:p: option
do
case "${option}"
in
s) SCHEMA=${OPTARG};;
h) SOURCE_HOST=${OPTARG};;
o) SOURCE_PORT=${OPTARG};;
u) SOURCE_AEM_USER=${OPTARG};;
p) SOURCE_AEM_PASSWORD=${OPTARG};;

esac
done
echo "SCHEMA: $SCHEMA"
echo "SOURCE_HOST: $SOURCE_HOST"
echo "SOURCE_PORT: $SOURCE_PORT"
echo "SOURCE_AEM_USER: $SOURCE_AEM_USER"
echo "ROOT_CONTENT_FOLDER: $ROOT_CONTENT_FOLDER"

#DAM assets aren't included as we don't intend to migrate them, only copy to lower environment
declare -a nodes=(
"/content/forms/af/campaign-forms"
"/content/forms/af/swinburne"
"/content/forms/af/swinburne-microsites-showcase"
"/content/experience-fragments/swinburne"
"/content/cq:tags/swinburne/component-analytics/linklocation"
"/content/cq:tags/swinburne/component-analytics/linktype"
"/content/dam/swinburne-microsites-showcase"
"/content/dam/swinburne-showcase"
"/content/dam/swinburne-site"
"/content/dam/swinburne-site-showcase"
"/content/experience-fragments/swinburne-microsites-showcase"
"/content/swinburne-showcase"
"/content/swinburne-site-showcase"
"/content/swinburne-microsites-showcase"
"/content/experience-fragments/swinburne-microsites"
"/content/cq:tags/swinburne-microsites"
"/content/cq:tags/swinburne-site"
"/content/cq:tags/swinburne-site-showcase"
"/content/cq:tags/swinburne"
"/content/cq:tags/swinburne-microsites-showcase"
"/content/cq:tags/swinburne-showcase"
"/content/cq:tags/swinburne-training"
"/content/experience-fragments/swinburne-site"
"/content/experience-fragments/swinburne-site-showcase"
"/content/dam/formsanddocuments/swinburne"
"/content/dam/formsanddocuments/swinburne-microsites-showcase"
"/content/dam/swinburne-training"
"/content/experience-fragments/swinburne"
"/apps/aemdesign"
"/apps/swinburne"
"/apps/swinburne-core"
"/apps/swinburne-microsites"
"/apps/swinburne-microsites/config.publish"
"/apps/swinburne-site"
"/conf/swinburne/settings/wcm"
"/conf/swinburne-microsites"
"/conf/swinburne-site"
"/etc/blueprints/aemdesign-english"
"/etc/blueprints/aemdesign-german"
"/etc/tenants/swinburne"
"/etc/tenants/swinburne-microsites"
"/etc/tenants/swinburne-site"
"/etc/designs/aemdesign"
"/etc/designs/swinburne"
"/etc/clientlibs/swinburne"
"/etc/clientlibs/swinburne-microsites"
"/etc/clientlibs/swinburne-site"
"/etc/clientlibs/swinburne-core"
"/etc/clientlibs/aemdesign"
"/etc/packages/aemdesign"
"/etc/packages/swinburne"
"/etc/packages/swinburne-microsites"
"/etc/packages/swinburne-site"
)

#Uninstall and delete packages
PACKAGE_PATH="/etc/packages/swinburne/swinburne-aem-deploy-1.1.0.zip"
echo "removing package $PACKAGE_PATH"
curl --insecure -w "\n" -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json$PACKAGE_PATH?cmd=uninstall
curl --insecure -w "\n" -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json$PACKAGE_PATH?cmd=delete

PACKAGE_PATH="/etc/packages/aemdesign/aemdesign-aem-core-deploy-1.0.3.zip"
echo "uninstalling package $PACKAGE_PATH"
curl --insecure -w "\n" -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json$PACKAGE_PATH?cmd=uninstall
curl --insecure -w "\n" -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json$PACKAGE_PATH?cmd=delete

#Delete content
echo "uninstalling content"
for node in "${nodes[@]}"
do
   #echo "curl -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -X DELETE $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node"
   curl --insecure -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
done
