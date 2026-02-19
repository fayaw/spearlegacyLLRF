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

  Abs:  Sequence to log general messages.

  Name: rf_msgs.st

  Rem:  The sequence logs messages of interest including trip reset, filament
        bypass, filament on/off, and station online/offline.  Note that most of
        these types of messages are logged by bumpless reboot - this sequence
        are for those few items which are not included in the save/restore 
        process.

	Logging of some special HVPS faults is also done in here - they are
        logged only if they fault and there are no other faults.  

        A kludge sequence to monitor the state of the taxi error bit and
        resync the LFB if it's set.

  State(s):
        init   Resets event flags.  Goes to on.
        on     Waits for events and logs messages.

  Auth: 27-Mar-1997, Stephanie Allison
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name)

-------------------------------------------------------------------------------

  Mod:
	 24-Apr-2000, S. Allison (SAA)
	   Open HVPS contactor whenever any filament fault happens.
	 28-Oct-1999, S. Allison (SAA)
	   Replace solenoid on/off with station online/offline.
           Log special HVPS faults.   
	 28-Jan-1999, R. Sass (RCS)
           Add kludgy rfmsgsTAXI sequence to check for LFB TAXI resynch.
         28-Oct-1997, S. Allison (SAA)
	   Open HVPS contactor when filament turned off.

=============================================================================*/

program rf_msgs ("name=tRFMSGS,STN=RRRS")

option -a;  /* All pvGets must be synchronous                          */
option +c;  /* All connections must be made before begin execution     */

%%#include <epicsPrint.h>
%%#include <alarm.h>            /* MAJOR_ALARM */
%%#include <stdlib.h>           /* srand, rand */
%%#include <taskLib.h>          /* VxWorks taskDelay */
%%#include <time.h>             /* time */
%%#include "p2RfGvfDef.h"       /* Gvf module defines */
#include   "rf_loop_defs.h"     /* define for LOOP_CONTROL_ON */

#define    RUN 1

/* Macro for checking for a specific change */

#define CHECK_MSG(channel, channel_ef, string)				\
	when (efTestAndClear(channel_ef) && channel)			\
	{								\
	   epicsPrintf("%s\n", string);					\
        } state on

/* Macro for checking for an on/off change  */

#define CHECK_ONOFF_MSG(channel, channel_ef, string, line)              \
	when (efTestAndClear(channel_ef))				\
	{								\
	   epicsPrintf("%s turned %s%s\n", string, 			\
			onoff_state_ac[channel], line);			\
        } state on

%%#define HVPS_ALARM_SEVERITY(sevr)    ((sevr) == MAJOR_ALARM)
%%#define HVPS_NO_ALARM_SEVERITY(sevr) ((sevr) == NO_ALARM)

#define CHECK_HVPS_MSG(channel, channel_ef, string)			\
	when (efTestAndClear(channel_ef)           &&			\
	      HVPS_NO_ALARM_SEVERITY(station_sumy) &&			\
	      (station_state != STATION_OFF)       &&			\
	      HVPS_ALARM_SEVERITY(pvSeverity(channel)))			\
	{								\
	   epicsPrintf("%s:HVPS%s:STAT faulted to %s\n",		\
		       station_id, string, channel);			\
	} state on

/* Process Variables */

int     hvps_reset;
assign  hvps_reset to "{STN}:HVPS:RESET:CTRL";
monitor hvps_reset;
evflag  hvps_reset_ef;
sync    hvps_reset hvps_reset_ef;

int     filament_timer;
assign  filament_timer to "{STN}:FILAMENT:TIMEBYP:PLC";
monitor filament_timer;
evflag  filament_timer_ef;
sync    filament_timer filament_timer_ef;

int     filament;
assign  filament to "{STN}:STN:AIM:FILAMENT";
monitor filament;
evflag  filament_ef;
sync    filament filament_ef;

int     station_sumy;
assign  station_sumy to "{STN}:STNPARK:SUMY:STAT.SEVR";
monitor station_sumy;

int     filament_sumy;
assign  filament_sumy to "{STN}:FILAMENT:SUMY:PLC";
monitor filament_sumy;
evflag  filament_sumy_ef;
sync    filament_sumy filament_sumy_ef;

int     filament_status;
assign  filament_status to "{STN}:FILAMENT:ON:PLC";
monitor filament_status;
evflag  filament_status_ef;
sync    filament_status filament_status_ef;

int     station;
assign  station to "{STN}:STN:AIM:SOLENOID";
monitor station;
evflag  station_ef;
sync    station station_ef;

string  hvps12kv;
assign  hvps12kv to "{STN}:HVPS12KV:VOLT:STAT";
monitor hvps12kv;
evflag  hvps12kv_ef;
sync    hvps12kv hvps12kv_ef;

string  hvpsenerfast;
assign  hvpsenerfast to "{STN}:HVPSENERFAST:ON:STAT";
monitor hvpsenerfast;
evflag  hvpsenerfast_ef;
sync    hvpsenerfast hvpsenerfast_ef;

string  hvpsenerslow;
assign  hvpsenerslow to "{STN}:HVPSENERSLOW:START:STAT";
monitor hvpsenerslow;
evflag  hvpsenerslow_ef;
sync    hvpsenerslow hvpsenerslow_ef;

string  hvpssupplyon;
assign  hvpssupplyon to "{STN}:HVPSSUPPLY:ON:STAT";
monitor hvpssupplyon;
evflag  hvpssupplyon_ef;
sync    hvpssupplyon hvpssupplyon_ef;

string  hvpsscr1;
assign  hvpsscr1 to "{STN}:HVPSSCR1:ON:STAT";
monitor hvpsscr1;
evflag  hvpsscr1_ef;
sync    hvpsscr1 hvpsscr1_ef;

string  hvpsscr2;
assign  hvpsscr2 to "{STN}:HVPSSCR2:ON:STAT";
monitor hvpsscr2;
evflag  hvpsscr2_ef;
sync    hvpsscr2 hvpsscr2_ef;

int     contactor;
assign  contactor to "{STN}:HVPSCONTACT:CLOSE:CTRL";

int     station_state;
assign  station_state to "{STN}:STN:STATE:CTRL";
monitor station_state;


/* PV's fpr rfmsgsTAXI */

int gvfstat1;
assign  gvfstat1 to "{STN}:STN:GVF:MODU.GST1";
monitor gvfstat1;
evflag  gvfstat1_ef;
sync    gvfstat1 gvfstat1_ef;


int gvfstate;
assign  gvfstate to "{STN}:STN:GVF:STATE";

int gvfwoof;
assign gvfwoof to "{STN}:STN:GVF:LFBLOOP";

int lfbtaxi;
assign lfbtaxi to "";  /* Do dynamic assignment in init */

int taxichk;
assign taxichk to "{STN}:STN:GVF:MODU.TMCK";

int     ring;
assign  ring to "{STN}:STN:RING:PLC";

/* Local Variables */

char *station_id;         /* 4-char station id      */
char *onoff_state_ac[2];  /* strings for on and off */
int  lasttaxi    ;        /* Last state of taxi bit */

ss  rf_msgs 
{
   /*
    *************** INITIALIZATION
    */ 
   state init
   {
      when ()
      {
	 station_id = macValueGet(MACRO_STN_NAME);
	 onoff_state_ac[0] = "OFF";
	 onoff_state_ac[1] = "ON";
         efClear(hvps_reset_ef);
         efClear(filament_timer_ef);
         efClear(filament_ef);
         efClear(filament_sumy_ef);
         efClear(filament_status_ef);
         efClear(station_ef);
	 efClear(hvps12kv_ef);
	 efClear(hvpsenerfast_ef);
	 efClear(hvpsenerslow_ef);
	 efClear(hvpssupplyon_ef);
	 efClear(hvpsscr1_ef);
	 efClear(hvpsscr2_ef);
/*
** Initialization for rfmsgsTAXI. Assign sync PV from ring.
** Done only for HER and LER.
*/
         pvGet(ring);
         if (ring == 1)
           pvAssign (lfbtaxi, "LFB0FSL:WF:SINGLE_SYNC");
         else if (ring == 0)
           pvAssign (lfbtaxi, "LFB0FSH:WF:SINGLE_SYNC");
         srand(time(0)); /* Seed rand so each IOC is different */
         lasttaxi = 0;  /* Set taxi link good */
      } state on
   }
   /*
    *************** PROCESS MESSAGES
    */
   state on
   {
      CHECK_MSG      (hvps_reset,     hvps_reset_ef, "Trip Reset")

      CHECK_MSG      (filament_timer, filament_timer_ef, "Filament Bypassed")

      CHECK_ONOFF_MSG(filament,       filament_ef,   "Filament", "")

      CHECK_ONOFF_MSG(station,        station_ef,    "Station", "LINE")

      when (efTestAndClear(filament_sumy_ef) && (!filament_sumy))
      {
	pvGet(contactor);
	if (contactor)
	{
	  epicsPrintf("Opening contactor due to filament fault\n");
	  contactor = 0;
	  pvPut(contactor);
	}

      } state on

      when (efTestAndClear(filament_status_ef) && (!filament_status) &&
            (filament))
      {
	  epicsPrintf("Filament OFF due to fault\n");

      } state on

      CHECK_HVPS_MSG(hvps12kv     , hvps12kv_ef     , "12KV:VOLT"     )
      CHECK_HVPS_MSG(hvpsenerfast , hvpsenerfast_ef , "ENERFAST:ON"   )
      CHECK_HVPS_MSG(hvpsenerslow , hvpsenerslow_ef , "ENERSLOW:START")
      CHECK_HVPS_MSG(hvpssupplyon , hvpssupplyon_ef , "SUPPLY:ON"     )
      CHECK_HVPS_MSG(hvpsscr1     , hvpsscr1_ef     , "SCR1:ON"       )
      CHECK_HVPS_MSG(hvpsscr2     , hvpsscr2_ef     , "SCR2:ON"       )

   }
}

/*****************************************************************
**  Sequence to check state of taxi error bit from the Gap module.
******************************************************************
*/

ss rf_msgsTAXI
{
   state s_checkTAXI
   {
      when (efTestAndClear(gvfstat1_ef) && gvfstat1)
      {
        pvGet (gvfwoof);  /* Check woofer loop */
        pvGet (gvfstate); /* Check for run state */
        if ((gvfstat1 & GVF_M_TAXIOFLW) && (gvfwoof == LOOP_CONTROL_ON)
             && (gvfstate == RUN))
        {
/*
**      Wait a random time .5-4 sec. so mostly only one IOC that 
**      sees the error actually does the reset. No harm if > 1 makes it.
*/
          taskDelay((rand() % 210) + 30);
          pvPut(taxichk);		 /* Force a taxi status check */
          taskDelay (2);                 /* Let it happen */   
          pvGet(gvfstat1);               /* Check if error is still up */
          if (gvfstat1 & GVF_M_TAXIOFLW)
          {
            lfbtaxi = 1; 
            pvPut(lfbtaxi);
            if ( (gvfstat1 & GVF_M_TAXIOFLW) && (!lasttaxi) )
            { 
               epicsPrintf("Gvf Taxi error detected. Resynch sent.\n");
               lasttaxi = gvfstat1 & GVF_M_TAXIOFLW;
            }
          }   /* Taxi error after delay */
        }     /* No Taxi error nor not woofing and not run */
        else
        {
          if ( !(gvfstat1 & GVF_M_TAXIOFLW) && lasttaxi) /* If link went good */
          {
             epicsPrintf("Gvf Taxi error cleared.\n");
             lasttaxi = gvfstat1 & GVF_M_TAXIOFLW;
          }
        }
      } state s_checkTAXI
   }
}

exit {}
