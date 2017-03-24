#!/bin/bash - 
for i in *; do unzip "$i"; done
find -type f ! -iregex  ".*\(jpg\|png\)" -delete
mv MH*/* .
rm -rf MH*
for i in *; do cd "$i"; tar cf "$i".tar *; mv "$i".tar ..; cd ..; done
ls -d */ | xargs rm -rf
for i in *tar; do comixchange.sh "$i"; done
