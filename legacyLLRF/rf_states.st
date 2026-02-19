#define CF2

program rf_states ("name=tRFSTATES,STN=barfonthis")
/*
 *      Author:		Robert C. Sass
 *      Date:		06-Mar-1997
 *
 *
 * For PEP-II alias B-Factory. Control the state of the RF station from 
 * operator requests or due to station fault changes.
 *
 * Modification Log:
 * -----------------
 *
 *      M. Laznovsky (LAZMO): 23-Sep-2004
 *         Turn off INTCOMP in OFF state
 *      M. Laznovsky (LAZMO): 16-Jun-2003
 *         Added AIM fault-file dump support (NUMFFILES modified 10 => 11)
 *         Fixed typo in "/dat/FAULTCmbQ_" filename string
 *         Cleaned up filename generation
 *      S. Allison (SAA): 31-Jan-2000
 *         Add AIM fault reset after beam abort reset to reset BATS.
 *      Robert C. Sass (RCS): 23-Jul-1999
 *         Add fast turnon enable check.
 *      Robert C. Sass (RCS): 7-May-1999
 *         Do fast turnon if going to ON_CW and direct loop is on.
 *      Robert C. Sass (RCS): 1-Oct-1998
 *         Write module data files after a fault.
 *      Steph Allison  (SAA): 31-Jul-1998
 *         Play with drive power when turning direct loop on.
 *      Steph Allison  (SAA): 05-Jan-1998
 *         Add longer delay after tuner reset.
 *      Steph Allison  (SAA): 19-Nov-1997
 *         Reset ripple loop DC coefficient before RF is switched on in ON_CW.
 *      Steph Allison  (SAA): 29-Oct-1997
 *         Add logic for lead and integral compensation.
 *         Remove beam abort reset in TUNE.
 *      Steph Allison  (SAA): 09-Oct-1997
 *         Allow comb off after beam abort.
 *      Steph Allison  (SAA): 26-Sep-1997 and 01-Oct-1997
 *         Changes for direct loop sequencing.
 *      Robert C. Sass (RCS): 05-Sep-1997
 *         Temp reset beam abort for Tune mode.
 *	Robert C. Sass (RCS): 26-Aug-1997
 *	   Add wait after ON_CW state to turn the direct loop.
 *         Add info message after tickle files loaded.
 *      Steph Allison  (SAA): 26-Jun-1997
 *         Add logic to zero and reset GFF I/QREF.
 *      Steph Allison  (SAA): 23-Jun-1997
 *         Add delay after setting HVPS triggers.  Shorten settle time.
 *      Steph Allison  (SAA): 18-Jun-1997
 *         No auto reset if contactor status is bad.
 *      Robert C. Sass (RCS): 15-May-1997
 *         Add log flag to MSGSUB. Move fault check to end of "on states.
 *      Robert C. Sass (RCS): 15-Apr-1997
 *         Zero requested HVPS voltage when going to off state. 
 *      Robert C. Sass (RCS): 01-Apr-1997
 *         Add Automatic reset/restart logic. 
 *      Robert C. Sass (RCS): 18-March-1997
 *         Add tickle toggle for ON_CW state. Loads the RFP memory to
 *         make a small modulation to the beam to measure the tune.
 *
***************** Legal State Transition Matrix ****************
**
** From   To ->	OFF	PARK	TUNE	ON_FM	ON_CW
**  |
**  v
** OFF		 	  Y	  Y	  Y	  Y
**
** PARK		 Y
**
** TUNE		 Y			  	  Y
**
** ON_FM	 Y		  Y
**
** ON_CW	 Y		  Y
**
****************************************************************
*/

/* Initial test for HR81. HR23 = rfs12her03 */

option -a;  /* All pvGets must be synchronous - default                */
option +c;  /* All connections must be made before begin execution - default */
option +d;  /* Turn on runtime debug messages */
option +l;  /* Produce C compiler error messages - default */
option -r;  /* Not reentrant - default */
option +w;  /* Display SNC warning messages - default */
option +e;  /* Use new event flag mode; no clear after event - default */

/*
** Escape to C for include files.
*/

%%#include <stdio.h>            /* printf etc.			*/
%%#include <stdlib.h>           /* getenv			*/
%%#include <string.h>           /* strcpy			*/
%%#include <taskLib.h>          /* VxWorks taskDelay            */
%%#include <alarm.h>            /* INVALID_ALARM 		*/
%%#include <epicsPrint.h>       /* epicsPrintf prototypes       */
%%#include <epicsTime.h>        /* epicsTime prototypes         */

/*
** local includes
*/

#include "rf_loop_defs.h"       /* defines for all STATION_* states */
#include "rf_loop_macs.h"       /* macros  for all sequences        */

/*
*****************************************************************
**  CA variables
*****************************************************************
*/
int     ctrl;	     /* Desired station state */
assign  ctrl to "{STN}:STN:STATE:CTRL";
monitor ctrl;

int     rbck;        /* Present station state */
assign  rbck to "{STN}:STN:STATE:RBCK";

int	stn_reset;   /* Whole station reset */
assign  stn_reset to "{STN}:STN:RESET:CTRL";

float	reset_count; /* Station retry count left */
assign  reset_count to "{STN}:STN:RESET:COUNTER";

/*
** If fault_noon is != NO_ALARM or panel_onoff is != NO_ALARM), don't allow a 
** transition from OFF to any ON-state. If park_noon != NO_ALARM don't
** allow a transition from OFF to PARK.
*/

int     fault_noon;
assign  fault_noon to "{STN}:STNON:SUMY:STAT.SEVR";
monitor fault_noon;

int     park_noon;
assign  park_noon to "{STN}:STNPARK:SUMY:STAT.SEVR";
monitor park_noon;

int     panel_onoff;  /* Local panel on/off switch. */
assign  panel_onoff to "{STN}:STN:LOCAL:ON.SEVR";
monitor panel_onoff;

int     forced_fault;
assign  forced_fault to "{STN}:STN:FORCED:LTCH";
monitor forced_fault;

int     vacuum_err1;
assign  vacuum_err1 to "{STN}:STNVACM:SUMY:LTCH";
int     vacuum_err2;
assign  vacuum_err2 to "{STN}:STNVACM:SUMY:SEVR";

/*
** fault_stnoff is fault_noon + panel_onoff + HVPS triggers & ready on 
** readback + whatever.
** Transition to OFF from any ON-state if this goes != NO_ALARM
*/

int     fault_stnoff; /* Fault.e */
assign  fault_stnoff to "{STN}:STNOFF:SUMY:STAT.SEVR";
monitor fault_stnoff;

/*
** HVPS contactor status summary.  Don't bother with auto-reset if the
** contactor status goes != NO_ALARM.
*/

int     contactor_noon;
assign  contactor_noon to "{STN}:HVPSCONTACT:SUMY:STAT.SEVR";
monitor contactor_noon;

/*
** Force/Reset Beam Abort in AIM module.
*/

int     fba;             /* Force Beam Abort */
assign  fba to "{STN}:STN:AIM:FRCBMABT";

int     rba;             /* Reset Beam Abort */
assign  rba to "{STN}:STN:AIM:MODU.RBA";

int     rstf;            /* Reset AIM Faults */
assign  rstf to "{STN}:STN:AIM:MODU.RSTF";

/*
** The rest of the channels we use.
*/

string  state_string; /* A string we can use for display */
assign  state_string to "{STN}:STN:STATE:STRING";

int     hvpstrig;     /* HVPS trigger control */
assign  hvpstrig to "{STN}:HVPSSCR:ON:CTRL";

int     rfswitch;     /* RF switch control */  
assign  rfswitch to "{STN}:STN:RFP:RFENABLE";

int     runmode;      /* Run mode; tune or operate */
assign  runmode to "{STN}:STN:RFP:RUNMODE";

double  hvpsrdefault; /* Read HVPS default voltage */
assign  hvpsrdefault to "{STN}:HVPS:VOLT:MIN";

double  hvpswdefault; /* Write HVPS requested voltage */
assign  hvpswdefault to "{STN}:HVPS:VOLT:CTRL.VAL";

long    aimon;        /* AIM HVPS on (permissive) can only write 1 */
assign  aimon to "{STN}:STN:AIM:MODU.HVPS";

int     dacfctl;      /* DAC file control */
assign  dacfctl to "{STN}:STN:RFP:STATE";

int     daconoff;     /* DAC on/off control */
assign  daconoff to "{STN}:STN:RFP:DACS";

int     sscont;       /* Single shot or continuous */
assign  sscont to "{STN}:STN:RFP:SSCONT";

int     fmtype;       /* which file to load (400Hz or 1KHz) for on_fm */
assign  fmtype to "{STN}:STN:FMTYPE:CTRL";

int     clock_resync; /* Resynchronize the clock module */
assign  clock_resync to "{STN}:STN:CLK:MODU.RSYN";

/*
** Set cavity tuners to their home or park position.
*/

int     cavtunehome;       /* Cavity tuner home position */
assign  cavtunehome to "{STN}:CAVTUNR:LOOPON:RESET.PROC";

int     cavtunepark;       /* Cavity tuner park position */
assign  cavtunepark to "{STN}:CAVTUNR:LOOPPARK:RESET.PROC";

/*
** Variables for turning direct loop on and off.
*/

int     directlpon;
assign  directlpon      to "{STN}:STN:RFP:DIRECTLOOP";

int     directlpoff;
assign  directlpoff     to "{STN}:STNDIRECT:LOOPOFF:SEQ.PROC";

int     directlptransit;
assign  directlptransit to "{STN}:STNDIRECT:LOOPTRNS:SEQ.PROC";

int     directlprestore;
assign  directlprestore to "{STN}:STNDIRECT:LOOPREST:SEQ.PROC";

int     drivepwrrestore;
assign  drivepwrrestore to "{STN}:STNDRIV:PWRREST:SEQ.PROC";

int	volt_err_sevr;
assign  volt_err_sevr   to "{STN}:STN:VOLT:ERR.SEVR";
monitor volt_err_sevr;

int     directlpcontrol;
assign  directlpcontrol to "{STN}:STNDIRECT:LOOP:CTRL";
monitor directlpcontrol;
evflag  directlp_ef;
sync    directlpcontrol directlp_ef;

/* Local event flag to invoke fast turnon processing */

evflag  directlpfast_ef;

float   directlpgainoff;
assign  directlpgainoff   to "{STN}:STNDIRECT:LOOP:COUNTS.C";

float   directlpgaindelta;
assign  directlpgaindelta to "{STN}:STNDIRECT:LOOP:COUNTS.H";

float   volt_settle_time;
assign  volt_settle_time  to "{STN}:STN:VOLT:SETTLE";

float   ramp_settle_time;
assign  ramp_settle_time  to "{STN}:STN:RAMP:SETTLE";

/*
** Variables for turning lead compensation on and off.
*/

int     leadcomp;
assign  leadcomp        to "{STN}:STN:RFP:LEADCOMP";

int     leadcompcontrol;
assign  leadcompcontrol to "{STN}:STNDIRECT:LEADCOMP:CTRL";
monitor leadcompcontrol;
evflag  leadcomp_ef;
sync    leadcompcontrol leadcomp_ef;

/*
** Variables for turning integral compensation on and off.
*/

int     intcomp;
assign  intcomp        to "{STN}:STN:RFP:INTCOMP";

int     intcompcontrol;
assign  intcompcontrol to "{STN}:STNDIRECT:INTCOMP:CTRL";
monitor intcompcontrol;
evflag  intcomp_ef;
sync    intcompcontrol intcomp_ef;

/*
** Variables for turning comb loop on and off.
*/

int     comblponoff;
assign  comblponoff     to "{STN}:STN:RFP:COMBLOOP";

int     comblptransit;
assign  comblptransit   to "{STN}:STNCOMB:LOOPTRNS:SEQ.PROC";

int     comblpreset;
assign  comblpreset     to "{STN}:STNCOMB:LOOP:RESET.PROC";

int     comblpcontrol;
assign  comblpcontrol   to "{STN}:STNCOMB:LOOP:CTRL";
monitor comblpcontrol;
evflag  comblp_ef;
sync    comblpcontrol comblp_ef;

float   comblpgainoff;
assign  comblpgainoff   to "{STN}:STNCOMB:LOOP:COUNTS.C";

float   comblpgaindelta;
assign  comblpgaindelta to "{STN}:STNCOMB:LOOP:COUNTS.H";

/*
** Variables for turning gff loop on and off.
*/

int     gfflp;
assign  gfflp           to "{STN}:STN:GVF:GFFLOOP";

int     gfflpcontrol;
assign  gfflpcontrol    to "{STN}:STN:GFF:CTRL";
monitor gfflpcontrol;
evflag  gfflp_ef;
sync    gfflpcontrol gfflp_ef;

/*
** Variables for turning lfb loop on and off.
*/

int     lfblp;
assign  lfblp           to "{STN}:STN:GVF:LFBLOOP";

int     lfblpcontrol;
assign  lfblpcontrol    to "{STN}:STN:LFB:CTRL";
monitor lfblpcontrol;
evflag  lfblp_ef;
sync    lfblpcontrol lfblp_ef;

/*
** Variables for ripple loop.
*/

int     ripplelpreset;
assign  ripplelpreset   to "{STN}:STNRIPPLE:LOOP:AMPL.J";

/*
************* Fast turnon variables ********
*/

float   hvpsvoltfaston; /* HVPS fast turnon voltage */
assign  hvpsvoltfaston to "{STN}:HVPS:VOLT:FASTON";

int     fastoncontrol; /* Fast turnon ON/OFF */
assign  fastoncontrol to "{STN}:STN:FASTON:CTRL";

/*
** To set I & Q tune/operate/GFF reference.
*/

int     gvf_module_sevr;
assign  gvf_module_sevr to "{STN}:STN:GVF:MODU.SEVR";
monitor gvf_module_sevr;

float   zeroiqtune;      /* Zero I & Q tune */
assign  zeroiqtune     to "{STN}:STN:TUNE:IQ.A";

int     setiqtune;       /* Set I & Q tune to initial values */
assign  setiqtune      to "{STN}:STN:TUNE:RESET.PROC";

float   zeroiqoper;      /* Zero I & Q operate */
assign  zeroiqoper     to "{STN}:STN:ON:IQ.A";

int     setiqoper;       /* Set I & Q operate to initial values */
assign  setiqoper      to "{STN}:STN:ON:RESET.PROC";

int     setiqoperseln;   /* Select initial values for I & Q operate */
assign  setiqoperseln  to "{STN}:STN:ON:RESET.SELN";

float   zeroiqgff;       /* Zero I & Q GFF reference */
assign  zeroiqgff      to "{STN}:STN:GFF:IQ.A";

int     setiqgff;        /* Set I & Q GFF reference to initial values */
assign  setiqgff       to "{STN}:STN:GFF:RESET.PROC";

int     setiqgffseln;    /* Select initial values for I & Q GFF */
assign  setiqgffseln   to "{STN}:STN:GFF:RESET.SELN";

/*
** I & Q filenames and control for on_fm mode.
*/

string  ri400;    /* Read 400HZ I filename */
assign  ri400 to "{STN}:STN:FM400HZ:IFILE";

string  rq400;    /* Read 400HZ Q filename */
assign  rq400 to "{STN}:STN:FM400HZ:QFILE";

string  ri1000;   /* Read 1000HZ I filename */
assign  ri1000 to "{STN}:STN:FM1000HZ:IFILE";

string  rq1000;   /* Read 1000HZ Q filename */
assign  rq1000 to "{STN}:STN:FM1000HZ:QFILE";

string  wdirf;       /* Write dirf filename */
assign  wdirf to "{STN}:STN:RFP:MODU.DIRF";

string  wdqrf;       /* Write dqrf filename */
assign  wdqrf to "{STN}:STN:RFP:MODU.DQRF";

int     ldir;       /* Load I file command */
assign  ldir to "{STN}:STN:RFP:MODU.LDIR";

int     ldqr;       /* Load Q file command */
assign  ldqr to "{STN}:STN:RFP:MODU.LDQR";

int     dist;       /* Load I file status */
assign  dist to "{STN}:STN:RFP:MODU.DIST";
monitor dist;

int     dqst;       /* Load Q file status */
assign  dqst to "{STN}:STN:RFP:MODU.DQST";
monitor dqst;

/*
** Fields to "tickle" the beam (just a teensy bit) to measure the tune.
*/

int     tickle;	      /* To tickle or not to tickle... */
assign  tickle to "{STN}:STN:TICKLE:CTRL";
monitor tickle;

string  tifile;       /* Tickle I filename */
assign  tifile to "{STN}:STN:TICKLE:IFILE";

string  tqfile;       /* Tickle Q filename */
assign  tqfile to "{STN}:STN:TICKLE:QFILE";

/*
************ Fault file data *********************
** Event flag, fault number, enable, times, and data file arrays.
**************************************************
*/

#define NUMFAULTS 15
#define NUMFFILES 11	/* 10->11 [lazmo 2003-06-12] */
#define MAXFFWAIT 180

evflag  ffwrite_ef;
int     faultnum;
assign  faultnum to "{STN}:STN:FAULT:NUM"; monitor faultnum;

int     faultanum;
assign  faultanum to "{STN}:STN:FAULT:ANUM";

int     faultctrl;
assign  faultctrl to "{STN}:STN:FAULT:CTRL";

int     faultfsize;
assign  faultfsize to "{STN}:STN:FAULT:FSIZE";

string  ftimes[NUMFAULTS];
assign  ftimes[0] to "{STN}:STN:FAULT:TIME1"; 
assign  ftimes[1] to "{STN}:STN:FAULT:TIME2"; 
assign  ftimes[2] to "{STN}:STN:FAULT:TIME3"; 
assign  ftimes[3] to "{STN}:STN:FAULT:TIME4"; 
assign  ftimes[4] to "{STN}:STN:FAULT:TIME5";
assign  ftimes[5] to "{STN}:STN:FAULT:TIME6";
assign  ftimes[6] to "{STN}:STN:FAULT:TIME7";
assign  ftimes[7] to "{STN}:STN:FAULT:TIME8";
assign  ftimes[8] to "{STN}:STN:FAULT:TIME9";
assign  ftimes[9] to "{STN}:STN:FAULT:TIME10";
assign  ftimes[10] to "{STN}:STN:FAULT:TIME11";
assign  ftimes[11] to "{STN}:STN:FAULT:TIME12";
assign  ftimes[12] to "{STN}:STN:FAULT:TIME13";
assign  ftimes[13] to "{STN}:STN:FAULT:TIME14";
assign  ftimes[14] to "{STN}:STN:FAULT:TIME15";

/* 
** Arrays for file size, name, get and status channels. 
** ********* ALL MUST BE IN THE SAME ORDER. ********
** The third Iqa is only present in HER. Check in init and
** dynamically assign if we're HER.
*/

/*
** The Rfp module has one size for it's 4 buffers so repeat
** it to keep loop consistency.
*/

int     fsz[NUMFFILES];  
assign  fsz[0] to "{STN}:STN:RFP:MODU.RMSZ";
assign  fsz[1] to "{STN}:STN:RFP:MODU.RMSZ";
assign  fsz[2] to "{STN}:STN:RFP:MODU.RMSZ";
assign  fsz[3] to "{STN}:STN:RFP:MODU.RMSZ";

#ifdef CF2
assign  fsz[4] to "{STN}:STN:CF2:MODU.IHSZ";
assign  fsz[5] to "{STN}:STN:CF2:MODU.QHSZ";
#else /* old comb */
assign  fsz[4] to "{STN}:STN:CFM1:MODU.HSIZ";
assign  fsz[5] to "{STN}:STN:CFM2:MODU.HSIZ";
#endif

assign  fsz[6] to "{STN}:STN:IQA1:MODU.AHSZ";
assign  fsz[7] to "{STN}:STN:IQA2:MODU.AHSZ";
assign  fsz[8] to "{STN}:STN:GVF:MODU.RSIZ";
assign  fsz[9] to "{STN}:STN:AIM:MODU.HBSZ";
assign  fsz[10] to "";

/*
** Existing file name channels.
*/

string  fname[NUMFFILES];
assign  fname[0] to "{STN}:STN:RFP:MODU.SIRF"; 
assign  fname[1] to "{STN}:STN:RFP:MODU.SQRF";
assign  fname[2] to "{STN}:STN:RFP:MODU.CIRF";
assign  fname[3] to "{STN}:STN:RFP:MODU.CQRF";

#ifdef CF2
assign  fname[4] to "{STN}:STN:CF2:MODU.IHFN";
assign  fname[5] to "{STN}:STN:CF2:MODU.QHFN";
#else
assign  fname[4] to "{STN}:STN:CFM1:MODU.HFIL";
assign  fname[5] to "{STN}:STN:CFM2:MODU.HFIL";
#endif

assign  fname[6] to "{STN}:STN:IQA1:MODU.AHFS";
assign  fname[7] to "{STN}:STN:IQA2:MODU.AHFS";
assign  fname[8] to "{STN}:STN:GVF:MODU.RFIL";
assign  fname[9] to "{STN}:STN:AIM:MODU.HBFN";
assign  fname[10] to "";

/* File get channels */

int      fget[NUMFFILES];
assign   fget[0] to "{STN}:STN:RFP:MODU.GSIR";
assign   fget[1] to "{STN}:STN:RFP:MODU.GSQR";
assign   fget[2] to "{STN}:STN:RFP:MODU.GCIR";
assign   fget[3] to "{STN}:STN:RFP:MODU.GCQR";

#ifdef CF2
assign   fget[4] to "{STN}:STN:CF2:MODU.IHGT";
assign   fget[5] to "{STN}:STN:CF2:MODU.QHGT";
#else
assign   fget[4] to "{STN}:STN:CFM1:MODU.GHST";
assign   fget[5] to "{STN}:STN:CFM2:MODU.GHST";
#endif

assign   fget[6] to "{STN}:STN:IQA1:MODU.GAHS";
assign   fget[7] to "{STN}:STN:IQA2:MODU.GAHS";
assign   fget[8] to "{STN}:STN:GVF:MODU.GRB";
assign   fget[9] to "{STN}:STN:AIM:MODU.HGET";
assign   fget[10] to "";

/* File status channels */

int      fstat[NUMFFILES];
assign   fstat[0] to "{STN}:STN:RFP:MODU.SIST";
assign   fstat[1] to "{STN}:STN:RFP:MODU.SQST";
assign   fstat[2] to "{STN}:STN:RFP:MODU.CIST";
assign   fstat[3] to "{STN}:STN:RFP:MODU.CQST";

#ifdef CF2
assign   fstat[4] to "{STN}:STN:CF2:MODU.IHST";
assign   fstat[5] to "{STN}:STN:CF2:MODU.QHST";
#else
assign   fstat[4] to "{STN}:STN:CFM1:MODU.HSTT";
assign   fstat[5] to "{STN}:STN:CFM2:MODU.HSTT";
#endif

assign   fstat[6] to "{STN}:STN:IQA1:MODU.ASTT";
assign   fstat[7] to "{STN}:STN:IQA2:MODU.ASTT";
assign   fstat[8] to "{STN}:STN:GVF:MODU.RSTT";
assign   fstat[9] to "{STN}:STN:AIM:MODU.HBST";
assign   fstat[10] to "";

/*
** Cfm & Gvf  module state fields to alter before
** writing fault file data.
*/

#ifdef CF2

int     cf2histrec; assign  cf2histrec to "{STN}:STN:CF2:HISTREC";
int     cf2diagrec; assign  cf2diagrec to "{STN}:STN:CF2:DIAGREC";

int     cf2state;   assign  cf2state  to "{STN}:STN:CF2:STATE";

#else
int     cfm1state;  assign  cfm1state to "{STN}:STN:CFM1:STATE";
int     cfm2state;  assign  cfm2state to "{STN}:STN:CFM2:STATE";
#endif

int     gvfstate;
assign  gvfstate to "{STN}:STN:GVF:STATE";

/*****************
** Local variables
******************/

%{
    /*
     * fault-file name roots; will be appended with fault number
     */
    static char *faultroot[NUMFFILES] = {
	"/dat/FAULTRfpSI_",
	"/dat/FAULTRfpSQ_",
	"/dat/FAULTRfpCI_",
	"/dat/FAULTRfpCQ_",

#ifdef CF2
	"/dat/FAULTCf2I_",
	"/dat/FAULTCf2Q_",
#else
	"/dat/FAULTCmbI_",
	"/dat/FAULTCmbQ_",
#endif

	"/dat/FAULTIqa1Amp_",
	"/dat/FAULTIqa2Amp_",
	"/dat/FAULTGvf_",
	"/dat/FAULTAim_",
	"/dat/FAULTIqa3Amp_"
    };
}%

/* 
** We need a local place to store each of the previous module 
** existing filenames and sizes.
*/

int     lfsz[NUMFFILES];         /* Save file sizes */
char    lfname[NUMFFILES][41];   /* Save filenames */
int     numffiles;               /* NUMFFILES-1 for LER */

/*
** Array of template fault filenames. 
** THESE MUST BE IN THE SAME ORDER AS THE OTHER FAULT ARRAYS ABOVE ***
** The code in rfstates replaces the last character with the current
** fault number.
*/

char faultfile[NUMFFILES][41];

int      i;            /* General purpose loopers  */
int      j;
int      iqfm_fault;   /* Error loading I & Q files for ON_FM */
int      iqcw_fault;   /* Error loading I & Q files for tickle in ON_CW */
int      curr_tickle;  /* Current tickle state; OFF or ON */
int      done;         /* Done with something */
%%epicsTimeStamp curtstamp;  /* Le current timestamp */
char     curasci_time[32]; /* In ascii */
float    wait_delay;   /* Time interval for sequence delays */

/*
** Items for auto reset code in s_go_stn_reset.
*/

int     state_when_fault;  /* State in which we were when fault detected. */
int     fault_detected;    /* Fault detected in an "ON" state flag. */
int     reset_noon;        /* Fault sumy to check in s_go_stn_reset */

char	errmsg[100];  /* Msg for error log. */
char    workmsg[100]; /* To construct a message with params */
char   *stn_p;
char    chan_name [80];

/*
************************************************************
** Local defines/macros
************************************************************
*/

#define NO_ALARM  0
#define OFF       0
#define ON        1

/*
** For runmode.
*/
#define TUNE     0
#define OPERATE  1
/*
** For DAC
*/
#define DACRESET 0
#define DACLOAD  1
#define DACRUN   2
/*
** For type of RF
*/
#define SINGLESHOT 0
#define CONTINUOUS 1
/*
** LOAD state for CFM & GVF
*/
#define CFMLOAD 0
#define GVFLOAD 0
#define CFMRUN 1
#define GVFRUN 1
/*
** For FM frequency file
*/
#define FM400HZ    0
#define FM1000HZ   1
/*
** Times to try for files to load in go_on_fm
*/
#define FILETRY    60
/*
** Various reset wait parameters in ticks. 60 ticks/second.
*/
#define VACUUMWAIT     600
#define RESETWAIT      300
#define TUNERWAIT      60
/*
** Loop transitioning wait params in seconds. 
*/
#define LP_ON_WAIT          5.0
#define COMPENSATION_WAIT   1.0
#define MAX_GV_UP_WAIT      30.0

#define MYUDF_ALARM 17

/*
** Because we can't easily use "C" code to do CA, we use macros where
** we need subroutine-like capability.
*/

/*
** Update state msg and optionally the error log if log flag is true.
*/
#define MSGSUB(msg, log) {\
         strcpy(state_string,(msg));\
         pvPut(state_string);\
	 if ((log))\
	 {\
	    strcpy(errmsg,"RFSTATES: ");\
            strcat(errmsg, (msg));\
            epicsPrintf (errmsg);\
	 }\
                    }

/*
** Turn on the high voltage power supply.
*/
#define HVPSONSUB() {\
         rfswitch = ON;		/* Turn on the RF */\
         pvPut (rfswitch);\
         pvGet (hvpsrdefault);	/* Get HVPS desired default voltage */\
         hvpswdefault = hvpsrdefault;\
         pvPut (hvpswdefault);	/* Make it the default */\
         pvPut(cavtunehome);\
	 MSGSUB("Waiting for cavity tuners to home.\n",0);\
         taskDelay(TUNERWAIT);  /* Wait 'till they home  */\
         if (fault_noon == NO_ALARM)\
         {\
            hvpstrig = ON;	/* Turn on HVPS triggers */\
            pvPut (hvpstrig);\
            aimon = ON;         /* Turn on AIM HVPS */\
            pvPut (aimon);\
	    MSGSUB("Waiting for HVPS to turn on.\n",0);\
            for (i=0; i<10; i++)\
            {\
               taskDelay (60);	/* Let HVPS readbacks update */\
               if (((fault_stnoff == NO_ALARM) && (i>5)) || \
                   (fault_noon != NO_ALARM))\
                  break;        /* HVPS is on or problem*/\
            }\
         }\
                    }
/*
** DAC reset & load.
*/
#define DACRLSUB() {\
         dacfctl = DACRESET;	/* First reset */\
         pvPut(dacfctl);\
	 taskDelay(60);\
         dacfctl = DACLOAD;	/* Then load */\
         pvPut(dacfctl);\
                   }
/*
** Set initial values of I and Q reference.
*/
#define SETIQSUB(seln) {\
	 if (LOOP_INVALID_SEVERITY(pvSeverity(gvf_module_sevr))) {\
	    pvPut (zeroiqgff);\
	    setiqoperseln = (seln);\
	    pvPut (setiqoperseln);\
	    pvPut (setiqoper);}\
	 else {\
	    pvPut (zeroiqoper);\
	    setiqgffseln = (seln);\
	    pvPut (setiqgffseln);\
            pvPut (setiqgff);}\
                   }
/*
** Go to operate and turn on the HVPS.
*/
#define OPERATESUB() {\
         runmode = OPERATE;	/* Set run mode to operate */\
	 taskDelay(60);\
         pvPut (runmode);\
         HVPSONSUB();		/* HVPS on sequence */\
                     }
/*
** Reset beam abort if no faults are present to prohibit going to ON_CW.
*/
#define RESET_BMABTSUB(fault) {\
         if ((fault) == NO_ALARM)\
         {\
	    MSGSUB("Resetting beam abort.\n",0);\
            fba = 0;\
            pvPut (fba);        /* Clear force beam abort */\
	    taskDelay(30);\
            pvPut (rba);        /* Reset beam abort */\
	    taskDelay(30);\
            pvPut (rstf);       /* Reset faults to reset BATS */\
         }\
                     }

/*
** Wait for a file to load.
*/
#define WAITLOADSUB(fstatus,fault_flag) {\
         taskDelay(2);     /* Let processing start */\
         i = 0;\
	 while ( ((fstatus) != 0) && (i < FILETRY) )\
         {\
            i++;\
            taskDelay(60);	/* Wait a second */\
         }\
         if (fstatus != 0)\
            fault_flag = 1;\
       }
/*
** Set appropriate noon fault summary depending on state.
*/
#define SETNOON(state, sumy) {\
         if ((state) == STATION_PARK)\
	    (sumy) = park_noon;\
         else\
            (sumy) = fault_noon;\
                     }
/*
** Setup for going to the tune state.
*/
#define TUNESUB() {\
	 fba = 1;\
         pvPut (fba);\
         pvPut (setiqtune);\
         runmode = TUNE;	/* Set run mode to tune */\
	 taskDelay(60);\
         pvPut (runmode);\
                     }

ss rf_states
{
/*
**----------------- Enter State program. Do initialization. ----------------
*/
   state  s_init
   {
/*
**    Initialize state and all our local stuff. 
*/
      when ()
      {
         pvGet(rbck);		/* Get present actual state */
         pvPut(rbck);		/* Force processing of status & severity  */
         curr_tickle = OFF;     /* Set current tickle state to OFF */
         fault_detected = 0;    /* Clear flag */
         state_when_fault = STATION_OFF;
/*
** If HER, construct channel names for 3rd IQA with station name from 
** IQA3MACROS environment variable.
*/ 
         stn_p = getenv ("IQA3MACROS");
         if (stn_p)
         {
           stn_p = strstr (stn_p, "R=") + 2;

           strncpy (chan_name, stn_p, 4);
           strcpy (&chan_name[4], ":STN:IQA3:MODU.AHSZ");
           pvAssign (fsz[NUMFFILES-1], chan_name);

           strcpy (&chan_name[4], ":STN:IQA3:MODU.AHFS");
           pvAssign (fname[NUMFFILES-1], chan_name);

           strcpy (&chan_name[4], ":STN:IQA3:MODU.GAHS");
           pvAssign (fget[NUMFFILES-1], chan_name);

           strcpy (&chan_name[4], ":STN:IQA3:MODU.ASTT");
           pvAssign (fstat[NUMFFILES-1], chan_name);

           numffiles = NUMFFILES;
         }
         else
         {
            numffiles = NUMFFILES - 1;
         }
         efClear(ffwrite_ef);
	 efClear(directlp_ef);
	 efClear(directlpfast_ef);
	 efClear(comblp_ef);
	 efClear(gfflp_ef);
	 efClear(lfblp_ef);
	 efClear(leadcomp_ef);
	 efClear(intcomp_ef);
/*
**	 Initialize flags used later for processing sequence records
**       and other requests.
*/
         ldir            = 1;
         ldqr            = 1;
         stn_reset       = 1;
         rba             = 1;
         rstf            = 1;
         cavtunehome     = 1;
         cavtunepark     = 1;
         setiqtune       = 1;
         setiqoper       = 1;
         setiqgff        = 1;
         zeroiqtune      = 0.0;
         zeroiqoper      = 0.0;
         zeroiqgff       = 0.0;
         directlpoff     = 1;
         directlpon      = 1;
         directlptransit = 1;
         directlprestore = 1;
         drivepwrrestore = 1;
         comblptransit   = 1;
         comblpreset     = 1;
         ripplelpreset   = 1;
	 clock_resync    = 1;

      } state s_go_off
   }
/*
**----------------- End initialization. -------------------
*/

/*
** ++++++++++ Off state. Transition to one of the "on" states  +++++++++
** ++++++++++ if no turnon faults are present and panel is on. +++++++++
** ++++++++++ If a fault was detected in an "on" state, try to +++++++++
** ++++++++++ reset the station.                               +++++++++
*/
   state  s_off
   {
      when (fault_detected)
      {
         fault_detected = 0;     /* Clear flag */
      } state s_go_stn_reset
 
      when (((ctrl == STATION_TUNE) || (ctrl == STATION_ON_FM) ||
             (ctrl == STATION_ON_CW)) &&
            ((fault_noon != NO_ALARM) || (panel_onoff != NO_ALARM)))
      {
         ctrl = STATION_OFF;
         pvPut(ctrl);
	 if (panel_onoff != NO_ALARM)
	 {
           MSGSUB("Key station ON from local panel first.\n",0);
	 }
	 else
	 {
           MSGSUB("Clear and RESET all faults first.\n",0);
	 }
      } state s_off

      when ((ctrl == STATION_PARK) && (park_noon != NO_ALARM))
      {
         ctrl = STATION_OFF;
         pvPut(ctrl);
         MSGSUB("Clear and RESET park faults first.\n",0);

      } state s_off

      when (ctrl == STATION_PARK)
      {
      } state s_go_park

      when (ctrl == STATION_TUNE)
      {
      } state s_go_tune

      when (ctrl == STATION_ON_FM)
      {
      } state s_go_on_fm

      when (ctrl == STATION_ON_CW)
      {
      } state s_go_on_cw
   }

/*
************************************************************
**** "on" states, They just wait for something to happen ***
************************************************************
*/

/*
** ++++++++ Park state. Transition only to off. +++++++++++++++
*/
   state s_park
   {
      when (ctrl == STATION_OFF)
      {
      } state s_go_off      

      when (ctrl == STATION_TUNE)
      {
         ctrl = STATION_PARK;
         pvPut (ctrl);
         MSGSUB("Only valid transition from PARK is OFF.\n",0);
      } state s_park

      when (ctrl == STATION_ON_FM)
      {
         ctrl = STATION_PARK;
         pvPut (ctrl);
         MSGSUB("Only valid transition from PARK is OFF.\n",0);
      } state s_park

      when (ctrl == STATION_ON_CW)
      {
         ctrl = STATION_PARK;
         pvPut (ctrl);
         MSGSUB("Only valid transition from PARK is OFF.\n",0);
      } state s_park

      when (park_noon != NO_ALARM)
      {
         MSGSUB("Fault detected in PARK! Going to OFF.\n",1);
         fault_detected = 1;
         state_when_fault = STATION_PARK;
      } state s_go_off
   }

/*
** ++++++++ Tune state. Transition to off or on_cw. +++++++++++++++
*/
   state s_tune
   {
      when (ctrl == STATION_OFF)
      {
      } state s_go_off      

      when (ctrl == STATION_ON_CW)
      {
      } state s_go_tune_to_on_cw

      when (ctrl == STATION_ON_FM)
      {
         ctrl = STATION_TUNE;
         pvPut (ctrl);
         MSGSUB("Invalid transition from TUNE to ON_FM.\n",0);
      } state s_tune

      when (ctrl == STATION_PARK)
      {
         ctrl = STATION_TUNE;
         pvPut (ctrl);
         MSGSUB("Invalid transition from TUNE to PARK.\n",0);
      } state s_tune

      when (fault_stnoff != NO_ALARM)
      {
         MSGSUB("Fault detected in TUNE! Going to OFF.\n",1);
         fault_detected = 1;
         state_when_fault = STATION_TUNE;
      } state s_go_off
   }

/*
** +++++++ On_fm state. Legal transitions are to off and tune. +++++++
*/
   state s_on_fm
   {
      when (iqfm_fault != NO_ALARM)
      {
         MSGSUB("Fault loading I&Q files! Going to OFF.\n",1);
      } state s_go_off

      when (ctrl == STATION_OFF)
      {
      } state s_go_off

      when (ctrl == STATION_TUNE)
      {
      } state go_on_fm_to_tune

      when (ctrl == STATION_ON_CW)
      {
         ctrl = STATION_ON_FM;
         pvPut(ctrl);
         MSGSUB("Invalid transition from ON_FM to ON_CW.\n",0);
      } state s_on_fm

      when (ctrl == STATION_PARK)
      {
         ctrl = STATION_ON_FM;
         pvPut(ctrl);
         MSGSUB("Invalid transition from ON_FM to PARK.\n",0);
      } state s_on_fm

      when (fault_stnoff != NO_ALARM)
      {
         MSGSUB("Fault detected in ON_FM! Going to OFF.\n",1);
         fault_detected = 1;
         state_when_fault = STATION_ON_FM;
      } state s_go_off
   }

/*
** ++++++ On_cw state. Transition to OFF, TUNE or TICKLE OFF/ON ++++++++++++
*/
   state s_on_cw
   {
      when (ctrl == STATION_OFF)
      {
      } state s_go_off      

      when (ctrl == STATION_TUNE)
      {
      } state go_on_cw_to_tune

      when ( (tickle == ON) && (curr_tickle == OFF) )
      {
      } state s_go_tickleon

      when ( (tickle == OFF) && (curr_tickle == ON) )
      {
      } state s_go_tickleoff

      when (ctrl == STATION_ON_FM)
      {
         ctrl = STATION_ON_CW;
         pvPut(ctrl);
         MSGSUB("Invalid transition from ON_CW to ON_FM.\n",0);
      } state s_on_cw

      when (ctrl == STATION_PARK)
      {
         ctrl = STATION_ON_CW;
         pvPut(ctrl);
         MSGSUB("Invalid transition from ON_CW to PARK.\n",0);
      } state s_on_cw

      when (fault_stnoff != NO_ALARM)
      {
         MSGSUB("Fault detected in ON_CW! Going to OFF.\n",1);
         fault_detected = 1;
         state_when_fault = STATION_ON_CW;
      } state s_go_off
   }

/*
***********************************************************
**** go states which do all of the work. ******************
***********************************************************
*/

/************* go_off ******************************/
/*
** Go Off state
*/
   state  s_go_off
   {
      when ()
      {
	 pvGet(hvpswdefault);   /* Read first which marks timestamp of fault */
	 
         rbck = STATION_OFF;    /* Tell the display the station is off */
         pvPut(rbck);		/* Force readback to off */
         MSGSUB("Waiting for loops to turn OFF.\n",0);
	 /* Pass through the TUNE state first and allow time for logging
            of HVPS faults by rfmsgs.st. */
	 TUNESUB();		
         ctrl = STATION_OFF;    /* In case we got here on a fault */
         pvPut(ctrl);

	 /* Don't bother ramping if there's no HVPS (ie, PARK to OFF) */
	 if (hvpswdefault > 0.1)
	 {
           hvpswdefault = 0.0;
           pvPut (hvpswdefault);  /* Make requested hvps voltage zero */
	   MSGSUB("Waiting for HVPS to ramp down.\n",0);\
	   taskDelay(300);	/* Wait 5 seconds for voltage to go near 0 */
	 }
         hvpstrig = OFF;	/* Turn off HVPS triggers */
         pvPut (hvpstrig);
         rfswitch = OFF;        /* Turn off the RF */
         pvPut (rfswitch);

         intcomp = OFF;		/* Turn off integrator (for MJB 2004-09-23) */
         pvPut(intcomp);

         pvPut (zeroiqtune);
         pvPut (directlpoff);
         pvPut (zeroiqgff);
         pvPut (zeroiqoper);
	 pvPut (clock_resync);
         pvGet(faultctrl);

         if (faultctrl && fault_detected)
         {
           MSGSUB("Waiting for fault files completion.\n",0);
           efSet(ffwrite_ef);  /* Start collecting fault data */
           while (efTest(ffwrite_ef))  /* Wait 'till fault files complete */
             taskDelay(60);
         }
         MSGSUB("In OFF.\n",1);

      } state s_off
   }

/************* go_stn_reset ******************************/
/*
** Try to reset station from a fault detected in an "on" state.
** HVPS contactor must be closed and the station online.  There also
** cannot be a forced fault.
*/
   state  s_go_stn_reset
   {
      when ()
      {
         pvGet(reset_count);
         if ((reset_count > 0.0) && (forced_fault == 0) &&
             ((state_when_fault == STATION_PARK) ||
	      ((contactor_noon == NO_ALARM) && (panel_onoff == NO_ALARM))))
         {
            pvGet(vacuum_err1);      /* Check for vacuum errors */
            pvGet(vacuum_err2);
            if ((vacuum_err1 != NO_ALARM) && (vacuum_err2 != NO_ALARM))
            {
               MSGSUB("Auto reset. Wait for vacuum pump down.\n",1);
               taskDelay(VACUUMWAIT);  /* Wait for vacuum to pump down etc. */
            }
            reset_noon = !NO_ALARM; /* Force at lease 1 reset attempt. */
            while ((reset_count > 0.0) && (reset_noon != NO_ALARM) &&
                   ((state_when_fault == STATION_PARK) || 
		    ((contactor_noon == NO_ALARM) && (panel_onoff == NO_ALARM))))
            {
               pvPut(stn_reset);
               reset_count -= 1.0;
               pvPut(reset_count);
               i = reset_count;  /* Convert trys left to int */
               sprintf (workmsg, "Forced station reset. Trys left: %d.\n",i);  
               MSGSUB(workmsg,1);
               taskDelay(RESETWAIT); /* Give station time to reset */
               SETNOON(state_when_fault, reset_noon); /* Set fault summary */
            }
            if (reset_noon == NO_ALARM) /* Faults OK so go state_when_fault */
            {
               MSGSUB("Automatic reset successful.\n",1);
               ctrl = state_when_fault; /* Set state when we faulted. */
               pvPut(ctrl);
            }
            else
            {            
               MSGSUB("Automatic reset failed. Going to OFF.\n",1);
               ctrl = STATION_OFF;  /* Should already be OFF. */
               rbck = STATION_OFF;
               pvPut(ctrl);
               pvPut(rbck);
            }
         }      /* reset_count > 0 */   
      } state s_off
   }

/************* go_park ******************************/
/*
** Go Park state
*/
   state  s_go_park
   {
      when ()
      {
	 pvPut (clock_resync);
         daconoff = OFF;       /* Set DACs off */
         pvPut(daconoff);
         pvPut(cavtunepark);
	 MSGSUB("Waiting for cavity tuners to park.\n",0);
         taskDelay(TUNERWAIT);       /* Wait 'till they park  */
         RESET_BMABTSUB(park_noon);  /* Reset beam abort */

         rbck = STATION_PARK;  /* Tell display the station is in park */
         pvPut(rbck);
         MSGSUB("In PARK.\n",1);

      } state s_park
   }


/************* go_tune ******************************/
/*
** Go Tune state
*/
   state  s_go_tune
   {
      when ()
      {
	 pvPut (clock_resync);
	 TUNESUB();
         pvPut (zeroiqoper);
         pvPut (zeroiqgff);
         HVPSONSUB();          /* HVPS on sequence */

         rbck = STATION_TUNE;  /* Name that tune */
         pvPut(rbck);
         MSGSUB("In TUNE.\n",1);

      } state s_tune
   }

/************* go_tune_to_on_cw  ******************************/
/*
** Go from tune state to on_cw state.
*/
   state  s_go_tune_to_on_cw
   {
      when ()
      {
         daconoff = OFF;     /* Set DACs off */
         pvPut(daconoff);
         DACRLSUB();         /* DACS reset, load & run */
	 taskDelay(60);
         dacfctl = DACRUN;
         pvPut(dacfctl);
	 SETIQSUB(1);        /* Initialize reference amplitude    */
	 pvPut(ripplelpreset);/* Initialize ripple loop amplitude */
         runmode = OPERATE;  /* Set run mode to operate */
	 taskDelay(60);
         pvPut(runmode);
         pvPut (zeroiqtune);

         rbck = STATION_ON_CW;
         pvPut(rbck);
	 efSet(directlp_ef); /* Turn direct loop on or off */
	 fba = 0;

      } state s_on_cw
   }


/************* go_on_fm ******************************/
/*
** Go on_fm state
*/

   state  s_go_on_fm
   {
      when ()
      {
	 pvPut (clock_resync);
         DACRLSUB();        /* DAC reset & load. */
         pvGet(fmtype);     /* Get which file to load */
         if (fmtype == FM400HZ)
         {
            MSGSUB("Loading 400Hz files for ON_FM.\n",1);
            pvGet(ri400);   /* 400HZ input I filename */
            strcpy (wdirf, ri400);
            pvGet(rq400);   /* 400HZ input Q filename */
            strcpy (wdqrf, rq400);
         }
         else
         {
            MSGSUB("Loading 1KHz files for ON_FM.\n",1);
            pvGet(ri1000);   /* 1000HZ input I filename */
            strcpy (wdirf, ri1000);
            pvGet(rq1000);   /* 1000HZ input Q filename */
            strcpy (wdqrf, rq1000);
         }
	 iqfm_fault = 0;    /* Assume no error loading the files */
/*
** Start & wait for I & Q files to load.
*/
         pvPut(wdirf);
         pvPut(ldir);       /* Poke to start I file load processing */
         WAITLOADSUB(dist,iqfm_fault);    /* Wait for I file to load */
         pvPut(wdqrf);
         pvPut(ldqr);       /* Poke to start Q file load processing */
         WAITLOADSUB(dqst,iqfm_fault);    /* Wait for Qfile to load */
/*
** Check that both files loaded and no fault happened.
*/
	 if ( (dist != 0) || (dqst != 0) || iqfm_fault)  /* If any problem */
         {
            iqfm_fault = 1;  /* Tell s_on_fm there was a problem */
         }
         else                /* No load faults */
         {
            daconoff = ON;      /* Set DACs on */
            pvPut(daconoff);
            sscont = CONTINUOUS;/* Set continuous RF */
            pvPut(sscont);
            dacfctl = DACRUN;   /* Now run */
            pvPut(dacfctl);
            pvPut (zeroiqoper);
            pvPut (zeroiqgff);
            OPERATESUB();        /* Go to operate and turn on the HVPS */
            rbck = STATION_ON_FM; /* Tell the world we're groovin' */
            pvPut(rbck);
            MSGSUB("In ON_FM.\n",1);
         }
      } state s_on_fm 
   }

/************* go_on_fm_to_tune  ******************************/
/*
** Go from ON_FM state to TUNE state.
*/
   state  go_on_fm_to_tune
   {
      when ()
      {
	 TUNESUB();
         rbck = STATION_TUNE;  /* Name that tune */
         pvPut(rbck);
         MSGSUB("In TUNE.\n",1);
      } state s_tune
   }


/************* go_on_cw ******************************/
/*
** Go ON_CW state
*/
   state  s_go_on_cw
   {
      when ()
      {
	 pvPut (clock_resync);
         daconoff = OFF;     /* Set DACs off */
         pvPut(daconoff);
         DACRLSUB();         /* DACS reset, load and run */
	 taskDelay(60);
         dacfctl = DACRUN;
         pvPut(dacfctl);
	 pvPut(ripplelpreset);/* Initialize ripple loop amplitude */
         pvGet(fastoncontrol);
         if ((directlpcontrol == LOOP_CONTROL_ON) && (fastoncontrol == ON)) 
         {
            MSGSUB("Fast ON - Waiting for tuners to home.\n",0);\
/*
**  Home cavities and reset both comb filters.
*/
            pvPut(cavtunehome);
	    if (comblpcontrol == LOOP_CONTROL_ON) pvPut(comblpreset);
/*
**  Preload Gap IREF & QREF; DAC loop operates asynchronously.
*/
            SETIQSUB(3);
	    taskDelay(180);	   /* Let sequence complete */

            pvPut(directlpon);     /* direct loop on. Leave gain asis */
/*
**  Turn on integral & lead compensation loops if enabled.
*/
            if (intcompcontrol == LOOP_CONTROL_ON)
            {
              intcomp = 1;
	      pvPut(intcomp);
            }
            if (leadcompcontrol == LOOP_CONTROL_ON)
            {
              leadcomp = 1;
	      pvPut(leadcomp);
            }
            if (comblpcontrol == LOOP_CONTROL_ON) {
	      comblponoff = 1;        /* Close comb loop */
	      pvPut(comblponoff);
	    }
/*
** Now bang on the high voltage
*/
            runmode = OPERATE;	/* Set run mode to operate */
            pvPut (runmode);
            rfswitch = ON;		/* Turn on the RF */
            pvPut (rfswitch);
            pvGet(hvpsvoltfaston);            /* Set HVPS to fast on value */
            hvpswdefault = hvpsvoltfaston;
            pvPut(hvpswdefault);
	    taskDelay(10);	/* Let task switch so put can happen */
            if (fault_noon == NO_ALARM)
            {
               hvpstrig = ON;	/* Turn on HVPS triggers */
               pvPut (hvpstrig);
               aimon = ON;         /* Turn on AIM HVPS */
               pvPut (aimon);
            }
            for (i=0; i<10; i++)
            {
               taskDelay (60);	/* Let HVPS readbacks update */
               if (((fault_stnoff == NO_ALARM) && (i>5)) || 
                   (fault_noon != NO_ALARM))
                  break;        /* HVPS is on or problem*/
            }

 	    if (gfflpcontrol == LOOP_CONTROL_ON)
            {
              gfflp = 1;
              pvPut(gfflp);
            } 
 	    if (lfblpcontrol == LOOP_CONTROL_ON)
            {
              lfblp = 1;
              pvPut(lfblp);
            }
            sscont = CONTINUOUS;/* Set continuous RF */
            pvPut(sscont);
 	    RESET_BMABTSUB(fault_stnoff);
	    fba = 1;
            if (comblpcontrol == LOOP_CONTROL_ON) 
	    {
	      MSGSUB("In ON_CW. Direct/Comb loops fast on.\n", 1);
	    }
	    else
	    {
	      MSGSUB("In ON_CW. Direct loop on.\n", 1);
	    }
            rbck = STATION_ON_CW;
            pvPut(rbck);
         }
         else                   /* Direct loop not on */
         {
            SETIQSUB(1);        /* Initialize reference amplitude    */
            OPERATESUB();       /* Go to operate and turn on the HVPS */
            rbck = STATION_ON_CW;
            pvPut(rbck);
            fba = 0;
	    efSet(directlp_ef); /* Direct loop off; turn off all loops etc. */
	 }

#ifdef CF2
	/* turn CF2 history buffers ON
	 */
         cf2histrec = 1;	pvPut(cf2histrec);
         cf2diagrec = 1;	pvPut(cf2diagrec);
#endif

      } state s_on_cw
   }


/************* go_on_cw_to_tune  ******************************/
/*
** Go from ON_CW state to TUNE.
*/
   state  go_on_cw_to_tune
   {
      when ()
      {
	 TUNESUB();
         pvPut (directlpoff);
         pvPut (zeroiqgff);
         pvPut (zeroiqoper);

         rbck = STATION_TUNE;	/* Name that tune */
         pvPut(rbck);
         MSGSUB("In TUNE.\n",1);
      } state s_tune
   }


/************* go_tickle* states ******************************/
/*
** Go tickleon
*/

   state  s_go_tickleon
   {
      when ()
      {
         DACRLSUB();       /* DAC reset & load. */
         MSGSUB("Loading Tickle I & Q files.\n",1);
         pvGet(tifile);    /* Tickle I filename */
         strcpy (wdirf, tifile);
         pvGet(tqfile);    /* Tickle Q filename */
         strcpy (wdqrf, tqfile);
	 iqcw_fault = 0;    /* Assume no error loading the files */
/*
** Start & wait for I & Q files to load.
*/
         pvPut(wdirf);
         pvPut(ldir);       /* Poke to start I file load processing */
         WAITLOADSUB(dist,iqcw_fault);    /* Wait for I file to load */
         pvPut(wdqrf);
         pvPut(ldqr);       /* Poke to start Q file load processing */
         WAITLOADSUB(dqst,iqfm_fault);    /* Wait for Qfile to load */
/*
** Check that both files loaded and no fault happened.
*/
	 if ( (dist != 0) || (dqst != 0) || iqcw_fault)  /* If any problem */
         {
            MSGSUB("In ON_CW. Error loading Tickle files.\n",1);
            tickle = OFF;
            pvPut(tickle);   /* Turn tickle control off */
            curr_tickle = OFF; /* Set current tickle state = OFF */
         }
         else                /* No load faults */
         {
            daconoff = ON;      /* Set DACs on */
            pvPut(daconoff);
            sscont = CONTINUOUS;/* Set continuous RF */
            pvPut(sscont);
            dacfctl = DACRUN;   /* Now run */
            pvPut(dacfctl);
            curr_tickle = ON;  /* Set current tickle state = ON */
            MSGSUB("In ON_CW. Tickle on.\n",0);
         }
      } state s_on_cw 
   }

/*
** Go tickleoff
*/

   state  s_go_tickleoff
   {
      when ()
      {
         daconoff = OFF;    /* Set DACs off */
         pvPut(daconoff);
         DACRLSUB();        /* DAC reset & load. */
         curr_tickle = OFF; /* Set current tickle state = OFF */
         MSGSUB("In ON_CW. Tickle off.\n",0);
      } state s_on_cw
   }
}

/*
**  Sequence for transitioning the direct and comb loops on and off.
*/
ss rf_statesLP
{
/*
** Check for loop on/off or a state change to on_cw (the event flag
** gets set by the previous sequence when that happens).
*/ 
   state s_lp_check
   {
/*
**    Service a direct loop on request.  Station must be on and beam aborted.
*/
      when (efTest(directlp_ef) && (directlpcontrol == LOOP_CONTROL_ON) &&
	    (rbck == STATION_ON_CW))
      {
         efClear(directlp_ef);
	 pvGet(volt_settle_time);
/*
**	 The direct loop transition sequence lowers gap voltage and drive power
**	 and initializes a direct loop gain offset in preparation for ramping.
**	 It also forces a beam abort.
*/
	 pvPut(directlptransit);
         fba = 0;
	 MSGSUB("Lowering gap volt and drive pwr\n", 0);

      } state s_gv_down
/*
**    Direct loop not allowed on until station is in ON_CW.
*/
      when (efTestAndClear(directlp_ef))
      {
/*
**	 If the direct loop is on and we've already reset the beam,
**       don't allow user to turn it off.  They must take the station
**	 out of ON_CW, turn the loop off, and then put the station back.
*/
	 if (directlpcontrol != LOOP_CONTROL_ON) 
         {
	    if ((fba != 0) && (rbck == STATION_ON_CW))
	    {
	       directlpcontrol = LOOP_CONTROL_ON;
	       pvPut(directlpcontrol);
	       MSGSUB("Cannot open direct loop while ON_CW\n", 0);
	       taskDelay(60);
	       efClear(directlp_ef);
	    }
	    else
	    {	    
/*
**             The direct loop off sequence turns turn off all loops and
**             processes another sequence that will zero
**             all gain offsets and restore gap voltage.
*/
	       pvPut(directlpoff);
	       efClear(leadcomp_ef);
	       efClear(intcomp_ef);
	       efClear(comblp_ef);
	       efClear(gfflp_ef);
	       efClear(lfblp_ef);
	    }
	 }

      } state s_lp_check
/*
**    Service a lead compensation request if the station and direct loop
**    are both on.  Otherwise, turn it off.
*/
      when (efTestAndClear(leadcomp_ef))
      {
	 if ((leadcompcontrol == LOOP_CONTROL_ON) &&
             (directlpcontrol == LOOP_CONTROL_ON) && (rbck == STATION_ON_CW))
	 {
            leadcomp = 1;
	    if (fba == 0) MSGSUB("Turning lead compensation ON.\n",0);
	 }
	 else
	 {
	    leadcomp = 0;
	 }
	 pvPut(leadcomp);
	 taskDelay(60);

      } state s_lp_check
/*
**    Service an integral compensation request if the station and direct loop
**    are both on.  Otherwise, turn it off.
*/
      when (efTestAndClear(intcomp_ef))
      {
	 if ((intcompcontrol == LOOP_CONTROL_ON)  &&
             (directlpcontrol == LOOP_CONTROL_ON) && (rbck == STATION_ON_CW))
	 {
            intcomp = 1;
	    if (fba == 0) MSGSUB("Turning integral compensation ON.\n",0);
	 }
	 else
	 {
	    intcomp = 0;
	 }
	 pvPut(intcomp);
	 taskDelay(60);

      } state s_lp_check
/*
**    Service a comb loop on request if the station and direct loop are
**    both on.
*/
      when (efTest(comblp_ef) && (comblpcontrol == LOOP_CONTROL_ON) &&
            (directlpcontrol == LOOP_CONTROL_ON) && (rbck == STATION_ON_CW))
      {
	 efClear(comblp_ef);
/*
**	 The comb loop transition sequence initializes a comb loop gain offset 
**       in preparation for ramping and turns on the comb loop.  A wait is
**       required before ramping since the transition sequence takes a 
**       noticeable amount of time.
*/
	 pvPut(comblptransit);
         wait_delay = LP_ON_WAIT;
	 comblpgainoff = -1.0;
	 MSGSUB("Turning comb loop ON.\n", 0);

      } state s_comb_ramp
/*
**    Comb loop not allowed on until station is in ON_CW and direct loop ON.
*/
      when (efTestAndClear(comblp_ef))
      {
	 if (comblpcontrol != LOOP_CONTROL_ON) 
	 {
            comblponoff = 0;
	    pvPut(comblponoff);
/*
**          Restore gap voltage and gains.
*/
	    pvPut(directlprestore);
/*
**          Log a message with the new state unless we are still waiting
**          to reset the beam abort in which case the message will be
**	    logged later on.
*/
	    if ((fba != 0) && (rbck == STATION_ON_CW))
	    {
	       if (directlpcontrol == LOOP_CONTROL_ON)
	       {
	          MSGSUB("In ON_CW. Direct loop on.\n", 0);
	       }
	       else
	       {
	          MSGSUB("In ON_CW. Direct loop off.\n", 0);
	       }
	    }
	 }
      } state s_lp_check
/*
**    Service a gff loop on request if the station and direct loop are
**    both on.  Otherwise, turn it off.
*/
      when (efTestAndClear(gfflp_ef))
      {
	 if ((gfflpcontrol == LOOP_CONTROL_ON) &&
             (directlpcontrol == LOOP_CONTROL_ON) && (rbck == STATION_ON_CW))
	 {
	    gfflp = 1;
	    if (fba == 0) MSGSUB("Turning GAP FF loop ON.\n",0);
	 }
	 else
	 {
	    gfflp = 0;
	 }
	 pvPut(gfflp);
	 taskDelay(60);

      } state s_lp_check
/*
**    Service a lfb woofer on request if the station and direct loop are
**    both on.  Otherwise, turn it off.
*/
      when (efTestAndClear(lfblp_ef))
      {
	 if ((lfblpcontrol == LOOP_CONTROL_ON) &&
             (directlpcontrol == LOOP_CONTROL_ON) && (rbck == STATION_ON_CW))
	 {
            lfblp = 1;
	    if (fba == 0) MSGSUB("Turning LFB woofer ON.\n",0);
	 }
	 else
	 {
	    lfblp = 0;
	 }
	 pvPut(lfblp);	    
	 taskDelay(60);

      } state s_lp_check
/*
**    Reset the beam abort if required.
*/
      when ((fba == 0) && (rbck == STATION_ON_CW))
      {
	 pvPut(directlprestore);
	 pvGet(volt_settle_time);
	 MSGSUB("Waiting for gap voltage to settle.\n", 0);

      } state s_gv_up
   }

/*
** Wait for gap voltage to decrease and settle.
*/ 
   state s_gv_down
   {
/*
**    Check for a direct loop off request or a state change.
*/
      when ((directlpcontrol != LOOP_CONTROL_ON) || (rbck != STATION_ON_CW))
      {
      } state s_lp_check
/*
**    Turn the direct loop on after the gap voltage delay.
*/
      when (delay(volt_settle_time))
      {
	 pvPut(directlpon);
	 /* Set reference amplitude to the direct-loop-ON initial value. */
	 SETIQSUB(2);
	 pvGet(directlpgainoff);
	 wait_delay = LP_ON_WAIT;
	 efSet(leadcomp_ef);	   
	 efSet(intcomp_ef);
	 MSGSUB("Turning direct loop ON.\n", 0);

      } state s_direct_ramp
   }
/*
** Wait for direct loop to turn on and gain to ramp up.
*/
   state s_direct_ramp
   {
/*
**    Check for a direct loop off request or a state change.
*/
      when ((directlpcontrol != LOOP_CONTROL_ON) || (rbck != STATION_ON_CW))
      {
      } state s_lp_check
/*
**    Do lead compensation now.
*/
      when (efTest(leadcomp_ef) && delay(wait_delay))
      {
	efClear(leadcomp_ef);
	if (leadcompcontrol == LOOP_CONTROL_ON)
	{
	  leadcomp = 1;
	  MSGSUB("Turning lead compensation ON.\n",0);
	}
	else
	{
	  leadcomp = 0;
	}
	pvPut(leadcomp);
	wait_delay = COMPENSATION_WAIT;

      } state s_direct_ramp
/*
**    Keep ramping the gain up until finished (gain offset of 0).
*/
      when ((directlpgainoff < 0.0) && delay(wait_delay))
      {
	pvGet(directlpgaindelta);
	/* Check for a reasonable value so we don't spin forever */
	if (directlpgaindelta < 1.0) directlpgaindelta = 1.0;
	directlpgainoff += directlpgaindelta;
	/* Offset must not be greater than zero - don't want to overdrive */
	if (directlpgainoff > -0.1) directlpgainoff = 0.0;
	pvPut(directlpgainoff);
	pvGet(ramp_settle_time);
	wait_delay = ramp_settle_time;
        sprintf (workmsg, "Setting direct lp gain offset to %g.\n", 
		 directlpgainoff);  
	MSGSUB(workmsg, 0);

      } state s_direct_ramp
/*
**    Do integral compensation now.
*/
      when (efTest(intcomp_ef) && delay(wait_delay))
      {
	efClear(intcomp_ef);
	if (intcompcontrol == LOOP_CONTROL_ON)
	{
	  intcomp = 1;
	  MSGSUB("Turning integral compensation ON.\n",0)
	}
	else
	{
	  intcomp = 0;
	}
	pvPut(intcomp);
	wait_delay = COMPENSATION_WAIT;

      } state s_direct_ramp
/*
**    Now do the other loops.
*/
      when (delay(wait_delay))
      {
	wait_delay = LP_ON_WAIT;
	efSet(comblp_ef);
	efSet(gfflp_ef);
	efSet(lfblp_ef);

      } state s_lp_check
   }
/*
** Wait for comb loop to turn on and gain to ramp up.
*/
   state s_comb_ramp
   {
/*
**    Check for a direct or comb loop off request or a state change.
**    Note that the direct loop is not allowed off if the beam abort
**    has already been reset so continue ramping in this case.
*/
      when (((directlpcontrol != LOOP_CONTROL_ON) && (fba == 0)) || 
            (rbck != STATION_ON_CW) || (comblpcontrol != LOOP_CONTROL_ON))
      {
      } state s_lp_check

/*
**    If the direct loop is on and we've already reset the beam,
**    don't allow user to turn it off.  They must take the station
**    out of ON_CW, turn the loop off, and then put the station back.
*/
      when (directlpcontrol != LOOP_CONTROL_ON) 
      {
	directlpcontrol = LOOP_CONTROL_ON;
	pvPut(directlpcontrol);
	MSGSUB("Cannot open direct loop while ON_CW\n", 0);

      } state s_comb_ramp
/*
**    Keep ramping the gain up until finished (gain offset of 0).
*/
      when ((comblpgainoff < 0.0) && delay(wait_delay))
      {
	pvGet(comblpgainoff);
	pvGet(comblpgaindelta);
	pvGet(ramp_settle_time);
	/* Check for a reasonable value so we don't spin forever */
	if (comblpgaindelta < 1.0) comblpgaindelta = 1.0;
	comblpgainoff += comblpgaindelta;
	/* Offset must not be greater than zero - don't want to overdrive */
	if (comblpgainoff > -0.1) comblpgainoff = 0.0;
	pvPut(comblpgainoff);
	wait_delay = ramp_settle_time;
        sprintf (workmsg, "Setting comb lp gain offset to %g.\n", 
		 comblpgainoff);  
	MSGSUB(workmsg, 0);

      } state s_comb_ramp
/*
**    Restore gap voltage and gains.
*/
      when (delay(wait_delay))
      {
	 pvPut(directlprestore);
/*
**       Clear the direct loop event flag here - it'll be set if
**       the when above that checks for an illegal request to turn
**       the direct loop off was executed.
*/
	 efClear(directlp_ef);
/*
**       Log a message with the new state unless we are still waiting
**       to reset the beam abort in which case the message will be
**	 logged later on.
*/
	 if (fba != 0)
	 {
	    MSGSUB("In ON_CW. Direct/Comb loops on.\n", 1);
	 }
      } state s_lp_check
   }
/*
** Wait for the gap voltage to increase and reset the beam abort.
*/
   state s_gv_up
   {
/*
**    Don't reset if the station is not ON_CW.  Also, restart this
**    delay if any button has been pushed and needs servicing.  
*/
      when ((rbck != STATION_ON_CW) || efTest(directlp_ef) ||
	    efTest(leadcomp_ef) || efTest(intcomp_ef) ||
	    efTest(comblp_ef)   || efTest(gfflp_ef)   || efTest(lfblp_ef)) 
      {
      } state s_lp_check
/*
**    Gap voltage must be within tolerance before increasing drive power
**    (and resetting the beam abort).
*/
      when ((delay(LP_ON_WAIT) && (volt_err_sevr == 0)) ||
            delay(MAX_GV_UP_WAIT))
      {
	 pvPut(drivepwrrestore);
	 MSGSUB("Restoring drive power.\n", 0);
	 taskDelay(60);
	 RESET_BMABTSUB(fault_stnoff);
	 fba = 1;
	 if ((directlpcontrol == LOOP_CONTROL_ON) &&
	     (comblpcontrol   == LOOP_CONTROL_ON))
	 {
	    MSGSUB("In ON_CW. Direct/Comb loops on.\n", 1);
	 }
	 else if (directlpcontrol == LOOP_CONTROL_ON)
	 {
	    MSGSUB("In ON_CW. Direct loop on.\n", 1);
	 }
	 else
	 {
	    MSGSUB("In ON_CW. Direct loop off.\n", 1);
	 }
      } state s_lp_check
   }
}

/*********************************************
**  Sequence to write data files after a fault.
**********************************************/

ss rf_statesFF
{
   state s_faultfiles
   {
      when (efTest(ffwrite_ef))
      {
/*
** Update faultnum which is one-based and the time. Don't write time to DB
** 'till we're done.  Write faultnum now so oscilloscope waveform
** acquisition being done on another ioc (see rfacq.st for gpb00ioc00)
** can start now.
*/ 

         pvGet(faultnum);
         if (++faultnum > NUMFAULTS)
           faultnum = 1;
         pvPut(faultnum);

         curtstamp = pvTimeStamp(hvpswdefault); /* Time we entered go_off */
%%       epicsTimeToStrftime(curasci_time, 32, "%b %d, %Y %H:%M:%S.%09f", &curtstamp);
         strncpy(ftimes[faultnum-1], curasci_time, 21); /* To nearest second */
%%       ftimes[faultnum-1][21] = '\0';  /* Make null terminated */
/*
** Set Rfp, Cfm & Gvf modules in "LOAD" state before we can dump.
*/
         dacfctl = DACLOAD;	/* Rfp to LOAD */
         pvPut(dacfctl);

#ifdef CF2
        /* Nothing to do for CF2... h/w turns off hist buffers, and DB syncs 
         * up the GUI buttons
         */
#else /* old comb */
         cfm1state = CFMLOAD;
         cfm2state = CFMLOAD;
         pvPut(cfm1state);
         pvPut(cfm2state);
#endif

         gvfstate = GVFLOAD;
         pvPut(gvfstate);
/*
** Read and save all module filenames & sizes, then store the new fault 
** filenames & sizes.  Fault filename initialization:
*/

         pvGet(faultfsize);

         for (i=0; i<numffiles; i++)
         {
            taskDelay(6);        /* Task switch to do the queued puts */
            pvGet(fname[i]);     /* Get existing filename */
            strcpy (lfname[i], fname[i]);  /* Save it */

            sprintf(faultfile[i],"%s%d",faultroot[i],faultnum);	/* [lazmo 2003-06-12] */

            strcpy (fname[i],faultfile[i]);
            pvPut (fname[i]);   /* Write fault file name */

            pvGet(fsz[i]);
            lfsz[i] = fsz[i];    /* Save current size locally */
            fsz[i] = faultfsize; 
            pvPut(fsz[i]);       /* Set fault size */

            fget[i] = 1;   
            pvPut(fget[i]);      /* Start the data collection */
         }
/*
** Wait until all statii go to NO_ALARM or a max timeout.
*/
         for (i=0, done = 0; i<MAXFFWAIT && !done; i++)
         {
            taskDelay(20);
            done = 1;   /* Assume all is done */
            for (j=0; j<numffiles; j++)  /* Check to see */
            {
               pvGet(fstat[j]);
               if (fstat[j] != NO_ALARM)
                 done = 0;  /* not done yet */
            }
         }
/*
** If we got here on a timeout, print errors for those
** fault files which failed to complete.
*/
         if (!done)
         {
            for (j=0; j<numffiles; j++)
            {
               pvGet(fstat[j]);
               if (fstat[j] != NO_ALARM)
               {
                  sprintf (workmsg, "Fault file %s error.\n",
                           faultfile[j]);
                  MSGSUB(workmsg,1); 
                  taskDelay(60);     /* Let ops see any error messages */
               }  
            }
          }
/*
** Restore all the filenames and sizes
*/
         for (i=0; i<numffiles; i++)
         {
            strcpy (fname[i], lfname[i]);  /* Restore it */
            pvPut (fname[i]);
            fsz[i] = lfsz[i];   /* Restore file sizes */
            pvPut(fsz[i]);
         }

/*
** Restore Cfm and Gvf states.
*/

#ifdef CF2
         /* Turn CF2 buffers back on
          */
         cf2histrec = 1; pvPut(cf2histrec);
         cf2diagrec = 1; pvPut(cf2diagrec);
#else
         cfm1state = CFMRUN;
         cfm2state = CFMRUN;
         pvPut(cfm1state);
         pvPut(cfm2state);
#endif

         gvfstate = GVFRUN;
         pvPut(gvfstate);
/*
** Update faultanum and time, clear the ef to say we're done 
** ... and we're back to this state
*/ 
         faultanum = faultnum;
         pvPut(faultanum);
         pvPut(ftimes[faultnum-1]);
         efClear (ffwrite_ef);
      } state s_faultfiles
   }
}        
exit {}
