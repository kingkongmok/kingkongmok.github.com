---
layout: post
title: "elasticsearch cluster on docker"
category: elk
tags: [elk, elasticsearch]
---

### docker-compose.yml

```
version: '2.2'
services:
    elasticsearch1:
        image: docker.elastic.co/elasticsearch/elasticsearch:6.5.0
        container_name: elasticsearch1
        environment:
            - cluster.name=docker-cluster
            - bootstrap.memory_lock=true
            - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
        ulimits:
            memlock:
                soft: -1
                hard: -1
        volumes:
            - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
            - /root/container/elasticsearch1/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro
            - esdata1:/usr/share/elasticsearch1/data
        ports:
            - 9200:9200
        networks:
            - esnet

    elasticsearch2:
        image: docker.elastic.co/elasticsearch/elasticsearch:6.5.0
        container_name: elasticsearch2
        environment:
            - cluster.name=docker-cluster
            - bootstrap.memory_lock=true
            - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
        ulimits:
            memlock:
                soft: -1
                hard: -1
        volumes:
            - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
            - /root/container/elasticsearch2/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro
            - esdata2:/usr/share/elasticsearch/data
        ports:
            - 9201:9200
        networks:
            - esnet

    elasticsearch3:
        image: docker.elastic.co/elasticsearch/elasticsearch:6.5.0
        container_name: elasticsearch3
        environment:
            - cluster.name=docker-cluster
            - bootstrap.memory_lock=true
            - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
        ulimits:
            memlock:
                soft: -1
                hard: -1
        volumes:
            - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
            - /root/container/elasticsearch3/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro
            - esdata3:/usr/share/elasticsearch/data
        ports:
            - 9202:9200
        networks:
            - esnet

volumes:
    esdata1:
        driver: local
    esdata2:
        driver: local
    esdata3:
        driver: local

networks:
    esnet:

```

---

### elasticsearch.yml for node1

```
cluster.name: "docker-cluster"

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 2

#give your nodes a name (change node number from node to node).
node.name: "elasticsearch1"

#define node 1 as master-eligible:
#node.master: true

#define nodes 2 and 3 as data nodes:
#node.data: true

#enter the private IP and port of your node:
network.host: "elasticsearch1"
http.port: 9200

#detail the private IPs of your nodes:
discovery.zen.ping.unicast.hosts: ["elasticsearch1", "elasticsearch2","elasticsearch3"]

# To avoid swapping you can either disable all swapping (recommended if Elasticsearch is the only service running on the server), or you can use mlockall to lock the Elasticsearch process to RAM.
#bootstrap.mlockall: true
```

---

### elasticsearch.yml for node2

```
cluster.name: "docker-cluster"

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 2

#give your nodes a name (change node number from node to node).
node.name: "elasticsearch2"

#define node 1 as master-eligible:
#node.master: false

#define nodes 2 and 3 as data nodes:
#node.data: true

#enter the private IP and port of your node:
network.host: "elasticsearch2"
http.port: 9200

#detail the private IPs of your nodes:
discovery.zen.ping.unicast.hosts: ["elasticsearch1", "elasticsearch2","elasticsearch3"]

# To avoid swapping you can either disable all swapping (recommended if Elasticsearch is the only service running on the server), or you can use mlockall to lock the Elasticsearch process to RAM.
#bootstrap.mlockall: true

```

---

### elasticsearch.yml for node3

```
cluster.name: "docker-cluster"

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 2

#give your nodes a name (change node number from node to node).
node.name: "elasticsearch3"

#define node 1 as master-eligible:
#node.master: false

#define nodes 2 and 3 as data nodes:
#node.data: true

#enter the private IP and port of your node:
network.host: "elasticsearch3"
http.port: 9200

#detail the private IPs of your nodes:
discovery.zen.ping.unicast.hosts: ["elasticsearch1", "elasticsearch2","elasticsearch3"]

# To avoid swapping you can either disable all swapping (recommended if Elasticsearch is the only service running on the server), or you can use mlockall to lock the Elasticsearch process to RAM.
#bootstrap.mlockall: true

```

---

## check status

```
# curl http://127.0.0.1:9200/_cat/health
1542783097 06:51:37 docker-cluster green 3 3 12 6 2 0 0 0 - 100.0%
```
