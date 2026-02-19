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

/* File name: rf_dac_loop_pvs.h */

int     station_state;
assign  station_state     to "{STN}:STN:STATE:RBCK";
monitor station_state;

int     loop_tune_ctrl;
assign  loop_tune_ctrl    to "{STN}:STN:TUNE:CTRL"; 
monitor loop_tune_ctrl;

int     loop_on_ctrl;
assign  loop_on_ctrl      to "{STN}:STN:ON:CTRL"; 
monitor loop_on_ctrl;

int     loop_ready;
assign  loop_ready     to "{STN}:STNDAC:LOOP:READY"; 
monitor loop_ready;
evflag  loop_ready_ef;
sync    loop_ready loop_ready_ef;


int     loop_delay;
assign  loop_delay to "{STN}:HVPS:LOOP:DELAY"; 

int     ripple_loop_ready;
assign  ripple_loop_ready to "{STN}:STNRIPPLE:LOOP:READY"; 
monitor ripple_loop_ready;
evflag  ripple_loop_ready_ef;
sync    ripple_loop_ready ripple_loop_ready_ef;

int     loop_status;
assign  loop_status       to "{STN}:STNDAC:LOOP:STATUS"; 

string  loop_status_c;
assign  loop_status_c     to "{STN}:STNDAC:LOOP:STRING";
  
float   phase;
assign  phase             to "{STN}:STN:PHASE:CALC";
monitor phase;
evflag  phase_ef;
sync    phase phase_ef;

float   ripple_loop_ampl;
assign  ripple_loop_ampl  to "{STN}:STNRIPPLE:LOOP:AMPL";
monitor ripple_loop_ampl;
evflag  ripple_loop_ampl_ef;
sync    ripple_loop_ampl ripple_loop_ampl_ef;

evflag  rfp_dac_ef;

float   direct_loop_phase;
assign  direct_loop_phase to "{STN}:STNDIRECT:LOOP:PHASE";
monitor direct_loop_phase;
sync    direct_loop_phase rfp_dac_ef;

float   comb_loop_phase;
assign  comb_loop_phase   to "{STN}:STNCOMB:LOOP:PHASE";
monitor comb_loop_phase;
sync    comb_loop_phase   rfp_dac_ef;

float   direct_loop_ampl;
assign  direct_loop_ampl  to "{STN}:STNDIRECT:LOOP:COUNTS";
monitor direct_loop_ampl;
sync    direct_loop_ampl  rfp_dac_ef;

float   comb_loop_ampl;
assign  comb_loop_ampl    to "{STN}:STNCOMB:LOOP:COUNTS";
monitor comb_loop_ampl;
sync    comb_loop_ampl    rfp_dac_ef;

int     rf_processor_sevr;
assign  rf_processor_sevr to "{STN}:STN:RFP:MODU.SEVR";
monitor rf_processor_sevr;

int     gvf_module_sevr;
assign  gvf_module_sevr   to "{STN}:STN:GVF:MODU.SEVR";
monitor gvf_module_sevr;

int     gv_error_stat;
assign  gv_error_stat     to "{STN}:STN:VOLT:ERR.STAT";
monitor gv_error_stat;

int     dp_error_stat;
assign  dp_error_stat     to "{STN}:KLYSDRIVFRWD:POWER:ERR.STAT";
monitor dp_error_stat;

int     direct_loop; 
assign  direct_loop       to "{STN}:STN:RFP:MODU.DLE";
monitor direct_loop;

float   tune_counts;
assign  tune_counts       to "{STN}:STN:TUNE:IQ.A";

float   on_counts;
assign  on_counts         to "{STN}:STN:ON:IQ.A";

float   gff_counts;
assign  gff_counts        to "{STN}:STN:GFF:IQ.A";

int     tune_proc_counts;
assign  tune_proc_counts  to "{STN}:STN:TUNE:IQ.PROC";

int     on_proc_counts;
assign  on_proc_counts    to "{STN}:STN:ON:IQ.PROC";

int     gff_proc_counts;
assign  gff_proc_counts   to "{STN}:STN:GFF:IQ.PROC";

int     rfp_dac_proc;
assign  rfp_dac_proc      to "{STN}:STNDIRECT:LOOP:IQ.PROC";

int     ripple_loop_load;
assign  ripple_loop_load  to "{STN}:STNRIPPLE:LOOP:LOAD.PROC";

float   tune_delta_counts;
assign  tune_delta_counts to "{STN}:KLYSDRIVFRWD:DAC:DELTA";

float   on_rfp_delta_counts;
assign  on_rfp_delta_counts to "{STN}:KLYSDRIVFRWD:ODAC:DELTA";

float   on_gff_delta_counts;
assign  on_gff_delta_counts to "{STN}:KLYSDRIVFRWD:GFF:DELTA";

float   on_delta_counts;
assign  on_delta_counts   to "{STN}:STNVOLT:DAC:DELTA";

float   gff_delta_counts;
assign  gff_delta_counts  to "{STN}:STNVOLT:GFF:DELTA";

int     hist_proc;
assign  hist_proc         to "{STN}:STN:VOLT:HIST.PROC";


