---
layout: post
title: "manage user account"
category: linux
tags: [chage, useradd]
---

## chage

+ disable password aging for an user account

```bash
# chage -m 0 -M 99999 -I -1 -E -1 dhinesh

# chage --list dhinesh
Last password change                                    : Apr 23, 2009
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

---

## useradd and groupadd

```
# groupadd -g 1000 GROUPNAME
# useradd -u 1000 -g 1000 -d /home/USERNAME USERNAME
```
