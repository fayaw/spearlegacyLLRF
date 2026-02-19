/*                                Copyright 1997
**                                      by
**                         The Board of Trustees of the
**                       Leland Stanford Junior University.
**                              All rights reserved.
**
**
**         Work supported by the U.S. Department of Energy under contract
**                               DE-AC03-76SF00515.
**
**                               Disclaimer Notice
**
**        The items furnished herewith were developed under the sponsorship
**   of the U.S. Government.  Neither the U.S., nor the U.S. D.O.E., nor the
**   Leland Stanford Junior University, nor their employees, makes any war-
**   ranty, express or implied, or assumes any liability or responsibility
**   for accuracy, completeness or usefulness of any information, apparatus,
**   product or process disclosed, or represents that its use will not in-
**   fringe privately-owned rights.  Mention of any product, its manufactur-
**   er, or suppliers shall not, nor is it intended to, imply approval, dis-
**   approval, or fitness for any particular use.  The U.S. and the Univer-
**   sity at all times retain the right to use and disseminate the furnished
**   items for any purpose whatsoever.                       Notice 91 02 01
*/

/* File name: rf_hvps_loop_defs.h */

/* Process at least every ten seconds no matter what. */
#define HVPS_LOOP_MAX_INTERVAL  10.0 
/* Allow 10 voltage out-of-tolerance conditions to happen before changing status. */
#define HVPS_LOOP_MAX_VOLT_TOL  10 

/* Definitions for controlling the loop */
#define HVPS_LOOP_CONTROL_OFF     0
#define HVPS_LOOP_CONTROL_PROC    1 
#define HVPS_LOOP_CONTROL_ON      2

/* Definitions for HVPS loop states, these MUST match pv {STN}:HVPS:LOOP:STATE */
#define HVPS_LOOP_STATE_OFF        0
#define HVPS_LOOP_STATE_PROC       1
#define HVPS_LOOP_STATE_ON         2

#define HVPS_LOOP_STATE_OFF_NAME   "OFF"
#define HVPS_LOOP_STATE_PROC_NAME  "PROCESS"
#define HVPS_LOOP_STATE_ON_NAME    "ON"

/* Definitions for HVPS loop statuses, these MUST match pv {STN}:HVPS:LOOP:STATUS */
#define HVPS_LOOP_STATUS_UNKNOWN   0
#define HVPS_LOOP_STATUS_GOOD      1
#define HVPS_LOOP_STATUS_RFP_BAD   2
#define HVPS_LOOP_STATUS_CAVV_LIM  3
#define HVPS_LOOP_STATUS_OFF       4
#define HVPS_LOOP_STATUS_VACM_BAD  5
#define HVPS_LOOP_STATUS_POWR_BAD  6
#define HVPS_LOOP_STATUS_GAPV_BAD  7
#define HVPS_LOOP_STATUS_GAPV_TOL  8
#define HVPS_LOOP_STATUS_VOLT_LIM  9
#define HVPS_LOOP_STATUS_STN_OFF  10
#define HVPS_LOOP_STATUS_VOLT_TOL 11
#define HVPS_LOOP_STATUS_VOLT_BAD 12
#define HVPS_LOOP_STATUS_DRIV_BAD 13
#define HVPS_LOOP_STATUS_ON_FM    14
#define HVPS_LOOP_STATUS_DRIV_TOL 15

#define HVPS_LOOP_STATUS_UNKNOWN_C   "HVPS loop in unknown status." 
#define HVPS_LOOP_STATUS_GOOD_C      "HVPS loop reporting good status."
#define HVPS_LOOP_STATUS_RFP_BAD_C   "RF Processor bad."
#define HVPS_LOOP_STATUS_CAVV_LIM_C  "Cavity voltage above limit."
#define HVPS_LOOP_STATUS_OFF_C       "HVPS loop is off."
#define HVPS_LOOP_STATUS_VACM_BAD_C  "Bad vacuum."
#define HVPS_LOOP_STATUS_POWR_BAD_C  "Klystron forward power bad."
#define HVPS_LOOP_STATUS_GAPV_BAD_C  "Gap voltage bad."
#define HVPS_LOOP_STATUS_GAPV_TOL_C  "Gap voltage out of tolerance."
#define HVPS_LOOP_STATUS_VOLT_LIM_C  "HVPS loop at HVPS voltage limit."
#define HVPS_LOOP_STATUS_STN_OFF_C   "Station is OFF or PARKed."
#define HVPS_LOOP_STATUS_VOLT_TOL_C  "Readback voltage differs from Requested"
#define HVPS_LOOP_STATUS_VOLT_BAD_C  "Readback HVPS voltage invalid."
#define HVPS_LOOP_STATUS_DRIV_BAD_C  "Klystron Drive Power is bad."
#define HVPS_LOOP_STATUS_ON_FM_C     "Station in ON_FM mode."
#define HVPS_LOOP_STATUS_DRIV_TOL_C  "Klystron Drive Power out of tolerance."
#define HVPS_LOOP_STATUS_UNDEFINED_C "Undefined HVPS loop status."
