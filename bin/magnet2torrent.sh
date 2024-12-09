#!/bin/bash - 
#===============================================================================
#
#          FILE: magnet2torrent.sh
# 
#         USAGE: ./magnet2torrent.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Kenneth Mok (kk), kingkongmok AT gmail DOT com
#  ORGANIZATION: datlet.com
#       CREATED: 06/04/24 22:31
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error


# Check that the user entered a valid magnet link
if [ "$#" -ne 1 ] || [ ! -z "${1##*magnet*}" ]; then
    echo "Usage: $0 "
    exit 1
fi

# Extract the info hash from the magnet link
hash="${1##*btih:}"
hash="${hash%%&*}"

# Download the torrent file from a torrent website
torrent_file="${hash}.torrent"
proxychains wget "https://itorrents.org/torrent/${hash}.torrent" -O "$torrent_file"

echo "Torrent file written to ${torrent_file}"

