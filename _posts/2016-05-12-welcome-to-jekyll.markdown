---
layout: post
title:  "Welcome to Jekyll!"
date:   2016-05-12 16:53:50 +0800
categories: jekyll update
---
You’ll find this post in your `_posts` directory. Go ahead and edit it and re-build the site to see your changes. You can rebuild the site in many different ways, but the most common way is to run `jekyll serve`, which launches a web server and auto-regenerates your site when a file is updated.

To add new posts, simply add a file in the `_posts` directory that follows the convention `YYYY-MM-DD-name-of-post.ext` and includes the necessary front matter. Take a look at the source for this post to get an idea about how it works.

Jekyll also offers powerful support for code snippets:

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}

Check out the [Jekyll docs][jekyll-docs] for more info on how to get the most out of Jekyll. File all bugs/feature requests at [Jekyll’s GitHub repo][jekyll-gh]. If you have questions, you can ask them on [Jekyll Talk][jekyll-talk].

[jekyll-docs]: http://jekyllrb.com/docs/home
[jekyll-gh]:   https://github.com/jekyll/jekyll
[jekyll-talk]: https://talk.jekyllrb.com/

---

## 新的Jekyll

> 第一需要新建一个站并把***_post***拷贝过来

* create new host

```
    gem update jekyll
    mkdir newhost && cd newhost
    jekyll new .
```

> 第二需要新的rakefile以生成post

* 这个[Rakefile]有快速部署的功能，但需要微调，例如open为vim，时间等，具体见diff。

* [Rakefile]的使用方法：

```
rake create_post[date,title,category,content]
```

[Rakefile]: https://github.com/kingkongmok/jekyll-rakefile



---

## 遗留问题


1. 本地使用jekyll server的时候提示***favicon.ico not found***

```
      Regenerating: 1 file(s) changed at 2016-05-13 11:00:42 ...done in 2.836243085 seconds.
      Regenerating: 1 file(s) changed at 2016-05-13 11:00:50 ...done in 2.926694952 seconds.
      Regenerating: 1 file(s) changed at 2016-05-13 11:01:19 ...done in 2.852907974 seconds.
      Regenerating: 1 file(s) changed at 2016-05-13 11:01:22 [2016-05-13 11:01:24] ERROR `/favicon.ico' not found.
...done in 3.012053543 seconds.
```
