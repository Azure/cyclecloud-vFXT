#!/bin/bash

package 'dnsmasq'

hoststring = node['dnsmasq']['hoststring']
hostalias = node['dnsmasq']['alias']

start_host, end_host = hoststring.split("-")
start_num = start_host.split(".")[3]
end_num = end_host.split(".")[3]
pre = start_host.split(".")[0..2].join(".")
hosts = (start_num..end_num).to_a 
hostlist = []
etc_hosts='/etc/hosts'
hosts.each do |host_num|
    hostlist << "#{pre}.#{host_num}"
    dnshost = "#{pre}.#{host_num}"
    hostline="#{dnshost}  #{hostalias}"
    ruby_block "Update #{etc_hosts} with #{dnshost}" do
    block do
        file = Chef::Util::FileEdit.new(etc_hosts)
        file.insert_line_if_no_match(hostline, hostline)
        file.write_file
    end
    end
end

dnsmasqconf='/etc/dnsmasq.d/listenaddr.conf'
file dnsmasqconf do
    content "listen-address=#{node[:ipaddress]},127.0.0.1"
end

service 'dnsmasq' do
    action :start
end

