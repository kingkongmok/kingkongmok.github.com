---
layout: post
title: "curl examples "
category: linux
tags: [curl, examples, upload, delete, ftp]
---

### curl的 --data-binary 应用

通过chrome的F12截取，可以获得一些url的post方式包含curl的***--data-binary***应用

```
curl localhost --data-binary "<object>"^
"  <int name=""comeFrom"">0</int>"^
"</object>"
```

可以通过***@-***转换一下：

```
echo '<object>
<int name="comeFrom">0</int>
</object>' | curl --data-binary @-
```
当然，如果是纯粹的POST的话，可以使用***--data***上传


---

### curl在ftp的删除

curl除了可以使用于http，还可以使用于ftp。

```
backup_ftps="ftp://user:pasw@ftp:21/"
backup_file="/home/backup/${backup_name}"
curl -s -T ${backup_file} ${backup_ftps}
```

-T为上传的参数
```
-T --upload files，

examples: 

    curl -T "{file1,file2}" http://www.uploadtothissite.com

or even

    curl -T "img[1-1000].png" ftp://ftp.picturemania.com/upload/
```

-X可以用于POST或者GET这些HTTP的方法，在ftp使用可以用DELETE

```
-X, --request <command>

curl -s -X "DELE ${backup_file_delete}" ${backup_ftps}
```

---

## curl set range

今天整理笔记的时候发现一个curl的***--range***选项，不错。

```
curl -r 0-199999999 -o mdk-iso.part1 $url1 &
curl -r 200000000-399999999 -o mdk-iso.part2 $url2 &
curl -r 400000000- -o mdk-iso.part3 $url3 &

cat mdk-iso.part? > mdk-80.iso

```


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
curl --form "photo=@/home/kk/phpinfo.php" --form \
"email_address=newaddress.kk.igb" localhost/uploadfile.pl
```


其中，本地文件前面需要添加`@`，否则不能上传。
`phpinfo.php`是本地的文件名。


```
http://user:pass@myhost/hudson/job/_jobName_/postBuildResult
```

---

[post一个xml](http://stackoverflow.com/questions/3007253/send-post-xml-file-using-curl-command-line)

```
$ curl -X POST -d @myfilename URL
```


