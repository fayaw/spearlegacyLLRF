/*=============================================================================

  Abs:  Process Variables used by the Cavity Tuner Loop Sequence

  Name: rf_tuner_loop_pvs.h

  Prev: None

  Auth: 31-Oct-1996, Stephanie Allison
  Rev:  DD-MMM-YYYY, Reviewer's Name (.NE. Author's Name) 

------------------------------------------------------------------------------

  Mod:

+============================================================================*/

int     loop_ctrl;
assign  loop_ctrl to "{STN}:CAVTUNR:LOOP:CTRL";
monitor loop_ctrl;

int     loop_reset;
assign  loop_reset to "{STN}:CAV{CAV}TUNR:LOOP:RESET";
monitor loop_reset;
evflag  loop_reset_ef;
sync    loop_reset loop_reset_ef;

int     loop_home;
assign  loop_home to "{STN}:CAV{CAV}TUNR:LOOP:HOME";
monitor loop_home;
evflag  loop_home_ef;
sync    loop_home loop_home_ef;

int     loop_reset_on;
assign  loop_reset_on to "{STN}:CAVTUNR:LOOPON:RESET";
monitor loop_reset_on;
evflag  loop_reset_on_ef;
sync    loop_reset_on loop_reset_on_ef;

int     loop_home_on;
assign  loop_home_on to "{STN}:CAVTUNR:LOOPON:HOME";
monitor loop_home_on;
evflag  loop_home_on_ef;
sync    loop_home_on loop_home_on_ef;

int     loop_reset_park;
assign  loop_reset_park to "{STN}:CAVTUNR:LOOPPARK:RESET";
monitor loop_reset_park;
evflag  loop_reset_park_ef;
sync    loop_reset_park loop_reset_park_ef;

int     loop_home_park;
assign  loop_home_park to "{STN}:CAVTUNR:LOOPPARK:HOME";
monitor loop_home_park;
evflag  loop_home_park_ef;
sync    loop_home_park loop_home_park_ef;

int     loop_ready;
assign  loop_ready to "{STN}:CAVTUNR:LOOP:READY";
monitor loop_ready;
evflag  loop_ready_ef;
sync    loop_ready loop_ready_ef;

int     meas_ready;
assign  meas_ready to "{STN}:CAV{CAV}TUNR:LOOPMEAS:READY";
monitor meas_ready;
evflag  meas_ready_ef;
sync    meas_ready meas_ready_ef;

int     loop_state;
assign  loop_state  to "{STN}:CAV{CAV}TUNR:LOOP:STATE";

int     loop_status;
assign  loop_status to "{STN}:CAV{CAV}TUNR:LOOP:STATUS";
  
string  loop_status_string_c;
assign  loop_status_string_c to "{STN}:CAV{CAV}TUNR:LOOP:STRING";
  
int     station_state;
assign  station_state to "{STN}:STN:STATE:RBCK";
monitor station_state;

float   posn_ctrl;
assign  posn_ctrl      to "{STN}:CAV{CAV}TUNR:POSN:CTRL";

int     phase_offset_proc;
assign  phase_offset_proc to "{STN}:CAV{CAV}LOAD:ANGLE:UNADOFFS.PROC";

float   posn;
assign  posn           to "{STN}:CAV{CAV}TUNR:POSN";

float   posn_mdel;
assign  posn_mdel      to "{STN}:CAV{CAV}TUNR:POSN.MDEL";

float   posn_new;
assign  posn_new       to "{STN}:CAV{CAV}TUNR:POSN:LOOP";

float   posn_delta;
assign  posn_delta     to "{STN}:CAV{CAV}TUNR:POSN:DELTA";

float   posn_park_home;
assign  posn_park_home to "{STN}:CAV{CAV}TUNR:POSN:PARKHOME";

float   posn_on_home;
assign  posn_on_home   to "{STN}:CAV{CAV}TUNR:POSN:ONHOME";

float   sm_posn;
assign  sm_posn to "{STN}:CAV{CAV}TUNR:STEP:MOTOR.RBV";

float   sm_drvh;
assign  sm_drvh to "{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVH";
monitor sm_drvh;

float   sm_drvl;
assign  sm_drvl to "{STN}:CAV{CAV}TUNR:STEP:MOTOR.DRVL";
monitor sm_drvl;

int     sm_dmov;
assign  sm_dmov to "{STN}:CAV{CAV}TUNR:STEP:MOTOR.DMOV";
monitor sm_dmov;

float   sm_rdbd;
assign  sm_rdbd to "{STN}:CAV{CAV}TUNR:STEP:MOTOR.RDBD";
monitor sm_rdbd;

float   klys_frwd_pwr;
assign  klys_frwd_pwr     to "{STN}:KLYSOUTFRWD:POWER";
monitor klys_frwd_pwr;

float   klys_frwd_pwr_min;
assign  klys_frwd_pwr_min to "{STN}:KLYSOUTFRWD:POWER:MIN";
monitor klys_frwd_pwr_min;

int     load_angle_sevr;
assign  load_angle_sevr to "{STN}:CAV{CAV}LOAD:ANGLE:ERR.SEVR";
monitor load_angle_sevr;
