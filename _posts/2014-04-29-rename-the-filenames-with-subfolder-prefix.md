---
layout: post
title: "rename the filenames with subfolder prefix"
category: bash
tags: [rename, subfolder, perl]
---
{% include JB/setup %}

http://bpaste.net/show/244959/

{% highlight bash %}
find -maxdepth 2 -type f -print0  | xargs -r0n1 | perl-rename -n 's#\b/##'
find . -type f | sed -r 's@([^/])/([^/]+)/(.*)@mv & \1/\2\3@'
find -maxdepth 2 -type f |perl -lne '$file=$_;s/\b\///g;rename $file,$_'
{% endhighlight %}
