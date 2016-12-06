---
title: "bat compress and remove old with 7-zip"
layout: post
category: windows
---

```
REM This is a batch script to zip all the files exclude *.zip in folder.
REM This script is using 7z to zip files, installation is required - "[http://www.7-zip.org/" 
REM Remember to point 'do' to 7z installed path 7z.exe 


SET FOLDER="c:\db test"

FOR /R  %FOLDER%  %%F IN (*.*) DO IF NOT "%%~xF" == ".zip" "C:\Program Files\7-Zip\7z.exe" a "%%F.zip" "%%F"  && del "%%F"
forfiles -p %FOLDER% -s -m *.zip -d 90 -c "cmd /c del @path"
forfiles /P %FOLDER% /S /M *.zip /D -90 /C "cmd /c del @PATH"

```
