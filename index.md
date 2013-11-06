---
layout: page
title: 莫庆强的运维博客
tagline: about linux perl and networking
---
{% include JB/setup %}


## about me
**  A linux administrator living in Guangzhou China. 
    

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>


