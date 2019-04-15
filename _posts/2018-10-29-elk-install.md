---
layout: post
title: "elk install"
category: elk
tags: [elk]
---

### docker

+ docker-compose.yml

```
elasticsearch:
        image: docker.elastic.co/elasticsearch/elasticsearch:6.4.2
        container_name: elasticsearch
        restart: always
        volumes:
                - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime
                # config        
                - /root/container/elasticsearch/config:/usr/share/elasticsearch/config:ro
                # logs
                - /root/container/elasticsearch/logs:/usr/share/elasticsearch/logs
                # data
                - /root/container/elasticsearch/data:/usr/share/elasticsearch/data
        environment:
                - cluster.name=docker-cluster
                - bootstrap.memory_lock=true
                - "ES_JAVA_OPTS=-Xms2048m -Xmx2048m"
        ulimits:
                memlock:
                        soft: -1
                        hard: -1

kibana:
        image: docker.elastic.co/kibana/kibana:6.4.2
        container_name: kibana
        restart: always
        ports:
                - 5601:5601
        volumes:
                - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
                - /root/container/kibana/config:/usr/share/kibana/config
        links: 
            - elasticsearch

logstash:
        image: docker.elastic.co/logstash/logstash:6.4.2
        container_name: logstash
        restart: always
        links: 
            - elasticsearch
        volumes:
                - /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime:ro
                - /root/container/logstash/pipeline:/usr/share/logstash/pipeline:ro
                - /root/container/logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml:ro

```


logstash.yml

```
http.host: "0.0.0.0"
path.config: /usr/share/logstash/pipeline
```

logstash 使用文件收取日志 **logstash.conf**

```
input {
    file {
        path => "/var/log/nginx/u_ex*.log"
        start_position => "beginning"
        ignore_older => 8000
    }
}

filter {
 grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:time} %{IPORHOST:server_ip} %{WORD:method} %{URIPATH:url} %{NOTSPACE:query_string} %{NUMBER:port} %{NOTSPACE:user_name} %{IPORHOST:remote_ip} %{NOTSPACE:agent} %{NOTSPACE:referrer} %{NUMBER:response_code} %{NUMBER:sub_status} %{NUMBER:win32_status} %{NUMBER:request_time_ms}" }
 }
 mutate {
   convert => ["response_code", "integer"]
   convert => ["request_time_ms", "integer"]
 }
 useragent {
   source => "agent"
 }
}
output {
	elasticsearch {
		hosts => ["elasticsearch:9200"]
			index => "gz_access_logs-%{+yyyy-MM-dd}"
			document_type => "iis_logs"
	}
}

```

---


###  [create a graph](https://stackoverflow.com/questions/22053926/how-do-i-create-a-stacked-graph-of-http-codes-in-kibana/26471825#26471825)

---

### [running-filebeat-in-windows](https://stackoverflow.com/questions/41751605/running-filebeat-in-windows)

+ Move the extracted directory into Program Files.

```
PS > mv filebeat-5.1.2-windows-x86_64 "C:\Program Files\Filebeat"
```

+ install the filebeat service.

```
PS > cd "C:\Program Files\Filebeat"
PS C:\Program Files\Filebeat> powershell.exe -ExecutionPolicy UnRestricted -File .\install-service-filebeat.ps1
```

+ Edit the filebeat.yml config file and test your config.

```
PS C:\Program Files\Filebeat> .\filebeat.exe -e -configtest
```

+ (Optional) Run Filebeat in the foreground to make sure everything is working correctly. 

```
PS C:\Program Files\Filebeat> .\filebeat.exe -c filebeat.yml -e -d "*"
```

+ Start the service.

```
PS > Start-Service filebeat
```


---

### nginx config

+ nginx.conf

```
#https://qbox.io/blog/elasticsearch-logstash-kibana-manage-nginx-logs
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for" '
                      '$request_time $upstream_response_time';
```

+ logstash/pipeline/logstash.conf

```
filter {
 grok {
    match => { "message" => "%{IPORHOST:[remote_ip]} - %{DATA:[user_name]} \[%{HTTPDATE:[time]}\] \"%{WORD:[method]} %{DATA:[url]} HTTP/%{NUMBER:[httpVers]}\" %{NUMBER:[respCode]} %{NUMBER:[body_sent][bytes]} \"%{DATA:[referrer]}\" \"%{DATA:[UserAgent]}\" \"(%{IPORHOST:[X_Forw]}|-)\" %{NUMBER:[requeTime]} %{NUMBER:[UpStRespTime]}" }
    add_field => { "upstream_failed" => "true" }
 }
 mutate {
   convert => ["bytes", "integer"]
   convert => ["UpStRespTime", "float"]
   convert => ["requeTime", "float"]
   convert => ["respCode", "integer"]
 }
 geoip {
   source => "remote_ip"
   target => "geoip"
   add_tag => [ "nginx-geoip" ]
 }
 useragent {
   source => "agent"
 }
}

```

---

### tomcmat

+ server.xml

```
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log." suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b %D" resloveHosts="false"/>

```


+ logstash/pipeline/logstash.conf

```
filter {
 grok {
    match => { "message" => "%{IPORHOST:[remote_ip]} - %{DATA:[user_name]} \[%{HTTPDATE:[time]}\] \"%{WORD:[method]} %{DATA:[url]} HTTP/%{NUMBER:[httpVers]}\" %{NUMBER:[respCode]} %{NUMBER:[body_sent][bytes]} %{NUMBER:[reqestTime]}" }
 }
 mutate {
   convert => ["bytes", "integer"]
   convert => ["reqestTime", "integer"]
   convert => ["respCode", "integer"]
 }
 useragent {
   source => "agent"
 }
}
```

---

### IIS

```
filter {
 grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:time} %{IPORHOST:server_ip} %{WORD:method} %{URIPATH:url} %{NOTSPACE:query_string} %{NUMBER:port} %{NOTSPACE:user_name} %{IPORHOST:remote_ip} %{NOTSPACE:agent} %{NOTSPACE:referrer} %{NUMBER:response_code} %{NUMBER:sub_status} %{NUMBER:win32_status} %{NUMBER:request_time_ms}" }
 }
 mutate {
   convert => ["response_code", "integer"]
   convert => ["request_time_ms", "integer"]
 }
 useragent {
   source => "agent"
 }
}
```

---

### apache

```
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D %T" combined
```

注意apached的**%D**是微秒，换算需要/1000变成一般使用的毫秒
这里需要使用 ruby 在logstash处来进行切换

```
filter {
 grok {
    match => { "message" => "%{IPORHOST:[remote_ip]} - %{DATA:[user_name]}\[%{HTTPDATE:time}\] \"%{WORD:[method]} %{DATA:[url]} HTTP/%{NUMBER:[httpVers]}\" %{NUMBER:[respCode]} %{NUMBER:[body_sent][bytes]} \"%{DATA:[referrer]}\" \"%{DATA:[UserAgent]}\" %{NUMBER:[requeTime]} %{NUMBER:[requeTime_sec]}" }
 }
 ruby {            
   code => "event.set('requeTime_millisec', event.get('requeTime').to_f/1000)"
 }    

 mutate {
   convert => ["bytes", "integer"]
   convert => ["requeTime_millisec", "integer"]
   convert => ["requeTime", "integer"]
   convert => ["respCode", "integer"]
 }


 useragent {
   source => "agent"
 }
}

```

---

### 使用**if**来进行grok匹配

```
filter {
    grok {
        match => { "message" => '^%{DATA:logdate} %{TIME:logtime} %{WORD:loglvl}' }
    }
    if [loglvl] =~ /INFO/  { 
        grok {
            match => { "message" => '^%{DATA:logdate} %{TIME:logtime} %{WORD:loglvl}\[%{DATA:eventCause}\(%{DATA:eventMethod}\)\]%{DATA:eventjob} boid:%{WORD:boid} botype:%{WORD:botype} operation:%{NOTSPACE:operation}' }
        } 
    }
}
```

---

### [FORBIDDEN/12/index read-only](https://discuss.elastic.co/t/forbidden-12-index-read-only-allow-delete-api/110282)

**low storage**,  go to your dev tools console and run below command:

```
PUT .kibana/_settings
{
    "index": {
        "blocks": {
            "read_only_allow_delete": "false"
        }
    }
}
```

---

### command

#### show indexes

```
curl -s "http://127.0.0.1:9200/_cat/indices?v"
```

#### show health

```
curl -s http://127.0.0.1:9200/_cat/health
```

#### delete indexes

```
curl -XDELETE localhost:9200/api*
```

#### mapping

```
curl -s http://localhost:9200/api_access_logs-2019-04-12/_mapping
```
