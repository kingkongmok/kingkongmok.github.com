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
screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf scale=-1:720 small/"$i" ; done'
screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -b:v 1M small/"$i" ; done'

screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -b:v 1M "ffmpegTemp_${i}" && mv -f "ffmpegTemp_${i}" "$i" ; done'
screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:540" -b:v 1M "ffmpegTemp_${i}" && mv -f "ffmpegTemp_${i}" "$i" ; done'


screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -c:v libx265 -crf 18 -vf  scale="trunc(oh*a/2)*2:540" "ffmpegTemp_${i}" && mv -f "ffmpegTemp_${i}" "$i" ; done'



screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf scale="trunc(oh*a/2)*2:720" -b:v 1M "ffmpegTemp_${i}" && mv -f "ffmpegTemp_${i}" "$i" ; done'

screen -S ffmpeg bash -c 'for i in *; do ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:720" -c:v libx265 -crf 18 "ffmpegTemp_${i}" && mv -f "ffmpegTemp_${i}" "$i" ; done'

screen -S ffmpeg sh -c 'for i in *; do [ `ffmpeg -i "$i" 2>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 480 ] && ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -b:v 1M "${i}_ffmpeg.mp4" && mv -f "${i}_ffmpeg.mp4" "$i" ; done'

screen -S ffmpeg sh -c 'for i in *; do [ `ffmpeg -i "$i" 2>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 720 ] && ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:720" -b:v 1M "${i}_ffmpeg.mp4" && mv -f "${i}_ffmpeg.mp4" "$i" ; done'



## https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg




# 目前测试中， current testing
screen -S ffmpeg sh -c 'for i in *; do [ `ffmpeg -i "$i" 2>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 480 ] &&  ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -c:v libx265 -crf 18 -c:s mov_text "${i}_ffmpeg.mp4" ; mv "${i}_ffmpeg.mp4" "$i" ;  done'

<<<<<<< HEAD
screen -S ffmpeg sh -c 'find . -size +5M -print0 | while read -d $'\''\0'\'' i ; do [ `ffmpeg -i "$i" 2>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 480 ] &&  \
ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -c:v libx265 -crf 18 -c:s mov_text "${i}_ffmpeg.mp4" ; done'


screen -S ffmpeg sh -c 'find . -size +5M -print0 | while read -d $'\''\0'\'' i ; do [ `ffmpeg -i "$i" 2>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 480 ] &&  \
ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -c:v libx265 -crf 18 -c:s mov_text "${i}_ffmpeg.mp4" && mv "${i}_ffmpeg.mp4" "$i" ; done'


screen -S ffmpeg sh -c 'for i in *; do [ `ffmpeg -i "$i" 3>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 480 ] &&  \
ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:480" -c:v libx265 -crf 18 -c:s mov_text "${i}_ffmpeg.mp4" && mv "${i}_ffmpeg.mp4" "$i" ; done'

=======
>>>>>>> 3ad7185480962c5886812526dad52be3ffb15c9f
```

+ [first audio only](https://ottverse.com/add-remove-extract-audio-from-video-using-ffmpeg/)

```
screen -S ffmpeg ffmpeg -i video.mp4 -vcodec libx264 -crf 20 -acodec ac3 -map 0 -map 0:a:0 -vf scale="trunc(oh*a/2)*2:20" -b:v 1M out.mp4
```

+ **Constant Rate Factor**, which lowers the average bit rate, but retains better quality. Vary the CRF between around 18 and 24

```
ffmpeg -i input.mp4 -vcodec libx264 -crf 20 output.mp4
```

---

### [join 2 mp4](https://stackoverflow.com/questions/7333232/how-to-concatenate-two-mp4-files-using-ffmpeg)


```
:: Create File List
ls *mp4 | perl -ne 'print "file $_"' > mylist.txt

:: Concatenate Files
ffmpeg -f concat -i mylist.txt -c copy output.mp4
```

```
ffmpeg -f concat -safe 0 -i <( find . -type f -name '*mp4' -printf "file '$PWD/%P'\n" | sort -g  ) -c copy all.mp4
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
for i in *ass; do ffmpeg -i "${i%ass}mp4" -i "$i" -c copy -c:s mov_text outfile_"${i%ass}mp4" && rm -f "${i%ass}mp4" "$i" && mv outfile_"${i%ass}mp4" "${i%ass}mp4" ; done 
```

**-vf subtitles=infile.srt** will not work with **-c copy**

---

### mkv to mp4


```
ffmpeg -i input.mkv -c copy -c:s mov_text output.mp4
screen -S ffmpeg sh -c 'for i in *mkv ; do ffmpeg -i "$i" -c copy -c:s mov_text "${i%mkv}mp4" ; done'
```


```
ffmpeg -i input.mkv -map 0:v:0 -map 0:a:0 -c copy -map_chapters -1 output.mp4
-map 0:v:0 选择第一个视频流。
-map 0:a:0 选择第一个音频流。
-c copy 确保视频和音频流直接复制而不进行重新编码。
-map_chapters -1 表示不从任何输入文件中复制章节信息。
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

---

### [merge mp4 and m4a](https://superuser.com/questions/277642/how-to-merge-audio-and-video-file-in-ffmpeg)


```
ffmpeg -i video.mp4 -i audio.wav -c:v copy -c:a aac output.mp4
```

```
ffmpeg -i video.mp4 -i audio.wav -c copy output.mkv
```

---

* m2ts to mp4

```
M2TS TO MP4
screen -S ffmpeg bash -c 'find . -iname "*m2ts" -exec ffmpeg -i {} -vcodec libx264 -crf 20 -acodec ac3 -vf scale="trunc(oh*a/2)*2:720" -b:v 1M "{}.mp4" \;'
screen -S ffmpeg bash -c 'find . -size +100M -exec ffmpeg -i {} -vcodec libx264 -crf 20 -acodec ac3 -vf scale="trunc(oh*a/2)*2:720" -b:v 1M "{}.mp4" \;'
```



```
screen -S ffmpeg sh -c 'for i in `find . -size +5M `; do [ `ffmpeg -i "$i" 2>&1 | grep -oP "Video.*x(\d+)" | grep -oP "\d+$"` -gt 540 ] && ffmpeg -i "$i" -vf  scale="trunc(oh*a/2)*2:540" -c:v libx265 -crf 18 -b:v 1500K   "${i}_ffmpeg.mp4" && mv -f "${i}_ffmpeg.mp4" "$i" ; done'

```
