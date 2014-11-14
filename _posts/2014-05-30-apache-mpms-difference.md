---
layout: post
title: "apache MPM"
category: linux
tags: [apache, mpm, worker, event]
---
{% include JB/setup %}

现在都是基于lnmmp的架构，也有nginx用户提出可以[100k每分钟的并发](http://stackoverflow.com/questions/7325211/tuning-nginx-worker-process-to-obtain-100k-hits-per-min)，但apache的lanmmp还是比较有意思的。这里粗略看看apache的MPM选择。

在选择apache MPM似乎没有什么需要调查的，直接安装[建议「(http://serverfault.com/questions/383526/how-do-i-select-which-apache-mpm-to-use)进行。


{% highlight bash %}
prefork

mpm_prefork is.. well.. it's compatible with everything. It spins of a number of child processes for serving requests, and the child processes only serve one request at a time. Because it's got the server process sitting there, ready for action, and not needing to deal with thread marshaling, it's actually faster than the more modern threaded MPMs when you're only dealing with a single request at a time - but concurrent requests suffer, since they're made to wait in line until a server process is free. Additionally, attempting to scale up in the count of prefork child processes, you'll easily suck down some serious RAM.

It's probably not advisable to use prefork unless you need a module that's not thread safe.

Use if: You need modules that break when threads are used, like mod_php. Even then, consider using FastCGI and php-fpm.

Don't use if: Your modules won't break in threading.

{% endhighlight %}
{% highlight bash %}

worker

mpm_worker uses threading - which is a big help for concurrency. Worker spins off some child processes, which in turn spin off child threads; similar to prefork, some spare threads are kept ready if possible, to service incoming connections. This approach is much kinder on RAM, since the thread count doesn't have a direct bearing on memory use like the server count does in prefork. It also handles concurrency much more easily, since the connections just need to wait for a free thread (which is usually available) instead of a spare server in prefork.

Use if: You're on Apache 2.2, or 2.4 and you're running primarily SSL.

Don't use if: You really can't go wrong, unless you need prefork for compatibility.

However, note that the treads are attached to connections and not requests - which means that a keep-alive connection always keeps ahold of a thread until it's closed (which can be a long time, depending on your configuration). Which is why we have..


{% endhighlight %}
{% highlight bash %}

event

mpm_event is very similar to worker, structurally; it's just been moved from 'experimental' to 'stable' status in Apache 2.4. The big difference is that it uses a dedicated thread to deal with the kept-alive connections, and hands requests down to child threads only when a request has actually been made (allowing those threads to free back up immediately after the request is completed). This is great for concurrency of clients that aren't necessarily all active at a time, but make occasional requests, and when the clients might have a long keep-alive timeout.

The exception here is with SSL connections; in that case, it behaves identically to worker (gluing a given connection to a given thread until the connection closes).

Use if: You're on Apache 2.4 and like threads, but you don't like having threads waiting for idle connections. Everyone likes threads!

Don't use if: You're not on Apache 2.4, or you need prefork for compatibility.

{% endhighlight %}
