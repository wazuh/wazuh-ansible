#!/bin/bash

sudo pipenv run elasticsearch
sudo pipenv run test
sudo pipenv run worker