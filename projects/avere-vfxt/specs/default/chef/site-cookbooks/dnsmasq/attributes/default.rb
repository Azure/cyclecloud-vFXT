default['dnsmasq']['etc_hosts_file'] = "/root/etc.hosts"


# for search
default[:dnsmasq][:ns][:hostname] = nil
default[:dnsmasq][:ns][:role] = nil
default[:dnsmasq][:ns][:clusterUID] = nil
default[:dnsmasq][:ns][:recipe] = "dnsmasq::server"
default[:dnsmasq][:ns][:ip_address] = nil
default[:dnsmasq][:ns][:fqdn] = nil

