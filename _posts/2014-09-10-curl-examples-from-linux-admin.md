---
layout: post
title: "curl examples from linux admin"
category: linux
tags: [curl, examples, upload, delete, ftp]
---
{% include JB/setup %}

curl除了可以使用于http，还可以使用于ftp。

{% highlight bash %}
backup_ftps="ftp://user:pasw@ftp:21/"
backup_file="/home/backup/${backup_name}"
curl -s -T ${backup_file} ${backup_ftps}
{% endhighlight %}

-T为上传的参数
{% highlight bash %}
-T --upload files，

examples: 

    curl -T "{file1,file2}" http://www.uploadtothissite.com

or even

    curl -T "img[1-1000].png" ftp://ftp.picturemania.com/upload/
{% endhighlight %}

-X可以用于POST或者GET这些HTTP的方法，在ftp使用可以用DELETE

{% highlight bash %}
-X, --request <command>

curl -s -X "DELE ${backup_file_delete}" ${backup_ftps}
{% endhighlight %}
