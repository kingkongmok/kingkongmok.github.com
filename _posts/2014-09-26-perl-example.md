---
layout: post
title: "perl example"
category: perl
tags: [search]
---
{% include JB/setup %}

{% highlight bash %}
kk@ins14 ~/workspace/kingkongmok.github.com $ sudo cat /var/log/syslog | perl -MData::Dumper -ne 'next unless /^Sep  2/../^Sep\s+3/; while(/((master_spawn|kernel|error))/g){$h{$1}++} }{ print Dumper\%h'
$VAR1 = {
          'master_spawn' => 595,
          'kernel' => 419,
          'error' => 2
        };
{% endhighlight %}

这个是用来检查某段之间（从Sep  2到Sep  2段落）间，出现以上词语的次数。
