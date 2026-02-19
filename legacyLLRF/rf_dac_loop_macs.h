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

/* filename: rf_dac_loop_macs.h */

%%#define DAC_LOOP_LOLO_STAT(arg_pvStat) (((arg_pvStat) == LOLO_ALARM))


%%#define DAC_LOOP_GET_STATUS(get_status, sevr, good_status, bad_meas_status)\
(									   \
  (((get_status) != pvStatOK)||((sevr) > MAJOR_ALARM)) ? (bad_meas_status):\
						           (good_status)   \
)

#define DAC_LOOP_OFF()                                                     \
{                                                                          \
        /* Set status to indicate DAC loop is off due to station off */    \
        loop_status = prev_loop_status = DAC_LOOP_STATUS_STN_OFF;          \
        strcpy(loop_status_c,            DAC_LOOP_STATUS_STN_OFF_C);       \
        pvPut(loop_status);                                                \
        pvPut(loop_status_c);                                              \
}  

#define DAC_LOOP_CHANGE()                                                  \
{                                                                          \
	efClear(loop_ready_ef);                                            \
	efSet(phase_ef);    /* force an update the first time through */   \
	efSet(rfp_dac_ef);  /* force an update the first time through */   \
	prev_tune_ctrl   = LOOP_CONTROL_OFF;                               \
        prev_on_ctrl     = LOOP_CONTROL_OFF;                               \
        prev_gff_ctrl    = LOOP_CONTROL_OFF;                               \
        prev_direct_loop = LOOP_CONTROL_OFF;                               \
}  

#define DAC_LOOP_SET(counts, delta_counts, tol_sev, other_stat, other_sev, \
                     prev_counts, proc_counts, ctrl, prev_ctrl,            \
                     good_status, off_status, tol_status, bad_status)      \
{                                                                          \
        /* Do nothing if RF module is offline */                           \
        if (LOOP_INVALID_SEVERITY(rf_processor_sevr))                      \
        {                                                                  \
          loop_status = DAC_LOOP_STATUS_RFP_BAD;                           \
        }                                                                  \
        else if (ctrl == LOOP_CONTROL_OFF)                                 \
        {                                                                  \
          prev_ctrl   = ctrl;                                              \
          if (efTestAndClear(phase_ef)) pvPut(proc_counts);                \
          if      (LOOP_INVALID_SEVERITY(tol_sev))                         \
             loop_status = bad_status;                                     \
          else if (LOOP_MAJOR_SEVERITY(tol_sev))                           \
             loop_status = tol_status;                                     \
          else                                                             \
             loop_status = off_status;                                     \
        }                                                                  \
        /* Otherwise get last count value and current delta count */       \
        else                                                               \
        {                                                                  \
	  get_status  = pvGet(counts);                                     \
	  loop_status = DAC_LOOP_GET_STATUS(get_status,                    \
                                            pvSeverity(counts),            \
	                                    good_status, bad_status);      \
	  get_status  = pvGet(delta_counts);                               \
	  loop_status = DAC_LOOP_GET_STATUS(get_status,                    \
                                            pvSeverity(delta_counts),      \
	                                    loop_status, bad_status);      \
          /* If loop status is bad, only update for a phase change */      \
	  if (loop_status == bad_status)                                   \
          {                                                                \
             if (efTestAndClear(phase_ef)) pvPut(proc_counts);             \
          }                                                                \
	  else if ((DAC_LOOP_LOLO_STAT(other_stat) ||                      \
		    LOOP_INVALID_SEVERITY(other_sev)) &&                   \
		   (delta_counts > DAC_LOOP_MIN_DELTA_COUNTS))             \
          {                                                                \
             loop_status = DAC_LOOP_STATUS_DRIV_HIGH;                      \
          }                                                                \
	  else                                                             \
	  {                                                                \
            /* If we've been controlling, check if current and previous    \
               counts don't agree */                                       \
            count_diff = counts - prev_counts;                             \
/* printf("%g %g %g %g\n",count_diff, delta_counts, counts, prev_counts);*/\
            if ((prev_ctrl == ctrl) &&                                     \
                ((count_diff >  DAC_LOOP_MIN_DELTA_COUNTS) ||              \
                 (count_diff < -DAC_LOOP_MIN_DELTA_COUNTS)))               \
              loop_status = DAC_LOOP_STATUS_CTRL;                          \
	    /* Calculate new counts value and compare against limit. */    \
	    counts += delta_counts;                                        \
            if (counts > DAC_LOOP_MAX_COUNTS)                              \
            {                                                              \
              delta_counts = DAC_LOOP_MAX_COUNTS - counts + delta_counts;  \
              counts       = DAC_LOOP_MAX_COUNTS;                          \
              loop_status  = DAC_LOOP_STATUS_DAC_LIMT;                     \
            }                                                              \
            else if (counts < 0)                                           \
            {                                                              \
              delta_counts = -counts + delta_counts;                       \
              counts       = 0;                                            \
              loop_status  = DAC_LOOP_STATUS_DAC_LIMT;                     \
            }                                                              \
	    /* Check for error out-of-tolerance. */                        \
            else if (LOOP_MAJOR_SEVERITY(tol_sev))                         \
            {                                                              \
              loop_status = tol_status;                                    \
            }                                                              \
	    /* Update new count value only if a change has occurred */     \
            if (efTestAndClear(phase_ef) || (prev_ctrl != ctrl) ||         \
                (delta_counts >  DAC_LOOP_MIN_DELTA_COUNTS) ||             \
                (delta_counts < -DAC_LOOP_MIN_DELTA_COUNTS))               \
            {                                                              \
              pvPut(counts);                                               \
	      prev_counts = counts;                                        \
              prev_ctrl   = ctrl;                                          \
            }                                                              \
          }                                                                \
        }                                                                  \
}

#define DAC_LOOP_CHECK_STATUS()                                            \
{                                                                          \
        /* Check for loop status change */                                 \
        if (prev_loop_status != loop_status)                               \
        {                                                                  \
          prev_loop_status = loop_status;                                  \
          if (loop_status ==      DAC_LOOP_STATUS_TUNE)                    \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_TUNE_C);                 \
          else if (loop_status == DAC_LOOP_STATUS_ON)                      \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_ON_C);                   \
          else if (loop_status == DAC_LOOP_STATUS_TUNE_OFF)                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_TUNE_OFF_C);             \
          else if (loop_status == DAC_LOOP_STATUS_ON_OFF)                  \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_ON_OFF_C);               \
          else if (loop_status == DAC_LOOP_STATUS_STN_OFF)                 \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_STN_OFF_C);              \
          else if (loop_status == DAC_LOOP_STATUS_DRIV_TOL)                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_DRIV_TOL_C);             \
          else if (loop_status == DAC_LOOP_STATUS_DRIV_HIGH)               \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_DRIV_HIGH_C);            \
          else if (loop_status == DAC_LOOP_STATUS_GAPV_TOL)                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_GAPV_TOL_C);             \
          else if (loop_status == DAC_LOOP_STATUS_DRIV_BAD)                \
          {                                                                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_DRIV_BAD_C);             \
            epicsPrintf("%s: %s\n", loop_name_c, loop_status_c);           \
          }                                                                \
          else if (loop_status == DAC_LOOP_STATUS_GAPV_BAD)                \
          {                                                                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_GAPV_BAD_C);             \
            epicsPrintf("%s: %s\n", loop_name_c, loop_status_c);           \
          }                                                                \
          else if (loop_status == DAC_LOOP_STATUS_RFP_BAD)                 \
          {                                                                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_RFP_BAD_C);              \
            epicsPrintf("%s: %s\n", loop_name_c, loop_status_c);           \
          }                                                                \
          else if (loop_status == DAC_LOOP_STATUS_GVF_BAD)                 \
          {                                                                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_GVF_BAD_C);              \
            epicsPrintf("%s: %s\n", loop_name_c, loop_status_c);           \
          }                                                                \
          else if (loop_status == DAC_LOOP_STATUS_CTRL)                    \
          {                                                                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_CTRL_C);                 \
            epicsPrintf("%s: %s\n", loop_name_c, loop_status_c);           \
          }                                                                \
          else if (loop_status == DAC_LOOP_STATUS_DAC_LIMT)                \
          {                                                                \
	    strcpy(loop_status_c, DAC_LOOP_STATUS_DAC_LIMT_C);             \
            epicsPrintf("%s: %s\n", loop_name_c, loop_status_c);           \
          }                                                                \
          pvPut (loop_status);                                             \
          pvPut (loop_status_c);                                           \
        }                                                                  \
        pvPut(hist_proc);                                                  \
}
