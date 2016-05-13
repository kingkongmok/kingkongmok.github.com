---
layout: post
title: "nginx转发jetty并保留真实ip"
category: 
tags: []
---

### [保留真实ip](./_posts/2015-12-03-nginx-x-forwarded-for-as-jettys-remote_addr-ip.md)

* 原理是转发***X-Forwarded-For***的同时，并告知jetty不要使用proxy地址作为原址。只需要一个 ***forwarded***即可



```
proxy_pass http://localhost:8080;
proxy_set_header X-Real-IP  $remote_addr;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

```
<Call name="addConnector">
    <Arg>
        <New class="org.eclipse.jetty.server.nio.SelectChannelConnector">
           <Set name="forwarded">true</Set>
```
