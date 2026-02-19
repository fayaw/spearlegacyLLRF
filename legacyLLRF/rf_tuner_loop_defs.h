/*=============================================================================

  Abs:  Defines used by the Cavity Tuner Loop Sequence

  Name: rf_tuner_loop_defs.h

  Prev: None

  Auth: 31-Oct-1996, Stephanie Allison
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name) 

------------------------------------------------------------------------------

  Mod:

+============================================================================*/

#define LOOP_MAX_DELAY   60.0 /* max # seconds between loop cycles         */
#define LOOP_NONFUNC_INTERVAL 1   /* # times that loop can miss a beat     */
#define LOOP_DMOV_MEAS        1   /* # meas after SM is done moving        */
#define LOOP_NOMOV_COUNT      5   /* # times attempts are made to move SM
                                     when SM is stuck at not-done-moving   */
#define LOOP_RESET_COUNT      5   /* # reset tries                         */
#define LOOP_RESET_DELAY      60  /* delay in ticks between reset tries    */
#define LOOP_RESET_TOLS       2   /* factor applied to posn mdel for 
                                     tolerance checking                    */
#define LOOP_MOVE_COUNT       100 /* # wait-for-done-moving tries          */
#define LOOP_MOVE_DELAY       10  /* delay in ticks between delay tries    */

/* Definitions for tuner loop states */
#define LOOP_OFF           0
#define LOOP_PARK          1
#define LOOP_ON            2
#define LOOP_OFF_NAME     "OFF"
#define LOOP_PARK_NAME    "PARK"
#define LOOP_ON_NAME      "ON"
#define LOOP_UNKNOWN_NAME "UNKNOWN"

/* Definitions for general       tuner loop statuses */
#define LOOP_UNKNOWN_STATUS  0
#define LOOP_OFF_STATUS      1
#define LOOP_STN_OFF_STATUS  2
#define LOOP_GOOD_STATUS     3
#define LOOP_ON_FM_STATUS    4

/* Definitions for stepper motor tuner loop statuses */
#define LOOP_SM_CTRL_STATUS  5
#define LOOP_SM_LIMIT_STATUS 6
#define LOOP_SM_BAD_STATUS   7
#define LOOP_DRV_LIMT_STATUS 8
#define LOOP_SM_MOVE_STATUS  9

/* Definitions for phase meas    tuner loop statuses */
#define LOOP_PHAS_BAD_STATUS 10
#define LOOP_PHASMISS_STATUS 11
#define LOOP_POWR_LOW_STATUS 12
#define LOOP_LDANGLIM_STATUS 13

/* Definitions for general       tuner loop status strings */
#define LOOP_UNKNOWN_STRING  "Unknown status"
#define LOOP_OFF_STRING      "Nonfunctional - loop is OFF"
#define LOOP_STN_OFF_STRING  "Nonfunctional - station is OFF"
#define LOOP_GOOD_STRING     "Successful"
#define LOOP_ON_FM_STRING    "Nonfunctional - station is ON_FM"

/* Definitions for stepper motor tuner loop status strings */
#define LOOP_SM_CTRL_STRING  "Warning - tuner not at requested posn"
#define LOOP_SM_LIMIT_STRING "Warning - tuner at hardware limit"
#define LOOP_SM_BAD_STRING   "Nonfunctional - tuner has bad status"
#define LOOP_DRV_LIMT_STRING "Warning - tuner at a drive limit"
#define LOOP_SM_MOVE_STRING  "Warning - tuner taking too long to move"

/* Definitions for phase meas    tuner loop status strings */
#define LOOP_PHAS_BAD_STRING "Nonfunctional - bad measurements"
#define LOOP_PHASMISS_STRING "Nonfunctional - missing measurements"
#define LOOP_POWR_LOW_STRING "Nonfunctional - RF power bad or too low"
#define LOOP_LDANGLIM_STRING "Warning - load ang error out of limits"

/* Definitions for some stepper motor attributes */
#define SM_DONE_MOVING       1
