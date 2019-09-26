#!/bin/sh

echo " Volume of directory $(pwd) is $(df -h "$(pwd)" | grep '^/dev' | cut -d' ' -f1)"
echo " Volume Serial Number is $(diskutil info /dev/disk0 | grep 'Device.*Media' |  sed 's/Device.*Media Name: *//' | xargs)" #TODO: Linux serial number

echo ""
echo " Directory of $(pwd)"
echo ""

fileSizeTotal=0

function printDir {
    for i in $@; do
        date=$(date -r "$i" "+%Y-%m-%d  %H:%M")

        if [[ -d $i ]]; then
            echo "$date    <DIR>           $i"
        elif [[ -f $i ]]; then
            if [ -r $i ]
            then
                size=$(perl -e 'print sprintf "% 19s\n", $_ for @ARGV' $(wc -c < "$i" |  awk '{ printf("%'"'"'d\n",$1); }'))
                fileSizeTotal=$((fileSizeTotal+$(wc -c < "$i")))
                echo "$date$size $i"
            else
                size=$(perl -e 'print sprintf "% 19s\n", $_ for @ARGV' N/A)
                echo "$date$size $i"
            fi
        fi
    done;
}

args=("$@")
files=0
free=0
folders=0

if [[ "$args" == "-a" ]]; then
    printDir $(ls -a)

    files=$(ls -la . | grep ^- | wc -l)
    free=$(df -h "$(pwd)" | grep '^/dev' | cut -d' ' -f8)
    folders=$(ls -la . | grep ^d | wc -l)
else
    echo "$(date -r "./" "+%Y-%m-%d  %H:%M")    <DIR>           ."
    echo "$(date -r "../" "+%Y-%m-%d  %H:%M")    <DIR>           .."

    printDir $(ls)

    files=$(ls -l . | grep ^- | wc -l)
    free=$(df -h "$(pwd)" | grep '^/dev' | cut -d' ' -f8)
    folders=$(ls -l . | grep ^d | wc -l)
fi

echo "        $files File(s) $(perl -e 'print sprintf "% 15s\n", $_ for @ARGV' $(echo "$fileSizeTotal" |  awk '{ printf("%'"'"'d\n",$1); }')) bytes"
free=${free%??}
free=$((free*1073741824))
echo "        $folders Dir(s) $(perl -e 'print sprintf "% 16s\n", $_ for @ARGV' $(echo "$free" |  awk '{ printf("%'"'"'d\n",$1); }')) bytes free"