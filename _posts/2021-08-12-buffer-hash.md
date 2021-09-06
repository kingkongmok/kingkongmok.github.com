---
layout: post
title: "buffer hash"
category: linux
tags: [oracle, buffer]
---

### [bh](https://oracle-abc.wikidot.com/x-bh)

XCUR - This is a RAM block that has been acquired in exclusive current mode. According the Oracle documentation, if a buffer state is exclusive current (XCUR), an instance owns the resource in exclusive mode.

CR - This mode indicates a "cloned" RAM block (a "stale" block), that was once in xcur mode. The instance has shared access to the block and can only perform reads. The cr state means the owning instance can perform a consistent read of the block, if the instance holds an older version of the data.

FREE - This is an “available” RAM block. It might contain data, but it is not currently in-use by Oracle.

READ – The buffer is reserved for a block that is currently being read from disk.

MREC – Indicates a block in media recovery mode

IREC – This is a block in instance (crash) recovery mode

SCUR - a current mode block, shared with other instances


