
chefstate = node[:cyclecloud][:chefstate] 

if node[:dnsmasq][:ns][:hostname].nil?
  cluster_UID = node[:dnsmasq][:ns][:clusterUID]
  if cluster_UID.nil?
    cluster_UID = node[:cyclecloud][:cluster][:id]
  end

  node_role = node[:dnsmasq][:ns][:role]
  if !node_role.nil?
    log "Searching for the dnsmasq namserver in cluster: #{cluster_UID}, role: #{node_role}" do level :info end
    ns_node = cluster.search(:clusterUID => cluster_UID, :role => node_role, :singular => "License Manager not found")
  else
    node_recipe = node[:dnsmasq][:ns][:recipe]
    if !node_recipe.nil?
      log "Searching for the dnsmasq namserver in cluster: #{cluster_UID}, recipe: #{node_recipe}" do level :info end
      ns_node = cluster.search(:clusterUID => cluster_UID, :recipe => node_recipe, :singular => "License Manager not found")
    else
      log "Must specify node[:dnsmasq][:ns][:role] or node[:cmls][:lm][:recipe] for search." do level :error end
    end
  end
  node.default[:dnsmasq][:ns][:hostname] = ns_node[:hostname]
  node.default[:dnsmasq][:ns][:ip_address] = ns_node[:ipaddress]
  node.default[:dnsmasq][:ns][:fqdn] = ns_node[:fqdn]

end

