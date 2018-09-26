#!/bin/bash -e

version=0.5
avere_sdk_repo=~/code/vfxt-cycle
# TODO RDH add versions in blobs
# TODO RDH rename vFXT-azure-preview.tgz to AzureSDK.tgz
# TODO RDH move to blobs
cwd=`pwd`
pushd $cwd
cd $avere_sdk_repo
git archive --format=tar HEAD | gzip > $cwd/projects/avere-vfxt/specs/vfxt/cluster-init/files/AvereSDK.tgz
popd
pushd $cwd
cd projects/avere-vfxt
cyclecloud project upload azure_transient-storage
cyclecloud project upload file:///Users/ryhamel/code/mono/integration/temp/
labrat exec 'rm -rf /opt/cycle_server/work/staging/projects/avere-vfxt'
labrat exec 'cp -r /code/integration/temp/projects/avere-vfxt /opt/cycle_server/work/staging/projects/'
rm -rf /Users/ryhamel/code/mono/integration/temp/

labrat exec 'cat <<EOF > /opt/cycle_server/config/data/avere.txt
AdType = "Cloud.Project"
Version = "0.5"
ProjectType = undefined
Url = "file///opt/cycle_server/work/staging/projects/avere-vfxt/2.5.0"
AutoUpgrade = true
Name = "Avere"
EOF'

cyclecloud import_cluster -t PBSPro-vfxt -c PBSPro -f templates/pbspro-vfxt.txt --force
cyclecloud import_cluster -t vfxt_0.5.0_template -c vfxt -f templates/az-vfxt-env.txt -P vnetrawjson=@templates/hpc-cache.json --force

popd