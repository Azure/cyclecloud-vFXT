include_recipe "dnsmasq::search_nameserver"

ns_ip = node[:dnsmasq][:ns][:ip_address]

r_conf = '/etc/resolv.conf'
execute 'update-resolv-conf' do
  command "echo \'nameserver #{ns_ip}\' | cat - #{r_conf} > temp && mv -f temp #{r_conf}"
  not_if "grep #{ns_ip} #{r_conf}"
end
