#==============================================================
#
#  Abs:  Makefile to build EPICS RF Host components
#
#  Name: Makefile
#
#  Facility:  SLAC/PEP-II 
#
#  Auth: dd-mmm-yyyy, Stephanie Allison  (SAA)
#  Rev:  14-Mar-2000, Kristi Luchini     (LUCHINI)
#
#--------------------------------------------------------------
#  Mod:
#       03-Feb-2005, M. Laznovsky (LAZMO)
#         Ported to EPICS R3.14.6
#       14-Jan-2003, K. Luchini (LUCHINI):
#         Removed install of p2RfRfpDef_phaseoff.h.
#         This include file does not exist.
#       14-Mar-2000, K. Luchini (LUCHINI):
#         Add stanfard header
#         Add $(EPICS_SITE)/dbd to USER_DBDFLAGS
#
#==============================================================
#
TOP=../../..
include $(TOP)/configure/CONFIG

#----------------------------------------
#  ADD MACRO DEFINITIONS AFTER THIS LINE
#----------------------------------------

USR_INCLUDES += -I ../../db

LIBRARY_IOC_vxWorks = rfSeq
DBD                 = rfSeq.dbd

# Sequences
rfSeq_SRCS += rf_tuner_loop.st
rfSeq_SRCS += rf_hvps_loop.st
rfSeq_SRCS += rf_states.st
rfSeq_SRCS += rf_dac_loop.st
rfSeq_SRCS += rf_calib.st
rfSeq_SRCS += rf_msgs.st

#===========================

include $(TOP)/configure/RULES

#----------------------------------------
#  ADD RULES AFTER THIS LINE
#----------------------------------------
