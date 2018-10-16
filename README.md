# Microsoft Avere vFXT in Azure CycleCloud

This project will allow you to create and manage a vFXT cluster in CycleCloud.  

### Creating user managed identities with appropriate permissions

This project relies on a User Managed Identity. Azure CycleCloud will poll your tenant to find identities. When docs are public this repo will point to Avere vFXT documentation.  

There are two separate managed identities required; One for the controller node and
the other for the storage cluster nodes.  Create the identities and assign them roles
with the following example using the az-cli.



```bash
az identity create -g ${ResourceGroup} --name ${IDName1}
az role assignment create --assignee-object-id ${IDName1PrincipalId} --role "Contributor"
az identity create -g ${ResourceGroup} --name ${IDName2}
az role assignment create --assignee-object-id ${IDName2-PrincipalId} --role "Avere Cluster Runtime Operator"
```

```json
{
  "clientId": "396efc5f-175a-4de3-919e-bf65e2697dca",
  "id": "/subscriptions/f16e7574-eecb-46b9-8adb-855b92f7b572/resourcegroups/demo-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/avere-storage",
  "location": "westus2",
  "name": "avere-storage",
  "principalId": "48f57d96-18d9-41b6-9fc3-1ca4674828de",
  "resourceGroup": "demo-rg",
  "tags": {},
  "tenantId": "e5e7f63d-cf83-4e0b-aec9-25102ff37db3",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
```

When you start the vFXT cluster in CycleCloud you'll see the identities in the drop menu.

### Uploading the project to your locker

The cluster scripts and recipes must be staged in your cloud locker.

```bash
cd vfxt/projects/avere-vfxt
cyclecloud project upload azure-locker
```

This locker name `azure-locker` may be incorrect.  If you get an error message, retry the command with the locker name in the error message.

### Import the ARM template and cluster template to CycleCloud

```bash
cd templates
cyclecloud import_cluster vFXT  -f az-vfxt-env.txt  -P vnetrawjson=@hpc-cache.json -t
```

Now the new cluster menu in CycleCloud will contain a VFXT cluster ready to be instantiated. 

### Create and Launch a vFXT Cluster

In the [+] Add Cluster menu find the `vFXT` cluster template that you just added and select it.  This will bring up a number of menu options for the cluster.  The defaults for this cluster are sufficient but Name, ManagedId and Tennant ID must all be selected from the menus.

When the menu is complete, then save the configuration.  You'll be linked back to the clusters page and you'll see your new cluster listed in the clusters table.

Start the cluster!

The file `hpc-cache.json` is an ARM template.  The cluster will create a virtual network, route table, subnets and storage account via ARM template deployment.  These resources can be seen by selecting the Environments tab of the cluster. 

When the deployment is complete, CycleCloud launches the shepherd node which determines low-level cluster configurations then uses the CycleCloud autoscale API to launch the vFXT cluster nodes.  The first host that comes up, usually `vfxt-1` in CycleCloud will host the vFXT administrative webpage.

It's advised to keep production resources off of the public internet. In this cluster the shepherd host acts as a jump box.  So while you can access the shepherd directly by running `cyclecloud connect shepherd -c ${ClusterName}` you can't access the vfxt nodes directly.  One suggestion to access the UI on the vFXT node is to tunnel the https port to your local machine:

    ssh -L 9443:${VfxtPrivateIp}:443 cyclecloud@${ShepherdPublicIP}

Then you can see the webpage by going to `https://localhost:9443` in a browser.

### Mounting clients in the cluster

An example template is contributed here in the templates directory.  

```bash
diff pbspro.txt pbspro-vfxt.txt
24c24,31
>         dnsmasq.ns.clusterUID = $VfxtCluster
>         run_list = recipe[dnsmasq::client],recipe[cyclecloud]
> 
>         [[[configuration cyclecloud.mounts.vfxt]]]
>         type = nfs
>         mountpoint = /mnt/vfxt
>         export_path = /azure
>         address = vfxt
93a101,104
>         [[[parameter VfxtCluster]]]
>         Description = vFXT Cluster
>         Config.Plugin = pico.form.QueryDropdown
>         Config.Query = '''select ClusterName as Name from Cloud.Cluster where state === "started" '''
```

Primarily, we add the vFXT mount block.  This mount block then depends on the availability of name resolution for the `vfxt` hostname which is provided by the addition of the `dnsmasq::client` recipe in the run_list.  And to make the cluster name selection easier we add a query dropdown selector.

### External Code

This project depends on the [Avere SDK](https://github.com/Azure/AvereSDK). A tar
archive of this repo must be added to the project cluster-init.  

```bash
git clone git@github.com:Azure/AvereSDK.git
tar -czvf AvereSDK AvereSDK.tgz
mv AvereSDK.tgz cyclecloud-vFXT/projects/avere-vfxt/specs/vfxt/cluster-init/files/
cd cyclecloud-vFXT/projects/avere-vfxt
cyclecloud project upload
```