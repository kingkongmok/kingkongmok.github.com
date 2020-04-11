---
layout: post
title: "ffmpeg and mplayer"
category: linux
tags: [ffmpeg, mplayer, media]
---


### [meaning of ffmpeg output tbc/tbn/tbr](https://stackoverflow.com/questions/3199489/meaning-of-ffmpeg-output-tbc-tbn-tbr)

+ **tbn** = the time base in AVStream that has come from the container
+ **tbc** = the time base in AVCodecContext for the codec used for a particular stream
+ **tbr** = tbr is guessed from the video stream and is the value users want to see when they look for the video frame rate

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
screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf scale=-1:576 -b:v 1M small/"$i" ; done'
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

---

~~[Merge MKV and ASS](https://www.flynsarmy.com/2015/01/bulk-merge-mkv-ass-subtitle-files/)~~

### [Use ffmpeg to add text subtitles](https://stackoverflow.com/questions/8672809/use-ffmpeg-to-add-text-subtitles)

```
ffmpeg -i infile.mp4 -i infile.srt -c copy -c:s mov_text outfile.mp4
```

**-vf subtitles=infile.srt** will not work with **-c copy**

---

### mkv to mp4


```
ffmpeg -i input.mkv -c copy -c:s mov_text output.mp4
```

### wmv to mp4 

```
ffmpeg -i input.wmv -c:v libx264 -c:a aac output.mp4
```

```
screen -S ffmpeg sh -c 'for i in *wmv ; do ffmpeg -i "$i" -c:v libx264 -crf 23 -profile:v high -r 30 -c:a aac -q:a 100 -ar 48000 "${i}.mp4" ; done'
```

---

### [docker](https://hub.docker.com/r/jrottenberg/ffmpeg/)

```
docker run -it --rm -v $PWD:/tmp/workdir  jrottenberg/ffmpeg -i output.mp4
```

---

[reindex](https://video.stackexchange.com/questions/18220/fix-bad-files-and-streams-with-ffmpeg-so-vlc-and-other-players-would-not-crash)

```
ffmpeg -err_detect ignore_err -i video.mkv -c copy video_fixed.mkv
```

---

ffmpeg -i action.mp4 -vf scale=-1:720 -b:v 2600k small_action.mp4
