# enerproPhaseReferenceAdapter

> **Source:** `hvps/controls/enerpro/enerproPhaseReferenceAdapter.docx`

> **Format:** DOCX (converted to Markdown for AI readability)


## Enerpro Phase Reference Adapter

## Introduction

We will use a new, modern twelve pulse rectifier firing board from Enerpro, the FCOG1200, for the HVPS controller upgrade.  As with all Enerpro boards, the FCOG1200 requires phase references from the transformer secondaries in order to provide correct phasing of the thyristor triggers.  Our configuration is different.  We do not have phase references from the secondary transformers.  Rather we only have phase references from the primary transformer which shifts its phases  onto each of the secondary transformers.  Enerpro uses a one pole RC low pass filter on its board to shift the phases of the input phase references.  By using different valued resistors, we can use our primary phase references and advance and retard the phase shifts at the Enerpro phase detector by .  In order to do this, we need to build an adapter that has three inputs, six resistors, and six outputs.
## Monitor Signals

We have measured the phase reference signals on both HVPS1 and HVPS2 to be sinusoids with a peak-to-peak amplitude of about .  The existing circuit uses  resistors on the Enerpro board to reduce the voltage at the Enerpro phase detector.
## Adapter

We have calculated that we would have two sets of three each equal resistors.  One set will be   resistors to pins  of the Enerpro J7 and the other will be  resistors to pins  of J7.  Enerpro will also modify resistors on their board to match our input resistors.  The inputs of the two sets of resistors will be tied together at the three phase references.  (For more details, refer to enerproBoardHvps.docx.)
## Parts

Enerpro recommends using the TE Connectivity parts to match their mating connector.
Header J7 (mating connector): Enerpro P/N  C2MTAPLG08 TE CONNECTIVITY 3-640440-8
Connector P7 COVER Enerpro P/N C2MTACVR08 TE CONNECVITY P/N C2MTACVR08
In addition, TE Connectivity recommends their hand crimp tool TE Connectivity: P/N 58074-1 for assembling the connectors.




