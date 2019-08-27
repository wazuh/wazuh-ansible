#!/bin/bash

paths=( "molecule/default/" "molecule/worker/" "molecule/elasticsearch/" "molecule/kibana/" )
images=( "solita/ubuntu-systemd:bionic" "solita/ubuntu-systemd:xenial" "milcom/centos7-systemd" "ubuntu:trusty" "centos:6" )
platform=( "bionic" "xenial" "centos7" "trusty" "centos6" )

#echo "Please select an image. "
#
#select IMAGE in "${images[@]}";
#do
#     echo "You picked $IMAGE ($REPLY)"
#     break
#done
#
#index=$(($REPLY - 1))

#if [ -z "$IMAGE" ]
#then
#      echo "Platform not selected. Please select a platform of [bionuc, xenial or centos7]. => Aborting"
#      exit
#else
        for i in "${paths[@]}"
        do
            cp "$i/playbook.yml.template" "$i/playbook.yml"
            sed -i "s/platform/${platform[0]}/g" "$i/playbook.yml"

            cp "$i/molecule.yml.template" "$i/molecule.yml"
            sed -i "s|imagename|${images[0]}|g" "$i/molecule.yml"
            sed -i "s/platform_/${platform[0]}/g" "$i/molecule.yml"    

        done
#fi

sudo pipenv run elasticsearch
sudo pipenv run test
sudo pipenv run worker
sudo pipenv run kibana

sudo pipenv run destroy
sudo pipenv run destroy_worker
sudo pipenv run destroy_elasticsearch
sudo pipenv run destroy_kibana

