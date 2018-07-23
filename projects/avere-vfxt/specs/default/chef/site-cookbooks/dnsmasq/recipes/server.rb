bootstrap = "#{node['cyclecloud']['bootstrap']}/dnsmasq.etc_hosts.done"

package 'dnsmasq'

file '/etc/dnsmasq.d/listenaddr.conf' do
    content "listen-address=#{node[:ipaddress]},127.0.0.1"
end

execute "update hostsfile dnsmasq" do
    command "cat #{node['dnsmasq']['etc_hosts_file']} >> /etc/hosts && touch #{bootstrap}"
    creates bootstrap
end

service 'dnsmasq' do
    action :start
end