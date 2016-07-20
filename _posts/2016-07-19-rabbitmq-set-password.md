---
title: "RabbitMQ set password"
layout: post
category: openstack
---

## ERROR

tailf nova/nova-compute.log

```
2016-07-18 22:36:09.387 2817 ERROR oslo.messaging._drivers.impl_rabbit [req-51faf017-4f1f-4a24-ab79-624b302b839b - - - - -] AMQP server controller:5672 closed the connection. Check login credentials: Socket closed
2016-07-18 22:36:38.446 2817 ERROR oslo.messaging._drivers.impl_rabbit [req-51faf017-4f1f-4a24-ab79-624b302b839b - - - - -] AMQP server controller:5672 closed the connection. Check login credentials: Socket closed
2016-07-18 22:37:09.524 2817 ERROR oslo.messaging._drivers.impl_rabbit [req-51faf017-4f1f-4a24-ab79-624b302b839b - - - - -] AMQP server controller:5672 closed the connection. Check login credentials: Socket closed
```

在 compute1的 /etc/nova/nova.conf 上，设置了RabbitMQ,如下:

```
rpc_backend = rabbit
rabbit_host = controller
rabbit_password = RABBIT_PASS
```

### [Configure the message queue service](http://docs.openstack.org/liberty/install-guide-ubuntu/environment-dependencies.html)

这里的说法，是 

***Permit configuration, write, and read access for the openstack user:***

```

# rabbitmqctl set_permissions openstack ".*" ".*" ".*"
  Setting permissions for user "openstack" in vhost "/" ...
```

### [有关基本架构安装](http://docs.openstack.org/juno/install-guide/install/yum/content/ch_basic_environment.html)

重新设置密码

```
rabbitmqctl status | grep rabbit
rabbitmqctl change_password guest RABBIT_PASS
systemctl restart rabbitmq-server
```
