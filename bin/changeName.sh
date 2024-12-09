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

find . -maxdepth 1  -type f -print0 | while read -d $'\0' file; do
unset variable
unset uncenlist
unset list

# uncen
uncenlist+=( "\[無修正化\]"  )
uncenlist+=( "\[無修正\]"  )
uncenlist+=( "無修正"  )
uncenlist+=( "\[无修正\]"  )
uncenlist+=( "\[汉化无修\]"  )
uncenlist+=( "\[無修正_重嵌\]"  )
uncenlist+=( "\[无修正中文\]"  )
uncenlist+=( "\[英版无修重嵌\]"  )
uncenlist+=( "\[無修化\]"  )
uncenlist+=( "\[無碼\]"  )
uncenlist+=( "\[无码\]"  )
uncenlist+=( "\[Decensored\]" )
command=''
exp=''
for mystr in "${uncenlist[@]}"; do 
   variable+="s/$mystr//; " 
done



# 包含以下字符的直接删除
list+=( "\[S版\]"  )
list+=( "\[無修正\]"  )
list+=( "\[无修正\]"  )
list+=( "bw版"  )
list+=( "\[中國語\]"  )
list+=( "（完全版）"  )
list+=( "个人整理汉化版"  )
list+=( "【个人整理】"  )
list+=( "\(成年コミック\)"  )
list+=( "\[Taka.Sub\]"  )
list+=( "\[GB\]"  )
list+=( "\[AVC-720P\]"  )
list+=( "\[無修正_重嵌\]"  )
list+=( "\[黑暗掃圖\]"  )
list+=( "\[无修正中文\]"  )
list+=( "\[原版\]"  )
list+=( "\[中文字幕\]"  )
list+=( "\[是小狐狸哦\]"  )
list+=( "\[改正\]"  )
list+=( "\[風的工房\]"  )
list+=( "【鬼畜王汉化组】"  )
list+=( "［中国翻訳］"  )
list+=( "\[4K漢化組\]"  )
list+=( "\[汉化组拼接版\]"  )
list+=( "\[無修\]"  )
list+=( "\[机翻\]"  )
list+=( "\[LKM渣嵌\]"  )
list+=( "\[全彩\]"  )
list+=( "\[步兵系村民渣嵌\]"  )
list+=( "\[中\]"  )
list+=( "\[chinese\]"  )
list+=( "\[中國翻譯\]"  )
list+=( "\[東方Project\]"  )
list+=( "\[無邪気無修宇宙分組\]"  )
list+=( "\[麻油鷄掃圖\]"  )
list+=( "\[DL版v2\]"  )
list+=( "\[皮皮个人重制\]"  )
list+=( "\[用爱发电个人重制版\]"  )
list+=( "\[不想記名高清重嵌版\]"  )
list+=( "\[未来数位中文\]"  )
# list+=( "Fatestaynight"  )
list+=( "\[DL版\]"  )
list+=( "\[黑条修正\]"  )
list+=( "\[单行本\]"  )
list+=( "\[單行本\]"  )
list+=( "\[d.art中文\]"  )
list+=( "デジタル特装版"  )
list+=( "\[洨五組\]"  )
list+=( "\[天鹅之恋\]"  )
list+=( "\[官方繁中\]"  )
list+=( "\[無碼\]"  )
list+=( "\[薄碼\]"  )
list+=( "\[無邪気漢化組中字\]"  )
list+=( "\[路過的騎士漢化組\*阿聰無修化\]"  )
list+=( "\[DL\]"  )
list+=( "\[中国翻訳\]" )
list+=( "［胸垫汉化组］" )
list+=( "\(单行本\)" )
list+=( "\[中国語\]" )
list+=( "\(PIXIV FANBOX\)" )
list+=( "\(中國語\)" )
list+=( "（Chinese）" )
list+=( "\(オリジナル\)" )
list+=( "\(WEEKLY快楽天_\d+\)" )
list+=( "\(同人誌\)" )
list+=( "\[Digital\]" )
list+=( "\[精修\]" )
list+=( "\[Chinese\]" )
list+=( "\[Decensored\]" )
list+=( "\(Complete\)" )
list+=( "\[English\]" )
list+=( "18禁アニメ"  )
list+=( "阿聰化"  )
list+=( "轟媽去黑格版"  )
list+=( "轟媽版"  )
list+=( "橄榄社翻译"  )
list+=( "\[水印\]"  )
list+=( "\[战栗的大白菜\]"  )
list+=( "\[督不进洞汉化组\]"  )
list+=( "\(siganos个人翻译）"  )
list+=( "\(東方Project\)"  )
list+=( "\(コミックホットミルク.*?号\)"  )
list+=( "\(コミックアンリアル.*?\)"  )
list+=( "\(ComicKairakutenBEAST.*?\)"  )
list+=( "\[漢化組.*?\]"  )
list+=( "\[漢化組.*?\]"  )
list+=( "\[d／art·\]"  )
list+=( "rongjx个人中文机翻润色"  )
list+=( "小衣ゆうき个人机翻润色"  )
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
variable+="s/①/_1/g;"
variable+="s/②/_2/g;"

# substrim，使用perl的 s///功能


variable+="s/ //g;"
variable+="s/ //g;"
variable+="s/　//g;"
variable+="s/!+//g;"
variable+="s/\|/_/g;"
variable+="s/\(\)//g;"
variable+="s/\[\]//g;"
variable+="s/【】//g;"
variable+="s/（）//g;"
variable+="s/\t+//g;"

variable+='s/\(C\d+\)//;'
variable+='s/\(ANGEL倶楽部.*?\)//;'
# variable+='s/\(例大祭\d+\)//;'
variable+='s/\[720P[^]]*?\]//;'
variable+='s/\[AVC-1080P\]//;'
variable+='s/\[MJK.*?\]//;'
variable+='s/\[(?:無)修正\]//;'
variable+='s/\((?:無)修正\)//;'
#variable+='s/～.*?～//;'
variable+='s/(-|～)*総集編(-|～)*//;'
variable+='s/\(COMIC.*?\)//;'
variable+='s/\(コミティア\d*?\)//;'
#variable+='s/(.*)\[.*?組\]\./$1\./;'
variable+='s/【.*?(漢|汉)化】//;'
variable+='s/【.*?翻(译|訳)】//;'
variable+='s/【.*?限定版】//;'
variable+='s/\[[^]]*?改圖\]//;'
variable+='s/\[[^]]*?嵌字\]//;'
variable+='s/\[[^]]*?翻(譯|译|訳)\]//;'
variable+='s/\[[^]]*?無修正化\]//;'
variable+='s/\[[^[]*?(漢|汉)化\]//;'
variable+='s/\([^[]*?(漢|汉)化\)//;'
variable+='s/\[[^[]*?(漢|汉)化(组|組)\]//;'
variable+='s/\([^[]*?(漢|汉)化(组|組)\)//;'
variable+='s/\[[^[]*?中文版\]//;'
variable+='s/\[[^[]*?中文\]//;'
variable+='s/\[[^[]*?個人掃本\]//;'
variable+='s/\[[^[]*?个人机翻\]//;'
variable+='s/\[[^[]*?日语社\]//;'
variable+='s/\[[^[]*?中国语\]//;'
variable+='s/\[[^[]*?掃圖組\]//;'
variable+='s/\[[^[]*?字幕组\]//;'
variable+='s/\[[^[]*?试看版\]//;'
variable+='s/\[[^[]*?重嵌\]//;'
variable+='s/\[[^[]*?無修正\]//;'
variable+='s/\[[^[]*?製作\]//;'
variable+='s/\[[^[]*?重制\]//;'
variable+='s/\[[^[]*?扫图组\]//;'
variable+='s/\[[^[]*?機翻\]//;'
variable+='s/\[[^[]*?如月工坊\]//;'
variable+='s/\[[^[]*?如月工房\]//;'
variable+='s/\[[^[]*?漢化整合版\]//;'
variable+='s/\[[^[]*?荻原沙优\]//;'
# variable+='s/「.*?」//;'
variable+='s/\&nbsp;//g;'
variable+='s/Vol.(\d)/_$1/g;'
# variable+='s/\(.*?\)(\.[^.]*?)$/$1/;'
# variable+='s/\[.*?\](\.[^.]*?)$/$1/;'
# variable+='s/【.*?】(\.[^.]*?)$/$1/;'

# # ～ 不要
# variable+='s/～[^\]]*?\././;'

# [fakename(realname)] -> [realname]
variable+='s/\[[^(]*?\((.*?)\)\]/\[$1\]/; '

command="perl-rename -n '$variable' " 


for mystr in "${uncenlist[@]}"; do 
    ls "$file" | grep -qs "$mystr" && variable+='s/(.\w+?)$/_uncen$1/;' && break
done

# eval "$command \"$file\"" >> "$changename_log"
if [ "$TESTMODE" == 0 ] ; then
    eval "perl-rename -n '$variable' \"$file\"" >> "$changename_log"
    eval "perl-rename -i '$variable' \"$file\""  
else
    eval "perl-rename -n '$variable' \"$file\""
fi

done

