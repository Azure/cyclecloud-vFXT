#!/bin/bash
exit
set -x
pushd $CYCLECLOUD_SPEC_PATH/files

tar -xf vfxt.tgz
pushd external
source /mnt/scratch/.venv/cc-vfxt/bin/activate
python setup.py install
popd

