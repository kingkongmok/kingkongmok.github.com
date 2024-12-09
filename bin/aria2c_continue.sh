#!/bin/bash
# Resume a torrent from a .aria2 file
# Assumes download in same directory as the .aria2c file, overwrite with --dir=
# Credit: https://github.com/aria2/aria2/issues/792
url="magnet:?xt=urn:btih:$(xxd -p -seek 10 -l 20 "$1")"
cd "$(dirname "$1")" || exit 1
shift # Allow further aria2c command line options
exec screen -S magnet_continue aria2c --listen-port=6882 "$url" "$@"
