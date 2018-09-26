#!/bin/bash -e
set -ex
pushd /root
LAUNCH=$CYCLECLOUD_SPEC_PATH/files/launch_azure.py

# move instructions to root dir
EX_FILE="launch_vfxt_cluster.sh"
touch $EX_FILE
echo "source /root/.venv/vfxt-azure/bin/activate" >> $EX_FILE
echo "export PYTHONHTTPSVERIFY=0" >> $EX_FILE
echo "az login -i" >> $EX_FILE
echo "set -o pipefail" >> $EX_FILE
echo "python launch_azure.py 2>&1 | tee vfxt_cluster_launch.log &" >> $EX_FILE

# launch cluster
cp $LAUNCH ./
source /root/.venv/vfxt-azure/bin/activate
export PYTHONHTTPSVERIFY=0


# tee will exit 0  if you don't set this
set -o pipefail
python $LAUNCH 2>&1 | tee vfxt_cluster_launch.log