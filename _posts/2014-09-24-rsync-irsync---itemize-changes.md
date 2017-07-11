---
layout: post
title: "rsync"
category: linux
tags: [rsync, command]
---

## [-i](http://stackoverflow.com/questions/4493525/rsync-what-means-the-f-on-rsync-logs)

`>f.st......`

```
> - the item is received
f - it is a regular file
s - the file size is different
t - the time stamp is different
```

`.d..t......`

```
. - the item is not being updated (though it might have attributes 
    that are being modified)
d - it is a directory
t - the time stamp is different
```

`>f+++++++++`

```
> - the item is received
f - a regular file
+++++++++ - this is a newly created item
```

在使用rsync的时候，需要配合rsync -auvhni功能来查看，甚至有时候需要配合--delete，其他都比较好理解，但-i需要注意一下：[这里有详细解析](./_posts/2014-09-24-rsync-irsync---itemize-changes.md)

```
YXcstpoguax  path/to/file
|||||||||||
`----------- the type of update being done::
 ||||||||||   <: file is being transferred to the remote host (sent).
 ||||||||||   >: file is being transferred to the local host (received).
 ||||||||||   c: local change/creation for the item, such as:
 ||||||||||      - the creation of a directory
 ||||||||||      - the changing of a symlink,
 ||||||||||      - etc.
 ||||||||||   h: the item is a hard link to another item (requires --hard-links).
 ||||||||||   .: the item is not being updated (though it might have attributes that are being modified).
 ||||||||||   *: means that the rest of the itemized-output area contains a message (e.g. "deleting").
 ||||||||||
 `---------- the file type:
  |||||||||   f for a file,
  |||||||||   d for a directory,
  |||||||||   L for a symlink,
  |||||||||   D for a device,
  |||||||||   S for a special file (e.g. named sockets and fifos).
  |||||||||
  `--------- c: different checksum (for regular files)
   ||||||||     changed value (for symlink, device, and special file)
   `-------- s: Size is different
    `------- t: Modification time is different
     `------ p: Permission are different
      `----- o: Owner is different
       `---- g: Group is different
        `--- u: The u slot is reserved for future use.
         `-- a: The ACL information changed
```



