/*=============================================================================

  Abs:  Macros Shared by States of the Cavity Tuner Loop Sequence

  Name: rf_tuner_loop_macs.h

  Prev: %%string.h            (str* prototypes)
        %%alarm.h             (*ALARM status and severity defines)
        %%taskLib.h           (taskDelay prototype)
        %%epicsPrint.h        (epicsPrintf prototype)
        loop_defs.h           (LOOP* macros)
        tuner_loop_defs.h     (LOOP* defines)
        tuner_loop_pvs.h      (tuner loop process variable names)

  Auth: 31-Oct-1996, Stephanie Allison
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name) 

------------------------------------------------------------------------------

  Mod:

+============================================================================*/


%%#define TUNER_LOOP_POSN_STATUS(get_status,sevr,stat)			\
(									\
  (((get_status) != pvStatOK)||((sevr) > MAJOR_ALARM)) ? LOOP_SM_BAD_STATUS:\
  ((stat) == HW_LIMIT_ALARM)		      ? LOOP_SM_LIMIT_STATUS:	\
  ((sevr) > NO_ALARM)			      ? LOOP_SM_CTRL_STATUS:	\
						LOOP_GOOD_STATUS	\
)

%%#define TUNER_LOOP_DELTA_STATUS(get_status,sevr,loop_status,bad_meas_status)\
(									\
  (((get_status) != pvStatOK)||((sevr) > MAJOR_ALARM)) ? (bad_meas_status):\
						           (loop_status)\
)

%%#define TUNER_LOOP_LDANG_STATUS(sevr)\
(								    \
  ((sevr) > MINOR_ALARM) ? LOOP_LDANGLIM_STATUS : LOOP_GOOD_STATUS  \
)

#define TUNER_LOOP_STATE_UPDATE(new_state, new_status, new_status_string,\
                                old_state_string, new_state_string, \
                                reset_needed)                       \
{                                                                   \
  prev_loop_status = loop_status; loop_status = (new_status);       \
  pvPut(loop_status);                                               \
  loop_state = (new_state);                                         \
  pvPut(loop_state);                                                \
  strcpy(loop_status_string_c, (new_status_string));                \
  pvPut(loop_status_string_c);                                      \
  efClear(loop_home_ef);                                            \
  efClear(loop_home_on_ef);                                         \
  efClear(loop_home_park_ef);                                       \
  if ((reset_needed)&&(loop_ctrl == LOOP_CONTROL_ON)) efSet  (loop_reset_ef);\
  else                                                efClear(loop_reset_ef);\
}
/*

*/                          
#define TUNER_LOOP_INIT_FLAGS()                          		\
{                                                                   	\
  efClear(meas_ready_ef);						\
  efClear(loop_ready_ef);						\
  meas_count      = 0;							\
  dmov_meas_count = 0;							\
  nomov_count     = 0;							\
  nonfunc_count   = 0;                  	                   	\
}

#define TUNER_LOOP_HOME(posn_home, home_name)				\
{									\
  efClear(loop_home_ef);						\
  efClear(loop_home_on_ef);                                             \
  efClear(loop_home_park_ef);                                           \
  if ((pvGet(posn)==pvStatOK) && (!LOOP_INVALID_SEVERITY(pvSeverity(posn)))) \
  {									\
    posn_home = posn;				          		\
    pvPut(posn_home);							\
    epicsPrintf("%s: %s home set to %g\n",           			\
                loop_name_c, home_name, posn);   			\
  }									\
  else									\
  {									\
    epicsPrintf("%s: Unable to get valid data to set %s home\n",        \
                loop_name_c, home_name);				\
  }									\
}
