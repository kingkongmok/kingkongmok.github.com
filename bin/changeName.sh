#!/bin/bash - 
#===============================================================================
#
#          FILE: changeName.sh
# 
#         USAGE: ./changeName.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 23/02/21 10:11
#      REVISION:  ---
#===============================================================================

set -o nounset                              


backup_dir=changeNameBackup
changename_log=${backup_dir}/changeName.log

if  [ ! -d "$backup_dir" ] ; then
    mkdir "$backup_dir"
fi

find .  -maxdepth 1 -type f -exec ln {} "$backup_dir" \;


# 包含以下字符的直接删除
list+=( "18禁アニメ"  )
list+=( "風的工房"  )
list+=( "東方Project"  )
# list+=( "Fatestaynight"  )
list+=( "DL版"  )
list+=( "中国翻訳"  )
list+=( "（Chinese）"  )
list+=( "\[Digital\]"  )
list+=( "精修"  )
command=''
exp=''
for mystr in "${list[@]}"; do 
   variable+="s/$mystr//; " 
done



variable+="s/第零話/_0/g;"
variable+="s/第〇話/_0/g;"
variable+="s/第一話/_1/g;"
variable+="s/第二話/_2/g;"
variable+="s/第三話/_3/g;"
variable+="s/第四話/_4/g;"
variable+="s/第五話/_5/g;"
variable+="s/第六話/_6/g;"
variable+="s/第七話/_7/g;"
variable+="s/第八話/_8/g;"
variable+="s/第九話/_9/g;"
variable+="s/第十話/_10/g;"

# substrim，使用perl的 s///功能


variable+="s/ +//g;"
variable+="s/!+//g;"
variable+="s/\|/_/g;"
variable+="s/\(\)//g;"
variable+="s/\[\]//g;"
variable+="s/【】//g;"
variable+="s/\t+//g;"

variable+='s/\(C\d+\)//;'
# variable+='s/\(例大祭\d+\)//;'
variable+='s/\[720P[^]]*?\]//;'
variable+='s/\[MJK.*?\]//;'
variable+='s/\[(?:無)修正\]//;'
variable+='s/～.*?～//;'
variable+='s/\(COMIC.*?\)//;'
#variable+='s/(.*)\[.*?組\]\./$1\./;'
variable+='s/【.*?(漢|汉)化】//;'
variable+='s/\[[^[]*?(漢|汉)化\]//;'
variable+='s/\[[^[]*?(漢|汉)化组\]//;'
variable+='s/\[[^[]*?掃圖組\]//;'
variable+='s/\&nbsp;//g;'
variable+='s/Vol.(\d)/_$1/g;'
# variable+='s/\(.*?\)(\.[^.]*?)$/$1/;'
# variable+='s/\[.*?\](\.[^.]*?)$/$1/;'
# variable+='s/【.*?】(\.[^.]*?)$/$1/;'

# # ～ 不要
# variable+='s/～[^\]]*?\././;'

# [fakename(realname)] -> [realname]
variable+='s/\[[^(]*?\((.*?)\)\]/\[$1\]/;'

command="perl-rename -n '$variable' " 

find . -maxdepth 1  -type f -print0 | while read -d $'\0' file; do

# eval "$command \"$file\"" >> "$changename_log"
eval "perl-rename -n '$variable' \"$file\"" >> "$changename_log"
eval "perl-rename -i '$variable' \"$file\""  

done

# echo "[33;1mfinish please see $changename_log [0;49m ";

