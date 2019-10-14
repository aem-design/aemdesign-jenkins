#!/bin/bash

while getopts r: option
do
case "${option}"
in
r) ROOT_CONTENT_FOLDER=${OPTARG};;
esac
done

echo "ROOT_CONTENT_FOLDER: $ROOT_CONTENT_FOLDER"

# Sample command to export data from localhost to local filesystem
#

# To test sting content migration on mac add '' to sed command below, e.g. sed -i '' -e
find $ROOT_CONTENT_FOLDER -type f -exec \
    sed -i -e 's/sling:resourceType="aemdesign\/components\/media\/image"/sling:resourceType="swinburne-microsites\/components\/media\/image"/g' \
    -e 's/sling:resourceType="swinburne\/components\/layout\/contentblock"/sling:resourceType="swinburne-microsites\/components\/layout\/contentblock"/g' \
    -e 's/sling:resourceType="swinburne\/components\/lists\/eventlist"/sling:resourceType="swinburne-microsites\/components\/lists\/eventlist"/g' \
    -e 's/sling:resourceType="swinburne\/components\/lists\/pagelist"/sling:resourceType="swinburne-microsites\/components\/lists\/pagelist"/g' \
    -e 's/sling:resourceType="swinburne\/components\/media\/image"/sling:resourceType="swinburne-microsites\/components\/media\/image"/g' \
    -e 's/sling:resourceType="swinburne\/components\/content\/link"/sling:resourceType="swinburne-microsites\/components\/content\/link"/g' \
    -e 's/sling:resourceType="swinburne\/components\/content\/text"/sling:resourceType="swinburne-microsites\/components\/content\/text"/g' \
    -e 's/sling:resourceType="swinburne\/components\/content\/pagetitle"/sling:resourceType="swinburne-microsites\/components\/content\/pagetitle"/g' \
    -e 's/sling:resourceType="swinburne\/components\/content\/pagedescription"/sling:resourceType="swinburne-microsites\/components\/content\/pagedescription"/g' \
    -e 's/sling:resourceType="swinburne\/components\/widgets\/onlinemedia"/sling:resourceType="swinburne-microsites\/components\/widgets\/onlinemedia"/g' \
    -e 's/sling:resourceType="swinburne\/components\/details\/event-details"/sling:resourceType="swinburne-microsites\/components\/details\/event-details"/g' \
    -e 's/sling:resourceType="swinburne\/components\/details\/page-details"/sling:resourceType="swinburne-microsites\/components\/details\/page-details"/g' \
    -e 's/sling:resourceType="swinburne\/components\/template\/base"/sling:resourceType="swinburne-microsites\/components\/template\/base"/g' \
    -e 's/sling:resourceType="swinburne\/components\/template\/experience-fragments\/base\/v1\/xfpage"/sling:resourceType="swinburne-microsites\/components\/template\/experience-fragments\/base\/v1\/xfpage"/g' \
    -e 's/cq:template="\/conf\/swinburne\/settings\/wcm\/templates/cq:template="\/conf\/swinburne-microsites\/settings\/wcm\/templates/g' \
    -e 's/swinburne:/swinburne-microsites:/g' \
    -e 's/\/content\/experience-fragments\/swinburne\//\/content\/experience-fragments\/swinburne-microsites\//g' \
    -e 's/\/content\/swinburne\/au\/en\//\/content\/swinburne-microsites\/au\/en\//g' {} +

#migrate vlt filter.xml
sed -i -e 's#"/content/experience-fragments/swinburne"#"/content/experience-fragments/swinburne-microsites"#g' $ROOT_CONTENT_FOLDER/META-INF/vault/filter.xml
sed -i -e 's#"/content/swinburne"#"/content/swinburne-microsites"#g' $ROOT_CONTENT_FOLDER/META-INF/vault/filter.xml
sed -i -e 's#"/content/cq:tags/swinburne"#"/content/cq:tags/swinburne-microsites"#g' $ROOT_CONTENT_FOLDER/META-INF/vault/filter.xml

# After migrating the files, we need to migrate the folder names
# First delete existing swinburne-microsites folder which may have previously been migrated
find $ROOT_CONTENT_FOLDER -path '**/swinburne-microsites*' -print
find $ROOT_CONTENT_FOLDER -path '**/swinburne-microsites*' -delete
find $ROOT_CONTENT_FOLDER -type d -name swinburne -execdir /usr/bin/rename.ul -v swinburne swinburne-microsites {} \+