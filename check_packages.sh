#!/bin/bash

VERSION=$1
#echo $VERSION
## Replace VERSION with $VERSION in packages_uri.txt and save it as packages_uri_new.txt
sed 's,VERSION,'$VERSION',g' packages_uri.txt > packages_uri_new.txt

checkPackages(){
    ## Set S3 Bucket URL
    if [ $1 == "production" ]; then
        PACKAGES_URL=https://packages.wazuh.com/4.x/
    elif [ $1 == "pre-release" ]; then
        PACKAGES_URL=https://packages-dev.wazuh.com/pre-release/
    elif [ $1 == "staging" ]; then
        PACKAGES_URL=https://packages-dev.wazuh.com/staging/
    fi

    ## Set EXISTS to 0 (true)
    EXISTS=0

    ## Loop through the packages_uri_new.txt file
    while IFS= read -r URI
    do
        #echo "$URI"
        ## Check if the package exists
        PACKAGE=$(curl --silent -I $PACKAGES_URL$URI | grep -E "^HTTP" | awk  '{print $2}')
        ## If it does not exist set EXISTS to 1 (false)
        if [ "$PACKAGE" != "200" ]; then
            EXISTS=1
            #echo $PACKAGES_URL$URI "does not exist"
            return $EXISTS
        fi
    done < packages_uri_new.txt

    return $EXISTS
}

## Call the checkPackages function for each repository
if checkPackages "production"; then
    echo "production"
    exit 0
elif checkPackages "pre-release"; then
    echo "pre-release"
    exit 0
elif checkPackages "staging"; then
    echo "staging"
    exit 0
else
    echo "Failed"
    exit 1
fi