#!/usr/bin/env bash

export IFS=$'\n'
jar="yuicompressor-2.4.7.jar"
jar="`dirname $0`/$jar"
# echo "jar: $jar"
export CLASSPATH=.:$jar
# echo "CLASSPATH: $CLASSPATH"

echo YUI Compressor

file="$1"
# echo "file: $file"
filetype="$(echo $file | egrep -o '(cs|j)s')"
# echo "filetype: $filetype"
if [[ $filetype != 'js' && $filetype != 'css' ]]; then
	exit 0
fi
target=`echo $1 | sed "s/\(\.*\)\(\.[css|js]\)/\1.min\2/"`
# echo "target: $target"

basename=`basename $file .$filetype` #$basename.min.$filetype
compressed=$basename.min.$filetype
# echo ${file##*.}
# echo ${file%.*}
# echo ${file%/*}

# result="$(java -jar $jar --type $filetype $file)"
result=$(java -jar $jar --type $filetype --charset GB18030 -o $compressed $file 2>&1)

result="$(echo "$result"|sed -e "s#^[org|	at].*##g")"
echo "${result//] /] $file }"
# sed -i "s/$1/$2/g"
# echo "$result"|sed -e "s#] #] $file #g"

if [[ -e $target ]]; then
    from_size=`stat -f %z $file`
    to_size=`stat -f %z $target`
    echo "Compressed $file -> $compressed($from_size bytes -> $to_size bytes)."
# else
#     echo "Compress faild";
fi
