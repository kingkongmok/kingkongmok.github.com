---
layout: post
title: "git push error"
category: linux
tags: [git]
---
{% include JB/setup %}


新安装的电脑，当然要clone一下git啦
{% highlight bash %}
[ cd ~/workspace ] && git clone git://github.com/kingkongmok/linux
{% endhighlight %}

这里是成功的，但push的时候出现异常：


{% highlight bash %}
fatal: remote error: 
You cant push to git://github.com/my_user_name/my_repo.git
Use git@github.com:my_user_name/my_repo.git
{% endhighlight %}

万能的[stackoverflow](http://stackoverflow.com/questions/7548661/git-github-cant-push-to-master)解决我的问题


{% highlight bash %}
git remote set-url origin git@github.com:kingkongmok/kingkongmok/perl.git
{% endhighlight %}
