---
layout: post
title: "mencoder"
category: linux
tags: [mencoder]
---

### for PC

```bash
nice -n 19 mencoder input.avi -oac mp3lame -lameopts abr:br=128 -ovc lavc -lavcopts vcodec=mpeg4:vhq:v4mv:vqmin=2:vbitrate=1422 -ffourcc XVID -o out.avi
```

### for DC

```bash
nice -n 19 mencoder -oac mp3lame -lameopts abr:br=128 -srate 22050 -ovc lavc -lavcopts vcodec=mpeg4:vhq:v4mv:vqmin=2:vbitrate=1500 -ffourcc XVID input.avi -o output.avi
```

### for wmv convert to avi

```bash
mencoder infile.wmv -ofps 23.976 -ovc lavc -oac copy -o outfile.avi
```
### for palm

```bash
mencoder -vf scale=320:240 -oac mp3lame -lameopts mode=0:cbr:br=96  -af volnorm -srate 32000 -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=250  input.avi -o output.avi
```
