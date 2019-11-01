#!/bin/bash

#Sample command:
# ./environment-package-install.sh -s http -h localhost -o 4502 -u admin -p admin -f /absolute/path/to/$PACKAGES_FILENAME
#Notes:
#The -f flag value cannot contain the ~ home shortcut character, it must be absolute.
#The paths in the $PACKAGES_FILENAME txt file must also be absolute.

while getopts s:h:o:u:p:f: option
do
case "${option}"
in
s) SCHEMA=${OPTARG};;
h) SOURCE_HOST=${OPTARG};;
o) SOURCE_PORT=${OPTARG};;
u) AEM_USER=${OPTARG};;
p) AEM_PASSWORD=${OPTARG};;
f) PACKAGES_FILENAME=${OPTARG};;

esac
done
echo "SCHEMA: $SCHEMA"
echo "SOURCE_HOST: $SOURCE_HOST"
echo "SOURCE_PORT: $SOURCE_PORT"
echo "SOURCE_AEM_USER: $AEM_USER"
echo "PACKAGES_FILENAME: $PACKAGES_FILENAME"

declare -a corenodes=(
"/content/dam/swinburne-showcase"
"/content/swinburne-showcase"
"/apps/aemdesign"
"/apps/swinburne"
"/apps/swinburne-core"
"/conf/swinburne/settings/wcm"
"/conf/global/settings/workflow/launcher/config"
"/conf/global/settings/workflow/models/sut"
"/conf/global/settings/workflow/models/swinburne"
"/conf/global/settings/workflow/models/swinburne-publish"
"/conf/global/settings/workflow/models/swinburne-unpublish"
"/conf/global/settings/workflow/models/sut"
"/etc/tenants/swinburne"
"/etc/designs/aemdesign"
"/etc/designs/swinburne"
"/etc/clientlibs/swinburne"
"/etc/clientlibs/swinburne-core"
"/etc/packages/swinburne"
)

declare -a sitenodes=(
"/content/dam/swinburne-site-showcase"
"/content/experience-fragments/swinburne-site-showcase"
"/content/swinburne-site-showcase"
"/content/cq:tags/swinburne-site-showcase"
"/apps/swinburne-site"
"/conf/swinburne-site"
"/etc/tenants/swinburne-site"
"/etc/clientlibs/swinburne-site"
"/etc/packages/swinburne-site"
)

declare -a micrositesnodes=(
"/content/dam/swinburne-microsites-showcase"
"/content/experience-fragments/swinburne-microsites-showcase"
"/content/swinburne-microsites-showcase"
"/content/cq:tags/swinburne-microsites-showcase"
"/content/dam/formsanddocuments/swinburne-microsites-showcase"
"/apps/swinburne-microsites"
"/apps/swinburne-microsites/config.publish"
"/conf/swinburne-microsites"
"/etc/tenants/swinburne-microsites"
"/etc/clientlibs/swinburne-microsites"
"/etc/packages/swinburne-microsites"
)

echo "Disable workflows"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=false "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_mod"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=false "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_create"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=false "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_mod_without_DM"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=false "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_create_without_DM"
echo "Disable aem mailer bundle"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -F action=stop "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/system/console/bundles/com.day.cq.cq-mailer"

#Delete existing content and bundles to ensure latest code gets deployed
while IFS= read -r package || [[ -n "$package" ]]; do
	if [[ $package == *"swinburne-core"* ]]; then
		echo "Deleting swinburne core content and bundles"
		for node in "${corenodes[@]}"
		do
		   echo curl --insecure -u $AEM_USER:xxxx -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
		   curl --insecure -u $AEM_USER:$AEM_PASSWORD -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
		done
	fi
	if [[ $package == *"swinburne-site"* ]]; then
		echo "Deleting swinburne site content and bundles"
		for node in "${sitenodes[@]}"
		do
		   echo curl --insecure -u $AEM_USER:xxxx -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
		   curl --insecure -u $AEM_USER:$AEM_PASSWORD -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
		done
	fi
	if [[ $package == *"swinburne-microsites"* ]]; then
		echo "Deleting swinburne microsites content and bundles"
		for node in "${micrositesnodes[@]}"
		do
		   echo curl --insecure -u $AEM_USER:xxxx -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
		   curl --insecure -u $AEM_USER:$AEM_PASSWORD -d ":operation=delete" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT$node
		done
	fi
done < "$PACKAGES_FILENAME"

echo "Installing packages"
while IFS= read -r package || [[ -n "$package" ]]; do
    echo "Deploying Package: $package"
    curl --insecure -w "\n" -u $AEM_USER:$AEM_PASSWORD -F file=@"$package" -F name="$package" -F force=true -F install=true $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service.jsp
    sleep 10s
done < "$PACKAGES_FILENAME"

echo "Enable workflows"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=true "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_mod"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=true "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_create"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=true "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_mod_without_DM"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -X POST -F enabled=true "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/conf/global/settings/workflow/launcher/config/update_asset_create_without_DM"
echo "Enable aem mailer bundle"
curl --insecure -u $AEM_USER:$AEM_PASSWORD -F action=start "$SCHEMA://$SOURCE_HOST:$SOURCE_PORT/system/console/bundles/com.day.cq.cq-mailer"

#Confirm packages have been installed
while IFS= read -r package || [[ -n "$package" ]]; do
if [[ $package == *"swinburne-core"* ]]; then
	PACKAGE_CHECK="$(curl -s --insecure -u $AEM_USER:$AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json/etc/packages/swinburne/$package?cmd=preview | grep -o '"success":true')"
	if [[ $PACKAGE_CHECK == *"true"* ]]; then
		echo "SWINBURNE-CORE-DEPLOY package installed"
	else
		echo "SWINBURNE-CORE-DEPLOY package NOT FOUND"
	fi
fi
if [[ $package == *"swinburne-site"* ]]; then
	PACKAGE_CHECK="$(curl -s --insecure -u $AEM_USER:$AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json/etc/packages/swinburne-site/$package?cmd=preview | grep -o '"success":true')"
	if [[ $PACKAGE_CHECK == *"true"* ]]; then
		echo "SWINBURNE-SITE-DEPLOY package installed"
	else
		echo "SWINBURNE-SITE-DEPLOY package NOT FOUND"
	fi
fi
if [[ $package == *"swinburne-microsites"* ]]; then
	PACKAGE_CHECK="$(curl -s --insecure -u $AEM_USER:$AEM_PASSWORD -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/crx/packmgr/service/.json/etc/packages/swinburne-microsites/$package?cmd=preview | grep -o '"success":true')"
	if [[ $PACKAGE_CHECK == *"true"* ]]; then
		echo "SWINBURNE-MICROSITES-DEPLOY package installed"
	else
		echo "SWINBURNE-MICROSITES-DEPLOY package NOT FOUND"
	fi
fi
done < "$PACKAGES_FILENAME"
#Currently disabled and left as a manual step if required as it causes the AEM server to become unavailable for a period of time.
#echo "Refresh OSGI Packages"
#curl --insecure -u $SOURCE_AEM_USER:$SOURCE_AEM_PASSWORD -d "action=refreshPackages" -X POST $SCHEMA://$SOURCE_HOST:$SOURCE_PORT/system/console/bundles