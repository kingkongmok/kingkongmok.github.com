---
title: "bat compress and remove old with 7-zip whith mysqldump.exe"
layout: post
category: windows
---


### backup with mysqldump.exe

```
set CURRENT_DATE_STAMP=%date:~0,4%%date:~5,2%%date:~8,2%

cd "C:\Program Files\MySQL\MySQL Server 5.6\bin"

# bacup all databases
mysqldump.exe  --all-databases -u root -pPASSWORD > c:\db\alldatabases_%CURRENT_DATE_STAMP%.sql

# backup prod database only
mysqldump.exe -u root -pPASSWORD  prod > c:\db\prod_%CURRENT_DATE_STAMP%.sql

```

---

### compress and remove old

```
REM This is a batch script to zip all the files exclude *.zip in folder.
REM This script is using 7z to zip files, installation is required - "[http://www.7-zip.org/" 
REM Remember to point 'do' to 7z installed path 7z.exe 


SET FOLDER="c:\db"

FOR /R  %FOLDER%  %%F IN (*.*) DO IF NOT "%%~xF" == ".zip" "C:\Program Files\7-Zip\7z.exe" a "%%F.zip" "%%F"  && del "%%F"
forfiles -p %FOLDER% -s -m *.zip -d 90 -c "cmd /c del @path"
forfiles /P %FOLDER% /S /M *.zip /D -90 /C "cmd /c del @PATH"

```

