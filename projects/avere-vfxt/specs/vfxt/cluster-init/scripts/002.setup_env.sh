#!/bin/bash -e

pushd $CYCLECLOUD_SPEC_PATH/files

rm -rf /root/.venv/vfxt-azure
mkdir -p /root/.venv/vfxt-azure
virtualenv /root/.venv/vfxt-azure

jetpack download --project $CYCLECLOUD_PROJECT_NAME jetpack-SNAPSHOT.tar.gz ./
jetpack download --project $CYCLECLOUD_PROJECT_NAME cyclecloud-cli.zip ./

source /root/.venv/vfxt-azure/bin/activate
pip install netaddr
pip install jetpack-SNAPSHOT.tar.gz
unzip -o cyclecloud-cli.zip
pip install cyclecloud-cli-installer-7.4.0-SNAPSHOT/packages/cyclecloud-cli-sdist.tar.gz

rm -rf AvereSDK
mkdir AvereSDK
pushd AvereSDK/
tar -xf ../AvereSDK.tgz
pip install .
popd # AvereSDK

popd # files