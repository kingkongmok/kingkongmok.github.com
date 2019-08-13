---
title: "youtube-dl"
layout: post
category: linux
---

### List all available formats of requested videos which **-F**

```
youtube-dl -F URL
```

### Video format code, see the "FORMAT SELECTION" for all the info

```
youtube-dl -f 001 URL
youtube-dl -f "[height < 720]" URL
```

---

### [download a video as mp3 file](https://www.tecmint.com/download-mp3-song-from-youtube-videos/)

```
youtube-dl -x --audio-format mp3 URL
```

### Where **NUMBER** is the starting and ending point of the playlist

```
youtube-dl -x --audio-format mp3 --playlist-start 1 --playlist-end 5 URL
```
