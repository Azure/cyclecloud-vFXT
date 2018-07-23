#!/bin/bash
set -ex
pushd $CYCLECLOUD_SPEC_PATH/files
mkdir -p /root/.venv/vfxt-azure
yum install -y python-pip
pip install virtualenv
virtualenv /root/.venv/vfxt-azure
