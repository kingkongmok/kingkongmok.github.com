---
layout: post
title: "print next lline if match pattern"
category: perl
tags: [next line, regex, perl]
---
{% include JB/setup %}

<pre lang="bash">
cat workspace/perl/0to9.txt | perl -ne '$n=3 if /4/ ; print if $n-- > 0'
</pre>

