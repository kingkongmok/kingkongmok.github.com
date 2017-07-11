---
layout: post
title: "revdep-rebuild.sh in gentoo"
category: linux
tags: [gentoo, revdep-rebuild.sh, libraries, broken]
---

##problems when run revdep-rebuild.sh

升级的时候，顺便查找并清除依赖，使用以下命令的

```
sudo emerge --sync && sudo emerge -a --update --deep --with-bdeps=y --newuse @world && sudo emerge --depclean && sudo revdep-rebuild.sh
```


```
kk@gentoo ~ $ sudo emerge --depclean && sudo revdep-rebuild.sh

* Always study the list of packages to be cleaned for any obvious
 * mistakes. Packages that are part of the world set will always
 * be kept.  They can be manually added to this set with
 * `emerge --noreplace <atom>`.  Packages that are listed in
 * package.provided (see portage(5)) will be removed by
 * depclean, even if they are part of the world set.
 * 
 * As a safety measure, depclean will not remove any packages
 * unless *all* required dependencies have been resolved.  As a
 * consequence, it is often necessary to run `emerge --update
 * --newuse --deep @world` prior to depclean.

Calculating dependencies... done!
>>> No packages selected for removal by depclean
>>> To see reverse dependencies, use --verbose
Packages installed:   693
Packages in world:    92
Packages in system:   44
Required packages:    693
Number removed:       0
 * Configuring search environment for revdep-rebuild.sh

 * Checking reverse dependencies
 * Packages containing binaries and libraries broken by a package update
 * will be emerged.

 * Collecting system binaries and libraries
 * Found existing 1_files.rr
 * Collecting complete LD_LIBRARY_PATH
 * Found existing 2_ldpath.rr.
 * Checking dynamic linking consistency
 * Found existing 3_broken.rr.
 * Assigning files to packages
 *  !!! /usr/lib64/codecs/cook.so not owned by any package is broken !!!
 *   /usr/lib64/codecs/cook.so -> (none)
 *  !!! /usr/lib64/codecs/drvc.so not owned by any package is broken !!!
 *   /usr/lib64/codecs/drvc.so -> (none)
 * Generated new 4_raw.rr and 4_owners.rr
 * Found some broken files, but none of them were associated with known packages
 * Unable to proceed with automatic repairs.
 * The broken files are listed in 4_owners.rr

kk@gentoo ~ $ ls -lh /usr/lib64/codecs/cook.so /usr/lib64/codecs/drvc.so
-rw-rw-r-- 1 1012 1004  42K 2005-02-16 03:39 /usr/lib64/codecs/cook.so
-rw-rw-r-- 1 1012 1004 314K 2005-02-16 03:40 /usr/lib64/codecs/drvc.so
```

**google了一下[解决方法](https://www.hellboundhackers.org/forum/gentoo_-_revdep-rebuild_%22not_owned_by_any_package%22-63-16523_0.html)**

##处理方法

```
sudo mv /usr/lib64/codecs/cook.so /tmp/
sudo revdep-rebuild.sh --ignore --pretend

Calculating dependencies... done!
>>> No packages selected for removal by depclean
>>> To see reverse dependencies, use --verbose
Packages installed:   693
Packages in world:    92
Packages in system:   44
Required packages:    693
Number removed:       0
 * Configuring search environment for revdep-rebuild.sh

 * Checking reverse dependencies
 * Packages containing binaries and libraries broken by a package update
 * will be emerged.

 * Collecting system binaries and libraries
 * Found existing 1_files.rr
 * Collecting complete LD_LIBRARY_PATH
 * Found existing 2_ldpath.rr.
 * Checking dynamic linking consistency
 * Found existing 3_broken.rr.
 * Assigning files to packages
 *  !!! /usr/lib64/codecs/cook.so not owned by any package is broken !!!
 *   /usr/lib64/codecs/cook.so -> (none)
 *  !!! /usr/lib64/codecs/drvc.so not owned by any package is broken !!!
 *   /usr/lib64/codecs/drvc.so -> (none)
 * Generated new 4_raw.rr and 4_owners.rr
 * Found some broken files, but none of them were associated with known packages
 * Unable to proceed with automatic repairs.
 * The broken files are listed in 4_owners.rr

sudo mv /usr/lib64/codecs/cook.so /tmp/
sudo mv /usr/lib64/codecs/drvc.so /tmp/

sudo revdep-rebuild.sh --ignore
 * Configuring search environment for revdep-rebuild.sh

 * Checking reverse dependencies
 * Packages containing binaries and libraries broken by a package update
 * will be emerged.

 * Collecting system binaries and libraries
 * Generated new 1_files.rr
 * Collecting complete LD_LIBRARY_PATH
 * Generated new 2_ldpath.rr
 * Checking dynamic linking consistency
[ 100% ]                 

 * Dynamic linking on your system is consistent... All done. 
```

这korg真是机智.
