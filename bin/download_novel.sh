#!/bin/bash - 
#===============================================================================
#
#          FILE: download_novel.sh
# 
#         USAGE: ./download_novel.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 02/21/2019 16:09
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

URL=$1
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")


echo downloading to "/tmp/novel-done/$TIMESTAMP"
mkdir -p /tmp/novel-done/$TIMESTAMP/
proxychains -q wget -q -P /tmp/novel-done/$TIMESTAMP --user-agent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" -r -l1 "$URL"
proxychains -q wget -q --user-agent="Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)" "$URL" -O /tmp/novel-done/${TIMESTAMP}/name.html

cd /tmp/novel-done/$TIMESTAMP
enca -L zh -x utf8 name.html
#TITLE=`perl -nE 'say $1 if /\<title\>.*?-(.*)-/' name.html`
TITLE=`perl -nE 'say $1 if /<title>.*?【(.*)】.*?<\/title>/' name.html`
#TITLE=${TITLE:-`echo $2`}
[[ "x$2" == "x" ]] ||  TITLE=$2

cd www*/bbs4/
enca -L zh -x utf8 *
rm -f index.php
mkdir txt
for i in `grep 送交者 index.php* -l ` ; do cp "$i" txt ; done
cd txt
perl-rename 's/.*/sprintf"%03d.txt",++$i/e' * -i
# 抓取title和正文内容
for i in *txt ; do perl -i.bak -00nE 'while(/<title>(.*?)<\/title>.*?\<pre\>(.*)\<\/pre\>/gsm){print $1, "\n",  $2}' "$i"; done
# 匹配一下是否有title再合并
for i in *txt ; do head -n10 "$i" | grep -q "$TITLE" && cat "$i" >> all.txt ; done 
perl -i.bak -pe 's/<font color=#\w+?>\w+?\.\w+<\/font><p><\/p>//g; s/\r\n//g; s/　　/\n　　/g; s/    /\n　　/g' all.txt
#perl -i.bak2 -pe 's#<font \S+?</font>##g; s#<p></p>#\n#g; s#<br />##g' all.txt
perl -i.bak2 -pe 's#<p></p>#\n#g; s#<font \S+?</font>##g; s#<br />##g' all.txt
perl -i -ne 'print unless /^[\s　]+\r?$/' all.txt
cp -f all.txt /tmp/"$TITLE".txt
echo /tmp/"$TITLE".txt done
