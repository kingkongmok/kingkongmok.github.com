---
layout: post
title: "perl cgi upload file"
category: perl
tags: [perl, cgi, upload, curl]
---
{% include JB/setup %}

##perl cgi file upload using curl

**[cgi代码](https://github.com/kingkongmok/perl/blob/master/web/uploadfile.pl)**

**curl上传的方法**

```sh
curl --form filename=@/home/kk/check_inn.pl localhost/uploadfile.pl
```

出现了`nginx 413 Request Entity Too Large`的字样，那个是web server的request设置过小了，需要在nginx.conf的server区加入： `client_max_body_size 2000M;`
当然这样由于我要上传软件。


```pl
use strict;
use warnings;
 
use CGI;
use CGI::Carp qw(fatalsToBrowser);
 
my $q = new CGI;
 
unless ( $q->param("file") ) {
    print $q->header, 
    $q->p("please insert a file"),
    $q->start_form,
    $q->filefield({-name=>"file"}),
    $q->submit,
    $q->end_form;
 
}
else {
    my $file = $q->upload("file");
    my $filename = $q->param("file");
    open FILE, "> /tmp/$filename";
    while ( <$file> ) {
        print FILE $_;
    }
    close FILE;
    print $q->header, $q->p("$filename is saved");
}
```
