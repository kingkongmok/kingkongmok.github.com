---
layout: page
title: 莫庆强的运维博客
tagline: about linux perl and networking
---
{% include JB/setup %}


我是一名Linux运维，家住广州。可以通过 kingkongmok AT gmail DOT com 联系我。

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>


