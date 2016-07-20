---
title: "neutron error"
layout: post
category: openstack
---

### neutron-l3-agent error

```
[root@network ~]# systemctl status  neutron-l3-agent.service
● neutron-l3-agent.service - OpenStack Neutron Layer 3 Agent
   Loaded: loaded (/usr/lib/systemd/system/neutron-l3-agent.service; enabled; vendor preset: disabled)
   Active: failed (Result: exit-code) since Tue 2016-07-19 03:08:09 EDT; 2h 19min ago
  Process: 6386 ExecStart=/usr/bin/neutron-l3-agent --config-file /usr/share/neutron/neutron-dist.conf --config-dir /usr/share/neutron/l3_agent --config-file /etc/neutron/neutron.conf --config-dir /etc/neutron/conf.d/common --config-dir /etc/neutron/conf.d/neutron-l3-agent --log-file /var/log/neutron/l3-agent.log (code=exited, status=1/FAILURE)
 Main PID: 6386 (code=exited, status=1/FAILURE)


# tail /var/log/neutron/l3-agent.log
2016-07-19 03:07:17.456 6166 INFO neutron.common.config [-] Logging enabled!
2016-07-19 03:07:17.456 6166 INFO neutron.common.config [-] /usr/bin/neutron-l3-agent version 8.1.2
2016-07-19 03:07:17.897 6166 ERROR neutron.agent.l3.agent [-] An interface driver must be specified
2016-07-19 03:08:09.413 6386 INFO neutron.common.config [-] Logging enabled!
2016-07-19 03:08:09.413 6386 INFO neutron.common.config [-] /usr/bin/neutron-l3-agent version 8.1.2
2016-07-19 03:08:09.425 6386 ERROR neutron.agent.l3.agent [-] An interface driver must be specified
```

### [interface driver must be specified](https://ask.openstack.org/en/question/30413/error-neutronagentlinuxdhcp-an-interface-driver-must-be-specified/)

```
[root@network ~]# grep interface -iI /etc/neutron/l3_agent.ini 
# Uses veth for an OVS interface or not. Support kernels with limited namespace
# The driver used to manage the virtual interface. (string value)
#interface_driver = <None>
# ipv6_gateway, when configured, should be the LLA of the interface on the

[root@network ~]# grep interface -iI /etc/neutron/dhcp_agent.ini
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
# Uses veth for an OVS interface or not. Support kernels with limited namespace
# The driver used to manage the virtual interface. (string value)
#interface_driver = <None>
```

将 **/etc/neutron/l3_agent.ini** 的**interface_driver** 修改为 **neutron.agent.linux.interface.OVSInterfaceDriver**
