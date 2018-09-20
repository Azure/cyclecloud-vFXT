from vFXT.cluster import Cluster
from vFXT.msazure import Service 
#from vFXT.cyclecloud.msazure import Service
import logging
import datetime
import jetpack.config
import jetpack.autoscale
import cyclecli
import pickle
import netaddr

_store = {}

_now = datetime.datetime.now().strftime("%y%m%d%H%M")

logging.basicConfig(level=logging.DEBUG)

logging.getLogger(Service.__module__).setLevel(logging.DEBUG)
logging.getLogger(Cluster.__module__).setLevel(logging.DEBUG)

log = logging.getLogger(__name__)

# network resource group
cluster_name = jetpack.config.get("cyclecloud.cluster.name")
node_name = jetpack.config.get("cyclecloud.node.template")
cs_config = jetpack.config.get("cyclecloud.config")
username = cs_config["username"]
password = cs_config["password"]
cs = cs_config["web_server"]

config = {"username" : username,
        "password" : password,
        "url" : cs,
        "verify_certificates" : False,
        "cycleserver" : {"timeout" : 2}}

ds = cyclecli.get_datastore(config)
filter_expr = 'ClusterName=="%s" && Name =="%s"' % (cluster_name,node_name)
res = ds.find("Cloud.node", filter_expr=filter_expr)
this_node = res[0]
cluster_rg = this_node['Azure']['ResourceGroup']

vfxt_settings = jetpack.config.get("vfxt")

#/subscriptions/e3786699-5116-4dc9-82c6-a8aab043fb85/resourceGroups/lsf-udzsxznabzd5bflifulahbzeme/providers/Microsoft.Network/virtualNetworks/VNet1

d = jetpack.config.get('vfxt')['cluster']
subscription_id = d['subnet_id'].split('/')[2]
network_rg = d['subnet_id'].split('/')[4]
network_name = d['subnet_id'].split('/')[8]
subnet_name = d['subnet_id'].split('/')[10]
storage_account = d['storage_account']

location = jetpack.config.get("azure.metadata.compute.location")
cluster_pass = d['password']
tenant_id = d['tenant_id']
vmsize = d['vmsize']

try:
    size = d['size']
except:
    size = 3

az = Service.environment_init(resource_group=network_rg,
                    subscription_id = subscription_id,
                    tenant_id = tenant_id,
                    storage_account=storage_account,
                    location=location,
                    network=network_name,
                    subnet=subnet_name,
                    no_connection_test=True,
                    use_cycle_api=True)

az.check()
# cluster resource group
az.resource_group = cluster_rg
az.network_resource_group = network_rg

cluster = Cluster.create(az, vmsize, '%s-%s' % (cluster_name,_now), cluster_pass,
                    root_image="microsoft-avere:vfxt:avere-vfxt-node:1.0.2",
                    azure_role="Contributor",
                    size=size,
                    management_address='10.0.1.20',
                    address_range_start='10.0.1.21',
                    address_range_end='10.0.1.26',
                    address_range_netmask='255.255.255.255')


print("VFXTPARSE cluster.mgmt_ip = %s" % cluster.mgmt_ip) 
_store = {"mgmt_ip" : cluster.mgmt_ip}

autoscale_array = {
        'Name': 'vfxt',
        'TargetCount': 0
        }

jetpack.autoscale.update(autoscale_array)

try:
    # storage account resource group
    az.resource_group = network_rg
    cluster.make_test_bucket(bucketname="%s/vfxt%s" % (storage_account,_now), corefiler='azure')
    cluster.add_vserver('vserver',
                netmask='255.255.255.255',
                start_address='10.0.1.30',
                end_address='10.0.1.32')

    cluster.add_vserver_junction('vserver', 'azure')
except Exception as e:
    # cluster resource group
    az.resource_group = cluster_rg
    #cluster.destroy(quick_destroy=True)
    raise

xml = cluster.xmlrpc()
vservers = xml.vserver.list()
vserver = xml.vserver.get(vservers[0])
first_ip = vserver['vserver']['clientFacingIPs'][0]['firstIP']
last_ip = vserver['vserver']['clientFacingIPs'][0]['lastIP']
print("VFXTPARSE vserver clientFacingIPs firstIp= %s" % first_ip)
print("VFXTPARSE vserver clientFacingIPs lastIp = %s" % last_ip)

_store = {}
_store["first_ip"] = first_ip
_store["last_ip"] = last_ip

with open('cluster.conf', 'w') as f:
    pickle.dump(_store, f)

try:
    etc_hosts = jetpack.config.get("dnsmasq.etc_hosts_file")
except:
    etc_hosts = "/root/etc.hosts"

with open(etc_hosts, 'w') as f: 
    ip_set = netaddr.IPRange(first_ip, last_ip)
    for _ip in ip_set:
        f.write("%s vfxt\n" % _ip)
