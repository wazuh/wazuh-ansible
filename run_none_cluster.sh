#!/bin/bash

sudo pipenv run elasticsearch
sudo pipenv run test
sudo pipenv run agent
sudo pipenv run kibana