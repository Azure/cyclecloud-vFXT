# Overview

This is a CycleCloud project for deploying and automating an Azure vFXT HPC Cache.

The underlying ARM template is copied from the Azure Avere [github project](https://github.com/Azure/Avere).

## Prerequisites

The principal requires the Role assignment permission. If you're using a Service Principal
or a Managed Identity.  

One way to do that is to assign the _Avere Cluster Create_ role to the principal
assigned to CycleCloud by the [az cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

```bash
az role assignment create --assignee XXXXXXXX-XXXX-XXXX-XXXXXXXXXXXX --role "Avere Contributor"
```

You can find details on the _Avere Contributor_ role [here](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#avere-contributor).

## Cluster Setup

This cluster requires that a Virtual Network exists and has Storage service endpoints
configured on the subnet where vFXT will be deployed.  If no such Virtual Network exists,
then:

* Create a virtual network in the desired region with several subnets (e.g. default, cache,
storage, compute).
* Add the Microsoft.Storage service endpoint to (at least) the subnet which will host vFXT.

## CycleCloud project setup

Some of the critical parts of this project are packaged as a [CycleCloud Project](https://docs.microsoft.com/en-us/azure/cyclecloud/projects).

* Upload the vFXT project to your storage account by running `cyclecloud project upload`
* Add the vFXT cluster template to the CycleCloud cluster menu by running `cyclecloud import_cluster vFXT -c vfxt-hpc -f io.txt -P rawaverejson=@azuredeploy-auto.json -t`

## Configure and Start a vFXT cluster

At this point all of the artifacts have been added to CycleCloud and a cluster may be configured and launched.

Add a new cluster in the CycleCloud UI by the `+` button and find the Azure vFXT
logo
![vFXT Icon](/images/vfxt-icon.png)

The primary configuration menu has selections to choose the Virtual Network 
which will host vFXT cluster.  

<aside class="notice">
The configuration menu has little validation, and some values need to be globally unique.
Make sure that the storage account name and control VM name are not re-used elsewhere.
</aside>

![Configuring a vFXT Cluster](/images/vfxt-configs.png)

With the cluster fully configured it can be started and the vFXT cluster will be
launched.  All resources and deployments will be created in the **same resource group
as the VirtualNetwork** that it's created in.

![Deployment in Portal](/images/rg.png)

CycleCloud has started a nameserver which is hosting the vfxt alias.  This is for
round-robin dns hosting of the VFXT client-facing IPs. Find the access details for
the cluster in the _Environments_ tab, and in the details of the _vfxt_ deployment.

## Add Storage client and transfer files

Once the cluster is running, the next activity is often to stage files
into the cache.  Do this by adding a client node to the cluster.

Find the add node button in the actions drop down.  There is a _vfxt-client_ node
type.

![vFXT Client Node](/images/add-client.png)

Add the new node to the cluster and it will go through the startup phases. 
When the indicator shows the status as _Started_ you can log into the
node with the _cyclecloud connect_ command.  Once logged in, you can inspect
the filesystem properties.

```bash 
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        30G  1.6G   28G   6% /
/dev/sda1       497M   79M  418M  16% /boot
/dev/sdb1        16G   45M   15G   1% /mnt/resource
vfxt:/msazure   8.0E     0  8.0E   0% /cache
```

Because Avere vFXT is backed by an Azure Storage Account you will see an 
extremely large capacity filesystem at the _/cache_ mountpoint.

