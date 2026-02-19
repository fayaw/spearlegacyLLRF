/*                                Copyright 1996
**                                      by
**                         The Board of Trustees of the
**                       Leland Stanford Junior University.
**                              All rights reserved.
**
**
**         Work supported by the U.S. Department of Energy under contract
**       DE-AC03-76SF00515.
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
/*=============================================================================

  Abs:  Drive Power and Gap Voltage RFP/GFF DAC Loop Sequence

  Name: rf_dac_loop.st
         States:
	   loop_init    - initialization
           loop_off     - station in off, park, or on_fm 
           loop_tune    - station in tune  - adjust for drive power 
           loop_on      - station in on_cw - adjust for drive power if
                          direct loop off, gap voltage if direct loop on

  Rem:  The DAC loop adjusts the amplitude (in counts) in the calculation
        of either the tuner mode setpoint or difference node offset RFP DAC 
        values or the gap feed-forward reference values. It adjusts the 
	previous count value by a delta value calculated
        based on error.  If either the tune or on_cw update is turned off,
        it updates the setpoints whenever there is a change to phase.   

  Auth: 29-May-1997, Stephanie Allison
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name)

-------------------------------------------------------------------------------

  Mod:  

=============================================================================*/

program rf_dac_loop("STN=RRRS,name=DACLOOP")

option -a;  /* All pvGets must be synchronous                          */
option +c;  /* All connections must be made before begin execution     */


%%#include <string.h>           /* str* prototypes                */
%%#include <taskLib.h>          /* VxWorks taskDelay prototype    */
%%#include <alarm.h>            /* MAJOR_ALARM, INVALID_ALARM     */
%%#include <epicsPrint.h>       /* epicsPrintf prototype          */
#include "rf_loop_defs.h"       /* defines for all sequence loops */
#include "rf_loop_macs.h"       /* macros  for all sequence loops */
#include "rf_dac_loop_defs.h"   /* defines for the DAC      loop  */
#include "rf_dac_loop_macs.h"   /* macros  for the dac loop       */
#include "rf_dac_loop_pvs.h"    /* DAC loop process variables     */

int     get_status;
int     prev_loop_status;
int     prev_tune_ctrl;
int     prev_on_ctrl;
int     prev_gff_ctrl;
int     prev_direct_loop;
float   prev_tune_counts;
float   prev_on_counts;
float   prev_gff_counts;
float   count_diff;
char   *loop_name_c;

ss  rf_dac_loop
{
   /*
    *************** INITIALIZATION
    * Set initial values and clear all event flag.  Set values of
    * things that are not monitored and will never be overwritten. 
    */ 
   state  loop_init
   {
      when ()
      {
        loop_name_c = macValueGet(MACRO_TASK_NAME);
	tune_proc_counts = 0;
        on_proc_counts   = 0;
        gff_proc_counts  = 0;
        rfp_dac_proc     = 0;
        hist_proc        = 0;
        DAC_LOOP_CHANGE();
        DAC_LOOP_OFF();

      } state loop_off
   }
   /*

    *************** STATION OFF
    * Don't do anything except wait for the station state to change or
    * for users to update the direct or comb loop phase or amplitude.
    */
   state loop_off
   {
      when (station_state == STATION_TUNE)
      {
	DAC_LOOP_CHANGE();

      } state loop_tune

      when (station_state == STATION_ON_CW)
      {
        pvGet(loop_delay);
        taskDelay(loop_delay*60); /* Delay in case fast turnon */
	DAC_LOOP_CHANGE();

      } state loop_on

      /* 
       * Force update of all RFP DAC setpoints if the direct or comb loop 
       * phase or amplitude have changed.   
       */
      when (efTestAndClear(rfp_dac_ef))
      {
	pvPut(rfp_dac_proc);

      } state loop_off
      /* 
       * Load the ripple loop amplitude setpoint if it's changed. 
       */
      when (efTestAndClear(ripple_loop_ampl_ef))
      {
	if (!(LOOP_INVALID_SEVERITY(pvSeverity(ripple_loop_ampl)))) 
	   pvPut(ripple_loop_load);

      } state loop_off
   }
   /*

    *************** STATION TUNE 
    * Adjust drive power using RFP module tune mode octal dacs.
    * Gap voltage adjustment done with HVPS.
    */
   state loop_tune
   {
      when (station_state == STATION_ON_CW)
      {
	DAC_LOOP_CHANGE();

      } state loop_on

      when (station_state != STATION_TUNE)
      {
	DAC_LOOP_OFF();

      } state loop_off

      when (efTestAndClear(loop_ready_ef) || delay(DAC_LOOP_MAX_INTERVAL))
      {
	/* 
         * Force update of all RFP DAC setpoints if the direct or comb loop 
         * phase or amplitude have changed.   
         */
	if (efTestAndClear(rfp_dac_ef)) efSet(phase_ef);
	DAC_LOOP_SET(tune_counts, tune_delta_counts, 
		     pvSeverity(dp_error_stat), 0, 0, prev_tune_counts, 
		     tune_proc_counts, loop_tune_ctrl, prev_tune_ctrl,
                     DAC_LOOP_STATUS_TUNE, DAC_LOOP_STATUS_TUNE_OFF,
                     DAC_LOOP_STATUS_DRIV_TOL, DAC_LOOP_STATUS_DRIV_BAD);
        DAC_LOOP_CHECK_STATUS();
        /* 
         * Load the ripple loop amplitude setpoint if it's changed and
         * not invalid.  Ripple loop gain tracking is done at a slower
         * rate than other updates so check if we're ready first. 
         */
	if (efTestAndClear(ripple_loop_ready_ef))
	{
          if (efTestAndClear(ripple_loop_ampl_ef) &&
	      (!(LOOP_INVALID_SEVERITY(pvSeverity(ripple_loop_ampl))))) 
	     pvPut(ripple_loop_load);
	}
      } state loop_tune
   }
   /*

    *************** STATION ON_CW 
    * If direct loop is off, adjust drive power using the gap module
    * feed forward reference values.  Gap voltage adjustment done with HVPS.
    * If direct loop is on but the gap module is not available, adjust
    * gap voltage using RFP module difference node octal DACs.
    * If direct loop is on and the gap module is available, adjust
    * gap voltage using the gap voltage feed forward reference values.
    */
   state loop_on
   {
      when (station_state == STATION_TUNE)
      {
	DAC_LOOP_CHANGE();

      } state loop_tune

      when (station_state != STATION_ON_CW)
      {
        DAC_LOOP_OFF();
      
      } state loop_off

      when (efTestAndClear(loop_ready_ef) || delay(DAC_LOOP_MAX_INTERVAL))
      {
	/*
         * Force update of all RFP DAC setpoints if the direct or comb loop 
         * phase or amplitude have changed.   
         */
	if (efTestAndClear(rfp_dac_ef)) efSet(phase_ef);
	if (direct_loop == LOOP_CONTROL_OFF)
	{
	  if (LOOP_INVALID_SEVERITY(pvSeverity(gvf_module_sevr)))
	  {
	    prev_gff_ctrl = LOOP_CONTROL_OFF;
	    DAC_LOOP_SET(on_counts, on_rfp_delta_counts,
		         pvSeverity(dp_error_stat), 0, 0, prev_on_counts,
		         on_proc_counts, loop_on_ctrl, prev_on_ctrl,
                         DAC_LOOP_STATUS_ON, DAC_LOOP_STATUS_ON_OFF,
                         DAC_LOOP_STATUS_DRIV_TOL, DAC_LOOP_STATUS_DRIV_BAD);
	  }
	  else
	  {
	    prev_on_ctrl = LOOP_CONTROL_OFF;
	    DAC_LOOP_SET(gff_counts, on_gff_delta_counts, 
			 pvSeverity(dp_error_stat), 0, 0, prev_gff_counts,
		         gff_proc_counts, loop_on_ctrl, prev_gff_ctrl,
                         DAC_LOOP_STATUS_ON, DAC_LOOP_STATUS_ON_OFF,
                         DAC_LOOP_STATUS_DRIV_TOL, DAC_LOOP_STATUS_DRIV_BAD);
	  }
	}
	else if (LOOP_INVALID_SEVERITY(pvSeverity(gvf_module_sevr)))
	{
	  /*
	   * Make sure DAC-being-control-by-others message is not logged
           * in the future for GFF or if the direct loop just turned ON
	   * in which case the RF state sequence has set the DAC to an
	   * initial value.
	   */
	  prev_gff_ctrl = LOOP_CONTROL_OFF;
	  if (prev_direct_loop != direct_loop) prev_on_ctrl = LOOP_CONTROL_OFF;
	  DAC_LOOP_SET(on_counts, on_delta_counts, pvSeverity(gv_error_stat),
                       dp_error_stat, pvSeverity(dp_error_stat), prev_on_counts,
		       on_proc_counts, loop_on_ctrl, prev_on_ctrl,
                       DAC_LOOP_STATUS_ON, DAC_LOOP_STATUS_ON_OFF,
                       DAC_LOOP_STATUS_GAPV_TOL, DAC_LOOP_STATUS_GAPV_BAD);
	}
	else
	{
	  /*
	   * Make sure DAC-being-control-by-others message is not logged
           * in the future for RFP or if the direct loop just turned ON
	   * in which case the RF state sequence has set the DAC to an
	   * initial value.
	   */
	  prev_on_ctrl = LOOP_CONTROL_OFF;
	  if (prev_direct_loop != direct_loop) prev_gff_ctrl = LOOP_CONTROL_OFF;
	  DAC_LOOP_SET(gff_counts, gff_delta_counts, pvSeverity(gv_error_stat),
                       dp_error_stat, pvSeverity(dp_error_stat), prev_gff_counts,
		       gff_proc_counts, loop_on_ctrl, prev_gff_ctrl,
                       DAC_LOOP_STATUS_ON, DAC_LOOP_STATUS_ON_OFF,
                       DAC_LOOP_STATUS_GAPV_TOL, DAC_LOOP_STATUS_GAPV_BAD);
	}
        DAC_LOOP_CHECK_STATUS();
	prev_direct_loop = direct_loop;
        /* 
         * Load the ripple loop amplitude setpoint if it's changed and
         * not invalid.  Ripple loop gain tracking is done at a slower
         * rate than other updates so check if we're ready first. 
         */
	if (efTestAndClear(ripple_loop_ready_ef))
	{
          if (efTestAndClear(ripple_loop_ampl_ef) &&
	      (!(LOOP_INVALID_SEVERITY(pvSeverity(ripple_loop_ampl))))) 
	     pvPut(ripple_loop_load);
	}
      } state loop_on
   }
}
exit {}
