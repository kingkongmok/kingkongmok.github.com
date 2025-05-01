#!/bin/bash - 
#===============================================================================
#
#          FILE: tabInfo
# 
#         USAGE: ./tabInfo.sh string 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 11/11/24 15:55
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

# 定义支持的压缩文件扩展名列表
supported_extensions=("zip" "rar" "tar" "tgz" "tar.gz" "tar.bz2" "tar.xz" "tar.gpg")

# 获取传入的文件路径
full_path="$1"

# 检查是否提供了文件路径
if [ -z "$full_path" ]; then
  echo "请提供一个文件路径作为参数！"
  exit 1
fi

# 提取文件名（去掉路径）
file_with_ext=$(basename "$full_path")

# 初始化基本文件名变量
base_filename="$file_with_ext"

# 遍历支持的扩展名列表
for ext in "${supported_extensions[@]}"; do
  # 检查文件名是否以指定的扩展名结尾
  if [[ "$file_with_ext" == *".$ext" ]]; then
    # 移除扩展名
    base_filename="${file_with_ext%.$ext}"
    # 对于 .tar.gz 类型的扩展名，需要额外处理
    if [[ "$ext" == "tar.gz" || "$ext" == "tgz" ]]; then
      base_filename="${base_filename%.tar}"
    fi
    break
  fi
done



# 使用 Bash 的字符串操作来获取下划线前的部分
if [[ $base_filename =~ ^[0-9]+_ ]]; then
    # 使用参数扩展移除最短匹配的前缀（即数字和紧随其后的下划线）
    base_filename=${base_filename#*_}
fi
front_part=${base_filename%%_*}

# 输出结果
echo "searching: $front_part"


CURL_HEADER="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36"
CURL="/usr/bin/curl -q -k --socks5-hostname localhost:7073"

# 定义要转换的中文字符串
chinese_string="$front_part"

# 使用 printf 将字符串转换为 URL 编码
encoded_string=$(printf "%s" "$chinese_string" | xxd -p -c256 | tr -d '\n' | sed 's/\(..\)/%\1/g')


sitename=`cat ~/Dropbox/pan/e_site`

URI="http://${sitename}/?f_search="


#$CURL -H "$CURL_HEADER" -q "${URI}${encoded_string}" | perl -nE 'while(/<div class="gt" title="(.*?)">/gsm ){ if ($1 !~ /language:.*/) {$H{$1}++}} }{ for (sort {$H{$a}<=>$H{$b}} keys %H){print "$H{$_}\t$_\t"; if(/:(.*)/){s/.*://; s/\s+/_/g; say "_$_"}}'
$CURL -H "$CURL_HEADER" -q "${URI}${encoded_string}" | perl -nE 'while(/<div class="gt" title="(.*?)">/gsm ){ if ($1 !~ /language:.*/) {$H{$1}++}} }{ for (sort {$H{$a}<=>$H{$b}} keys %H){print "$H{$_}\t$_\t"; if(/:(.*)/){s/.*://; s/\s+/_/g; s/netorare/ntr/; s/schoolgirl_uniform/jk/; s/gyaru-oh/bss/ ; s/gyaru/gal/; s/dark_skin/dark/; s/sole_female/sole/;  say "_$_"}}'
