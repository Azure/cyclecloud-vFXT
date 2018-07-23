name "dnsmasq_client"
description "dnsmasq client"
run_list("recipe[dnsmasq::search_nameserver]",
        "recipe[avere-client::mount_vfxt]")