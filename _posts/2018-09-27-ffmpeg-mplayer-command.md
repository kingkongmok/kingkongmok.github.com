---
layout: post
title: "ffmpeg and mplayer"
category: linux
tags: [ffmpeg, mplayer, media]
---

###  [reduce video size](https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg)


+ ***change size***

```
ffmpeg -i input.mp4 -vf "scale=iw/2:ih/2" output.mp4

```

540P

```
mkdir small
screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf scale=-1:540 small/"$i" ; done'
```

720P

```
mkdir small
screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf scale=-1:720 small/"$i" ; done'
```

+ **Constant Rate Factor**, which lowers the average bit rate, but retains better quality. Vary the CRF between around 18 and 24

```
ffmpeg -i input.mp4 -vcodec libx264 -crf 20 output.mp4
```

---

### mp3 reduce size


```
screen -S lame bash -c 'for i in *mp3; do lame --preset phon+ "$i"; done'
```
