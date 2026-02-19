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

/* File name: rf_dac_loop_defs.h */

/* 
 * Process at least every ten seconds no matter what 
 */
#define DAC_LOOP_MAX_INTERVAL     10.0
#define DAC_LOOP_MAX_COUNTS       2047
#define DAC_LOOP_MIN_DELTA_COUNTS 0.5

/* 
 * Definitions for DAC loop statuses - 
 * these MUST match pv {STN}:STNDAC:LOOP:STATUS 
 */
#define DAC_LOOP_STATUS_UNKNOWN     0
#define DAC_LOOP_STATUS_TUNE        1
#define DAC_LOOP_STATUS_ON          2
#define DAC_LOOP_STATUS_TUNE_OFF    3
#define DAC_LOOP_STATUS_ON_OFF      4
#define DAC_LOOP_STATUS_DRIV_BAD    5
#define DAC_LOOP_STATUS_GAPV_BAD    6
#define DAC_LOOP_STATUS_CTRL        7
#define DAC_LOOP_STATUS_STN_OFF     8
#define DAC_LOOP_STATUS_RFP_BAD     9
#define DAC_LOOP_STATUS_DAC_LIMT    10
#define DAC_LOOP_STATUS_GVF_BAD     11
#define DAC_LOOP_STATUS_DRIV_HIGH   12
#define DAC_LOOP_STATUS_DRIV_TOL    13
#define DAC_LOOP_STATUS_GAPV_TOL    14

#define DAC_LOOP_STATUS_UNKNOWN_C   "DAC loop has unknown status" 
#define DAC_LOOP_STATUS_TUNE_C      "Good - drive power control"
#define DAC_LOOP_STATUS_ON_C        "Good - stn gap voltage control"
#define DAC_LOOP_STATUS_TUNE_OFF_C  "Drive power control turned off" 
#define DAC_LOOP_STATUS_ON_OFF_C    "Stn gap voltage control turned off" 
#define DAC_LOOP_STATUS_DRIV_BAD_C  "Nonfunctional - drive power bad"
#define DAC_LOOP_STATUS_GAPV_BAD_C  "Nonfunctional - stn gap voltage bad"
#define DAC_LOOP_STATUS_CTRL_C      "Warning - DAC not at requested value"
#define DAC_LOOP_STATUS_STN_OFF_C   "Station is OFF, PARK, or ON_FM"
#define DAC_LOOP_STATUS_RFP_BAD_C   "Nonfunctional - RF processor bad"
#define DAC_LOOP_STATUS_DAC_LIMT_C  "Warning - DAC at limit"
#define DAC_LOOP_STATUS_GVF_BAD_C   "Nonfunctional - Gap module bad"
#define DAC_LOOP_STATUS_DRIV_HIGH_C "No gap volt increase - drive too high"
#define DAC_LOOP_STATUS_DRIV_TOL_C  "Drive power out of tolerance"
#define DAC_LOOP_STATUS_GAPV_TOL_C  "Stn gap voltage out of tolerance"


