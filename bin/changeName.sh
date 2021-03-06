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



#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    cat <<- EOT

    DESCRIPTION: download video from youtube-dl

    Usage :  ${0##/*/} [-f]

    Options:
    -n		  Test only
    -h|help       Display this message

EOT
}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

TESTMODE=0

while getopts "n" opt
do
    case $opt in

        n     	   )  TESTMODE=1 ;  ;;
        h|help     )  usage; exit 0   ;;

        \? )  echo -e "\n  Option does not exist : $OPTARG\n"
            usage; exit 1   ;;

        esac    # --- end of case ---
    done
shift $(($OPTIND-1))



backup_dir=changeNameBackup
changename_log=${backup_dir}/changeName.log

if [ "$TESTMODE" == 0 ] ; then
    if  [ ! -d "$backup_dir" ] ; then
	mkdir "$backup_dir"
    fi
    find .  -maxdepth 1 -type f -exec ln {} "$backup_dir" \;
fi



# 包含以下字符的直接删除
list+=( "\[S版\]"  )
list+=( "\[無修正_重嵌\]"  )
list+=( "\[无修正中文\]"  )
list+=( "\[原版\]"  )
list+=( "\[改正\]"  )
list+=( "\[風的工房\]"  )
list+=( "\[4K漢化組\]"  )
list+=( "\[無修\]"  )
list+=( "\[中\]"  )
list+=( "\[東方Project\]"  )
# list+=( "Fatestaynight"  )
list+=( "\[DL版\]"  )
list+=( "\[中国翻訳\]" )
list+=( "（Chinese）" )
list+=( "\[Digital\]" )
list+=( "\[精修\]" )
list+=( "\[Chinese\]" )
list+=( "\[Decensored\]" )
list+=( "\(Complete\)" )
list+=( "\[English\]" )
list+=( "18禁アニメ"  )
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
variable+='s/\((?:無)修正\)//;'
variable+='s/～.*?～//;'
variable+='s/\(COMIC.*?\)//;'
#variable+='s/(.*)\[.*?組\]\./$1\./;'
variable+='s/【.*?(漢|汉)化】//;'
variable+='s/【.*?翻(译|訳)】//;'
variable+='s/\[[^]]*?翻(译|訳)\]//;'
variable+='s/\[[^[]*?(漢|汉)化\]//;'
variable+='s/\[[^[]*?(漢|汉)化(组|組)\]//;'
variable+='s/\[[^[]*?日语社\]//;'
variable+='s/\[[^[]*?掃圖組\]//;'
variable+='s/\[[^[]*?试看版\]//;'
variable+='s/\[[^[]*?重嵌\]//;'
# variable+='s/「.*?」//;'
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
if [ "$TESTMODE" == 0 ] ; then
    eval "perl-rename -n '$variable' \"$file\"" >> "$changename_log"
    eval "perl-rename -i '$variable' \"$file\""  
else
    eval "perl-rename -n '$variable' \"$file\""
fi

done

