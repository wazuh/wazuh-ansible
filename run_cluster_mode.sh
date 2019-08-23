#!/bin/bash

paths=( "molecule/default/" "molecule/worker/" "molecule/elasticsearch/" "molecule/kibana/" )

if [ -z "$1" ]
then
      echo "Platform not selected. Please select a platform. => Aborting"
      exit
else
      for i in "${paths[@]}"
      do
            cp "$i/playbook.yml.template" "$i/playbook.yml"
            sed -i "s/platform/$1/g" "$i/playbook.yml"
      done

      cp Pipfile.template Pipfile
      sed -i "s/_PLATFORM_/$1/g" Pipfile
fi

sudo pipenv run elasticsearch
sudo pipenv run test
sudo pipenv run agent
sudo pipenv run kibana