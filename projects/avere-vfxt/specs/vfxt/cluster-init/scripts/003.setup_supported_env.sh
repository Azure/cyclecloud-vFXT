#!/bin/bash
set -x
#apt install -y zip
pushd $CYCLECLOUD_SPEC_PATH/files

jetpack download --project $CYCLECLOUD_PROJECT_NAME jetpack-SNAPSHOT.tar.gz ./
jetpack download --project $CYCLECLOUD_PROJECT_NAME cyclecloud-cli.zip ./

yum install -y gcc 


source /root/.venv/vfxt-azure/bin/activate
pip install netaddr
pip install jetpack-SNAPSHOT.tar.gz
unzip -o cyclecloud-cli.zip
pip install cyclecloud-cli-installer-7.4.0-SNAPSHOT/packages/cyclecloud-cli-sdist.tar.gz


tar -xf vFXT-azure-preview.tgz
pushd vFXT-azure-preview
python setup.py install
for VAR in 'azure-mgmt-compute' 'azure-cli-core' 'azure-mgmt-resource' 'azure-mgmt-storage' 'azure-mgmt-network' 'azure-mgmt-authorization>=0.40.0' 'azure-mgmt-msi' 'azure-storage-common' 'azure-storage-blob' 
do
	pip install $VAR --upgrade --force-reinstall
done
popd




