#define DOCOMB 0	/* include comb code? */

/*
** ++
**
**  Facility:  APP - Application code
**
**  Abstract:
**      EPICS State Notation code for calibrating the Octal DACs on the
**      PEP-II RF RF-Processing Module
**
**  Author:
**	R. Claus, SLAC/PEP-II Low Level RF Group
**
**  History:
**
**	January 30, 1997 - Created
**
**	April  2, 1997 - P. Corredoura - Added offset nulling for klystron
**                                       modulator,  compensation loop and
**                                       comb loop outputs.
**
**	April 18, 1997 - P. Corredoura - Added offset nulling for all cavity,
**                                       direct loop, and comb loop modulators
**                                       multiplier weights from octal DACs and
**                                       RF modulator offsets
**
**	June 2004 - M. Laznovsky -       Major rewrite...
**					 Replaced repeated code w/macros
**					 Reduced or removed superfluous taskDelay()s
**					 Reduced from 4630 lines to ~2800
**					 Reduced run time from ~20 to ~3 minutes
**
**	Septmber 10, 2004 - M. Laznovsky Added new states "DiffNodeOffsets"
**					 and "KlysDemod".
**
**	April 17, 2005 -- M. Laznovsky   Reset comb to initial values at end of 
**					 "ZeroCombMults"
**
**  Copyright:
**                                Copyright 1997
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
**
** --
*/

program P2RF_Calib ("STN=RRRS")

option -r;  /* Reentrancy is not required for this program */
option -a;  /* All pvGets must be synchronous */
option +c;  /* All connections must be made before execution begins */

%%#include <string.h>                   /* String library */
%%#include <stdlib.h>                   /* For calloc & free */
%%#include <sysLib.h>                   /* sysClkRateGet() prototype */
%%#include <taskLib.h>                  /* taskDelay() prototype */

%%#include <epicsPrint.h>               /* EPICS print facility */
%%#include <epicsTime.h>                /* epicsTime prototypes */
%%#include <dbAccess.h>                 /* For DBADDR */

%%#include <p2RfLib.h>                  /* Structure definitions */
%%#include <drvP2RfVxi.h>               /* Driver access prototypes */
%%#include <p2RfRfpDef.h>               /* RFP definitions */
%%#include <p2RfRfpRecord.h>            /* RFP Record definition */

/*************************************************************************/
/* constants                                                             */
/*************************************************************************/

#define OFF         0
#define ON          1

#define STT_OK      0
#define STT_ERROR   1
#define STT_ABORT   2
#define STT_COMBERR 3
#define STT_NORF    4

#define SGL_SHOT    0
#define CONTINUOUS  1

#define RESET       0
#define LOAD        1
#define RUN         2

#define TOTAL       0
#define COMB_OUT    1
#define NOISE       2
#define DRIVE       3
#define RIPPLE_MON  4
#define ERROR_SUM   5
#define GROUND      6
#define KLYSTRON    7

#define TUNE        0
#define OPERATE     1

#define THRU        3

#define COMB_LOAD   0
#define COMB_RUN    1
#define COMB_GAIN   0

#define P2RF_K_CAVCNT      4

#define COUNT          30000       /* Number of words of data to average */

#define MAX_ATTEMPTS      50       /* Maximum number of times to iterate for nulling */

#define MARGIN             1       /* Error that we'll tolerate */
#define BIG_MARGIN         2       /* Error that we'll tolerate for TUNESTPT */
#define BIG_MARGIN2        4       /* Error that we'll tolerate for KLYSTAGE and COMPSTAGE */

#define GOAL               0       /* Location to call NULL */

#define ZERO_ATTEMPTS     11       /* Number of time to iterate for zeroing */

#define MAX_DAC         2047       /* maximum value for octal DACs */
#define MIN_DAC        -2048       /* minimum value for octal DACs */

#define MAX_DAC_SMALL    511       /* maximum value for octal DACs (small version) */
#define MIN_DAC_SMALL   -512       /* minimum value for octal DACs (small version) */

#if 0
#define MAX_COMB        2047       /* maximum perturbation for nulling COMB modulators*/
#define MIN_COMB       -2048       /* minimum perturbation for nulling COMB modulators*/
#else
#define MAX_COMB         512       /* maximum perturbation for nulling COMB modulators*/
#define MIN_COMB        -512       /* minimum perturbation for nulling COMB modulators*/
#endif

#define MODMAX          1024       /* maximum value for nulling RF modulator */

#define RANGE            256       /* range of acceptable multiplier offsets for searching */
#define ERROR_TOLERANCE    8       /* maximum error for multiplier zeroing */
#define MIN_COMB_DELAY    10       /* delay value for nulling comb modulators */

/*************************************************************************/
/* PVs                                                                   */
/*************************************************************************/

#if 0 /* old; use !doCAlib */
int      calAbort;      assign   calAbort   to "{STN}:STN:RFP:CALABORT"; monitor  calAbort;
#endif

int      doCalib;	assign   doCalib to "{STN}:STN:RFP:DOODCALIB";	monitor  doCalib;

string   calMsg;	assign   calMsg  to "{STN}:STN:RFP:CALMSG";

int      lod;		assign   lod     to "{STN}:STN:RFP:MODU.LOD";
int      dlod;		assign   dlod    to "{STN}:STN:RFP:MODU.DLOD";

int      rfEnb;		assign   rfEnb   to "{STN}:STN:RFP:RFENABLE";	monitor  rfEnb;

int      dacs;		assign   dacs    to "{STN}:STN:RFP:DACS";
short    dacsSave;

int      dirLp;		assign   dirLp   to "{STN}:STN:RFP:DIRECTLOOP";
int      cmbLp;		assign   cmbLp   to "{STN}:STN:RFP:COMBLOOP";
int      ripLp;		assign   ripLp   to "{STN}:STN:RFP:RIPPLELOOP";
short    ripLpSave;

int      ldComp;	assign   ldComp  to "{STN}:STN:RFP:LEADCOMP";
short    ldCompSave;

int      intComp;	assign   intComp to "{STN}:STN:RFP:INTCOMP";
short    intCompSave;

int      ssCont;	assign   ssCont  to "{STN}:STN:RFP:SSCONT";
short    ssContSave;

int      rfpStt;	assign   rfpStt  to "{STN}:STN:RFP:STATE";
int      cavSel;	assign   cavSel  to "{STN}:STN:RFP:CAVSEL";

int      fbSig;		assign   fbSig   to "{STN}:STN:RFP:FBSIG";
int      fbSigSave;

float    amplSetpt;	assign   amplSetpt  to "{STN}:STN:RFP:MODU.AMSP";
float    amplSetptSave;

int      lodAmsp;	assign   lodAmsp  to "{STN}:STN:RFP:MODU.LDAS";

int      lodDsp;	assign   lodDsp  to "{STN}:STN:RFP:MODU.LDSP";

int      runMode;	assign   runMode  to "{STN}:STN:RFP:RUNMODE";
short    gvffi;		assign   gvffi    to "{STN}:STN:GVF:MODU.IREF";
short    gvffq;		assign   gvffq    to "{STN}:STN:GVF:MODU.QREF";
short    gvffState;	assign   gvffState    to "{STN}:STN:GVF:STATE";


#if DOCOMB
/*----------------------------------------------------------------*/
int      cmbSel[2];
assign   cmbSel[0]   to "{STN}:STN:CFM1:CMBSETSEL";
assign   cmbSel[1]   to "{STN}:STN:CFM2:CMBSETSEL";
short    cmbSelSave[2];

int      cmbState[2];
assign   cmbState[0]   to "{STN}:STN:CFM1:STATE";
assign   cmbState[1]   to "{STN}:STN:CFM2:STATE";
short    cmbStateSave[2];

int      cmbGain[2];
assign   cmbGain[0]   to "{STN}:STN:CFM1:DATAALIGN";
assign   cmbGain[1]   to "{STN}:STN:CFM2:DATAALIGN";
short    cmbGainSave[2];

int      cmbDelay[2];
assign   cmbDelay[0]   to "{STN}:STN:CFM1:MODU.F0FO";
assign   cmbDelay[1]   to "{STN}:STN:CFM2:MODU.F0FO";
short    cmbDelaySave[2];
/*----------------------------------------------------------------*/
#endif


int      klysDriveI;	assign   klysDriveI  to "{STN}:STN:IQA1:MODU.IDT4";
int      klysDriveQ;	assign   klysDriveQ  to "{STN}:STN:IQA1:MODU.QDT4";

short  comCoef[16];                     /* Should be P2RF_K_CAVCNT * 4 */
short  comCoefSave[4][4];

assign comCoef[0]  to "{STN}:STN:RFP:CAV1.A";	/* cavity 1 II */
assign comCoef[1]  to "{STN}:STN:RFP:CAV1.C";	/* cavity 1 IQ */
assign comCoef[2]  to "{STN}:STN:RFP:CAV1.E";	/* cavity 1 QI */
assign comCoef[3]  to "{STN}:STN:RFP:CAV1.G";	/* cavity 1 QQ */

assign comCoef[4]  to "{STN}:STN:RFP:CAV2.A";	/* cavity 2 II */
assign comCoef[5]  to "{STN}:STN:RFP:CAV2.C";	/* cavity 2 IQ */
assign comCoef[6]  to "{STN}:STN:RFP:CAV2.E";	/* cavity 2 QI */
assign comCoef[7]  to "{STN}:STN:RFP:CAV2.G";	/* cavity 2 QQ */

assign comCoef[8]  to "{STN}:STN:RFP:CAV3.A";	/* cavity 3 II */
assign comCoef[9]  to "{STN}:STN:RFP:CAV3.C";	/* cavity 3 IQ */
assign comCoef[10] to "{STN}:STN:RFP:CAV3.E";	/* cavity 3 QI */
assign comCoef[11] to "{STN}:STN:RFP:CAV3.G";	/* cavity 3 QQ */

assign comCoef[12] to "{STN}:STN:RFP:CAV4.A";	/* cavity 4 II */
assign comCoef[13] to "{STN}:STN:RFP:CAV4.C";	/* cavity 4 IQ */
assign comCoef[14] to "{STN}:STN:RFP:CAV4.E";	/* cavity 4 QI */
assign comCoef[15] to "{STN}:STN:RFP:CAV4.G";	/* cavity 4 QQ */

short  comOfset[16];                     /* Should be P2RF_K_CAVCNT * 4 */

assign comOfset[0]  to "{STN}:STN:RFP:CAV1.B";	/* cavity 1 II offset */
assign comOfset[1]  to "{STN}:STN:RFP:CAV1.D";	/* cavity 1 IQ offset */
assign comOfset[2]  to "{STN}:STN:RFP:CAV1.F";	/* cavity 1 QI offset */
assign comOfset[3]  to "{STN}:STN:RFP:CAV1.H";	/* cavity 1 QQ offset */

assign comOfset[4]  to "{STN}:STN:RFP:CAV2.B";	/* cavity 2 II offset */
assign comOfset[5]  to "{STN}:STN:RFP:CAV2.D";	/* cavity 2 IQ offset */
assign comOfset[6]  to "{STN}:STN:RFP:CAV2.F";	/* cavity 2 QI offset */
assign comOfset[7]  to "{STN}:STN:RFP:CAV2.H";	/* cavity 2 QQ offset */

assign comOfset[8]  to "{STN}:STN:RFP:CAV3.B";	/* cavity 3 II offset */
assign comOfset[9]  to "{STN}:STN:RFP:CAV3.D";	/* cavity 3 IQ offset */
assign comOfset[10] to "{STN}:STN:RFP:CAV3.F";	/* cavity 3 QI offset */
assign comOfset[11] to "{STN}:STN:RFP:CAV3.H";	/* cavity 3 QQ offset */

assign comOfset[12] to "{STN}:STN:RFP:CAV4.B";	/* cavity 4 II offset */
assign comOfset[13] to "{STN}:STN:RFP:CAV4.D";	/* cavity 4 IQ offset */
assign comOfset[14] to "{STN}:STN:RFP:CAV4.F";	/* cavity 4 QI offset */
assign comOfset[15] to "{STN}:STN:RFP:CAV4.H";	/* cavity 4 QQ offset */

short  comOutOs[8];                      /* Should be [P2RF_K_CAVCNT * 2] */

assign comOutOs[0] to "{STN}:STN:RFP:MODU.CO1I";
assign comOutOs[1] to "{STN}:STN:RFP:MODU.CO1Q";
assign comOutOs[2] to "{STN}:STN:RFP:MODU.CO2I";
assign comOutOs[3] to "{STN}:STN:RFP:MODU.CO2Q";

assign comOutOs[4] to "{STN}:STN:RFP:MODU.CO3I";
assign comOutOs[5] to "{STN}:STN:RFP:MODU.CO3Q";
assign comOutOs[6] to "{STN}:STN:RFP:MODU.CO4I";
assign comOutOs[7] to "{STN}:STN:RFP:MODU.CO4Q";

short  dirLpCoef[4];
assign dirLpCoef[0] to "{STN}:STN:RFP:DIRECT.A";
assign dirLpCoef[1] to "{STN}:STN:RFP:DIRECT.C";
assign dirLpCoef[2] to "{STN}:STN:RFP:DIRECT.E";
assign dirLpCoef[3] to "{STN}:STN:RFP:DIRECT.G";
short  dirLpCoefSave[4];

short  dirLpOfset[4];
assign dirLpOfset[0] to "{STN}:STN:RFP:DIRECT.B";
assign dirLpOfset[1] to "{STN}:STN:RFP:DIRECT.D";
assign dirLpOfset[2] to "{STN}:STN:RFP:DIRECT.F";
assign dirLpOfset[3] to "{STN}:STN:RFP:DIRECT.H";

short  combLpCoef[4];
short  combLpCoefSave[4];
assign combLpCoef[0] to "{STN}:STN:RFP:COMB.A";
assign combLpCoef[1] to "{STN}:STN:RFP:COMB.C";
assign combLpCoef[2] to "{STN}:STN:RFP:COMB.E";
assign combLpCoef[3] to "{STN}:STN:RFP:COMB.G";

short  combLpOfset[4];
assign combLpOfset[0] to "{STN}:STN:RFP:COMB.B";
assign combLpOfset[1] to "{STN}:STN:RFP:COMB.D";
assign combLpOfset[2] to "{STN}:STN:RFP:COMB.F";
assign combLpOfset[3] to "{STN}:STN:RFP:COMB.H";

short  dirLpCtlOs[2];
assign dirLpCtlOs[0] to "{STN}:STN:RFP:MODU.DLIO";
assign dirLpCtlOs[1] to "{STN}:STN:RFP:MODU.DLQO";

short  directNullI;
short  directNullQ;

short  sumNodeOs[2];
assign sumNodeOs[0] to "{STN}:STN:RFP:MODU.SNIO";
assign sumNodeOs[1] to "{STN}:STN:RFP:MODU.SNQO";

short  gainStgOs[8];
assign gainStgOs[0] to "{STN}:STN:RFP:MODU.GO1I";
assign gainStgOs[1] to "{STN}:STN:RFP:MODU.GO1Q";
assign gainStgOs[2] to "{STN}:STN:RFP:MODU.GO2I";
assign gainStgOs[3] to "{STN}:STN:RFP:MODU.GO2Q";
assign gainStgOs[4] to "{STN}:STN:RFP:MODU.GO3I";
assign gainStgOs[5] to "{STN}:STN:RFP:MODU.GO3Q";
assign gainStgOs[6] to "{STN}:STN:RFP:MODU.GO4I";
assign gainStgOs[7] to "{STN}:STN:RFP:MODU.GO4Q";

short  klysModuOfset[4];
assign klysModuOfset[0] to "{STN}:STN:RFP:MODU.KMII";
assign klysModuOfset[1] to "{STN}:STN:RFP:MODU.KMIQ";
assign klysModuOfset[2] to "{STN}:STN:RFP:MODU.KMQI";
assign klysModuOfset[3] to "{STN}:STN:RFP:MODU.KMQQ";

short  klysModuOs[2];
assign klysModuOs[0] to "{STN}:STN:RFP:MODU.KLIO";
assign klysModuOs[1] to "{STN}:STN:RFP:MODU.KLQO";

short  rfModuOs[2];
assign rfModuOs[0] to "{STN}:STN:RFP:MODU.RFIO";
assign rfModuOs[1] to "{STN}:STN:RFP:MODU.RFQO";

short  compStgOs[2];
assign compStgOs[0] to "{STN}:STN:RFP:MODU.CSIO";
assign compStgOs[1] to "{STN}:STN:RFP:MODU.CSQO";

short  diffNodeOs[2];
assign diffNodeOs[0] to "{STN}:STN:RFP:MODU.DNIO";
assign diffNodeOs[1] to "{STN}:STN:RFP:MODU.DNQO";

short  klysDemodOs[2];
assign klysDemodOs[0] to "{STN}:STN:RFP:MODU.KLOI";
assign klysDemodOs[1] to "{STN}:STN:RFP:MODU.KLOQ";

short  combLpCtlOs[2];
assign combLpCtlOs[0] to "{STN}:STN:RFP:MODU.CLIO";
assign combLpCtlOs[1] to "{STN}:STN:RFP:MODU.CLQO";

short  tuneSetpt[2];
short  tuneSetptSave[2];
assign tuneSetpt[0] to "{STN}:STN:RFP:TUNE.A";
assign tuneSetpt[1] to "{STN}:STN:RFP:TUNE.C";

short  tuneSetptOs[2];
assign tuneSetptOs[0] to "{STN}:STN:RFP:TUNE.B";
assign tuneSetptOs[1] to "{STN}:STN:RFP:TUNE.D";

string RfDspFile;
assign RfDspFile to "{STN}:STN:RFP:MODU.DSPE";


/* comb module PVs, for comb presence check
 */
int    cfm_sevr[2];
assign cfm_sevr[0] to "{STN}:STN:CFM1:MODU.SEVR";
assign cfm_sevr[1] to "{STN}:STN:CFM2:MODU.SEVR";
/*----------------------------------------------------------------*/


int    calStatus;
assign calStatus to "{STN}:STN:RFP:CALSTATUS";

string calTime;
assign calTime to "{STN}:STN:RFP:CALTIME";


/*************************************************************************/
/* local vars                                                            */
/*************************************************************************/

%%static void        *drvPvt;
%%static P2RfBufDsc  *bufDsc;
%%epicsTimeStamp     curtstamp;
char timeOfDay[32];

int    attemptCnt;

short  delta;

short  IIcenter;
short  QIcenter;
short  IQcenter;
short  QQcenter;

short  IImax;
short  QImax;
short  IQmax;
short  QQmax;

short  IImin;
short  QImin;
short  IQmin;
short  QQmin;

short  IIupper;
short  QIupper;
short  IQupper;
short  QQupper;

short  IIlower;
short  QIlower;
short  IQlower;
short  QQlower;

short  Icenter;
short  Qcenter;

short  iGoal;
short  qGoal;

short  Iupper;
short  Qupper;

short  Ilower;
short  Qlower;

short  maxError;

int    iNulled;
int    qNulled;

short  iPrevX;
short  qPrevX;
short   prevX;

%%double iPrevY;
%%double qPrevY;
%%double  prevY;

int    nulled;

int    cav;
int    i;

char  *msg;

string origDspFile;

/* retry stuff, for certain states */
#define NUM_TRIES 3
int try;

int rfAbort;

int numComb;		/* # of combs detected... 0 or 2 is OK; 1 => error */


/*************************************************************************/
/* 
/*************************************************************************/

%%static int   P2RF_UpdateSetPt (P2RfBufDsc *, double , short, double *, short *, short *);

%%static short P2RF_AvgOffset (P2RfBufDsc *);

%%static void  P2RF_DumpBuf (P2RfBufDsc *bufDsc);

#define FN        "P2RF_Calib"
#define rippleRfp  "/dsp/rippleRfp"

/*************************************************************************/
/* macros                                                                */
/*************************************************************************/

#define DELAY_1TICK  taskDelay(1)
#define DELAY_2TICKS taskDelay(2)
#define DELAY_50MS   taskDelay(sysClkRateGet() / 20)
#define DELAY_67MS   taskDelay(sysClkRateGet() / 15)
#define DELAY_100MS  taskDelay(sysClkRateGet() / 10)
#define DELAY_167MS  taskDelay(sysClkRateGet() /  6)
#define DELAY_500MS  taskDelay(sysClkRateGet() /  2)
#define DELAY_1SEC   taskDelay(sysClkRateGet())
#define DELAY_2SEC   taskDelay(sysClkRateGet() *  2)
#define DELAY_5SEC   taskDelay(sysClkRateGet() *  5)

/*----------------------------------------------------------------*/

/* pvSav() - pvGet() followed by copy to normal var
 */
#define pvSav(_PV_,_VAR_)\
{\
  pvGet(_PV_);\
  _VAR_ = _PV_;\
}

/*----------------------------------------------------------------*/

/* pvSet() - set to value, then pvPut()
 */
#define pvSet(_VAR_,_EXPR_)\
{\
  _VAR_ = ( _EXPR_ );\
  pvPut(_VAR_);\
}

/*----------------------------------------------------------------*/

#define CAL_MSG(_S_) {\
  msg = _S_;\
  epicsPrintf ("%s: %s\n", FN, msg);\
  strncpy (calMsg, msg, sizeof (calMsg));\
  pvPut (calMsg);\
}

/*----------------------------------------------------------------*/

/* check for abort requested... toggle button is Calibrate/Abort
 */
#define CHECK_ABORT \
  { if (doCalib == 0) %{ goto ABORT; }% ;}

/*----------------------------------------------------------------*/

/* set cavity "cav" gain offsets
 */
#define SET_GAIN_OFFSETS(_I_,_Q_)\
{\
  pvSet(gainStgOs[2*cav+0],_I_);	/* I path */\
  pvSet(gainStgOs[2*cav+1],_Q_);	/* Q path */\
}

/*----------------------------------------------------------------*/

/* set first 2 elements of array
 */
#define SET_TWO_VALS(_ARR_,_V1_,_V2_)\
{\
  pvSet(_ARR_[0], _V1_);\
  pvSet(_ARR_[1], _V2_);\
}

/*----------------------------------------------------------------*/

/* LOD: load octal DACs -- requires db_post_events() for .LOD in devP2RfRfp.c? (Not!?)
 *   ... while(lod!=0) check not needed if record processes in-line ...
 */
#define LOD \
{\
  pvSet(lod,1);\
}
#if 0
  pvGet(lod);\
  while (lod != 0) {  /* wait for devP2RfRfp.c::Action() to finish? */\
    %{ taskDelay(1); }%\
    pvGet(lod);\
  }
#endif

/*----------------------------------------------------------------*/

/* QUADLOD: load quad DACs -- requires db_post_events() for .DLOD in devP2RfRfp.c? (Not!?)
 *   ... while(dlod!=0) check not needed if record processes in-line ...
 */
#define QUADLOD \
{\
  pvSet(dlod,1);\
}
#if 0
  pvGet(dlod);\
  while (dlod != 0) {  /* wait for devP2RfRfp.c::Action() to finish? */\
    %{ taskDelay(1); }%\
    pvGet(dlod);\
  }
#endif

/*----------------------------------------------------------------*/

/* TAKE_DATA: ...
 *   _Z_ != 0 -> load octal DACs
 */
#define TAKE_DATA(_Z_) \
{\
  pvSet(rfpStt,RESET);\
  pvSet(rfpStt,LOAD);  %{DELAY_1TICK; }%\
  pvSet(rfpStt,RUN);\
  %{ DELAY_50MS; }%  /* delay input step ... memory length = 53.42 ms [per mjb] */\
  if (_Z_) LOD;\
  %{ DELAY_1TICK; }%\
  %{ DELAY_1TICK; }%\
  pvSet(rfpStt,LOAD);  %{DELAY_1TICK; }%\
}

/*----------------------------------------------------------------*/

/* read I & Q from h/w
 *   _TYPE_ == "SIG" or "CAV"
 */
#define GET_IQ(_TYPE_,_Z1_,_Z2_) \
%{\
         P2RF_CopyMemory (drvPvt, RFP_I_##_TYPE_##IRAM, bufDsc);/* Read I data out */\
  _Z1_ = P2RF_AvgOffset  (bufDsc);				/* Average I data */\
         P2RF_WriteVme   (drvPvt, RFP_I_SMPRELD, NULL);		/* Preload the state machine address counter */\
         P2RF_CopyMemory (drvPvt, RFP_I_##_TYPE_##QRAM, bufDsc);/* Read Q data out */\
  _Z2_ = P2RF_AvgOffset  (bufDsc);				/* Average Q data */\
}%

/*----------------------------------------------------------------*/

/* set *CAVITY* I/Q offsets to center value +/- delta
 *   note order: 0,2,1,3
 */
#define SET_CAV_OFFSETS(_Z_,_D0_,_D1_,_D2_,_D3_) \
{\
  pvSet(_Z_[4*cav+0],IIcenter+(_D0_));\
  pvSet(_Z_[4*cav+2],QIcenter+(_D1_));\
  pvSet(_Z_[4*cav+1],IQcenter+(_D2_));\
  pvSet(_Z_[4*cav+3],QQcenter+(_D3_));\
}

/*----------------------------------------------------------------*/

/* set *OTHER* I/Q offsets to center value +/- delta
 *   note order: 0,2,1,3
 */
#define SET_IQ_OFFSETS(_Z_,_D0_,_D1_,_D2_,_D3_) \
{\
  pvSet(_Z_[0],IIcenter+(_D0_));\
  pvSet(_Z_[2],QIcenter+(_D1_));\
  pvSet(_Z_[1],IQcenter+(_D2_));\
  pvSet(_Z_[3],QQcenter+(_D3_));\
}

/*----------------------------------------------------------------*/

/* recenter based on upper/lower
 */
#define RECENTER(Z) \
{\
  if (Z##upper < Z##lower) Z##center += delta/2;\
  if (Z##upper > Z##lower) Z##center -= delta/2;\
}

/*----------------------------------------------------------------*/

/* find max error (in all II/IQ/QI/QQ)
 */
#define FIND_MAXERROR \
%{\
  maxError = 0;\
  maxError = maxError < IIupper ? IIupper : maxError;\
  maxError = maxError < IIlower ? IIlower : maxError;\
  maxError = maxError < QQupper ? QQupper : maxError;\
  maxError = maxError < QQlower ? QQlower : maxError;\
  maxError = maxError < QIupper ? QIupper : maxError;\
  maxError = maxError < QIlower ? QIlower : maxError;\
  maxError = maxError < IQupper ? IQupper : maxError;\
  maxError = maxError < IQlower ? IQlower : maxError;\
}%
/****************************************************************/
/****************************************************************/

ss P2RF_Calib
{

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * Init state.  Find the RFP module handle and register this task
   * as a client of the RFP module.  This allows collisions with other
   * registered users of the hardware to be properly handled;
   * nonregistered users cancreate havoc.
   *----------------------------------------------------------------
   */

  state Init
  {
    when () {

     {
%%    DBADDR       addr;
%%    char         dpvt[80];

      /* Get the pointer to the driver-private structure */
%%    sprintf (dpvt, "%s:STN:RFP:MODU.DPVT", seq_macValueGet (ssId, "STN"));
%%    dbNameToAddr (dpvt, &addr); /* To get around field marked NO_ACCESS */

%%    if ((drvPvt = **(void ***) addr.pfield) == NULL)
      {
        CAL_MSG("RFP record has not initialized");
        exit (-1);
      }

      /* Register this task as a client of the RFP module */
%%    if (P2RF_RegisterClient (drvPvt) != OK) exit (-1);

      /* restore previous ("current") status msg */
      if (calStatus == STT_OK     ) strncpy (calMsg, "Calibration Done",     sizeof (calMsg));
      if (calStatus == STT_ERROR  ) strncpy (calMsg, "Calibration Error",    sizeof (calMsg));
      if (calStatus == STT_ABORT  ) strncpy (calMsg, "Calibration Aborted",  sizeof (calMsg));
      if (calStatus == STT_COMBERR) strncpy (calMsg, "Cal Aborted - 1 Comb", sizeof (calMsg));
      if (calStatus == STT_NORF   ) strncpy (calMsg, "Cal Aborted - no RF",  sizeof (calMsg));
      pvPut(calMsg);
     }
    }  state Startup
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * This state starts the calibration sequence.
   * It is responsible for initialization of the calibration sequence
   * and sets the hardware to a known state.
   *----------------------------------------------------------------
   */

  state Startup
  {
    when (doCalib && rfEnb) {

      /*  If calibration is requested but RF is ON, reset the calibration
       *  request, output a message, and go back to wait for another
       *  request.
       */
      CAL_MSG("RF must be OFF");
      pvSet(doCalib,0);
    } state Startup

    when (doCalib) {

      calStatus = STT_OK;	/* init status ... don't pvPut() until end */

/*    pvSet(calAbort,0);*/
      rfAbort = 0;

    } state CombCheck
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * This state checks for missing combs... zero or two combs are
   * allowed; only one is an error.
   *----------------------------------------------------------------
   */

  state CombCheck
  {
    when () {

      /* count comb modules, via PV severities */
      numComb = 0;
      for (i = 0; i < 2; i++) {
        pvGet(cfm_sevr[i]);
        if (cfm_sevr[i] < 3) numComb++;
      }

      if (numComb == 1) {		/* only 1 comb, error... */
        CAL_MSG("Only one COMB detected");
        calStatus = STT_COMBERR;
      }

    } state Startup2
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * Continue startup.
   *----------------------------------------------------------------
   */

  state Startup2
  {
    when (calStatus != STT_OK) {
    } state Abend

    when () {

      /* Allocate a buffer to take data in */
%%    bufDsc = (P2RfBufDsc *)calloc(1,sizeof(*bufDsc)+(COUNT*sizeof(*bufDsc->buffer)));
%%    if (bufDsc) {
%%      printf ("%s - Buffer descriptor located at %08x\n", FN, (int)bufDsc);
%%      bufDsc->count  = COUNT;
%%      bufDsc->buffer = (short *) &bufDsc[1];
%%      bufDsc->self   = bufDsc;
%%    }
%%    else {
        CAL_MSG("Insufficient Memory");
        calStatus = STT_ERROR;
%%    }
    }  state Setup
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * This state sets up the RFP module for calibration.
   *----------------------------------------------------------------
   */

  state Setup
  {
    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("Setup");

      pvSet(gvffi,0);		/* Set gap voltage outputs to zero */
      pvSet(gvffq,0);

      pvSet(gvffState,1);	/* Set gap voltage module to run */

      /* Initialize the following to a safe state */

/*............. verify ALL saved (& restored!) ....................................*/

      pvSav(fbSig,fbSigSave);

      pvSav(dacs,dacsSave);
      pvSet(dacs, OFF);

      pvSet(dirLp,OFF);
      pvSet(cmbLp,OFF);

      pvSav(ripLp,  ripLpSave  );	pvSet(ripLp,  OFF);
      pvSav(ldComp, ldCompSave );	pvSet(ldComp, OFF);
      pvSav(intComp,intCompSave);	pvSet(intComp,OFF);
      pvSav(ssCont, ssContSave );	pvSet(ssCont, SGL_SHOT);

      pvSav(tuneSetpt[0],tuneSetptSave[0]);
      pvSav(tuneSetpt[1],tuneSetptSave[1]);

      pvSav(amplSetpt,amplSetptSave);
      printf("original AMSP = %f\n",amplSetptSave);

      for (i = 0; i < 4; i++) {
        pvSav(dirLpCoef[i], dirLpCoefSave[i]);	/* Save original direct coefficients values */
        pvSav(combLpCoef[i],combLpCoefSave[i]);	/* Save original comb coefficients values */
      }

#if DOCOMB
      for (i = 0; i < 2; i++) {
        pvSav(cmbSel  [i], cmbSelSave  [i]);
        pvSav(cmbState[i], cmbStateSave[i]);
        pvSav(cmbGain [i], cmbGainSave [i]);
        pvSav(cmbDelay[i], cmbDelaySave[i]);
      }
#endif

%%    for (cav = 0; cav < P2RF_K_CAVCNT; cav++) { /* Set combiner coefficients to zero for each cav */
%%      for (i = 0; i < 4; i++) {
          pvSav(comCoef[4*cav+i], comCoefSave[cav][i]);
          pvSet(comCoef[4*cav+i],0);
%%      }
%%    }

      LOD;		/* load octal DACs */

      pvGet(RfDspFile);	/* save original DSP filename */
      strcpy (origDspFile, RfDspFile);
      printf("original Dsp file is %s\n", origDspFile);

      strcpy (RfDspFile, rippleRfp);	/* load RFP DSP with rippleRfp file and set for constant operation*/
      pvPut(RfDspFile);
      pvSet(lodDsp,1);

%%    DELAY_5SEC;	/* wait for file to load - 5 seconds */

      printf("loading DSP with %s\n",RfDspFile);

      pvSet(amplSetpt,0.5);	/* set to half scale */
      pvSet(lodAmsp,1);

    } state ZeroCavMults
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * This state zeros the multiplier outputs for the cavity combiners.
   *----------------------------------------------------------------
   */

  state ZeroCavMults
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("ZeroCavMults");
      {
        /* For each cavity, zero the multiplier outputs */
        for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {

          IIcenter = 0;
          QIcenter = 0;
          IQcenter = 0;
          QQcenter = 0;

          delta = RANGE;

          for (i = 0; i < 4; i++) {
            pvSet(comCoef[4*cav+i],0);	/* zero combiner coefficients */
          }

          pvSet(cavSel,cav);	/* Set the analog multiplexer to the desired cavity */

          /* here is the main loop to null the multipliers */
          /* it is basically a 2-dimensional binary search */

          attemptCnt = ZERO_ATTEMPTS;
%%        while (attemptCnt-- > 0)
          {
            CHECK_ABORT;

            /* first we measure the II and QQ endpoints */
            /* offset DACs set to II/QQcenter + delta and II/QQcenter - delta) */
    
            /* set multiplier offsets to center value + delta */
            /* for testing I will use the cavity combiner coefficeints */
            /* eventually this will need to be replaced by the offset locations */

            SET_CAV_OFFSETS(comOfset,delta,0,delta,0);

            SET_GAIN_OFFSETS(MAX_DAC,0);	/* set gain stage I offsets to max */
            LOD;			/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,IImax,IQmax);

            SET_GAIN_OFFSETS(MIN_DAC,0);	/* set gain stage I offsets to min */
            LOD;		/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,IImin,IQmin);

            /* store the proper values of peak to peak measurements */
%%          IIupper = abs(IImax - IImin);
%%          IQupper = abs(IQmax - IQmin);

            /* set multiplier offsets to center value - delta */
            SET_CAV_OFFSETS(comOfset,-delta,0,-delta,0);

            SET_GAIN_OFFSETS(MAX_DAC,0);	            /* set gain stage I offsets to max */
            LOD;		/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,IImax,IQmax);

            SET_GAIN_OFFSETS(MIN_DAC,0);	            /* set gain stage I offsets to min */
            LOD;		/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,IImin,IQmin);

            /* store the proper values of peak to peak measurements */
%%          IIlower = abs(IImax - IImin);
%%          IQlower = abs(IQmax - IQmin);

/*
%%          printf("iteration = %d, IImax = %d,  IImin = %d, "
%%                 "IQmax = %d, IQmin = %d, IIlower = %d, IQlower = %d\n", 
%%                  attemptCnt,
%%                  IImax, IImin, IQmax, IQmin, IIlower, IQlower);
*/

            /* based on II/QQ upper/lower measurements find new II/QQcenter */
            RECENTER(II);
            RECENTER(IQ);

            /* now we measure the QI and QQ endpoints */
            /* offset DACs set to QI/QQcenter + delta and QI/QQcenter - delta) */
    
            /* set multiplier offsets to center value + delta */
            /* for testing I will use the cavity combiner coefficeints */
            /* eventually this will need to be replaced by the offset locations */

            SET_CAV_OFFSETS(comOfset,0,delta,0,delta);

            SET_GAIN_OFFSETS(0,MAX_DAC);	            /* set gain stage Q offsets to max */
            LOD;			/* load octal DACs */
            TAKE_DATA(0);		/* Take some data */
            GET_IQ(CAV,QImax,QQmax);

            SET_GAIN_OFFSETS(0,MIN_DAC);	            /* set gain stage Q offsets to min */
            LOD;		/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,QImin,QQmin)

            /* store the proper values of peak to peak measurements */
%%          QIupper = abs(QImax - QImin);
%%          QQupper = abs(QQmax - QQmin);

            /* set multiplier offsets to center value - delta */
            /* for testing I will use the cavity combiner coefficeints */
            /* eventually this will need to be replaced by the offset locations */

            SET_CAV_OFFSETS(comOfset,0,-delta,0,-delta);

            SET_GAIN_OFFSETS(0,MAX_DAC);	            /* set gain stage Q offsets to max */
            LOD;		/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,QImax,QQmax);

            SET_GAIN_OFFSETS(0,MIN_DAC);	            /* set gain stage Q offsets to min */
            LOD;		/* load octal DACs */
            TAKE_DATA(0);            /* Take some data */
            GET_IQ(CAV,QImin,QQmin);

            /* store the proper values of peak to peak measurements */
%%          QIlower = abs(QImax - QImin);
%%          QQlower = abs(QQmax - QQmin);

#if 0
%%          printf("iteration = %d\n IIupper = %d IIlower = %d\n"
%%                 " QQupper = %d QQlower = %d\n"
%%                 " QIupper = %d QIlower = %d\n"
%%                 " IQupper = %d IQlower = %d\n" , attemptCnt,
%%                   IIupper, IIlower, QQupper, QQlower,
%%                   QIupper, QIlower, IQupper, IQlower);
#endif

            /* based on II/QQ upper/lower measurements find new QI/IQcenter */
            RECENTER(QI);
            RECENTER(QQ);

%%          delta = delta/2;	/* chop search area before next attemptCnt */
%%          if (delta < 2) delta = 2;  /* allow for fine tuning near end of search */

          } /* end attemptCnt while() loop */

          FIND_MAXERROR;

%%        if (maxError > ERROR_TOLERANCE) {
%%          epicsPrintf ("%s: Cavity %d %s failed  due to maxError = %d\n",
%%                       FN, cav+1, "Multiplier Zeroing", maxError);
            CAL_MSG("Cavity Multiplier Zeroing failed");
            calStatus = STT_ERROR;
%%        }
%%        else {
%%          printf ("%s: Cavity %d %s multiplier offset set to %d\n", FN, cav+1, "II", comOfset[4*cav+0]);
%%          printf ("%s: Cavity %d %s multiplier offset set to %d\n", FN, cav+1, "IQ", comOfset[4*cav+1]);
%%          printf ("%s: Cavity %d %s multiplier offset set to %d\n", FN, cav+1, "QI", comOfset[4*cav+2]);
%%          printf ("%s: Cavity %d %s multiplier offset set to %d\n", FN, cav+1, "QQ", comOfset[4*cav+3]);
%%        }

          SET_GAIN_OFFSETS(0,0);	          /* set gain stage offsets back to zero */

        } /* end cavity for() loop */
      }
%%ABORT: ;;
    } state ZeroDirMults
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  This state zeros the multiplier outputs for the direct loop
   *----------------------------------------------------------------
   */

  state ZeroDirMults
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("ZeroDirMults");
      {
        IIcenter = 0;
        QIcenter = 0;
        IQcenter = 0;
        QQcenter = 0;

        delta    = RANGE;

        for (i = 0; i < 4; i++) {
          pvSet(dirLpCoef[i], 0);	/* Set direct combiner coefficients to zero */
        }

        pvSet(fbSig, TOTAL);	/* Set the analog multiplexer to TOTAL */

        /* here is the main loop to null the multipliers */
        /* it is basically a 2-dimensional binary search */

        attemptCnt = ZERO_ATTEMPTS;
        while (attemptCnt-- > 0) {

          CHECK_ABORT;

          /* first we measure the II and IQ endpoints */
          /* offset DACs set to II/IQcenter + delta and II/IQcenter - delta) */
    
          SET_IQ_OFFSETS(dirLpOfset,delta,0,delta,0);

          SET_TWO_VALS(comOutOs, MAX_DAC_SMALL, 0);	/* set summing node I offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImax,IQmax);

          SET_TWO_VALS(comOutOs, MIN_DAC_SMALL, 0);	/* set summing node I offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImin,IQmin);

          /* store the proper values of peak to peak measurements */
%%        IIupper = abs(IImax - IImin);
%%        IQupper = abs(IQmax - IQmin);

/*
%%        printf("iteration: %d, IImax: %d,  IImin: %d, IQmax: %d, IQmin: %d, IIupper: %d, IQupper: %d\n", 
%%                attemptCnt, Imax, IImin, IQmax, IQmin, IIupper, IQupper);
*/

          SET_IQ_OFFSETS(dirLpOfset,-delta,0,-delta,0);

          SET_TWO_VALS(comOutOs, MAX_DAC_SMALL, 0);	/* set summing node I offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImax,IQmax);

          SET_TWO_VALS(comOutOs, MIN_DAC_SMALL, 0);	/* set summing node I offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImin,IQmin);

          /* store the proper values of peak to peak measurements */
%%        IIlower = abs(IImax - IImin);
%%        IQlower = abs(IQmax - IQmin);

/*
%%        printf("iteration: %d, IImax: %d,  IImin: %d, IQmax: %d, IQmin: %d, IIlower: %d, IQlower: %d\n", 
%%                attemptCnt, IImax, IImin, IQmax, IQmin, IIlower, IQlower);
*/

          /* based on II/QQ upper/lower measurements find new II/QQcenter ??? */
          RECENTER(II);
          RECENTER(IQ);

          /* now we measure the QI and QQ endpoints */
          /* offset DACs set to QI/QQcenter + delta and QI/QQcenter - delta) */
    
          SET_IQ_OFFSETS(dirLpOfset,0,delta,0,delta);

          SET_TWO_VALS(comOutOs, 0, MAX_DAC_SMALL);	/* set summing node Q offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImax,QQmax);

          SET_TWO_VALS(comOutOs, 0, MIN_DAC_SMALL);	/* set summing node Q offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImin,QQmin);

          /* store the proper values of peak to peak measurements */
%%        QIupper = abs(QImax - QImin);
%%        QQupper = abs(QQmax - QQmin);

/*
%%        printf("iteration: %d, QImax: %d,  QImin: %d, QQmax: %d, QQmin: %d, QIupper: %d, QQupper: %d\n", 
%%                attemptCnt, QImax, QImin, QQmax, QQmin, QIupper, QQupper);
*/

          SET_IQ_OFFSETS(dirLpOfset,0,-delta,0,-delta);

          SET_TWO_VALS(comOutOs, 0, MAX_DAC_SMALL);	/* set summing node Q offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImax,QQmax);

          SET_TWO_VALS(comOutOs, 0, MIN_DAC_SMALL);	/* set summing node Q offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImin,QQmin);

          /* store the proper values of peak to peak measurements */
%%        QIlower = abs(QImax - QImin);
%%        QQlower = abs(QQmax - QQmin);

/*
%%        printf("iteration: %d, QImax: %d,  QImin: %d, QQmax: %d, QQmin: %d, QIlower: %d, QQlower: %d\n", 
%%                attemptCnt, QImax, QImin, QQmax, QQmin, QIlower, QQlower);
*/

/*
%%        printf("iteration: %d\n IIupper: %d IIlower: %d\n"
%%               " QQupper: %d QQlower: %d\n"
%%               " QIupper: %d QIlower: %d\n"
%%               " IQupper: %d IQlower: %d\n" , attemptCnt,
%%                 IIupper, IIlower, QQupper, QQlower,
%%                 QIupper, QIlower, IQupper, IQlower);
*/

          /* based on II/QQ upper/lower measurements find new QI/IQcenter */
          RECENTER(QI);
          RECENTER(QQ);

%%        delta = delta/2;	/* chop search area before next attemptCnt */
%%        if (delta < 2) delta = 2;  /* allow for fine tuning near end of search */

        } /* end of the attemptCnt WHILE loop */

        FIND_MAXERROR;

%%      if (maxError > ERROR_TOLERANCE) {
%%        epicsPrintf ("%s: Direct %s failed  due to maxError =%d\n", FN, "Multiplier Zeroing", maxError);
          CAL_MSG("Direct Multiplier Zeroing failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: Direct %s multiplier offset set to %d\n", FN, "II", dirLpOfset[0]);
%%        printf ("%s: Direct %s multiplier offset set to %d\n", FN, "IQ", dirLpOfset[1]);
%%        printf ("%s: Direct %s multiplier offset set to %d\n", FN, "QI", dirLpOfset[2]);
%%        printf ("%s: Direct %s multiplier offset set to %d\n", FN, "QQ", dirLpOfset[3]);
%%      }

        SET_TWO_VALS(comOutOs, 0, 0);	        /* set summing node I and Q offsets to ZERO */
      }
%%ABORT: ;;
    } state DirectInitial
  }

/****************************************************************/
/****************************************************************/

  state DirectInitial
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("DirectInitial");

      for (i = 0; i < 4; i++) {	
        pvSet(dirLpCoef[i], 0);		/* Set direct coefficients to zero */
        pvSet(combLpCoef[i], 0);	/* Set comb coefficients to zero */
      }

      LOD;		/* load octal DACs */

      pvSet(fbSig, TOTAL);	/* Look at TOTAL feedback signal */

      /* Null with Direct Loop Control Offsets */
      {
        /* Get the current state */
        pvSav(dirLpCtlOs[0],iPrevX); %%iPrevY = 0.0;
        pvSav(dirLpCtlOs[1],qPrevX); %%qPrevY = 0.0;

%%      iNulled    = FALSE;
%%      qNulled    = FALSE;
%%      attemptCnt = MAX_ATTEMPTS;

%%      while (((!iNulled) || (!qNulled)) && (attemptCnt-- > 0))
        {
          CHECK_ABORT;
          TAKE_DATA(0);

          %{
            P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
            iNulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average I data */
                                        &iPrevY, &iPrevX, &dirLpCtlOs[0]);
            P2RF_WriteVme (drvPvt, RFP_I_SMPRELD, NULL);	/* Preload the state machine address counter */
            P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
            qNulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average Q data */
                                        &qPrevY, &qPrevX, &dirLpCtlOs[1]);
          }%

          pvPut(dirLpCtlOs[0]);
          pvPut(dirLpCtlOs[1]);

          LOD;
        } /* end while() */

%%      if (!(iNulled & qNulled)) {
%%        if (!iNulled) epicsPrintf("%s: Could not null I Direct Loop Control.\n",FN);
%%        if (!qNulled) epicsPrintf("%s: Could not null Q Direct Loop Control.\n",FN);
          CAL_MSG("Initial Direct Loop Control nulling failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: %s %s offset set to %d\n", FN, "I", "Direct Loop Control", dirLpCtlOs[0]);
%%        printf ("%s: %s %s offset set to %d\n", FN, "Q", "Direct Loop Control", dirLpCtlOs[1]);
%%      }
      }
%%ABORT: ;;
    } state ZeroCombMults
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  This state zeros the multiplier outputs for the comb loop
   *----------------------------------------------------------------
   */

  state ZeroCombMults
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when (numComb == 0) {
      printf ("\n%s: skipping ZeroCombMults ... no combs\n",FN);
    } state Combiner

    when () {
      CAL_MSG("ZeroCombMults");

#if DOCOMB
%%    {
        IIcenter = 0;
        QIcenter = 0;
        IQcenter = 0;
        QQcenter = 0;

        delta    = RANGE;

        /* Set both comb filters for THRU operation (no filtering) */
        pvSet(cmbState[0], COMB_LOAD);
        pvSet(cmbState[1], COMB_LOAD);

        /* set the delay to the minimum value */
        pvSet(cmbDelay[0], MIN_COMB_DELAY);
        pvSet(cmbDelay[1], MIN_COMB_DELAY);
        pvSet(cmbSel[0], THRU);
        pvSet(cmbSel[1], THRU);

        /* Set both comb filters for minimum gain */
        pvSet(cmbGain[0], COMB_GAIN);
        pvSet(cmbGain[1], COMB_GAIN);

        /* activate the comb filters */
        pvSet(cmbState[0], COMB_RUN);
        pvSet(cmbState[1], COMB_RUN);

        /* Set comb multiplier coefficients to zero */
        for (i = 0; i < 4; i++) {
          pvSet(combLpCoef[i], 0);
        }

        /* read out the current setting of the direct loop offsets */
        /* we will dither about these null settings to control errors */
        /* this will prevent combs from saturating */

        pvSav(dirLpCtlOs[0], directNullI);
        pvSav(dirLpCtlOs[1], directNullQ);

        pvSet(fbSig, COMB_OUT);	/* Set the analog multiplexer to COMB_OUT */

        /* here is the main loop to null the multipliers */
        /* it is basically a 2-dimensional binary search */

        attemptCnt = ZERO_ATTEMPTS;
%%      while (attemptCnt-- > 0)
        {
          CHECK_ABORT;

          /* first we measure the II and QQ endpoints */
          /* offset DACs set to II/QQcenter + delta and II/QQcenter - delta) */
    
          SET_IQ_OFFSETS(combLpOfset,delta,0,delta,0);
          LOD;		/* load octal DACs */

          /* set direct loop output I offset to null value + MAX_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI + MAX_COMB, directNullQ);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */
          GET_IQ(SIG,IImax,IQmax);
#if 0
P2RF_DumpBuf (bufDsc);
#endif

          /* set direct loop output I offset to null value + MIN_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI + MIN_COMB, directNullQ);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */

          GET_IQ(SIG,IImin,IQmin);

          /* store the proper values of peak to peak measurements */
%%        IIupper = abs(IImax - IImin);
%%        IQupper = abs(IQmax - IQmin);

/*
%%        printf("iteration: %d, IImax: %d,  IImin: %d, IQmax: %d, IQmin: %d, IIupper: %d, IQupper: %d\n", 
%%                attemptCnt, IImax, IImin, IQmax, IQmin, IIupper, IQupper);
*/
          SET_IQ_OFFSETS(combLpOfset,-delta,0,-delta,0);

          LOD;		/* load octal DACs */

          /* set direct loop output I offset to null value + MAX_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI + MAX_COMB, directNullQ);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */

          GET_IQ(SIG,IImax,IQmax);

          /* set direct loop output I offset to null value + MIN_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI + MIN_COMB, directNullQ);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */

          GET_IQ(SIG,IImin,IQmin);

          /* store the proper values of peak to peak measurements */
%%        IIlower = abs(IImax - IImin);
%%        IQlower = abs(IQmax - IQmin);

/*
%%        printf("iteration: %d, IImax: %d,  IImin: %d, IQmax: %d, IQmin: %d, IIlower: %d, IQlower: %d\n", 
%%                attemptCnt, IImax, IImin, IQmax, IQmin, IIlower, IQlower);
*/

          /* based on II/QQ upper/lower measurements find new II/QQcenter */
          RECENTER(II);
          RECENTER(IQ);

          /* now we measure the QI and QQ endpoints */
          /* offset DACs set to QI/QQcenter + delta and QI/QQcenter - delta) */
    
          SET_IQ_OFFSETS(combLpOfset,0,delta,0,delta);
          LOD;		/* load octal DACs */

          /* set direct loop output Q offset to null value + MAX_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI , directNullQ + MAX_COMB);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */
          GET_IQ(SIG,QImax,QQmax);

          /* set direct loop output Q offset to null value + MIN_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI, directNullQ + MIN_COMB);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */
          GET_IQ(SIG,QImin,QQmin);

          /* store the proper values of peak to peak measurements */
%%        QIupper = abs(QImax - QImin);
%%        QQupper = abs(QQmax - QQmin);

          SET_IQ_OFFSETS(combLpOfset,0,-delta,0,-delta);
          LOD;		/* load octal DACs */

          /* set direct loop output Q offset to null value + MAX_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI, directNullQ + MAX_COMB);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */
          GET_IQ(SIG,QImax,QQmax);

          /* set direct loop output Q offset to null value + MIN_COMB */
          SET_TWO_VALS(dirLpCtlOs, directNullI, directNullQ + MIN_COMB);

          TAKE_DATA(1);		/* load octal DACs after we begin to take data */
          GET_IQ(SIG,QImin,QQmin);

          /* store the proper values of peak to peak measurements */
%%        QIlower = abs(QImax - QImin);
%%        QQlower = abs(QQmax - QQmin);

/*
%%        printf("iteration: %d\n IIupper: %d IIlower: %d\n"
%%               " QQupper: %d QQlower: %d\n"
%%               " QIupper: %d QIlower: %d\n"
%%               " IQupper: %d IQlower: %d\n" , attemptCnt,
%%                 IIupper, IIlower, QQupper, QQlower,
%%                 QIupper, QIlower, IQupper, IQlower);
*/

          /* based on II/QQ upper/lower measurements find new QI/IQcenter */
          RECENTER(QI);
          RECENTER(QQ);

%%        delta = delta/2;	/* chop search area before next attemptCnt */
%%        if (delta < 2) delta = 2;  /* allow for fine tuning near end of search */

        } /* end of the attemptCnt WHILE loop */

        FIND_MAXERROR;

%%      if (maxError > ERROR_TOLERANCE * 4) {  /* allow more error - very sensitive */
%%        epicsPrintf ("%s: Comb %s failed  due to maxError = %d\n", FN, "Multiplier Zeroing", maxError);
#if 0
          CAL_MSG("Comb Multiplier Zeroing failed");
          calStatus = STT_ERROR;
#endif
%%      }

#if 0
        /* set multiplier offsets to fixed value for now */
        pvSet(combLpOfset[0], 26);		/* for the II path */
        pvSet(combLpOfset[2], 26);		/* for the QI path */
        pvSet(combLpOfset[1], 26);		/* for the IQ path */
        pvSet(combLpOfset[3], 26);		/* for the QQ path */
#endif

%%      printf ("%s: Comb %s multiplier offset set to %d\n", FN, "II", combLpOfset[0]);
%%      printf ("%s: Comb %s multiplier offset set to %d\n", FN, "IQ", combLpOfset[1]);
%%      printf ("%s: Comb %s multiplier offset set to %d\n", FN, "QI", combLpOfset[2]);
%%      printf ("%s: Comb %s multiplier offset set to %d\n", FN, "QQ", combLpOfset[3]);

        /* set direct loop output I and Q offsets to ZERO */
        pvSet(dirLpCtlOs[0], 0);	/* I path */
        pvSet(dirLpCtlOs[1], 0);	/* Q path */

%%ABORT: ;;

        /* reset comb settings */
        for (i = 0; i < 2; i++) {
          pvSet(cmbDelay[i], cmbDelaySave[i]);
          pvSet(cmbSel  [i], cmbSelSave  [i]);
          pvSet(cmbGain [i], cmbGainSave [i]);
          pvSet(cmbState[i], cmbStateSave[i]);
        }

%%    }

#else /* !DOCOMB */
      /* just jam coefs... per mjb 2005-04-28 (cop-out to deal w/CF2) */
#define ZCM_JAM 26
      printf ("\n(ZeroCombMults) *** DUMMY OFFSETS... set all to %d ***\n",ZCM_JAM);
      for (i = 0; i < 4; i++) {
        pvSet(combLpOfset[i],ZCM_JAM);
      }
#endif /* DOCOMB */

    } state Combiner
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  This state calibrates the combiners.
   *----------------------------------------------------------------
   */

  state Combiner
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("Combiner");
%%    {
        /* For each cavity, null out the output offsets */
%%      for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {

          pvSet(cavSel,cav);	/* Select a cavity */

          /* Set the current state to zero - preload the i/qPrevx/y */
          pvSet(comOutOs[2*cav+0], 0);	%%iPrevX = iPrevY = 0.0;
          pvSet(comOutOs[2*cav+1], 0);	%%qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        iNulled    = FALSE;
%%        qNulled    = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while (((!iNulled) || (!qNulled)) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
              P2RF_CopyMemory (drvPvt, RFP_I_CAVIRAM, bufDsc);	/* Read I data out */
              iNulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &comOutOs[2*cav+0]);
              P2RF_WriteVme   (drvPvt, RFP_I_SMPRELD, NULL);	/* Preload the state machine address counter */
              P2RF_CopyMemory (drvPvt, RFP_I_CAVQRAM, bufDsc);	/* Read Q data out */
              qNulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &comOutOs[2*cav+1]);
            }%

            /* Update DACs for all cavities and load them */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x, q = %h04x\n", FN, comOutOs[2*cav+0], comOutOs[2*cav+1]);*/
            pvPut(comOutOs[2*cav+0]);
            pvPut(comOutOs[2*cav+1]);
            LOD;
          }

%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s for cavity %d\n", FN, "I", "Combiner Output", cav);
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s for cavity %d\n", FN, "Q", "Combiner Output", cav);
            CAL_MSG("Combiner Output nulling failed");
            calStatus = STT_ERROR;
%%        }
%%        else {
%%          printf ("%s: Cavity %d %s %s offset set to %d\n", FN, cav+1, "I", "Combiner Output", comOutOs[2*cav+0]);
%%          printf ("%s: Cavity %d %s %s offset set to %d\n", FN, cav+1, "Q", "Combiner Output", comOutOs[2*cav+1]);
%%        }
%%      }
%%    }
%%ABORT: ;;
    } state Direct
  }

/****************************************************************/
/****************************************************************/

  state Direct
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("Direct");

      for (i = 0; i < 4; i++) {
        pvSet(dirLpCoef[i], 0);		/* Set direct coefficients to zero */
        pvSet(combLpCoef[i], 0);	/* Set comb coefficients to zero */
      }

      LOD;		/* load octal DACs */

      pvSet(fbSig, TOTAL);	/* Look at TOTAL feedback signal */

      /* Null with Direct Loop Control Offsets */
%%    {
        /* Get the current state */
        pvSav(dirLpCtlOs[0],iPrevX); %%iPrevY = 0.0;
        pvSav(dirLpCtlOs[1],qPrevX); %%qPrevY = 0.0;

%%      iNulled    = FALSE;
%%      qNulled    = FALSE;
%%      attemptCnt = MAX_ATTEMPTS;

%%      while (((!iNulled) || (!qNulled)) && (attemptCnt-- > 0))
        {
          CHECK_ABORT;
          TAKE_DATA(0);

          %{
            P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */

            iNulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average I data */
                                        &iPrevY, &iPrevX, &dirLpCtlOs[0]);

            P2RF_WriteVme (drvPvt,   RFP_I_SMPRELD, NULL);	/* Preload the state machine address counter */
            P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */

            qNulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average Q data */
                                        &qPrevY, &qPrevX, &dirLpCtlOs[1]);
          }%

          /* Update DACs for all cavities and load them */
          /* epicsPrintf ("%s: Updating DACs: i = %h04x, q = %h04x\n", FN, dirLpCtlOs[0], dirLpCtlOs[1]);*/
          pvPut(dirLpCtlOs[0]);
          pvPut(dirLpCtlOs[1]);
          LOD;
        }

%%      if (!(iNulled & qNulled)) {
%%        if (!iNulled) epicsPrintf ("%s: Could not null out %s %s. iNulled = %d\n", FN, "I", "Direct Loop Control", iNulled);
%%        if (!qNulled) epicsPrintf ("%s: Could not null out %s %s. qNulled = %d\n", FN, "Q", "Direct Loop Control", qNulled);
          CAL_MSG("Direct Loop Control nulling failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: %s %s offset set to %d\n", FN, "I", "Direct Loop Control", dirLpCtlOs[0]);
%%        printf ("%s: %s %s offset set to %d\n", FN, "Q", "Direct Loop Control", dirLpCtlOs[1]);
%%      }
%%    }
%%ABORT: ;;
    }  state SummingNodeI
  }

/****************************************************************/
/****************************************************************/

  state SummingNodeI
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("SummingNodeI");

      /* Set up direct coefficients */
      pvSet(dirLpCoef[0], MAX_DAC);
      pvSet(dirLpCoef[1], 0);
      pvSet(dirLpCoef[2], 0);
      pvSet(dirLpCoef[3], 0);

      LOD;		/* load octal DACs */

      pvSet(fbSig,TOTAL);	/* Look at TOTAL feedback signal */

      /* Null with Summing Node Offsets */
%%    {
        /* Get the current state */
        pvSav(sumNodeOs[0], prevX); %%prevY = 0.0;

%%      nulled     = FALSE;
%%      attemptCnt = MAX_ATTEMPTS;

%%      while ((!nulled) && (attemptCnt-- > 0))
        {
          CHECK_ABORT;
          TAKE_DATA(0);

          %{
            P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
            nulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average I data */
                                       &prevY, &prevX, &sumNodeOs[0]);
          }%

          /* Update DACs for all cavities and load them */
          /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, sumNodeOs[0]);*/
          pvPut(sumNodeOs[0]);
          LOD;
        }

%%      if (attemptCnt == 0) {
%%        if (!nulled) epicsPrintf ("%s: Could not null out %s %s\n", FN, "I", "Summing Node");
          CAL_MSG("I Summing Node nulling failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: %s %s offset set to %d\n", FN, "I", "Summing Node", sumNodeOs[0]);
%%      }
%%    }
%%ABORT: ;;
    }  state SummingNodeQ
  }

/****************************************************************/
/****************************************************************/

  state SummingNodeQ
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("SummingNodeQ");

      /* Set up direct coefficients */
      pvSet(dirLpCoef[0], 0);
      pvSet(dirLpCoef[1], 0);
      pvSet(dirLpCoef[2], 0);
      pvSet(dirLpCoef[3], MAX_DAC);

      LOD;		/* load octal DACs */

      pvSet(fbSig,TOTAL);	/* Look at TOTAL feedback signal */

      /* Null with Summing Node Offsets */
%%    {
        /* Get the current state */
        pvSav(sumNodeOs[1],prevX); %%prevY = 0.0;

%%      nulled     = FALSE;
%%      attemptCnt = MAX_ATTEMPTS;

%%      while ((!nulled) && (attemptCnt-- > 0))
        {
          CHECK_ABORT;
          TAKE_DATA(0);

          %{
             P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
             nulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average Q data */
                                        &prevY, &prevX, &sumNodeOs[1]);
          }%

          /* Update DACs for all cavities and load them */
          /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, sumNodeOs[1]);*/
          pvPut(sumNodeOs[1]);
          LOD;
        }

%%      if (attemptCnt == 0) {
%%        if (!nulled) epicsPrintf ("%s: Could not null out %s %s\n", FN, "Q", "Summing Node");
          CAL_MSG("Q Summing Node nulling failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: %s %s offset set to %d\n", FN, "Q", "Summing Node", sumNodeOs[1]);
%%      }
%%    }
%%ABORT: ;;
    }  state GainStageI
  }

/****************************************************************/
/****************************************************************/

  state GainStageI
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("GainStageI");
%%    {
%%      int cav;
%%
%%      /* Set up direct coefficients - allow I-I to pass */
        pvSet(dirLpCoef[0], MAX_DAC);
        pvSet(dirLpCoef[1], 0);
        pvSet(dirLpCoef[2], 0);
        pvSet(dirLpCoef[3], 0);

        for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {
          for (i = 0; i < 4; i++) {
            pvSet(comCoef[4*cav+i],0);	/* zero combiner coefficients for each cavity */
          }
        }

        LOD;		/* load octal DACs */

        pvSet(fbSig, TOTAL);	/* Look at TOTAL feedback signal */


%%      for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {	/* For each cavity, null with Gain Stage Offsets */

          pvSet(cavSel,cav);			/* Select a cavity */
          pvSet(comCoef[4*cav+0], MAX_DAC);	/* Set I Combiner Coefficient high */
          pvSet(gainStgOs[2*cav+0], 0);		/* Set the current state to zero*/

          LOD;

%%        prevX = prevY = 0;

%%        nulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

          while ((!nulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
               nulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average I data */
                                          &prevY, &prevX, &gainStgOs[2*cav+0]);
            }%

            /* Update DACs for all cavities and load them */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, gainStgOs[2*cav+0]);*/
            pvPut(gainStgOs[2*cav+0]);
            LOD;
          }

          if ((attemptCnt == 0) || nulled) {
            /* Set I Combiner Coefficient back to zero */
            pvSet(comCoef[4*cav+0], 0);	%%DELAY_167MS;
            LOD;

            /* Set II Direct Coefficient back to zero after the last cavity */
            if (cav == P2RF_K_CAVCNT-1) {
               pvSet(dirLpCoef[0], 0);
               LOD;
            }
%%          if (!nulled) {
%%              epicsPrintf ("%s: Could not null out %s %s for cavity %d\n", FN, "I", "Gain Stage", cav);
                CAL_MSG("I Gain Stage nulling failed");
                calStatus = STT_ERROR;
            }
%%          else {
%%              printf ("%s: Cavity %d %s %s offset set to %d\n", FN, cav+1, "I", "Gain Stage", gainStgOs[2*cav+0]);
%%          }
%%        }
%%      }
%%    }
%%ABORT: ;;
    }  state GainStageQ
  }

/****************************************************************/
/****************************************************************/

  state GainStageQ
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("GainStageQ");
%%    {
%%      int cav;
%%
%%      /* Set up direct coefficients - allow Q-Q to pass */
        pvSet(dirLpCoef[0], 0);
        pvSet(dirLpCoef[1], 0);
        pvSet(dirLpCoef[2], 0);
        pvSet(dirLpCoef[3], MAX_DAC);

        /* Set combiner coefficients to zero for each of the cavities */
        for (cav = 0; cav < 4; cav++) {
          for (i = 0; i < 2; i++) {
            pvSet(comCoef[4*cav+i], 0);
          }
        }

        LOD;		/* load octal DACs */

        pvSet(fbSig, TOTAL);	/* Look at TOTAL feedback signal */

%%      for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {	/* For each cavity, null with Gain Stage Offsets */

          pvSet(cavSel, cav);	/* Select a cavity */

          pvSet(comCoef[4*cav+3], MAX_DAC);	/* Set I Combiner Coefficient high */

          /* Set the current state to zero*/
          pvSet(gainStgOs[2*cav+1], 0);
          LOD;
%%        prevX = prevY = 0;

%%        nulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!nulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read I data out */
               nulled = P2RF_UpdateSetPt (bufDsc, MARGIN, GOAL,	/* Average I data */
                                           &prevY, &prevX, &gainStgOs[2*cav+1]);
            }%

            /* Update DACs for all cavities and load them */
            /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, gainStgOs[2*cav+1]);*/
            pvPut(gainStgOs[2*cav+1]);
            LOD;
          }

%%        if ((attemptCnt == 0) || nulled) {
            /* Set Q Combiner Coefficient back to zero */
            pvSet(comCoef[4*cav+3], 0);
            LOD;

            /* Set QQ Direct Coefficient back to zero after the last cavity */
            if (cav == P2RF_K_CAVCNT-1) {
               pvSet(dirLpCoef[3], 0);
               LOD;
            }
%%          if (!nulled) {
%%              epicsPrintf ("%s: Could not null out %s %s for cavity %d\n", FN, "Q", "Gain Stage", cav);
                CAL_MSG("Q Gain Stage nulling failed");
                calStatus = STT_ERROR;
%%          }
%%          else {
%%              printf ("%s: Cavity %d %s %s offset set to %d\n", FN, cav+1, "Q", "Gain Stage", gainStgOs[2*cav+1]);
%%          }
%%        }
%%      }
%%    }
%%ABORT: ;;
    }  state TuneStage
  }

/****************************************************************/
/****************************************************************/

  state TuneStage
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("TuneStage");
%%    {
%%       /* look at the DRIVE signals and use tuneSetptOs[0-1] to null 	*/
%%       /* value to null to is the measured value of the TUNE offset   */
%%       {
          pvSet(runMode, TUNE);	/* Set Station to TUNE mode to measure TUNE offset */

          SET_TWO_VALS(tuneSetpt,0,0);		/* Set TUNE_I and TUNE_Q to zero */

          pvSet(fbSig, DRIVE);	/* Look at DRIVE feedback signal */

%%        /* set the current state of the tune setpoint I offset to zero */
          pvSet(tuneSetptOs[0], 0);
%%        iPrevX = iPrevY = 0.0;

%%        /* set the current state of the tune setpoint Q offset to zero */
          pvSet(tuneSetptOs[1], 0);
%%        qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        /* first null the tune setpoint I output */
%%        iNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!iNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
               iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &tuneSetptOs[0]);
            }%

            /* Update DACs for tune setpoint I offset */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, tuneSetptOs[0]);*/
            pvPut(tuneSetptOs[0]);
            LOD;
          }

%%        /* next null the tune setpoint Q output */
%%        qNulled    = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!qNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
               qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &tuneSetptOs[1]);
            }%

            /* Update DACs for tune setpoint Q offset */
            /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, tuneSetptOs[1]);*/
            pvPut(tuneSetptOs[1]);
            LOD;
          }

%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "I", "Tune Setpoint");
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "Q", "Tune Setpoint");
            CAL_MSG("Tune setpoint nulling failed");
            calStatus = STT_ERROR;
%%        }
%%        else {
%%          printf ("%s: %s %s offset set to %d\n", FN, "Tune setpoint", "I", tuneSetptOs[0]);
%%          printf ("%s: %s %s offset set to %d\n", FN, "Tune setpoint", "Q", tuneSetptOs[1]);
%%        }
%%      }
%%    }
%%ABORT: ;;
    }  state ZeroKlysMults
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  This state zeros the multiplier outputs for the klystron modulator
   *----------------------------------------------------------------
   */

  state ZeroKlysMults
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("ZeroKlysMults");
%%    {
        IIcenter = 0;
        QIcenter = 0;
        IQcenter = 0;
        QQcenter = 0;

        delta    = RANGE;

        /* load RFP DSP with rippleRfp file set for no transmission */
        strcpy (RfDspFile, rippleRfp);
        pvPut(RfDspFile);
        pvSet(lodDsp, 1);
%%      DELAY_5SEC;	/* wait for file to load - 5 seconds */

        printf("loading DSP with %s\n",RfDspFile);
        pvSet(amplSetpt, 0);	/* set for no transmission */
        pvSet(lodAmsp, 1);

        pvSet(runMode, OPERATE);	/* Set Station to OPERATE mode */

        pvSet(fbSig, DRIVE);	/* Set the analog multiplexer to DRIVE */

        /* here is the main loop to null the multipliers */
        /* it is basically a 2-dimensional binary search */

        attemptCnt = ZERO_ATTEMPTS;
%%      while (attemptCnt-- > 0)
        {
          CHECK_ABORT;

          /* first we measure the II and IQ endpoints */
          /* offset DACs set to II/IQcenter + delta and II/IQcenter - delta) */
    
          SET_IQ_OFFSETS(klysModuOfset,delta,0,delta,0);

          QUADLOD;	/* load quad DACs */

          SET_TWO_VALS(compStgOs, MAX_DAC, 0);          /* set compensation stage I output offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImax,IQmax);

          SET_TWO_VALS(compStgOs, MIN_DAC, 0);          /* set compensation stage I output offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImin,IQmin);

          /* store the proper values of peak to peak measurements */
%%        IIupper = abs(IImax - IImin);
%%        IQupper = abs(IQmax - IQmin);

/*
%%        printf("iteration: %d, IImax: %d,  IImin: %d, IQmax: %d, IQmin: %d, IIupper: %d, IQupper: %d\n", 
%%                attemptCnt, IImax, IImin, IQmax, IQmin, IIupper, IQupper);
*/

          SET_IQ_OFFSETS(klysModuOfset,-delta,0,-delta,0);

          QUADLOD;	/* load quad DACs */

          /* set compensation stage I output offsets to max */
          pvSet(compStgOs[0], MAX_DAC);	/* I path */
          pvSet(compStgOs[1], 0);	/* Q path */

          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImax,IQmax);

          SET_TWO_VALS(compStgOs, MIN_DAC, 0);          /* set compensation stage I output offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,IImin,IQmin);

          /* store the proper values of peak to peak measurements */
%%        IIlower = abs(IImax - IImin);
%%        IQlower = abs(IQmax - IQmin);

/*
%%        printf("iteration: %d, IImax: %d,  IImin: %d, Qmax: %d, IQmin: %d, IIlower: %d, IQlower: %d\n", 
%%                attemptCnt, IImax, IImin, IQmax, IQmin, IIlower, IQlower);
*/

          /* based on II/QQ upper/lower measurements find new II/QQcenter */
          RECENTER(II);
          RECENTER(IQ);

          /* now we measure the QI and QQ endpoints */
          /* offset DACs set to QI/QQcenter + delta and QI/QQcenter - delta) */
    
          SET_IQ_OFFSETS(klysModuOfset,0,delta,0,delta);

          QUADLOD;	/* load quad DACs */

          SET_TWO_VALS(compStgOs, 0, MAX_DAC);          /* set compensation stage Q output offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImax,QQmax);

          SET_TWO_VALS(compStgOs, 0, MIN_DAC);          /* set compensation stage Q output offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImin,QQmin);

          /* store the proper values of peak to peak measurements */
%%        QIupper = abs(QImax - QImin);
%%        QQupper = abs(QQmax - QQmin);

/*
%%        printf("iteration: %d, QImax: %d,  QImin: %d, QQmax: %d, QQmin: %d, QIupper: %d, QQupper: %d\n", 
%%                attemptCnt, QImax, QImin, QQmax, QQmin, QIupper, QQupper);
*/

          SET_IQ_OFFSETS(klysModuOfset,0,-delta,0,-delta);

          QUADLOD;	/* load quad DACs */

          SET_TWO_VALS(compStgOs, 0, MAX_DAC);          /* set compensation stage Q output offsets to max */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImax,QQmax);

          SET_TWO_VALS(compStgOs, 0, MIN_DAC);          /* set compensation stage Q output offsets to min */
          LOD;		/* load octal DACs */
          TAKE_DATA(0);
          GET_IQ(SIG,QImin,QQmin);

          /* store the proper values of peak to peak measurements */
%%        QIlower = abs(QImax - QImin);
%%        QQlower = abs(QQmax - QQmin);

/*
%%        printf("iteration: %d, QImax: %d,  QImin: %d, QQmax: %d, QQmin: %d, QIlower: %d, QQlower: %d\n", 
%%                attemptCnt, QImax, QImin, QQmax, QQmin, QIlower, QQlower);
*/

/*
%%        printf("iteration: %d\n IIupper: %d IIlower: %d\n"
%%               " QQupper: %d QQlower: %d\n"
%%               " QIupper: %d QIlower: %d\n"
%%               " IQupper: %d IQlower: %d\n" , attemptCnt,
%%                 IIupper, IIlower, QQupper, QQlower,
%%                 QIupper, QIlower, IQupper, IQlower);
*/

          /* based on II/QQ upper/lower measurements find new QI/IQcenter */
          RECENTER(QI);
          RECENTER(QQ);

%%        delta /= 2;	/* chop search area before next attemptCnt */
%%        if (delta < 2) delta = 2;  /* allow for fine tuning near end of search */

        } /* end of the attemptCnt WHILE loop */

        FIND_MAXERROR;

%%      if (maxError > ERROR_TOLERANCE * 2) {  /* allow more tolerance - sensitive! */
%%        epicsPrintf ("%s: Klystron %s failed  due to maxError =%d\n", FN, "Multiplier Zeroing", maxError);
          CAL_MSG("Klystron Multiplier Zeroing failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: Klystron modulator %s multiplier offset set to %d\n", FN, "II", klysModuOfset[0]);
%%        printf ("%s: Klystron modulator %s multiplier offset set to %d\n", FN, "IQ", klysModuOfset[1]);
%%        printf ("%s: Klystron modulator %s multiplier offset set to %d\n", FN, "QI", klysModuOfset[2]);
%%        printf ("%s: Klystron modulator %s multiplier offset set to %d\n", FN, "QQ", klysModuOfset[3]);
%%      }

        /* set compensation stage I and Q output offsets to ZERO */
        pvSet(compStgOs[0], 0);	/* I path */
        pvSet(compStgOs[1], 0);	/* Q path */

        LOD;		/* load octal DACs */
%%    }
%%ABORT: ;;
    } state DiffNodeOffsets
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * new state [lazmo 2004-09-10]
   *----------------------------------------------------------------
   */

  state DiffNodeOffsets
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("DiffNodeOffsets");

      /* multiple retries needed here for now............. */
%%    for (try = 0; try < NUM_TRIES; try++)
%%    {

         printf("%s: try %d ...\n",FN,try);

         /* look at the ERROR_SUM signals and use diffNodeOs[0-1] to null 	*/
%%       {
          pvSet(fbSig, ERROR_SUM);	/* Look at ERROR_SUM feedback signal */

          /* first null the difference node I output */
          /* intialize the search variables             */
%%        iPrevX = iPrevY = 0.0;
%%        qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        /* first null the difference node I output */
%%        iNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!iNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
               iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &diffNodeOs[0]);
            }%
            /* Update DACs for klystron modulator I offset */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, diffNodeOs[0]);*/
            pvPut(diffNodeOs[0]);
            LOD;
           }

          /* next null the difference node Q output */
%%        qNulled    = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!qNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
               qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &diffNodeOs[1]);
            }%

            /* Update DACs for difference node Q offset */
            /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, diffNodeOs[1]);*/
            pvPut(diffNodeOs[1]);
            LOD;
          }

/*---------------------*/
	if (try == NUM_TRIES-1) {
%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "I", "Difference Node");
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "Q", "Difference Node");
            CAL_MSG("Difference Node nulling failed");
            calStatus = STT_ERROR;
%%        }
        }
%%      printf ("%s: %s %s offset set to %d\n", FN, "Difference Node", "I", diffNodeOs[0]);
%%      printf ("%s: %s %s offset set to %d\n", FN, "Difference Node", "Q", diffNodeOs[1]);
/*---------------------*/

%%      }
%%    }

%%ABORT: ;;
    } state KlysStage
  }

/****************************************************************/
/****************************************************************/

  state KlysStage
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("KlysStage");
%%    {
         /* look at the DRIVE signals and use klysModuOs[0-1] to null 	*/
         /* the RFP DSP must be loaded with file to zero klystron     	*/
         /* modulator multiplier weights - set station to OPERATE	*/
         /* value to null to is the measured value of the TUNE offset   */

%%       {
          pvSet(runMode,  OPERATE);	/* Set Station to OPERATE mode */
          pvSet(fbSig, DRIVE);		/* Look at DRIVE feedback signal */

          /* first null the klystron modulator I output */

          /* set the current state of the klystron modulator I offset to zero */
          pvSet(klysModuOs[0], 0);
%%        iPrevX = 0.0;
%%        iPrevY = 0.0;

          /* set the current state of the klystron modulator Q offset to zero */
          pvSet(klysModuOs[1], 0);
%%        qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        /* first null the klystron modulator I output */
%%        iNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!iNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
               iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &klysModuOs[0]);
            }%

            /* Update DACs for klystron modulator I offset */
            /* printf ("%s: Updating DACs: i = %h04x\n", FN, klysModuOs[0]); */
            pvPut(klysModuOs[0]);
            LOD;
          }

%%        /* next null the klystron modulator Q output */
%%        qNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!qNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
               qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &klysModuOs[1]);
            }%

            /* Update DACs for klystron modulator Q offset */
            /* printf ("%s: Updating DACs: q = %h04x\n", FN, klysModuOs[1]);*/
            pvPut(klysModuOs[1]);
            LOD;
          }

%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "I", "Klystron Modulator");
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "Q", "Klystron Modulator");
            CAL_MSG("Klystron Modulator offset nulling failed");
            calStatus = STT_ERROR;
%%        } else {
%%            printf ("%s: %s %s offset set to %d\n", FN, "Klystron Modulator", "I", klysModuOs[0]);
%%            printf ("%s: %s %s offset set to %d\n", FN, "Klystron Modulator", "Q", klysModuOs[1]);
%%        }

%%      }
%%    }
%%ABORT: ;;
    } state CompStage
  }

/****************************************************************/
/****************************************************************/

  state CompStage
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("CompStage");
%%    {
%%       /* look at the DRIVE signals and use compStgOs[0-1] to null 	*/
%%       /* the RFP DSP must be loaded with file to set klystron     	*/
%%       /* modulator multiplier weights to mid scale			*/
%%       {
          /* load RFP DSP with rippleRfp file set for constant transmission */
          strcpy (RfDspFile, rippleRfp);
          pvPut(RfDspFile);
          pvSet(lodDsp, 1);
%%        DELAY_5SEC;	/* wait for file to load - 5 seconds */

          printf("loading DSP with %s\n",RfDspFile);
          pvSet(amplSetpt, 0.5);	/* set for 1/2 scale operating point */
          pvSet(lodAmsp, 1);

          pvSet(runMode,  OPERATE);	/* Set Station to OPERATE mode */

          pvSet(fbSig, DRIVE);	/* Look at DRIVE feedback signal */

	  pvSet(intComp,ON);

          /* first null the compensation stage I output */
          /* intialize the search variables             */
%%        iPrevX = iPrevY = 0.0;
%%        qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        /* first null the compensation stage I output */
%%        iNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!iNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
               iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &compStgOs[0]);
            }%
            /* Update DACs for klystron modulator I offset */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, compStgOs[0]);*/
            pvPut(compStgOs[0]);
            LOD;
           }

          /* next null the compensation stage Q output */
%%        qNulled    = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!qNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
               qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &compStgOs[1]);
            }%

            /* Update DACs for compensation stage Q offset */
            /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, compStgOs[1]);*/
            pvPut(compStgOs[1]);
            LOD;
          }

	  pvSet(intComp,OFF);

%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "I", "Compensation Stage");
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "Q", "Compensation Stage");
            CAL_MSG("Compensation Stage nulling failed");
            calStatus = STT_ERROR;
%%        }
%%        else {
%%          printf ("%s: %s %s offset set to %d\n", FN, "Compensation Stage", "I", compStgOs[0]);
%%          printf ("%s: %s %s offset set to %d\n", FN, "Compensation Stage", "Q", compStgOs[1]);
%%        }

%%      }
%%    }
%%ABORT: ;;
    }  state Direct_Final
  }

/****************************************************************/
/****************************************************************/

  state Direct_Final
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("Direct_Final");

      for (i = 0; i < 4; i++) {	
        pvSet(dirLpCoef [i], 0);	/* Set direct coefficients to zero */
        pvSet(combLpCoef[i], 0);	/* Set comb coefficients to zero */
      }

      LOD;		/* load octal DACs */

      pvSet(dirLp, ON);	/* close the direct loop */
      %{ DELAY_100MS; }%

      pvSet(fbSig, DRIVE);	/* Look at DRIVE feedback signal */

      /* Null with Direct Loop Control Offsets */
      {
        /* Get the current state */
        pvSav(dirLpCtlOs[0],iPrevX); %%iPrevY = 0.0;
        pvSav(dirLpCtlOs[1],qPrevX); %%qPrevY = 0.0;

%%      iNulled    = FALSE;
%%      qNulled    = FALSE;
%%      attemptCnt = MAX_ATTEMPTS;

%%      while (((!iNulled) || (!qNulled)) && (attemptCnt-- > 0))
        {
          CHECK_ABORT;
          TAKE_DATA(0);

          %{
            P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
            iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average I data */
                                        &iPrevY, &iPrevX, &dirLpCtlOs[0]);
            P2RF_WriteVme (drvPvt, RFP_I_SMPRELD, NULL);	/* Preload the state machine address counter */
            P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
            qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average Q data */
                                        &qPrevY, &qPrevX, &dirLpCtlOs[1]);
          }%

          /* Update DACs for all cavities and load them */
          /* epicsPrintf ("%s: Updating DACs: i = %h04x, q = %h04x\n", FN, dirLpCtlOs[0], dirLpCtlOs[1]);*/

          pvPut(dirLpCtlOs[0]);
          pvPut(dirLpCtlOs[1]);
          LOD;
        }

        pvSet(dirLp, OFF);	/* open the direct loop */
        %{ DELAY_100MS; }%

%%      if (!(iNulled & qNulled)) {
%%        if (!iNulled) epicsPrintf ("%s: Could not null out %s %s. iNulled = %d\n", FN, "I", "Direct Loop Control", iNulled);
%%        if (!qNulled) epicsPrintf ("%s: Could not null out %s %s. qNulled = %d\n", FN, "Q", "Direct Loop Control", qNulled);
          CAL_MSG("Direct Loop Control nulling failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: %s %s offset set to %d\n", FN, "I", "Direct Loop Control", dirLpCtlOs[0]);
%%        printf ("%s: %s %s offset set to %d\n", FN, "Q", "Direct Loop Control", dirLpCtlOs[1]);
%%      }
      }
%%ABORT: ;;
    }  state CombStage
  }

/****************************************************************/
/****************************************************************/

  state CombStage
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when (numComb == 0) {
      printf ("\n%s: skipping CombStage ... no combs\n",FN);
    } state KlysDemod

    when () {
      CAL_MSG("CombStage");
%%    {
%%       /* look at the DRIVE signals and use combLpCtlOs[0-1] to null 	*/
%%       /* the RFP DSP must still be loaded with file to set klystron  */
%%       /* modulator multiplier weights to mid scale			*/
%%       {
          pvSet(fbSig, DRIVE);	/* Look at DRIVE signal */

#if DOCOMB
	  /* restore the normal comb configuration */
          for (i= 0 ; i < 2; i++) {
            pvSet(cmbSel  [i], cmbSelSave  [i]);
            pvSet(cmbGain [i], cmbGainSave [i]);
            pvSet(cmbState[i], cmbStateSave[i]);
          }
#endif

          pvSet(cmbLp, ON);	/* close the comb loop */
          %{ DELAY_100MS; }%

#if 0
	  pvSet(intComp,ON);
#endif

          /* first null the comb I output */

          SET_TWO_VALS(combLpCtlOs, 0, 0);	/* set the current state of the comb offsets to zero */

%%        iPrevX = iPrevY = 0.0;
%%        qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        /* first null the comb I output */
%%        iNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!iNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);		/* Read I data out */
               iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &combLpCtlOs[0]);
            }%

            /* Update DACs for comb I offset */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, combLpCtlOs[0]);*/
            pvPut(combLpCtlOs[0]);
            LOD;
          }

          /* next null the comb Q output */
%%        qNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!qNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
               qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &combLpCtlOs[1]);
            }%

            /* Update DACs for comb Q offset */
            /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, combLpCtlOs[1]);*/
            pvPut(combLpCtlOs[1]);
            LOD;
          }

          pvSet(cmbLp, OFF);	/* open the comb loop */
          %{ DELAY_100MS; }%

	  pvSet(intComp,OFF);

%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "I", "Comb Loop");
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "Q", "Comb Loop");
            CAL_MSG("Comb Loop nulling failed");
            calStatus = STT_ERROR;
%%        }
%%        else {
%%          printf ("%s: %s %s offset set to %d\n", FN, "Comb Loop", "I", combLpCtlOs[0]);
%%          printf ("%s: %s %s offset set to %d\n", FN, "Comb Loop", "Q", combLpCtlOs[1]);
%%        }
%%      }
%%    }

%%ABORT: ;;
    } state KlysDemod
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   * new state [lazmo 2004-09-10]
   *----------------------------------------------------------------
   */

  state KlysDemod
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    /*
     *  This state zeros ..........
     */
    when () {
      CAL_MSG("KlysDemod");
%%    {
%%       /* look at the KLYSTRON signals and use... klysDemodOs[0-1] to null 	*/

%%    for (try = 0; try < NUM_TRIES; try++)
%%    {
         printf("%s: try %d ...\n",FN,try);

          pvSet(fbSig, KLYSTRON);	/* Look at ERROR_SUM feedback signal */

          /* first null the klystron demod I output */
          /* intialize the search variables             */
%%        iPrevX = iPrevY = 0.0;
%%        qPrevX = qPrevY = 0.0;

          LOD;		/* load octal DACs */

%%        /* first null the klystron demod I output */
%%        iNulled     = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!iNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGIRAM, bufDsc);	/* Read I data out */
               iNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average I data */
                                          &iPrevY, &iPrevX, &klysDemodOs[0]);
            }%

            /* Update DACs for klystron modulator I offset */
            /* epicsPrintf ("%s: Updating DACs: i = %h04x\n", FN, klysDemodOs[0]);*/
            pvPut(klysDemodOs[0]);
printf("klysDemodOs[0]: %d\n",klysDemodOs[0]);
            LOD;
           }

          /* next null the klystron Q output */
%%        qNulled    = FALSE;
%%        attemptCnt = MAX_ATTEMPTS;

%%        while ((!qNulled) && (attemptCnt-- > 0))
          {
            CHECK_ABORT;
            TAKE_DATA(0);

            %{
               P2RF_CopyMemory (drvPvt, RFP_I_SIGQRAM, bufDsc);	/* Read Q data out */
               qNulled = P2RF_UpdateSetPt (bufDsc, BIG_MARGIN2, GOAL,	/* Average Q data */
                                          &qPrevY, &qPrevX, &klysDemodOs[1]);
            }%

            /* Update DACs for klystron Q offset */
            /* epicsPrintf ("%s: Updating DACs: q = %h04x\n", FN, klysDemodOs[1]);*/
            pvPut(klysDemodOs[1]);
printf("klysDemodOs[1]: %d\n",klysDemodOs[1]);
            LOD;
          }

/*---------------------*/
	if (try == NUM_TRIES-1) {
%%        if (!(iNulled & qNulled)) {
%%          if (!iNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "I", "Klystron Demod");
%%          if (!qNulled) epicsPrintf ("%s: Could not null out %s %s offset\n", FN, "Q", "Klystron Demod");
            CAL_MSG("Klystron Demod nulling failed");
            calStatus = STT_ERROR;
%%        }
        }
%%      printf ("%s: %s %s offset set to %d\n", FN, "Klystron Demod", "I", klysDemodOs[0]);
%%      printf ("%s: %s %s offset set to %d\n", FN, "Klystron Demod", "Q", klysDemodOs[1]);
/*---------------------*/

%%      }
%%    }

%%ABORT: ;;
    } state NullModulator
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  This state zeros the output of the RF modulator
   *----------------------------------------------------------------
   */

  state NullModulator
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
      CAL_MSG("NullModulator");
%%    {
        Icenter = 0;
        Qcenter = 0;
        delta = MODMAX;

        pvSet(runMode, TUNE);	/* Set Station to TUNE mode to measure TUNE offset */

        SET_TWO_VALS(tuneSetpt, 0, 0);		/* Set TUNE_I and TUNE_Q to zero */
        LOD;		/* load octal DACs */

        pvSet(rfEnb, OFF);	/* turn OFF RF to measure leakage to IQ detector */
%%      DELAY_1SEC;	/* Wait for IQ&A to update */

	/* measure the klystron drive I and Q leakage (RF is OFF) */
        pvSav(klysDriveI,iGoal);
        pvSav(klysDriveQ,qGoal);

%%      printf("Igoal = %d, Qgoal = %d\n",iGoal,qGoal);

        pvSet(rfEnb, ON);	/* turn ON RF to prepare to null modulator */

	/* check to see if RF is really ON...
	 */
        printf("P2RF_Calib: Checking for RF ON...\n");
        SET_TWO_VALS(tuneSetpt,256,256);	/* Set TUNE_I and TUNE_Q to SOMETHING */
        LOD;		/* load octal DACs */
%%      DELAY_1SEC;
        pvGet(klysDriveI);
        pvGet(klysDriveQ);
        SET_TWO_VALS(tuneSetpt,0,0);	/* Set TUNE_I and TUNE_Q to zero */
        if (((klysDriveI*klysDriveI)+(klysDriveQ*klysDriveQ)) < (500*500)) {
          printf("P2RF_Calib: no RF... aborting!\n");
          rfAbort  = 1;
          doCalib = 0;			/* abort */
          %{ goto ABORT; }%		/* goto! considered harmful?? :P */
        }
        printf("P2RF_Calib: RF is ON!\n");
        LOD;		/* load octal DACs */

        /* here is the main loop to null the multipliers */
        /* it is basically a 2-dimensional binary search */

        attemptCnt = ZERO_ATTEMPTS;
%%      while (attemptCnt-- > 0)
        {
          CHECK_ABORT;

          /* measure the I endpoints */
          /* offset DACs set to Icenter + delta and Icenter - delta) */
    
          SET_TWO_VALS(rfModuOs, Icenter + delta, Qcenter);   /* set modulator offsets to Icenter value + delta */
          LOD;		/* load octal DACs */
%%        DELAY_1SEC;	/* Wait for IQ&A to update */
          CHECK_ABORT;

          pvGet(klysDriveI);	/* Read data out */
          pvGet(klysDriveQ);
/*%%      printf("klysDriveI = %d    klysDriveQ =%d\n", klysDriveI, klysDriveQ);*/
%%        Iupper = abs(klysDriveI - iGoal) + abs(klysDriveQ - qGoal);

          SET_TWO_VALS(rfModuOs, Icenter - delta, Qcenter);  /* set modulator offsets to Icenter value - delta */
          LOD;		/* load octal DACs */
%%        DELAY_1SEC;	/* Wait for IQ&A to update */
          CHECK_ABORT;

          /* Read data out */
          pvGet(klysDriveI);
          pvGet(klysDriveQ);
/*%%      printf("klysDriveI = %d    klysDriveQ =%d\n", klysDriveI, klysDriveQ);*/
%%        Ilower = abs(klysDriveI - iGoal) + abs(klysDriveQ - qGoal);

          RECENTER(I);

          /* measure the Q endpoints */
          /* offset DACs set to Qcenter + delta and Qcenter - delta) */
    
          SET_TWO_VALS(rfModuOs, Icenter, Qcenter + delta);  /* set modulator offsets to Qcenter value + delta */
          LOD;		/* load octal DACs */
%%        DELAY_1SEC;	/* Wait for IQ&A to update */
          CHECK_ABORT;

          pvGet(klysDriveI);	/* Read data out */
          pvGet(klysDriveQ);
%%        Qupper = abs(klysDriveI - iGoal) + abs(klysDriveQ - qGoal);

          SET_TWO_VALS(rfModuOs, Icenter, Qcenter - delta);  /* set multiplier offsets to Qcenter value - delta */
          LOD;		/* load octal DACs */
%%        DELAY_1SEC;	/* Wait for IQ&A to update */
          CHECK_ABORT;

          pvGet(klysDriveI);	/* Read data out */
          pvGet(klysDriveQ);
%%        Qlower = abs(klysDriveI - iGoal) + abs(klysDriveQ - qGoal);

          RECENTER(Q);	/* based on Q upper/lower measurements find new Qcenter */

/*
%%        printf("iteration: %d, Delta: %d, Iupper: %d,  Ilower: %d, Qupper: %d, Qlower: %d, Icenter: %d, Qcenter: %d\n", 
%%                attemptCnt, pdelta, Iupper, Ilower, Qupper, Qlower, Icenter, Qcenter);
*/

%%        delta /= 2; /* chop search area before next attemptCnt */
%%        if (delta < 6) delta = 6;  /* allow for fine tuning near end of search */

        } /* end of the attemptCnt WHILE loop */

        pvSet(rfEnb, OFF);	/* turn OFF RF to finish */

        /* find the max of Iupper, Ilower, Qupper, Qlower */
        /*                 QIupper, QIlower, IQupper, IQlower */
        /* for error checking                                 */
        maxError = 0;
%%      maxError = maxError < Iupper ? Iupper : maxError;
%%      maxError = maxError < Ilower ? Ilower : maxError;
%%      maxError = maxError < Qupper ? Qupper : maxError;
%%      maxError = maxError < Qlower ? Qlower : maxError;

%%      if (maxError > ERROR_TOLERANCE * 12) {  /* very sensitive - increase tolerance */
%%        epicsPrintf ("%s: RF Modulator nulling failed  due to maxError =%d\n", FN, maxError);
          CAL_MSG("RF Modulator Nulling failed");
          calStatus = STT_ERROR;
%%      }
%%      else {
%%        printf ("%s: RF Modulator %s offset set to %d\n", FN, "I", rfModuOs[0]);
%%        printf ("%s: RF Modulator %s offset set to %d\n", FN, "Q", rfModuOs[1]);
%%      }
%%    }

%%ABORT: ;;
    }  state Finish
  }

/****************************************************************/
/****************************************************************/

  state Finish
  {
    when (doCalib == 0) {
    } state Abort

    when (calStatus != STT_OK) {
    } state Abend

    when () {
    } state Done
  }

/****************************************************************/
/****************************************************************/

  state Abort
  {
    when() {
      CAL_MSG("Aborting...");

      if (rfAbort) {
	calStatus = STT_NORF;
      }
      else {
	printf("%s: Operator Abort\n",FN);
	calStatus = STT_ABORT;
      }
    } state Done
  }

/****************************************************************/

  state Abend
  {
    when() {
/*    CAL_MSG("ERROR ABORT...");*/
    } state Done
  }

/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  This state completes the calibration and frees resources.
   *----------------------------------------------------------------
   */

  state Done
  {
    when ()
    {
/*printf ("\nState = Done\n");*/

      pvSet(rfEnb, OFF);	/* turn RF OFF */

      pvSet(runMode, TUNE);	/* Set RUNMODE to tune */

      /* Restore saved values ... */

      pvSet(fbSig,   fbSigSave);

      pvSet(dacs,    dacsSave);
      pvSet(ripLp,   ripLpSave);
      pvSet(ldComp,  ldCompSave);
      pvSet(intComp, intCompSave);

      pvSet(ssCont,  ssContSave);
      if (ssCont == CONTINUOUS) {
        pvSet(rfpStt,RESET);
        pvSet(rfpStt,LOAD);  %{DELAY_1TICK; }%
        pvSet(rfpStt,RUN);
      }

      for (cav = 0; cav < P2RF_K_CAVCNT; cav++) {	/* Restore combiner coefficients for each cavity */
        for (i = 0; i < 4; i++) {
          pvSet(comCoef[4*cav+i], comCoefSave[cav][i]);
        }
      }

      for (i = 0; i < 4; i++) {
        pvSet(dirLpCoef [i], dirLpCoefSave [i]);	/* Restore the direct coefficients */
        pvSet(combLpCoef[i], combLpCoefSave[i]);	/* Restore the comb coefficients */
      }

      LOD;		/* load octal DACs */

      /* restore the original DSP file */
      strcpy (RfDspFile, origDspFile);
      pvPut(RfDspFile);
      pvSet(lodDsp, 1);
%%    DELAY_5SEC;	/* wait for file to load - 5 seconds */
      printf("%s: restoring DSP with original file %s\n",FN,RfDspFile);

      pvSet(amplSetpt, amplSetptSave);	/* restore the ampl setpoint */
      pvSet(lodAmsp, 1);

#if DOCOMB
      pvSet(cmbState[0], COMB_LOAD);	/* Restore the COMB modules */
      pvSet(cmbState[1], COMB_LOAD);
      for (i = 0; i < 2; i++) {
        pvSet(cmbDelay[i], cmbDelaySave[i]);
        pvSet(cmbSel  [i], cmbSelSave  [i]);
        pvSet(cmbGain [i], cmbGainSave [i]);
        pvSet(cmbState[i], cmbStateSave[i]);
      }
#endif

      /* Free buffer */
%%    if (bufDsc) free (bufDsc);

      /* Indicate completion status */
      if (calStatus == STT_OK     ) strncpy (calMsg, "Calibration Done",    sizeof (calMsg));
      if (calStatus == STT_ERROR  ) strncpy (calMsg, "Calibration Error",   sizeof (calMsg));
      if (calStatus == STT_ABORT  ) strncpy (calMsg, "Calibration Aborted", sizeof (calMsg));
      if (calStatus == STT_COMBERR) strncpy (calMsg, "Aborted - 1 Comb",    sizeof (calMsg));
      if (calStatus == STT_NORF   ) strncpy (calMsg, "Cal Aborted - no RF", sizeof (calMsg));
      pvPut(calMsg);
      pvPut(calStatus);		/* for save/restore */

      /* timestamp it */
%%    epicsTimeGetCurrent(&curtstamp);
%%    epicsTimeToStrftime(timeOfDay, 32, "%m/%d/%Y %H:%M:%S", &curtstamp);
      strcpy(calTime,timeOfDay);
      pvPut(calTime);

      pvSet(doCalib,0);		/* reset calib/abort toggle button */

      printf("%s: Calibration sequence done\n\n",FN);

    } state Startup
  }
}

/* Exit procedure */
exit
{
  printf("%s: Calibration sequence task exiting\n",FN);
}

/****************************************************************/
/****************************************************************/
/****************************************************************/

  /*----------------------------------------------------------------
   *  Escaped code...
   *----------------------------------------------------------------
   */

%{

static int P2RF_UpdateSetPt (P2RfBufDsc     *bufDsc,
                             double          margin,
                             short           goal,
                             double         *lastAvg,
                             short          *lastSetPt,
                             short          *setPt)
/*
   Description
   -----------

   Parameters
   ----------

   Returns
   -------
*/
{
  double         m, b, tmp;
  double         avg = 0.0;
  int            count;
  short         *buf;

  /* Fatal error if the buffer descriptr is screwed up */
  if (bufDsc->self != bufDsc) {
    epicsPrintf ("%s: Bad buffer descriptor at %08x\n", FN, (unsigned int)bufDsc);
    exit (-1);
  }

  count = bufDsc->count;
  buf   = bufDsc->buffer;

  while (count--) avg += (*buf++ >> 4);

  avg /= bufDsc->count;

  /* If the new point is within the margin of the goal, return success */
  if ((goal - avg < margin) && (avg - goal < margin))  return (TRUE);

  /* If not within margin, and set point isn't changing, move away */
  if (*setPt == *lastSetPt) {
    *lastAvg  = avg;
    *setPt   ^= 0x0200;		/* was 0x0400 originally - Paul */
/*printf ("%s: lastAvg = avg = %f:  setpoint changed to %hd\n", FN, avg, *setPt);*/
    return (FALSE);
  }

  /* Calculate new slope and intercept */
  m = (avg - *lastAvg) / (*setPt - *lastSetPt);
  b = avg - m * *setPt;

/*printf ("%s: avg = %f, lastAvg = %f, setPt = %hd, lastSetPt = %hd\n", FN, avg, *lastAvg, *setPt, *lastSetPt);*/
/*printf ("%s: m = %f, b = %f\n", FN, m, b);*/

  /* Save current points and calculate new set point */
  *lastAvg   =  avg;
  *lastSetPt = *setPt;

  tmp        = (goal - b) / m;

  if      (tmp >= 2047.0)  *setPt =  2047;
  else if (tmp < -2048.0)  *setPt = -2048;
  else                     *setPt =  tmp;

/*printf ("%s: new setPt = %f = %hd\n", FN, tmp, *setPt);*/

  return (FALSE);
}

/****************************************************************/
/****************************************************************/

static short P2RF_AvgOffset (P2RfBufDsc     *bufDsc)
/*
   Description
   -----------
   averages the data in the P2RfBufDsc

   Parameters
   ----------
   pointer to the buffer

   Returns
   -------
   the average value rounded to the nearest integer value
*/
{
  double         avg = 0.0;
  int            count;
  short         *buf;

  /* Fatal error if the buffer descriptor is screwed up */
  if (bufDsc->self != bufDsc) {
    epicsPrintf ("%s: Bad buffer descriptor at %08x\n", FN, (unsigned int)bufDsc);
    exit (-1);
  }

  count = bufDsc->count;
  buf   = bufDsc->buffer;

  while (count--) avg += (*buf++ >> 4);

  avg /= bufDsc->count;

  return (short)((avg >= 0) ? (avg + 0.5) : (avg - 0.5));
}

/****************************************************************/
/****************************************************************/

static void P2RF_DumpBuf (P2RfBufDsc *bufDsc)
/*
   Description
   -----------
   dump buf

   Parameters
   ----------
   pointer to the buffer

   Returns
   -------
   nuttin
*/
{
  int            count;
  short         *buf;

  int i = 0;
  int n = 0;

printf("buffer dump:\n");

  /* Fatal error if the buffer descriptor is screwed up */
  if (bufDsc->self != bufDsc) {
    epicsPrintf ("%s: Bad buffer descriptor at %08x\n", FN, (unsigned int)bufDsc);
    exit (-1);
  }

  count = bufDsc->count;
  buf   = bufDsc->buffer;

#define STEP 100
  while (i < count) {
    printf("%s%d",((n%20)==0)?"\n":" ",(*buf >> 4));
    buf += STEP;
    i   += STEP;
    n++;
  }
  printf("\n\n");
}
}%

/****************************************************************/
/****************************************************************/
/****************************************************************/

/* end */
