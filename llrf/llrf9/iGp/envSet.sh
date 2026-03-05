#!/bin/sh -f

# This script initializes all the environment variables to run
# the softIOC and the EDM
#
# Copyright (c) 2006 Dimtel, Inc., All Rights Reserved
#
# $Id: envSet.sh,v 1.6 2016/08/22 22:38:58 dim Exp $
# $Date: 2016/08/22 22:38:58 $
# $Author: dim $
# $Revision: 1.6 $
# $Log: envSet.sh,v $
# Revision 1.6  2016/08/22 22:38:58  dim
# Integrated LLRF panels and matlab tools
#
# Revision 1.5  2015/02/13 10:15:46  dim
# Added support for 32 and 64 bit machines
#
# Revision 1.4  2011/10/20 17:00:22  dim
# Significantly increased maximum array size, version bumps
#
# Revision 1.3  2010/11/07 22:43:36  dim
# Small fixes from CentOS 5.5 install (caRepeater restart, LD_LIBRARY_PATH)
#
# Revision 1.2  2010/10/05 18:16:54  dim
# Initial cleanup
#
# Revision 1.6  2009/02/06 00:11:00  dim
# Script updates
#
# Revision 1.5  2007/12/30 15:29:01  dim
# Script updates for Fedora 8 client software, configuration for IOC
# installations on different motherboards (boot device, network driver)
#
# Revision 1.4  2007/03/14 08:36:13  dim
# Extensive installation script updates
#
# Revision 1.3  2006/12/11 09:29:15  dim
# Installation process cleanup, EDM config updates
#
# Revision 1.2  2006/12/07 05:41:25  dim
# Updates for more robust installation
#
# Revision 1.1  2006/12/07 00:01:17  dim
# Distribution scripts - initial import
#
#

# Service functions
strstr() {
  [ "${1#*$2*}" = "$1" ] && return 1
  return 0
}
strnstr() {
  [ "${1#*$2*}" = "$1" ] && return 0
  return 1
}

if [ -n "${IGPTOP}" ]; then
  # Don't run twice, but set LD_LIBRARY_PATH !!!
  if [ -z "$LD_LIBRARY_PATH" ]; then
    export LD_LIBRARY_PATH=${EPICS_LIB}
  elif strnstr "$LD_LIBRARY_PATH" "$EPICS_LIB" ; then
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${EPICS_LIB}
  fi

  return 0
fi

# Figure out install directory
dir1=`pwd`
dir2=`dirname $BASH_ARGV`
if [ ${dir2:0:1} == "/" ]; then
  export IGPTOP=${dir2}
else
  export IGPTOP=${dir1}/${dir2}
fi
IGPTOP=`(cd $IGPTOP; pwd)`

case $(arch) in
  i386)   HOST_ARCH=linux-x86;;
  i686)   HOST_ARCH=linux-x86;;
  x86_64) HOST_ARCH=linux-x86_64;;
esac
export HOST_ARCH
export EPICS_HOST_ARCH=${HOST_ARCH}

# IOC and EDM communication config
export EPICS_CA_ADDR_LIST
export EPICS_CA_SERVER_PORT=5064
export EPICS_CA_REPEATER_PORT=5065
export EPICS_CA_MAX_ARRAY_BYTES=26000000
export EPICS_TS_MIN_WEST=480

# EDM files
export EDMPVOBJECTS=${IGPTOP}/extensions/edm/pref
export EDMOBJECTS=${IGPTOP}/extensions/edm/pref
export EDMFILES=${IGPTOP}/extensions/edm/pref
export EDMHELPFILES=${IGPTOP}/extensions/edm/help

# MATLABPATH interfacing
IGPMLP=${IGPTOP}/extensions/labca/${HOST_ARCH}:${IGPTOP}/matlab/iGp:${IGPTOP}/matlab/llrf
if [ -z "$MATLABPATH" ]; then
  export MATLABPATH=${IGPMLP}
else
  export MATLABPATH=$MATLABPATH:${IGPMLP}
fi

export EPICS_LIB=${IGPTOP}/base/lib/${HOST_ARCH}:${IGPTOP}/extensions/lib/${HOST_ARCH}
if [ -z "$LD_LIBRARY_PATH" ]; then
  export LD_LIBRARY_PATH=${EPICS_LIB}
elif strnstr "$LD_LIBRARY_PATH" "$EPICS_LIB" ; then
  LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${EPICS_LIB}
fi

if strnstr "$PATH" "${IGPTOP}/bin"; then
  PATH=${IGPTOP}/bin:${IGPTOP}/bin/${HOST_ARCH}:${PATH}
fi

if [ -f ${IGPTOP}/config/epics_addr_list ]; then
  EPICS_CA_ADDR_LIST=`cat ${IGPTOP}/config/epics_addr_list`
fi

id=`pgrep caRepeater`
if [ $? -eq 0 ]; then
  kill -9 ${id}
fi
${IGPTOP}/bin/${HOST_ARCH}/caRepeater &
