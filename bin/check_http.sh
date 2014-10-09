#!/bin/bash - 
set -o nounset                              # Treat unset variables as an error

curl -sI $@ >/dev/null 2>&1 && echo OK || echo Warning: no response.

