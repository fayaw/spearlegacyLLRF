#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 file"
  exit 1
fi

file=$1

# Find width and height
w=$(awk 'NR == 8' ${file}| cut -f2 -d" ")
h=$(awk 'NR == 9' ${file}| cut -f2 -d" ")
h_rect=$((h-30))

echo Width $w, height $h, rectangle height $h_rect

# Find out the proper insertion point
line=$(awk '/^endScreenProperties$/ { print NR+1;exit}' ${file})

tmp=$(mktemp)

head -n ${line} ${file} > ${tmp}

cat >> ${tmp} << EOT
# (Rectangle)
object activeRectangleClass
beginObjectProperties
major 4
minor 0
release 0
x 0
y 30
EOT
echo "w $w" >> ${tmp}
echo "h $h_rect" >> ${tmp}

cat >> ${tmp} << EOT2
lineColor index 83
fill
fillColor index 83
lineWidth 0
alarmPv "$\(sys\):PANEL:BG"
endObjectProperties
EOT2
tail -n +${line} ${file} >> ${tmp}
mv ${tmp} ${file}
