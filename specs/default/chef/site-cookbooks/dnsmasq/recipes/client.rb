

ns_ip = node['dnsmasq']['server']
r_conf = '/etc/resolv.conf'
execute 'update-resolv-conf' do
    command "echo \'nameserver #{ns_ip}\' | cat - #{r_conf} > temp && mv temp #{r_conf}"
    not_if "grep #{ns_ip} #{r_conf}"
end