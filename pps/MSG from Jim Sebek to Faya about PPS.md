MSG from Jim Sebek to Faya, forwarded from 2022 email thread with Matt Cyterski and Tracy Yott regarding PPS in spear HVPS controllers.
Date: 3/3/2026

Dear Faya,
Here is an email from 2022 when we started to initiate a discussion with Matt Cyterski (then the SSRL protections manager) and Tracy, his PPS deputy.  There was a meeting or two that followed this, but nothing else.  I think the documentation is still as it was four years ago.  I recall that, under a high voltage electrician lockout, we looked at some wiring in their local HVPS contactor controller.  I think that we verified some of the wiring to the input relays, but I do not think we verified their logic chain past that.  (Pre-pandemic, facilities had a project to redo their controller because some parts in it are obsolete.  But that project died during the pandemic.)
Jim


-------- Forwarded Message -------- 
Subject: 	pps in spear HVPS controllers
Date: 	Tue, 5 Jul 2022 14:51:58 -0700
From: 	Sebek, Jim <sebek@slac.stanford.edu>

To: 	Cyterski, Matthew D. <cyterski@slac.stanford.edu>, Yott, Tracy E. <yott@slac.stanford.edu>

CC: 	Larrus, Marc H. <larrus@slac.stanford.edu>



Dear Matt and Tracy,

Marc and I are in the process of rebuilding the HVPS controllers (Hoffman boxes) for spear.  This is part of a larger upgrade of the LLRF controls for spear.  The reason for the upgrade is to replace old and obsolete hardware with new hardware, improve the documentation, and make it easier for others to learn about the system and maintain it going forward.

The controllers contain the interface between your PPS system and our PPS controls and readbacks.  Reviewing the existing design, we are not convinced that the design meets current PPS standards.  We would like your opinion on this design before we make any plans to modify it.  We would like some guidance on what is acceptable and, if the current design is not, what we should do to make it acceptable.

The existing PPS system has two chains.  One chain goes to the input 12.47 kV contactor on the HVPS.  This removes power from the HVPS.  Since this contactor is such a large electro-mechanical object, it has its own controller, in the local switchgear, to operate and hold the contactor closed.  Removal of the first PPS chain interrupts the voltage on the contactor controller.  An auxiliary contact on the contactor returns the state to the PPS. The second chain goes to the output of the HVPS, which is the input to the klystron grid.  A high voltage electro-mechanical shorting switch made by Ross Engineering (Ross relay) shorts the HVPS output a few feet upstream of the klystron.  The PPS command initiates the sequence that opens the relay and it observes the status of this relay via another auxiliary contact.

Our questions about the implementation of this system center around two main issues.  First, the Ross relay command is first given to our Allen-Bradley PLC, which then closes a relay to provide 120 VAC to the Ross relay.  Our PLC is actually the device that energizes the relay.  Second, the wiring from the PPS system passes through our HVPS controller.  Wires go from the PPS interface to terminal strips in the controller and then out to the remote locations where the contactors and switches are.  We are not sure of the requirements for exposed PPS wiring inside of other electrical boxes.  We would like to be able to open up and work on our controller without initiating a rediation safety work control form and a system retest.  There may also be other issues of which we are unaware.

I am sending you a collection of documents on which we can base future discussions.  I have a word document that describes our current analysis of the system.  (This analysis is based on our existing documentation.  Not all of the documentation is known to be correct.  We have an action item to open up the input to the HVPS with the electricians during the downtime to verify the documentation.)  I am also sending along several other schematics.
wd7307900206 is the wiring diagram for the HVPS controller inside B118.
rossEngr713203 is a mature schematic of the 12.47 kV vacuum contactor and the location of the auxiliary coils.
gp4397040201 is a recent redrawing of the vacuum contactor controller
wd7307940600 is an interconnection diagram between the B118 controller and the termination tank
sd7307900501 is a schematic of the grounding (termination) tank
wd7307900103 is a larger interconnection diagram between the B118 controller and both the contactor disconnect and the termination tank

We have meetings every Wednesday at 10:00.  It may make sense to have a first meeting where we go over the document and some of the drawings just to introduce you to the system.  Then we can schedule a follow-up meeting during which we can discuss any required redesigns.  Are you two free tomorrow?  If so, I will send you the link for the meeting.  Also, please feel free to include anyone else on your side who should be involved in these discussions.

Thanks,
Jim

