#!/bin/bash

VERSION=$1
#echo $VERSION
## Replace VERSION with $VERSION in packages_uri.txt and save it as packages_uri_new.txt
sed 's,VERSION,'$VERSION',g' ../files/packages_uri.txt > ../files/packages_uri_new.txt

checkPackages(){
    ## Set S3 Bucket URL
    if [ $1 == "production" ]; then
        echo "production"
        PACKAGES_URL=https://packages.wazuh.com/5.x/
    elif [ $1 == "pre-release" ]; then
        echo "pre-release"
        PACKAGES_URL=https://packages-dev.wazuh.com/pre-release/
    elif [ $1 == "staging" ]; then
        echo "staging"
        PACKAGES_URL=https://packages-dev.wazuh.com/staging/
        CHECK_WIN_PACKAGE=$(grep windows ../files/packages_uri_new.txt)
        echo $CHECK_WIN_PACKAGE
        if [ -n "$CHECK_WIN_PACKAGE" ]; then
            WIN_AGENT_NAME=$(aws s3 ls s3://packages-dev.wazuh.com/staging/windows/wazuh-agent-$VERSION --region=us-west-1 | tail -1 | awk '{printf $4}')
            if [ -z $WIN_AGENT_NAME ]; then
                echo "Windows agent package for version " $VERSION " does not exist in the staging repository"
                exit 1
            fi
            WIN_AGENT_URI="windows/"$WIN_AGENT_NAME
            echo $PACKAGES_URL$WIN_AGENT_URI "check"
            sed -i 's,windows/.*,'$WIN_AGENT_URI',g' ../files/packages_uri_new.txt
            sed -i 's,wazuh_winagent_config_url.*,wazuh_winagent_config_url: \"'$PACKAGES_URL$WIN_AGENT_URI'\",g' ../../vars/repo_staging.yml
            sed -i 's,wazuh_winagent_package_name.*,wazuh_winagent_package_name: \"'$WIN_AGENT_NAME'\",g' ../../vars/repo_staging.yml
        fi
    fi

    ## Set EXISTS to 0 (true)
    EXISTS=0

    ## Loop through the packages_uri_new.txt file
    while IFS= read -r URI
    do
        echo "$URI"
        ## Check if the package exists
        PACKAGE=$(curl --silent -I $PACKAGES_URL$URI | grep -E "^HTTP" | awk  '{print $2}')
        ## If it does not exist set EXISTS to 1 (false)
        if [ "$PACKAGE" != "200" ]; then
            EXISTS=1
            #echo $PACKAGES_URL$URI "does not exist"
            return $EXISTS
        fi
    done < ../files/packages_uri_new.txt

    return $EXISTS
}

replaceVars(){
    sed -i "s|packages_repository:.*|packages_repository: $1|g" ../../vars/repo_vars.yml

}

## Call the checkPackages function for each repository
if checkPackages "production"; then
    echo "production"
    replaceVars "production"
    exit 0
elif checkPackages "pre-release"; then
    echo "pre-release"
    replaceVars "pre-release"
    exit 0
elif checkPackages "production"; then
    echo "production"
    replaceVars "production"
    exit 0
elif checkPackages "staging"; then
    echo "staging"
    replaceVars "staging"
    exit 0
else
    echo "Failed"
    exit 1
fi