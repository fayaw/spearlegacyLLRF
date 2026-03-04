# rfedmHvpsLabelsPvs

> **Source:** `hvps/architecture/designNotes/rfedmHvpsLabelsPvs.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Instructions for Saving Data to Diagnose RF Trips

## Introduction

We have diagnostics that allow us to correctly diagnose most of the causes of SPEAR beam trips caused by the RF and the high voltage power supply (HVPS).  However, there are still some trips for which we do not yet have adequate diagnostics.  This note documents some steps we should take to use existing software diagnostics to help diagnose further trips.
## RF Expert Panels

The RF system has many EPICS process variables (PVs), too many to usefully display on a user panel.  The operators have summarized the most important PVs and placed them on an RF Station EDM panel, shown in figure 1.  All of the PVs are available through a series of “expert” panels.  This series can be accessed by selecting the RF Detail button in the lower right-hand corner of RF Station.  This brings up the SPEAR RF Station panel shown in figure 2.  The information of interest for the HVPS can be accessed by selecting the HVPS button in the middle of the top row of SPEAR RF Station.  This brings up the SPEAR RF Klystron HVPS page shown in figure 3.  The information of interest is hopefully displayed on the EPICS PVs on that page.  If there is a trip of the RF station, a screen shot of SPEAR RF Klystron HVPS or a list of the faults that are displayed may be useful in diagnosing the cause of the trip.
Table 1 lists the labels of the various status bars on SPEAR RF Klystron HVPS, the PVs that they monitor, and a terse description of their meaning.

Figure :  RF Station EDM panel

Figure :  RF "expert" panel

Figure :  RF "expert" HVPS panel


| Panel Label | PV | Description |
| --- | --- | --- |
| Contactor Closed | SRF1:HVPSCONTACT:CLOSE:STAT | Aux. relay that closes when contactor closed |
| Contactor Open | SRF1:HVPSCONTACT:OPEN:STAT | Aux. relay that closes when contactor open |
| Contactor Status | SRF1:HVPSCONTACT:ON:STAT | Inverted value of contactor closed |
| Contactor Ready | SRF1:HVPSCONTACT:READY:STAT | Aux. relay closes when contactor can be closed |
| Over Voltage | SRF1:HVPS:VOLT:LTCH | HVPS voltage limit exceeded (reg. card) |
| Klystron Arc | SRF1:HVPSKLYS:ARC:LTCH | Klystron arc sensed (ground tank and LHS trigger board) |
| Transformer Arc | SRF1:HVPSXFORM:ARC:LTCH | Transformer arc sensed (HVPS and RHS trigger board) |
| Crowbar | SRF1:HVPS:CROWBAR:LTCH | Senses pulses to crowbar thyristors |
| Crowbar from RF | SRF1:HVPSRF:CROWBAR:LTCH | LLRF commanded crowbar to fire |
| Emergency Off | SRF1:HVPS:PANIC:LTCH | Status of mushroom switch in ground tank |
| AC Current | SRF1:HVPSAC:CURR:LTCH | 12.47 kVAC mains over-current trip |
| Over Temperature | SRF1:HVPS:TEMP:LTCH | Mechanical thermal switch in HVPS oil |
| Oil Level | SRF1:HVPSOIL:LEVEL:LTCH | Mechanical oil level switch in HVPS oil |
| Transformer Press | SRF1:HVPSXFORM:PRESS:LTCH | Slow HVPS oil overpressure |
| Transfer Vac/Press | SRF1:HVPSXFORM:VACM:LTCH | HVPS rapid overpressure and/or vacuum |
| Open Load | SRF1:HVPS:OPENLOAD:LTCH | Connection from HVPS to klystron is open |
| 12 kV Available | SRF1:HVPS12KV:VOLT:STAT | 12.47 kVAC measured on phase A |
| AC Auxiliary Power | SRF1:HVPSAC:POWER:STAT | Control power in HVPS controller |
| DC Auxiliary Power | SRF1:HVPSDC:POWER:STAT | HVPS controller DC supplies on |
| Enerpro Fast Inhibit | SRF1:HVPSENERFAST:ON:STAT | Enerpro board fast inhibit status |
| Enerpro Slow Start | SRF1:HVPSENERSLOW:START:STAT | Enerpro board soft start status |
| Supply Status | SRF1:HVPSSUPPLY:ON:STAT | Contactor turned on and some interlocks clear |
| Supply Ready | SRF1:HVPSSUPPLY:READY:STAT | Supply is ready to output HV |
| PPS | SRF1:HVPS:PPS:STAT | PPS chain is made up |
| SCR 1 | SRF1:HVPSSCR1:ON:STAT | Firing status of left side board thyristors |
| SCR 2 | SRF1:HVPSSCR2:ON:STAT | Firing status of right side board thyristors |

Table :  PVs corresponding to displayed status bars on SPEAR RF Klystron HVPS

> **Note:** This document contains embedded images that cannot be directly converted to text.
> Please refer to the original DOCX file for visual content.
