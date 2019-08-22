#!/bin/bash

if [ -z "$1" ]
then
      echo "Platform not selected. Please select a platform. => Aborting"
      exit
else
      cp Pipfile.template Pipfile
      sed -i "s/_PLATFORM_/$1/g" Pipfile
fi

sudo pipenv run elasticsearch
sudo pipenv run test
sudo pipenv run agent
sudo pipenv run kibana

cp Pipfile.template Pipfile