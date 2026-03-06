**PPS Interface Upgrade Proposal for the SPEAR  High-Voltage Power Supply**  
**Meeting Date:** 5 March 2026  
**Prepared from:** Project team meeting transcript (focus on PPS discussion)  
**Presenter:** Ben Morris  
**Key Participants:** Faya Wang, Jim Sebek, Mark Larrus, and team  

### 1. Current System & Identified Issues
The existing PPS interface for the RF high-voltage power supply (HVPS) is located inside the Hoffman box:

- The PPS control cable is easily accessible and can be unplugged by anyone who opens the door.  
- Contactor control wiring is exposed on separate terminal strips.  
- The permit display is limited to a single light (does not show both channels clearly).  
- The interface is tied into the emergency-off circuit (violates current PPS rules).  

These issues make the setup non-standard and non-compliant with modern PPS expectations used elsewhere in the gallery and at NLCTA.

### 2. Proposed Standard Interface Solution
Adopt the exact interface design already approved and in use by the PPS group for the 6575 modulator and gallery systems.

**Interface Box Characteristics**
- Small Bud enclosure (≈6″ × 5″ × 4″).  
- Contains 4 relays, status LEDs (Permit A/B granted & enabled), and inhibit push-buttons.  
- Single board with one connector that the PPS group can lock with their collar.  
- Provides two independent permit channels + two read-back channels (dry contacts).  
- Completely isolated from the modulator/HVPS internals.  

**How it works**
- PPS supplies two enable signals → our box relays close the contactor circuits.  
- Our box returns four dry-contact confirmations (Permit A made, Permit B made, etc.).  
- PPS can independently inhibit either channel and verify the system drops off correctly.  
- The box is labeled “PPS Interface – RSWCF required to open” (standard PPS practice).

This box is identical (or functionally identical) to the blue PPS chassis used in the gallery, so the PPS group is already familiar with it.

### 3. Integration with HVPS & Termination Tank
Because the inhibit and safety-discharge wiring cannot be physically separated inside the existing HVPS and termination tank:

- Add a second relay in series with the inhibit/safety-discharge lines (one relay per channel).  
- Label those relays and the associated terminal-strip wiring “PPS Controlled – RSWCF required before work”.  
- Use PPS-provided cable tags on the relevant wires.  
- The extra relay contacts are fed to the HVPS controller PLC for status readout.  

This approach was successfully implemented at NLCTA in 2025 and was explicitly approved by Ed Chin’s group.

### 4. Benefits
- Meets all current PPS requirements (two independent channels, lockable interface, visible verification).  
- Eliminates the “unique RF situation” that the PPS group dislikes.  
- Provides clear visual feedback and independent inhibit capability.  
- Minimal new cabling; most changes are inside the existing Hoffman box or at the contactors.  
- Future maintenance is standardized and documented.

### 5. Next Steps & Required Approvals
1. **PPS Review Meeting** (immediate)  
   - Attendees: Ben Morris, Jim Sebek, Mark Larrus, Ed Chin (or Matt Satursky), and the current SSRL PPS lead (Jen Bohan / acting Protection Systems Leader).  
   - Present the schematic, box photo, labeling plan, and relay-addition details.  
   - Obtain written sign-off that the proposed interruption of the inhibit and safety-discharge circuits in the tank is acceptable.

2. **Safety Review**  
   - Full safety review (RSWCF) will be required once the design is frozen.

3. **Procedure Update**  
   - PPS group will update the validation procedure (step-by-step with pictures) for the new interface box.  
   - Existing validation method (remove permit → LED dims → contactor opens → voltage disappears) remains valid; only the interface box changes.

4. **Implementation**  
   - Fabricate one standard PPS interface box.  
   - Install second relays and labeling inside HVPS and termination tank.  
   - Integrate auxiliary contacts into the PLC.  
   - Perform PPS validation and sign-off before returning to service.

### 6. Photon-Side Note (brief)
The photon-side PBS/PPS will continue to use the existing Tom Rabideau / Jen Bohan process; no changes proposed in this discussion.

### Recommendation
The proposed solution is low-risk, uses a proven PPS-approved design, and resolves all compliance issues with minimal disruption. Once PPS sign-off is obtained, implementation can proceed quickly and be included in the next available downtime.

**Action Items**  
- Ben/Jim: Schedule PPS review meeting with Ed Chin/Matt Satursky + SSRL PPS lead (target: within 1–2 weeks).  
- Mark: Confirm PLC auxiliary contact availability.  
- Team: Update chassis schematic to show new relays and labeling.

This document captures the complete PPS discussion from the 5 March 2026 meeting and serves as the baseline for the design-review package.