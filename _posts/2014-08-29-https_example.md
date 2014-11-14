---
layout: post
title: "https howto"
category: linux
tags: [https, ssl, rsa, csr, pem, crt]
---
{% include JB/setup %}

首先看看文件是什么，[这里](http://serverfault.com/questions/9708/what-is-a-pem-file-and-how-does-it-differ-from-other-openssl-generated-key-file)有介绍，

{% highlight bash %}
.key 
This is a PEM formatted file containing just the private-key of a specific certificate and is merely a conventional name and not a standardized one. In Apache installs, this frequently resides in /etc/ssl/private. The rights on these files are very important, and some programs will refuse to load these certificates if they are set wrong.
{% endhighlight %}

最先需要的是一个rsa的key，和gpg/ssh一样，rsa是非对称加密有公私匙。据称私钥包含了公匙。

{% highlight bash %}
openssl genrsa -out datlet.com.key 1024

kk@ins14 /etc/ssl/datlet $ sudo file datlet.com.key
datlet.com.key: PEM RSA private key

kk@ins14 /etc/ssl/datlet $ sudo head -n 1 datlet.com.key 
-----BEGIN RSA PRIVATE KEY-----

{% endhighlight %}



{% highlight bash %}
.csr 
This is a Certificate Signing Request. Some applications can generate these for submission to certificate-authorities. The actual format is PKCS10 which is defined in RFC 2986. It includes some/all of the key details of the requested certificate such as subject, organization, state, whatnot, as well as the public key of the certificate to get signed. These get signed by the CA and a certificate is returned. The returned certificate is the public certificate (not the key), which itself can be in a couple of formats.
{% endhighlight %}


csr就是通过私钥加密后的声明,PEM打包了，包括域名，组织，地区等信息。正常来说，把这个给CA，然后CA就会把证书给你。注意别加密码，否则每次webserver都要输入密码。
{% highlight bash %}
openssl req -new -key datlet.com.key -out datlet.com.csr

kk@ins14 /etc/ssl/datlet $ sudo file datlet.com.csr 
datlet.com.csr: PEM certificate request
kk@ins14 /etc/ssl/datlet $ sudo head -n 1 datlet.com.key 
-----BEGIN RSA PRIVATE KEY-----

{% endhighlight %}

{% highlight bash %}
.pem 
Defined in RFC 1421 through 1424, this is a container format that may include just the public certificate (such as with Apache installs, and CA certificate files /etc/ssl/certs), or may include an entire certificate chain including public key, private key, and root certificates. The name is from Privacy Enhanced Email, a failed method for secure email but the container format it used lives on, and is a base64 translation of the x509 ASN.1 keys.
{% endhighlight %}

最后是PEM,其实比较好的名字应该是`.crt`,就是certifcation了。是通过PEM打包的东西。
这里有自签的证书方式。

{% highlight bash %}
openssl x509 -req -days 365 -in datlet.com.csr -signkey datlet.com.key -out datlet.com.crt

kk@ins14 /etc/ssl/datlet $ file datlet.com.crt 
datlet.com.crt: PEM certificate
kk@ins14 /etc/ssl/datlet $ head -n 1 datlet.com.crt
-----BEGIN CERTIFICATE-----
{% endhighlight %}


{% highlight bash %}
kk@ins14 ~ $ curl -Iv https://ins14.datlet.com/ 
* Hostname was NOT found in DNS cache
*   Trying 10.0.2.15...
* Connected to ins14.datlet.com (10.0.2.15) port 443 (#0)
* successfully set certificate verify locations:
*   CAfile: none
  CApath: /etc/ssl/certs
* SSLv3, TLS handshake, Client hello (1):
* SSLv3, TLS handshake, Server hello (2):
* SSLv3, TLS handshake, CERT (11):
* SSLv3, TLS alert, Server hello (2):
* SSL certificate problem: self signed certificate
* Closing connection 0
curl: (60) SSL certificate problem: self signed certificate
More details here: http://curl.haxx.se/docs/sslcerts.html

curl performs SSL certificate verification by default, using a "bundle"
 of Certificate Authority (CA) public keys (CA certs). If the default
 bundle file isn't adequate, you can specify an alternate file
 using the --cacert option.
If this HTTPS server uses a certificate signed by a CA represented in
 the bundle, the certificate verification probably failed due to a
 problem with the certificate (it might be expired, or the name might
 not match the domain name in the URL).
If you'd like to turn off curl's verification of the certificate, use
 the -k (or --insecure) option.
kk@ins14 ~ $ curl -Iv https://ins14.datlet.com/ --cacert /etc/ssl/datlet/datlet.com.crt 
* Hostname was NOT found in DNS cache
*   Trying 10.0.2.15...
* Connected to ins14.datlet.com (10.0.2.15) port 443 (#0)
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/datlet/datlet.com.crt
  CApath: /etc/ssl/certs
* SSLv3, TLS handshake, Client hello (1):
* SSLv3, TLS handshake, Server hello (2):
* SSLv3, TLS handshake, CERT (11):
* SSLv3, TLS handshake, Server key exchange (12):
* SSLv3, TLS handshake, Server finished (14):
* SSLv3, TLS handshake, Client key exchange (16):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSLv3, TLS change cipher, Client hello (1):
* SSLv3, TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES256-GCM-SHA384
* Server certificate:
* 	 subject: C=CN; ST=Guangdong; L=Guangzhou; O=datlet.com; CN=*.datlet.com; emailAddress=kingkongmok@gmail.com
* 	 start date: 2014-08-29 06:18:22 GMT
* 	 expire date: 2015-08-29 06:18:22 GMT
* 	 common name: *.datlet.com (matched)
* 	 issuer: C=CN; ST=Guangdong; L=Guangzhou; O=datlet.com; CN=*.datlet.com; emailAddress=kingkongmok@gmail.com
* 	 SSL certificate verify ok.
> HEAD / HTTP/1.1
> User-Agent: curl/7.36.0
> Host: ins14.datlet.com
> Accept: */*
> 
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
* Server nginx/1.7.4 is not blacklisted
< Server: nginx/1.7.4
Server: nginx/1.7.4
< Date: Fri, 29 Aug 2014 06:59:40 GMT
Date: Fri, 29 Aug 2014 06:59:40 GMT
< Content-Type: text/html
Content-Type: text/html
< Content-Length: 6
Content-Length: 6
< Last-Modified: Thu, 28 Aug 2014 04:49:13 GMT
Last-Modified: Thu, 28 Aug 2014 04:49:13 GMT
< Connection: keep-alive
Connection: keep-alive
< Keep-Alive: timeout=20
Keep-Alive: timeout=20
< ETag: "53feb4c9-6"
ETag: "53feb4c9-6"
< Accept-Ranges: bytes
Accept-Ranges: bytes

< 
* Connection #0 to host ins14.datlet.com left intact
{% endhighlight %}
