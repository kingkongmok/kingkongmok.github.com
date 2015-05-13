#!/bin/bash
 

#-------------------------------------------------------------------------------
# http://linuxaria.com/howto/linux-shell-introduction-to-flock
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Some explanation of the interesting parts of the code
#-------------------------------------------------------------------------------
set -e

#-------------------------------------------------------------------------------
# When this option is on, if a simple command fails for any of the reasons
# listed in Consequences of Shell Errors or returns an exit status value >0,
# and is not part of the compound list following a while, until, or if keyword,
# and is not a part of an AND or OR list, and is not a pipeline preceded by the
# ! reserved word, then the shell shall immediately exit.
#-------------------------------------------------------------------------------
lock="/tmp/`basename $0`.pid"
exec 200>$lock

#-------------------------------------------------------------------------------
# Normally “exec” in a shell script is used to turn over control of the
# script to some other program. But it can also be used to open a file and name
# a file handle for it. Normally, every script has standard input (file handle
# 0), standard output (file handle 1) and standard error (file handle 2) opened
# for it. The call “exec 200>$lock” will open the file named in $lock for
# reading, and assign it file handle 200
#-------------------------------------------------------------------------------
flock -n 200 || exit 1

#-------------------------------------------------------------------------------
# Tells flock to exclusively lock the file referenced by file handle 200 or
# exit with code 1. The state of being locked lasts after the flock call,
# because the file handle is still valid. That state will last until the file
# handle is closed, typically when the script exits.

# After that i collect in the variable $pid the PID of this process and I write
# it in the lock file, i sleep 60 seconds (to test what happen if the script is
# run a second time) and at the end I give my message to the world.
#-------------------------------------------------------------------------------
pid=$$
echo $pid 1>&200

#-------------------------------------------------------------------------------
# here my code, or the other codes.
#-------------------------------------------------------------------------------
sleep 60
echo "Hello world"
