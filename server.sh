#!/bin/sh
# Very simple wrapper for Python web server, with inotify

PORT=8088
PID=0
INOT=`which inotifywait`

handler()
{
    echo
    echo "Exiting ..."
    kill -INT $PID
}

FILES=$*
if [ -z "$FILES" ]; then
    FILES=`find . -name '*.md'`
fi

trap handler 2

python3 -m http.server $PORT &
PID=$!

if [ -n "$INOT" ]; then
    echo "Watching $FILES ..."
    $INOT -e CLOSE_WRITE -mqr $FILES 2>/dev/null | while read line; do
	echo "Got: $line"
	make
    done
    kill $!
else
    wait $!
fi

