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

/* File name: rf_hvps_loop_pvs.h */

int     station_state;
assign  station_state to "{STN}:STN:STATE:RBCK";
monitor station_state;

int     hvps_loop_ctrl;
assign  hvps_loop_ctrl to "{STN}:HVPS:LOOP:CTRL"; 
monitor hvps_loop_ctrl;

int     hvps_loop_state;
assign  hvps_loop_state  to "{STN}:HVPS:LOOP:STATE";

int     hvps_loop_status;
assign  hvps_loop_status to "{STN}:HVPS:LOOP:STATUS"; 

int     hvps_loop_delay;
assign  hvps_loop_delay to "{STN}:HVPS:LOOP:DELAY"; 

string  hvps_loop_status_c;
assign  hvps_loop_status_c to "{STN}:HVPS:LOOP:STRING";
  
int     hvps_loop_ready;
assign  hvps_loop_ready to "{STN}:HVPS:LOOP:READY";
monitor hvps_loop_ready;
evflag  hvps_loop_ready_ef;
sync    hvps_loop_ready hvps_loop_ready_ef;

int     rf_processor_severity;
assign  rf_processor_severity to "{STN}:STN:RFP:MODU.SEVR";
monitor rf_processor_severity;

int     direct_loop; 
assign  direct_loop to "{STN}:STN:RFP:MODU.DLE";
monitor direct_loop;

float   klystron_forward_power;
assign  klystron_forward_power to "{STN}:KLYSOUTFRWD:POWER";
monitor klystron_forward_power;

float   max_klystron_forward_power;
assign  max_klystron_forward_power to "{STN}:KLYSOUTFRWD:POWER:MAX";
monitor max_klystron_forward_power;

int     cavity_vacuum_sevr; 
assign  cavity_vacuum_sevr to "{STN}:CAVVACM:SUMY:SEVR.SEVR"; 
monitor cavity_vacuum_sevr;

int     cavity_vacuum_check; 
assign  cavity_vacuum_check to "{STN}:CAVVACM:CHECK"; 
monitor cavity_vacuum_check;

int     gap_voltage_sevr;
assign  gap_voltage_sevr to "{STN}:STN:VOLT.SEVR"; 
monitor gap_voltage_sevr;

int     gv_error_stat;
assign  gv_error_stat     to "{STN}:STN:VOLT:ERR.STAT";
monitor gv_error_stat;

int     dp_error_stat;
assign  dp_error_stat     to "{STN}:KLYSDRIVFRWD:POWER:ERR.STAT";
monitor dp_error_stat;

int     gap_voltage_check;
assign  gap_voltage_check to "{STN}:CAVVOLT:CHECK"; 
monitor gap_voltage_check;

float   requested_hvps_voltage;
assign  requested_hvps_voltage to "{STN}:HVPS:VOLT:CTRL";

float   readback_hvps_voltage;
assign  readback_hvps_voltage to "{STN}:HVPS:VOLT";
monitor readback_hvps_voltage;

float   history_hvps_voltage;
assign  history_hvps_voltage to "{STN}:HVPS:VOLT:LOOP";

int     reset_hvps_voltage_history;
assign  reset_hvps_voltage_history to "{STN}:HVPS:LOOP:VOLTHIST.RES";

float   allowed_hvps_voltage_diff;
assign  allowed_hvps_voltage_diff to "{STN}:HVPS:LOOP:VOLTDIFF";
monitor allowed_hvps_voltage_diff;

float   min_hvps_voltage;
assign  min_hvps_voltage to "{STN}:HVPS:VOLT:MIN"; 
monitor min_hvps_voltage;

float   max_hvps_voltage;
assign  max_hvps_voltage to "{STN}:HVPS:VOLT:CTRL.DRVH";
monitor max_hvps_voltage;

float   delta_proc_voltage_down;
assign  delta_proc_voltage_down to "{STN}:HVPS:LOOP:VOLTDOWN"; 
monitor delta_proc_voltage_down;

float   delta_proc_voltage_up;
assign  delta_proc_voltage_up to "{STN}:HVPS:LOOP:VOLTUP"; 
monitor delta_proc_voltage_up;

float   delta_on_voltage_severity;
assign  delta_on_voltage_severity to "{STN}:KLYSDRIVFRWD:HVPS:DELTA.SEVR";
monitor delta_on_voltage_severity;

float   delta_on_voltage;
assign  delta_on_voltage to "{STN}:KLYSDRIVFRWD:HVPS:DELTA";

float   delta_tune_voltage;
assign  delta_tune_voltage to "{STN}:STNVOLT:HVPS:DELTA";
