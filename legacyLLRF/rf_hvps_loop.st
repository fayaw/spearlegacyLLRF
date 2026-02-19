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
/*=============================================================================

  Abs:  Sequence to control the RF High Voltage Power Supply (HVPS)

  Name: rf_hvps_loop.st

  Rem:  The HVPS supplies voltage to a klystron which supplies power to the   
        pepii RF cavilies.  When the HVPS sequence is turned on it's two main 
        functions are to (1.) "process" the cavity - adjust the voltage supplied
        to the klystron while the vacuum system removes and foreign particles 
        from the inside of the rf cavity; and (2.) keep the klystron drive
        power or station gap voltage as steady as possible.

  State(s):
        init   Puts the HVPS sequence in the proper state when an IOC is booted.

        off    The RF station is turned off or park.

        proc   Every cycle, usually every 0.5 second, raise or lower the HVPS
               voltage depending on the state of the klystron power, cavity
               vacuums, and the cavity gap voltage.

        on     Every cycle, usually every 0.5 second, check to see if the HVPS
               voltage needs to be adjusted to keep the klystron drive power
               or station gap voltage constant.

  Auth: 03-Feb-1997, Mike Zelazny
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name)

-------------------------------------------------------------------------------

  Mod: 
        19-May-1999, Robert C. Sass (RCS)
          Delay by hvps_loop_delay before turning loop on to accommodate
          the fast turnon sequence. 
        23-Oct-1997, Stephanie Allison
	  Add tolerance status update.  Other cleanup.
	08-Apr-1997, Stephanie Allison
	  Don't do anything when ON and not ON_CW.
        01-Apr-1997, Stephanie Allison
	  Change check for bad vacuum and gap voltage.  

=============================================================================*/

program rf_hvps_loop ("name=HVPSLOOP")

option -a;  /* All pvGets must be synchronous                          */
option +c;  /* All connections must be made before begin execution     */

int     prev_hvps_loop_status;
int     volt_tol_count;
int     cavv_lim_count;
float   prev_requested_hvps_voltage;
float   delta_hvps_voltage;
char   *sequence_name_c;

%%#include <string.h>
%%#include <math.h>
%%#include <alarm.h>
%%#include <taskLib.h>          /* VxWorks taskDelay            */
%%#include <epicsPrint.h>
#include "rf_loop_defs.h"
#include "rf_loop_macs.h"
#include "rf_hvps_loop_pvs.h"
#include "rf_hvps_loop_defs.h"
#include "rf_hvps_loop_macs.h"

ss  rf_hvps_loop
{
   /*
    *************** INITIALIZATION
    */ 
   state init
   {
      when ()
      {
         /* Get sequence name */
         sequence_name_c = macValueGet(MACRO_TASK_NAME);

         /* Set the requested hvps voltage to whatever the readback currently
            indicates. */ 
         prev_requested_hvps_voltage = readback_hvps_voltage;
         requested_hvps_voltage = prev_requested_hvps_voltage;
         pvPut(requested_hvps_voltage);

         /* Update the HVPS loop status */ 
         sprintf (hvps_loop_status_c, HVPS_LOOP_STATUS_STN_OFF_C); 
         hvps_loop_status = HVPS_LOOP_STATUS_STN_OFF;
         prev_hvps_loop_status = hvps_loop_status;
         pvPut(hvps_loop_status);
         pvPut(hvps_loop_status_c);

         /* Update the HVPS loop state */ 
         hvps_loop_state = HVPS_LOOP_STATE_OFF;
         pvPut(hvps_loop_state);

         /* Clear our loop ready event flag because a monitor always goes off
            when you first set it. */
         efClear(hvps_loop_ready_ef);

      } state off

   } /* INITIALIZATION */

   /*
    *************** HVPS PROCESS
    */
   state proc
   {
      when ((station_state == STATION_OFF) || (station_state == STATION_PARK))
      {
         hvps_loop_state = HVPS_LOOP_STATE_OFF;
         pvPut(hvps_loop_state);
         hvps_loop_status = HVPS_LOOP_STATUS_STN_OFF;
         HVPS_LOOP_CHECK_STATUS();

      } state off

      when (hvps_loop_ctrl != HVPS_LOOP_CONTROL_PROC)
      {
         hvps_loop_state = HVPS_LOOP_STATE_ON;
         pvPut(hvps_loop_state);
         pvGet(hvps_loop_delay);
         taskDelay(hvps_loop_delay*60); /* Delay in case fast turnon */
         prev_requested_hvps_voltage = readback_hvps_voltage;

      } state on

      when (efTestAndClear(hvps_loop_ready_ef) || delay(HVPS_LOOP_MAX_INTERVAL))
      {
         /* Is the RFP module plugged in? */
         if (LOOP_INVALID_SEVERITY(pvSeverity(rf_processor_severity)))
            hvps_loop_status = HVPS_LOOP_STATUS_RFP_BAD; 

         /* Is the Klystron Forward Power OK? */
         else if (LOOP_INVALID_SEVERITY(pvSeverity(klystron_forward_power)))
            hvps_loop_status = HVPS_LOOP_STATUS_POWR_BAD; 

         /* Is the cavity gap voltage OK? */
         else if (LOOP_INVALID_SEVERITY(pvSeverity(gap_voltage_sevr)))
            hvps_loop_status = HVPS_LOOP_STATUS_GAPV_BAD;

         /* Are the cavity vacuums OK? */
         else if (LOOP_INVALID_SEVERITY(pvSeverity(cavity_vacuum_sevr)))
            hvps_loop_status = HVPS_LOOP_STATUS_VACM_BAD;

         /* Is the hvps voltage reading out? */
         else if (LOOP_INVALID_SEVERITY(pvSeverity(readback_hvps_voltage)))
            hvps_loop_status = HVPS_LOOP_STATUS_VOLT_BAD;

         else /* All modules are plugged in and working and everything is reading out */
         {
            /* Look for reasons to decrease voltage. */
            if ((klystron_forward_power > max_klystron_forward_power) ||  /* Klystron Forward Power above setpoint */
	        (LOOP_MAJOR_SEVERITY(pvSeverity(gap_voltage_check)))  ||  /* cavity gap voltage above setpoint */
                (LOOP_MAJOR_SEVERITY(pvSeverity(cavity_vacuum_check))))   /* worst cavity vacuum is too high */
            {
               delta_hvps_voltage = delta_proc_voltage_down;

            } /* decrease HVPS voltage */

            else  /* All is OK - increase voltage */
            {
	       delta_hvps_voltage = delta_proc_voltage_up;

	    }
            HVPS_LOOP_SET_VOLTAGE();

         }; /* else all modules are plugged in and everything is reading out */
   
         /* Check for hvps loop status change */
         HVPS_LOOP_CHECK_STATUS();

      } state proc

   } /* HVPS PROCESS */

   /*
    *************** HVPS ON
    */
   state on
   {
      when ((station_state == STATION_OFF) || (station_state == STATION_PARK))
      {
         hvps_loop_state = HVPS_LOOP_STATE_OFF;
         pvPut(hvps_loop_state);
         hvps_loop_status = HVPS_LOOP_STATUS_STN_OFF;
         HVPS_LOOP_CHECK_STATUS();

      } state off

      when (hvps_loop_ctrl == HVPS_LOOP_CONTROL_PROC)
      {
         hvps_loop_state = HVPS_LOOP_STATE_PROC;
         pvPut(hvps_loop_state);
         prev_requested_hvps_voltage = readback_hvps_voltage;

      } state proc

      when (efTestAndClear(hvps_loop_ready_ef) || delay(HVPS_LOOP_MAX_INTERVAL))
      {
         if (hvps_loop_ctrl == HVPS_LOOP_CONTROL_OFF)
	    prev_requested_hvps_voltage = readback_hvps_voltage;

         /* Is the RFP module plugged in? */
         if (LOOP_INVALID_SEVERITY(pvSeverity(rf_processor_severity)))
            hvps_loop_status = HVPS_LOOP_STATUS_RFP_BAD;

         /* Is the station in ON_FM mode? */
         else if (station_state == STATION_ON_FM)
            hvps_loop_status = HVPS_LOOP_STATUS_ON_FM;

	 else if (hvps_loop_ctrl == HVPS_LOOP_CONTROL_OFF)
            hvps_loop_status = HVPS_LOOP_STATUS_OFF;

         /* Is the hvps voltage reading out? */
         else if (LOOP_INVALID_SEVERITY(pvSeverity(readback_hvps_voltage)))
            hvps_loop_status = HVPS_LOOP_STATUS_VOLT_BAD;

         /* Is the Klystron Drive Power OK? Only matters if we're in on_cw mode and
            the direct loop is on. */
         else if ((station_state == STATION_ON_CW)    && 
                  (direct_loop   != LOOP_CONTROL_OFF) &&
                  (LOOP_INVALID_SEVERITY(pvSeverity(delta_on_voltage_severity))))
            hvps_loop_status = HVPS_LOOP_STATUS_DRIV_BAD;

         /* Is the cavity gap voltage OK? */
         else if (LOOP_INVALID_SEVERITY(pvSeverity(gap_voltage_sevr)))
            hvps_loop_status = HVPS_LOOP_STATUS_GAPV_BAD;

         else /* All modules are plugged in and working and everything is reading out */
         {
            /* Get the delta hvps voltage ala subroutine record.*/
            /* The delta is different depending on station mode.*/

            if ((station_state == STATION_ON_CW) &&
                (direct_loop   != LOOP_CONTROL_OFF))
            {
		pvGet(delta_on_voltage);
		delta_hvps_voltage = -delta_on_voltage;
            }
            else
	    {
		pvGet(delta_tune_voltage);
		delta_hvps_voltage = delta_tune_voltage;
	    }

            /* If we are increasing, all the cavity voltages must be below the max. */
	    if ((LOOP_MAJOR_SEVERITY(pvSeverity(gap_voltage_check))) &&
		(delta_hvps_voltage > 0)) {
		cavv_lim_count++;
		if ((cavv_lim_count > HVPS_LOOP_MAX_VOLT_TOL) ||
		    (hvps_loop_status != HVPS_LOOP_STATUS_GOOD))
		   hvps_loop_status = HVPS_LOOP_STATUS_CAVV_LIM;
	    }
            /* Apply the delta, if any, to the HVPS */ 
	    else {
		cavv_lim_count = 0;
		HVPS_LOOP_SET_VOLTAGE();
	    }
         } /* All modules are plugged in and working and everything is reading out */
         /* Check for out-of-tolerance only if nothing else unusual has happened. */
         if ( (hvps_loop_status == HVPS_LOOP_STATUS_GOOD)  ||
              (hvps_loop_status == HVPS_LOOP_STATUS_OFF) )
	 {
	    if ((station_state == STATION_ON_CW)    &&
                (direct_loop   != LOOP_CONTROL_OFF) &&
		(LOOP_MAJOR_SEVERITY(pvSeverity(dp_error_stat))))
	    {
		hvps_loop_status = HVPS_LOOP_STATUS_DRIV_TOL;
	    }
            else if (((station_state == STATION_TUNE) || 
                      (direct_loop   == LOOP_CONTROL_OFF)) &&
                     (LOOP_MAJOR_SEVERITY(pvSeverity(gv_error_stat))))
            {
		hvps_loop_status = HVPS_LOOP_STATUS_GAPV_TOL;
	    }
	 }
         /* Check for hvps loop status change */
         HVPS_LOOP_CHECK_STATUS();

      } state on

   } /* HVPS ON */

   /*
    ************** HVPS OFF
    */
   state off
   {
      when ((station_state != STATION_OFF)  && 
            (station_state != STATION_PARK) && 
            (hvps_loop_ctrl == HVPS_LOOP_CONTROL_PROC)) 
      {
         hvps_loop_state = HVPS_LOOP_STATE_PROC;
         pvPut(hvps_loop_state);
         prev_requested_hvps_voltage = readback_hvps_voltage;
         volt_tol_count = 0;
	 efClear(hvps_loop_ready_ef);

      } state proc

      when ((station_state != STATION_OFF)  && 
            (station_state != STATION_PARK))
      {
         hvps_loop_state = HVPS_LOOP_STATE_ON;
         pvPut(hvps_loop_state);
         pvGet(hvps_loop_delay);
         taskDelay(hvps_loop_delay*60); /* Delay in case fast turnon */
         prev_requested_hvps_voltage = readback_hvps_voltage;
         volt_tol_count = 0;
	 efClear(hvps_loop_ready_ef);

      } state on

   } /* HVPS OFF */
}    /* hvps_loop */

exit {}
