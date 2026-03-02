#!/bin/sh

# EPICS sweep/record script. Used for various timing/adjustment tasks
#
# Copyright (c) 2008 Dimtel, Inc., All Rights Reserved
#
# $Id: sweep.sh,v 1.2 2010/10/05 18:16:54 dim Exp $
# $Date: 2010/10/05 18:16:54 $
# $Author: dim $
# $Revision: 1.2 $
# $Log: sweep.sh,v $
# Revision 1.2  2010/10/05 18:16:54  dim
# Initial cleanup
#
# Revision 1.3  2009/02/06 00:11:00  dim
# Script updates
#
# Revision 1.2  2008/09/25 21:02:58  dim
# Debug statements removed
#
# Revision 1.1  2008/09/25 20:59:21  dim
# Initial import
#
#

usage() {
  echo "Usage: $1 [-p] [-d delay] [-b N] CTRL MONITOR START STEP STOP"
  echo "  CTRL       - EPICS channel to sweep"
  echo "  MONITOR    - EPICS channel to record"
  echo "  START      - Start value for the sweep"
  echo "  STEP       - Increment step"
  echo "  STOP       - Stop value for the sweep"
  echo "  [-p]       - Plot option, uses octave to generate the sweep plot (sweep.eps)"
  echo "  [-d delay] - Set delay between steps (defaults to 2 seconds)"
  echo "  [-b N]     - Bunch number to monitor (defaults to 1)"
  
  exit 1
}

script=`basename $0`

# Option defaults
plot=0;
bunch=1;
delay=2;

# Get the options
while getopts d:b:p o; do
  case "$o" in
    p)    plot=1;;
    d)    delay="$OPTARG";;
    b)    bunch="$OPTARG";;
    [?])  usage ${script};;
  esac
done
let sft=${OPTIND}-1
shift ${sft}
 
if [ $# -ne 5 ]; then
  usage ${script}
fi
 
ctrl=$1
mon=$2
start=$3
step=$4
stop=$5

# Calibrate the monitoring - count the elements
count=`caget -t $mon | wc -w`
let element=$bunch+1

# Start the actual sweep
let k=${start}+${step}
caput ${ctrl} ${start} > /dev/null
k1=${start}
sleep ${delay}
cnt=1;
while [ $k -le ${stop} ]; do
  out=`caget -t ${mon}`
  if [ ${count} -eq 1 ]; then
    val[${cnt}]=${out}
  else
    val[${cnt}]=`echo ${out} | cut -d" " -f${element}`
  fi
  swp[${cnt}]=$k1

  # Progress
  echo -n "${cnt} "
  
  caput ${ctrl} $k > /dev/null
  sleep ${delay}

  # Incrementers
  k1=$k
  let k=$k+$step
  let cnt=${cnt}+1
done
out=`caget -t ${mon}`
if [ ${count} -eq 1 ]; then
  val[${cnt}]=${out}
else
  val[${cnt}]=`echo ${out} | cut -d" " -f${element}`
fi
swp[${cnt}]=$k1
echo "${cnt} Done"

# Temporary file
file=`mktemp /tmp/sweep.tmp.XXXXXXX`

# Put in octave script header
echo "swp=[" > ${file}

# Print out the results
k=1
while [ $k -le ${cnt} ]; do
  echo -e ${swp[$k]}\\t${val[$k]}
  echo ${swp[$k]} ${val[$k]} >> ${file}
  let k=$k+1
done
if [ ${plot} -eq 1 ]; then
  # Generate labels
  ctrl_label=`echo ${ctrl} | sed -e 's/_/\\\\_/g'`
  mon_label=`echo ${mon} | sed -e 's/_/\\\\_/g'`
  
  octave -v |grep 'version 3' >> /dev/null
  if [ $? -eq 0 ]; then
    cat >> ${file} <<EOF
];
plot(swp(:,1), swp(:,2), 'o-', 'markersize', 2);
xlabel('${ctrl_label}', 'fontsize', 16);
ylabel('${mon_label}', 'fontsize', 16);
print -depsc2 sweep.eps
EOF
  else
    cat >> ${file} <<EOF
];
gset term post eps enhanced solid color;
gset output 'sweep.eps';
gset xlabel '${ctrl}';
gset ylabel '${mon}';
plot(swp(:,1), swp(:,2));
EOF
  fi
  cat ${file} |octave -q
  echo "Plot saved in sweep.eps"
fi
rm ${file}
