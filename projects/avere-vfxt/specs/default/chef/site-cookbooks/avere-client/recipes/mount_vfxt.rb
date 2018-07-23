include_recipe 'nfs'

chefstate = node[:cyclecloud][:chefstate]
vfxt_ip = "#{chefstate}/vfxt.hostname"

cloud_filer_mountpoint = node[:vfxt][:client][:nfs][:mountpoint]
cloud_filer_export = node[:vfxt][:server][:nfs][:export]

directory cloud_filer_mountpoint do
end

mount cloud_filer_mountpoint do
    device "#{node[:vfxt][:client][:nfs][:alias]}:#{cloud_filer_export}"
    fstype node[:vfxt][:client][:nfs][:fstype]
    action [:mount, :enable]
end

package 'iotop' do
end