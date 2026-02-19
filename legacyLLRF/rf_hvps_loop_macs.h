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

/* filename: rf_hvps_loop_macs.h */

#define HVPS_LOOP_SET_VOLTAGE() {                                                   \
                pvGet(requested_hvps_voltage);                                      \
                requested_hvps_voltage += delta_hvps_voltage;                       \
                hvps_loop_status = HVPS_LOOP_STATUS_GOOD;                           \
                if (requested_hvps_voltage > max_hvps_voltage) {                    \
                   hvps_loop_status = HVPS_LOOP_STATUS_VOLT_LIM;                   \
                   if (delta_hvps_voltage > 0)                                     \
			requested_hvps_voltage = max_hvps_voltage;                  \
                   }                                                               \
                else if ((requested_hvps_voltage < min_hvps_voltage) &&             \
                         (delta_hvps_voltage <= 0)){                                \
                   requested_hvps_voltage = min_hvps_voltage;                       \
                   }                                                                \
                if (fabs(readback_hvps_voltage - prev_requested_hvps_voltage) >     \
                   allowed_hvps_voltage_diff) {                                     \
                   requested_hvps_voltage = prev_requested_hvps_voltage;            \
                   if (volt_tol_count > HVPS_LOOP_MAX_VOLT_TOL)                     \
                      hvps_loop_status = HVPS_LOOP_STATUS_VOLT_TOL;                 \
                   else volt_tol_count++;                                           \
                   }                                                                \
                else volt_tol_count = 0;                                            \
                pvPut(requested_hvps_voltage);                                      \
                prev_requested_hvps_voltage = requested_hvps_voltage;               \
                history_hvps_voltage = requested_hvps_voltage;                      \
                pvPut(history_hvps_voltage);                                        \
                } /* HVPS_LOOP_SET_VOLTAGE */

#define HVPS_LOOP_CHECK_STATUS() {                                                         \
            /* Check for hvps loop status change */                                        \
            if (prev_hvps_loop_status != hvps_loop_status) {                               \
                                                                                           \
               /* Check to see if we need to clear the HVPS voltage history */             \
               if (prev_hvps_loop_status == HVPS_LOOP_STATUS_OFF) {                        \
                  reset_hvps_voltage_history = 1;                                          \
                  pvPut(reset_hvps_voltage_history);                                       \
                  };                                                                       \
                                                                                           \
               /* Write the hvps loop status to the database */                            \
               prev_hvps_loop_status = hvps_loop_status;                                   \
               pvPut(hvps_loop_status);                                                    \
                                                                                           \
               /* Determine the hvps loop status string */                                 \
               if (hvps_loop_status == HVPS_LOOP_STATUS_UNKNOWN) {                         \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_UNKNOWN_C);                 \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_GOOD) {                       \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_GOOD_C);                    \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_RFP_BAD) {                    \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_RFP_BAD_C);                 \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_CAVV_LIM) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_CAVV_LIM_C);                \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_OFF) {                        \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_OFF_C);                     \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_VACM_BAD) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_VACM_BAD_C);                \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_POWR_BAD) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_POWR_BAD_C);                \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_GAPV_BAD) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_GAPV_BAD_C);                \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_GAPV_TOL) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_GAPV_TOL_C);                \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_VOLT_LIM) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_VOLT_LIM_C);                \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_STN_OFF) {                    \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_STN_OFF_C);                 \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_VOLT_TOL) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_VOLT_TOL_C);                \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_VOLT_BAD) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_VOLT_BAD_C);                \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_DRIV_BAD) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_DRIV_BAD_C);                \
                  epicsPrintf ("%s: %s\n", sequence_name_c, hvps_loop_status_c);           \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_DRIV_TOL) {                   \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_DRIV_TOL_C);                \
                  }                                                                        \
               else if (hvps_loop_status == HVPS_LOOP_STATUS_ON_FM) {                      \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_ON_FM_C);                   \
                  }                                                                        \
               else {                                                                      \
                  strcpy (hvps_loop_status_c, HVPS_LOOP_STATUS_UNDEFINED_C);               \
                  };                                                                       \
                                                                                           \
               /* Write the hvps loop status to the database */                            \
               pvPut (hvps_loop_status_c);                                                 \
                                                                                           \
               }; /* Check for hvps loop status change */                                  \
            } /* HVPS_LOOP_CHECK_STATUS */

