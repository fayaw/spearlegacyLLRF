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

  Abs:  Cavity Tuner Loop Sequence

  Name: rf_tuner_loop.st
         States:
	   loop_init    - initialization
           loop_unknown - go to loop state after init or reset
           loop_reset   - reset 
           loop_on      - station in park,tune,on_fm,or on_cw state

  Rem:  The cavity tuner loop moves the tuner based on changes
        calculated in the database depending on the current station
        state.  It also processes reset and set-home requests from
        the user.

  Auth: 31-Oct-1996, Stephanie Allison
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name)

-------------------------------------------------------------------------------

  Mod:
	18-Oct-1999, Stephanie Allison (SAA)
	   Added logic for bad load angle.  

=============================================================================*/

program rf_tuner_loop("STN=RRRS,CAV=X,name=CXTUNRLOOP")

option +r;  /* Must be reentrant since there is one program per cavity */
option -a;  /* All pvGets must be synchronous                          */
option +c;  /* All connections must be made before begin execution     */

%%#include <string.h>           /* str* prototypes                */
%%#include <taskLib.h>          /* VxWorks taskDelay prototype    */
%%#include <alarm.h>            /* MAJOR_ALARM, INVALID_ALARM     */
%%#include <epicsPrint.h>       /* epicsPrintf prototype          */
#include "rf_tuner_loop_defs.h" /* defines for the tuner    loop  */
#include "rf_loop_defs.h"       /* defines for all sequence loops */
#include "rf_loop_macs.h"       /* macros  for all sequence loops */
#include "rf_tuner_loop_macs.h" /* macros  for the tuner loop     */
#include "rf_tuner_loop_pvs.h"  /* tuner loop process variables   */

int     get_status;
int     nonfunc_count;
int     meas_count;
int     dmov_meas_count;
int     nomov_count;
int     reset_count;
int     delay_count;
int     do_printf;
int     prev_loop_status;
int     prev_loop_ctrl;
char   *loop_name_c;
char   *loop_state_c;

ss  rf_tuner_loop
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
        loop_state  = LOOP_OFF;
        loop_status = LOOP_UNKNOWN_STATUS;
        strcpy(loop_status_string_c, LOOP_UNKNOWN_STRING);
        pvPut(loop_state);
	pvPut(loop_status);
	pvPut(loop_status_string_c);
        /* 
         * There's been no control while the loop was down.
         */
	prev_loop_ctrl = LOOP_CONTROL_OFF;
        /*
         * Initialize flag to force processing of the phase offset.
         */
	phase_offset_proc = 0;
        /*
         * Clear all event flags.
         */
	efClear(loop_reset_ef);
        efClear(loop_reset_on_ef);
        efClear(loop_reset_park_ef);
	efClear(loop_home_ef);
        efClear(loop_home_on_ef);
        efClear(loop_home_park_ef);
	efClear(loop_ready_ef);

      } state loop_unknown
   }
   /*

    ************** UNKNOWN
    * When current loop state is unknown, use previous loop state
    * to figure out where to start.
    * Default to the OFF state if previous loop state is not on or park.
    * Also, wait for the next time the loop is ready - allows time for
    * the stepper motor initialization to finish.
    */
   state  loop_unknown
   {
      when ((loop_state == LOOP_ON) && 
            (efTest(loop_ready_ef) || delay(LOOP_MAX_DELAY))) 
      {
	TUNER_LOOP_INIT_FLAGS();
        TUNER_LOOP_STATE_UPDATE(loop_state, loop_status, loop_status_string_c,
				LOOP_ON_NAME, LOOP_ON_NAME, FALSE);

      } state loop_on

      when (efTest(loop_ready_ef) || delay(LOOP_MAX_DELAY))
      {
	TUNER_LOOP_INIT_FLAGS();
	TUNER_LOOP_STATE_UPDATE(LOOP_OFF, LOOP_STN_OFF_STATUS, LOOP_STN_OFF_STRING,
				LOOP_UNKNOWN_NAME, LOOP_OFF_NAME, FALSE);

      } state loop_off
   }
   /*

    *************** RESET
    * Reset tuner to its home position (on or park).  Make a few attempts
    * to get it right since the position from the potentiometer and the
    * readback position from the stepper motor are not exactly the same.
    */
   state loop_reset
   {
      when ()
      {  
        /*
         * Get home positions.  Don't check their severity since
         * these are not processed after reboot and still have
         * the "undefined" (invalid) severity.
         */
	if (efTest(loop_reset_park_ef))
	{
          pvGet(posn_park_home);
          posn_new     = posn_park_home;
	  loop_state_c = LOOP_PARK_NAME;
        }
        else
        {
          pvGet(posn_on_home);
          posn_new     = posn_on_home;
	  loop_state_c = LOOP_ON_NAME;
        }
        /*
         * Get the monitor-delta on the position from the potentiometer.
         * Calculate the tolerance allowed between the desired home posn
         * and the current position.
         */
        pvGet(posn_mdel);
        posn_mdel *= LOOP_RESET_TOLS;
	reset_count = 0;
	while (reset_count < LOOP_RESET_COUNT)
	{
          /*
           * Wait for the potentiometer reading to update 
           * from the last reset attempt.
           */
          if (reset_count > 0) taskDelay(LOOP_RESET_DELAY);
          /*
           * Get the current position from the potentiometer and from
           * the stepper motor.  Don't do anything if the stepper motor
           * is still moving or there is a bad get or an invalid severity.
           */ 
	  if ((sm_dmov == SM_DONE_MOVING) && 
              (pvGet(posn)==pvStatOK) && (pvGet(sm_posn)==pvStatOK) &&
              (!LOOP_INVALID_SEVERITY(pvSeverity(posn)))  &&
              (!LOOP_INVALID_SEVERITY(pvSeverity(sm_posn))))
          {
            /*
             * Log an informational message the first time through.
             * Don't log a message if the loop is OFF.
             */
	    if ((reset_count == 0) && (loop_state != LOOP_OFF))
	        epicsPrintf("%s: Attempt reset to %s home (%g mm)\n",
                            loop_name_c, loop_state_c, posn_new);
	    /*
             * Don't do anymore if the current position is close enough
             * to the desired position.
             */
            posn_delta = posn_new - posn;
            if ( (posn_delta < posn_mdel) && (posn_delta > -posn_mdel))
            {
	      reset_count = LOOP_RESET_COUNT;
            }
            else
            {
              /*
               * Calculate the new stepper motor position by adding the
               * delta between the current and home positions to the
               * current stepper motor position.
               */
              posn_ctrl = sm_posn + posn_delta;
	      pvPut(posn_ctrl);
              /*
               * Wait for the stepper motor to stop moving.
               */
	      taskDelay(LOOP_MOVE_DELAY);
              delay_count = 0;
	      while ((delay_count < LOOP_MOVE_COUNT) &&
                     (sm_dmov != SM_DONE_MOVING))
	      {
                taskDelay(LOOP_MOVE_DELAY);
                delay_count++;
              }
            }
	  }
          /*
           * If this is the first attempt and there was ANY problem,
           * log a message and give up - a reset just cannot be done
           * under these conditions.
           */
	  else if (reset_count == 0)
          {
	    epicsPrintf("%s: Cannot reset to %s home due to bad posn\n",
                        loop_name_c, loop_state_c);
            reset_count = LOOP_RESET_COUNT;
	  }
          /*
           * If there has been at least one attempt to reset, delay
           * just a little bit and try again.
           */
          else
          {
	    taskDelay(LOOP_MOVE_DELAY);
          }
          reset_count++;
        }
        posn_new = posn_ctrl;
        efClear(loop_reset_ef);
        efClear(loop_reset_on_ef);
        efClear(loop_reset_park_ef);

      } state loop_unknown
   }
   /*

    *************** STATION OFF
    * Don't do anything except wait for the station state to
    * change.
    */
   state loop_off
   {
      when ((sm_dmov == SM_DONE_MOVING) &&
            (efTest(loop_reset_on_ef) || efTest(loop_reset_park_ef))) 
      {
      } state loop_reset

      when ((sm_dmov == SM_DONE_MOVING) &&
            (efTest(loop_home_on_ef)))
      {
	TUNER_LOOP_HOME(posn_on_home, LOOP_ON_NAME);

      } state loop_off

      when ((sm_dmov == SM_DONE_MOVING) &&
            (efTest(loop_home_park_ef)))
      {
	TUNER_LOOP_HOME(posn_park_home, LOOP_PARK_NAME);

      } state loop_off

      when (station_state != STATION_OFF)
      {
	TUNER_LOOP_STATE_UPDATE(LOOP_ON, loop_status, loop_status_string_c,
				LOOP_OFF_NAME, LOOP_ON_NAME, FALSE);
	TUNER_LOOP_INIT_FLAGS();
	prev_loop_ctrl = LOOP_CONTROL_OFF;
      
      } state loop_on

   }
   /*

    *************** STATION PARK, TUNE, ON_FM, or ON_CW
    */
   state loop_on
   {
      /* Check for a fresh measurement. */
      when (efTest(meas_ready_ef))
      {
	efClear(meas_ready_ef);
	meas_count++;
	if (sm_dmov == SM_DONE_MOVING) dmov_meas_count++;
	else                           dmov_meas_count = 0;

      } state loop_on

      /* Check if anyone has hit a go-home button. */
      when ((sm_dmov == SM_DONE_MOVING) && (efTest(loop_reset_ef)           ||
            ((station_state == STATION_PARK) && efTest(loop_reset_park_ef)) ||
            ((station_state != STATION_PARK) && efTest(loop_reset_on_ef  )))) 
      {
        if (station_state == STATION_PARK) efSet(loop_reset_park_ef);
        else                               efSet(loop_reset_on_ef);

      } state loop_reset

      /* Clear any go-home button that was pushed while the station is in 
         the wrong state. */
      when ((sm_dmov == SM_DONE_MOVING) &&
            (efTest(loop_reset_park_ef) || efTest(loop_reset_on_ef))) 
      {
	efClear(loop_reset_park_ef);
	efClear(loop_reset_on_ef);

      } state loop_on

      /* Check if anyone has hit the set-home button. */
      when ((sm_dmov == SM_DONE_MOVING) && (efTest(loop_home_ef)           ||
            ((station_state == STATION_PARK) && efTest(loop_home_park_ef)) ||
            ((station_state != STATION_PARK) && efTest(loop_home_on_ef  )))) 
      {
        if (station_state == STATION_PARK)
	{
	  TUNER_LOOP_HOME(posn_park_home, LOOP_PARK_NAME);
	}
	else
	{
	  TUNER_LOOP_HOME(posn_on_home,   LOOP_ON_NAME);
	}

      } state loop_on

      /* Clear any set-home button that was pushed while the station is in 
         the wrong state. */
      when ((sm_dmov == SM_DONE_MOVING) &&
            (efTest(loop_home_park_ef) || efTest(loop_home_on_ef)))
      {
	efClear(loop_home_park_ef);
	efClear(loop_home_on_ef);

      } state loop_on

      when (station_state == STATION_OFF)
      {
        TUNER_LOOP_STATE_UPDATE(LOOP_OFF, LOOP_STN_OFF_STATUS, 
                                LOOP_STN_OFF_STRING,
				LOOP_ON_NAME, LOOP_OFF_NAME, FALSE);

      } state loop_off

      when (efTest(loop_ready_ef))
      {
	efClear(loop_ready_ef);
	prev_loop_status = loop_status;
	if (loop_ctrl == LOOP_CONTROL_OFF)
	{
	  dmov_meas_count = 0;
	  nomov_count     = 0;
	  nonfunc_count   = 0;
	  loop_status     = LOOP_OFF_STATUS;
	}
	else if (meas_count == 0)
	{
	  dmov_meas_count = 0;
	  nomov_count     = 0;
	  nonfunc_count   = 0;
	  loop_status     = LOOP_PHASMISS_STATUS;
	}
	else if ((sm_dmov != SM_DONE_MOVING) && 
                 (nomov_count > LOOP_NOMOV_COUNT))
	{
	  dmov_meas_count = 0;
	  if (nonfunc_count >= LOOP_NONFUNC_INTERVAL)
	    loop_status = LOOP_SM_MOVE_STATUS;
	  else
	   nonfunc_count++;
	}
	else if (dmov_meas_count < LOOP_DMOV_MEAS)
	{
	  if (nonfunc_count >= LOOP_NONFUNC_INTERVAL)
	    loop_status = LOOP_SM_MOVE_STATUS;
	  else
	    nonfunc_count++;
	}
	else if (station_state == STATION_ON_FM)
	{
	  dmov_meas_count = 0;
	  nomov_count     = 0;
	  nonfunc_count   = 0;
	  loop_status     = LOOP_ON_FM_STATUS;
	}
	else
	{
	  if (sm_dmov != SM_DONE_MOVING) nomov_count++; 
	  else                           nomov_count = 0; 
	  nonfunc_count = 0;
	  loop_status   = LOOP_GOOD_STATUS;
	  get_status    = pvGet(posn_delta);
          loop_status   = TUNER_LOOP_DELTA_STATUS(get_status,
				pvSeverity(posn_delta), loop_status, 
				LOOP_PHAS_BAD_STATUS);
          if ((loop_status == LOOP_GOOD_STATUS) &&
	      (station_state != STATION_PARK)   && 
	      (LOOP_INVALID_SEVERITY(pvSeverity(klys_frwd_pwr)) ||
               (klys_frwd_pwr < klys_frwd_pwr_min)))
          {
            loop_status = LOOP_POWR_LOW_STATUS;
          }
          if (loop_status != LOOP_GOOD_STATUS) dmov_meas_count = 0;
        }
	if (dmov_meas_count >= LOOP_DMOV_MEAS)
	{
	  get_status      = pvGet(sm_posn);
	  loop_status     = TUNER_LOOP_POSN_STATUS(get_status,
				pvSeverity(sm_posn), pvStatus(sm_posn));
	  if (loop_status == LOOP_SM_BAD_STATUS)
	  {
	    dmov_meas_count = 0;
	  }
	  else
	  {
	    if ((loop_status == LOOP_GOOD_STATUS)   &&
	        (station_state != STATION_PARK)     && 
		(prev_loop_ctrl == LOOP_CONTROL_ON)) 
	    {
	        loop_status = TUNER_LOOP_LDANG_STATUS(load_angle_sevr);
	    }
	    posn_new = sm_posn + (posn_delta);
	    if ((posn_new > sm_drvh) || (posn_new < sm_drvl))
	    {
	      if (loop_status == LOOP_GOOD_STATUS)
	        loop_status = LOOP_DRV_LIMT_STATUS;
	      if (posn_new > sm_drvh) posn_new = sm_drvh;
	      else                    posn_new = sm_drvl;
	    }
	    if ((loop_status    == LOOP_GOOD_STATUS) &&
	        (prev_loop_ctrl == LOOP_CONTROL_ON)  &&
	        ((posn_ctrl < (sm_posn - sm_rdbd)) ||
	         (posn_ctrl > (sm_posn + sm_rdbd))))
	    {
	      loop_status = LOOP_SM_CTRL_STATUS;
	      /*epicsPrintf("%s: Prev posn = %g, SM Posn = %g\n",  
	                  loop_name_c, posn_ctrl, sm_posn);*/
	      prev_loop_ctrl = LOOP_CONTROL_OFF;
	    }
	    if ((posn_ctrl != posn_new) || (prev_loop_ctrl != LOOP_CONTROL_ON))
	    { 
	      /*epicsPrintf("%s: Old posn = %g, New posn = %g\n"
	             loop_name_c, posn_ctrl, posn_new);*/
	      posn_ctrl = posn_new;
	      pvPut(posn_ctrl);
	    }
	    prev_loop_ctrl = loop_ctrl;
	  }
	}
	pvPut(posn_new);
	if ((station_state != STATION_PARK) && 
	    (dmov_meas_count >= LOOP_DMOV_MEAS)) pvPut(phase_offset_proc);
	dmov_meas_count = 0;
	meas_count      = 0;
	if (prev_loop_status != loop_status)
	{
	  do_printf = TRUE;
	  if      (loop_status == LOOP_GOOD_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_GOOD_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_STN_OFF_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_STN_OFF_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_ON_FM_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_ON_FM_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_UNKNOWN_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_UNKNOWN_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_OFF_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_OFF_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_DRV_LIMT_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_DRV_LIMT_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_POWR_LOW_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_POWR_LOW_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_LDANGLIM_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_LDANGLIM_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_SM_LIMIT_STATUS)
	    strcpy(loop_status_string_c, LOOP_SM_LIMIT_STRING);
	  else if (loop_status == LOOP_SM_CTRL_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_SM_CTRL_STRING);
	    do_printf = FALSE;
	  }
	  else if (loop_status == LOOP_SM_MOVE_STATUS)
	    strcpy(loop_status_string_c, LOOP_SM_MOVE_STRING);
	  else if (loop_status == LOOP_SM_BAD_STATUS)
	    strcpy(loop_status_string_c, LOOP_SM_BAD_STRING);
	  else if (loop_status == LOOP_PHAS_BAD_STATUS)
	    strcpy(loop_status_string_c, LOOP_PHAS_BAD_STRING);
	  else if (loop_status == LOOP_PHASMISS_STATUS)
	  {
	    strcpy(loop_status_string_c, LOOP_PHASMISS_STRING);
	    do_printf = FALSE;
	  }
	  pvPut(loop_status);
	  pvPut(loop_status_string_c);
	  if (do_printf) epicsPrintf("%s: %s\n", loop_name_c, 
				     loop_status_string_c);
	}

      } state loop_on
   }
}
exit {}
