---
layout: post
title: "find files on a specific day"
category: linux
tags: [find, newer]
---
{% include JB/setup %}

### [这里](https://stackoverflow.com/questions/158044/how-to-use-find-to-search-for-files-created-on-a-specific-date/158235#158235)介绍了如何查找特定日子的文件

Example: To find all files modified on the 7th of June, 2006:

```bash
$ find . -type f -newermt 2007-06-07 ! -newermt 2007-06-08
```

To find all files accessed on the 29th of september, 2008:

```bash
$ find . -type f -newerat 2008-09-29 ! -newerat 2008-09-30
```

Or, files which had their permission changed on the same day:

```bash
$ find . -type f -newerct 2008-09-29 ! -newerct 2008-09-30
```
