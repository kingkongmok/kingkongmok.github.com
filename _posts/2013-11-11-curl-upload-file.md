---
layout: post
title: "curl upload file"
category: linux
tags: [linux, curl, upload, form]
---

##curl一般使用post和get


在curl中，提交get和post的方法分别是？和 -d， 而-b -c 分别是使用和产生cookie。
在pl的上传文件中，表格是这样写的：

```
form action=”/cgi-bin/upload.cgi” method=”post”
input type=”file” name=”photo”
input type=”text” name=”email_address”
input type=”submit” name=”Submit” value=”Submit Form”
```

针对第二行，我们可以用curl的form进行测试

```
curl --form "photo=@/home/kk/phpinfo.php" --form “email_address=newaddress.kk.igb” localhost/uploadfile.pl
```


其中，本地文件前面需要添加`@`，否则不能上传。
`phpinfo.php`是本地的文件名。
