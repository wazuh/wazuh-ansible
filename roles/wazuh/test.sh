#!/bin/bash

set -eux -o pipefail

unset ANSIBLE_STRATEGY && unset ANSIBLE_STRATEGY_PLUGINS && molecule test
