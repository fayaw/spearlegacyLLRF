# HVPS Documentation Index - AI-Readable Format

> **Purpose:** This index catalogs all documents in the `hvps/` folder, converted to
> AI-readable markdown format. An AI can use this index to navigate the complete
> HVPS (High Voltage Power Supply) documentation set for the SPEAR3 synchrotron.

## System Overview

The SPEAR3 HVPS converts 3-phase 12.47 kV RMS AC input to up to -90 kV, 27 A DC
output for a 1.5 MW klystron. Key specifications:

- **Input:** 3-phase 12.47 kV RMS AC
- **Output:** Up to -90 kV DC, 27 A (2.5 MW)
- **Phase-shifting transformer:** 3.5 MVA, extended delta, ±15° shift
- **Rectifier transformers:** 2x 1.5 MVA open wye (T1, T2)
- **Phase control:** 12 thyristor stacks (14x Powerex T8K7 each)
- **Filter inductors:** 2x 0.3 H, 85 A
- **Output filter:** 4x 8 μF caps + 0.22 μF output cap
- **Protection:** Crowbar thyristors, MOVs

## Document Categories


### architecture/designNotes

- [`EnerproVoltageandCurrentRegulatorBoardNotes.md`](hvps/architecture/designNotes/EnerproVoltageandCurrentRegulatorBoardNotes.md)
- [`HoffmanBoxPPSWiring.md`](hvps/architecture/designNotes/HoffmanBoxPPSWiring.md)
- [`HoffmanBoxPowerDistribution.md`](hvps/architecture/designNotes/HoffmanBoxPowerDistribution.md)
- [`LLRFUpgradeTaskListRev0.md`](hvps/architecture/designNotes/LLRFUpgradeTaskListRev0.md)
- [`RFSystemMPSRequirements.md`](hvps/architecture/designNotes/RFSystemMPSRequirements.md)
- [`controllerFiberOpticConnections.md`](hvps/architecture/designNotes/controllerFiberOpticConnections.md)
- [`hoffmanTestingNotes.md`](hvps/architecture/designNotes/hoffmanTestingNotes.md)
- [`interfacesBetweenRFSystemControllers.md`](hvps/architecture/designNotes/interfacesBetweenRFSystemControllers.md)
- [`regulatorEnerproTestingNotes.md`](hvps/architecture/designNotes/regulatorEnerproTestingNotes.md)
- [`rfedmHvpsLabelsPvs.md`](hvps/architecture/designNotes/rfedmHvpsLabelsPvs.md)

### architecture/originalDocuments

- [`pepII supply.md`](hvps/architecture/originalDocuments/pepII supply.md)
- [`ps3413600102.md`](hvps/architecture/originalDocuments/ps3413600102.md)
- [`slac-pub-7591.md`](hvps/architecture/originalDocuments/slac-pub-7591.md)

### controls/enerpro

- [`MC34071-D.md`](hvps/controls/enerpro/MC34071-D.md)
- [`enerproBoardHvps.md`](hvps/controls/enerpro/enerproBoardHvps.md)
- [`enerproDiscussion07072022.md`](hvps/controls/enerpro/enerproDiscussion07072022.md)
- [`Closing the Loop.md`](hvps/controls/enerpro/enerproDocuments/Closing the Loop.md)
- [`E128_R_Schematic_11-14.md`](hvps/controls/enerpro/enerproDocuments/E128_R_Schematic_11-14.md)
- [`E640_F FCOG1200 Schematic (08-13-96).md`](hvps/controls/enerpro/enerproDocuments/E640_F FCOG1200 Schematic (08-13-96).md)
- [`E640_K FCOG1200 Schematic (09-30-09).md`](hvps/controls/enerpro/enerproDocuments/E640_K FCOG1200 Schematic (09-30-09).md)
- [`E640_L FCOG1200 Schematic (03-01-21).md`](hvps/controls/enerpro/enerproDocuments/E640_L FCOG1200 Schematic (03-01-21).md)
- [`FCOG1200 Auto Balance.md`](hvps/controls/enerpro/enerproDocuments/FCOG1200 Auto Balance.md)
- [`FCOG1200 Brochure.md`](hvps/controls/enerpro/enerproDocuments/FCOG1200 Brochure.md)
- [`OP-0102_FCOG6100_Op_Manual.md`](hvps/controls/enerpro/enerproDocuments/OP-0102_FCOG6100_Op_Manual.md)
- [`OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.md`](hvps/controls/enerpro/enerproDocuments/OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.md)
- [`PD720_FCOG6100_Prod_Gd_07-2017.md`](hvps/controls/enerpro/enerproDocuments/PD720_FCOG6100_Prod_Gd_07-2017.md)
- [`PHASE CONTROL THEORY.md`](hvps/controls/enerpro/enerproDocuments/PHASE CONTROL THEORY.md)
- [`bourbeauIEEE1983_04504257.md`](hvps/controls/enerpro/enerproDocuments/bourbeauIEEE1983_04504257.md)
- [`enerproPhaseReferenceAdapter.md`](hvps/controls/enerpro/enerproPhaseReferenceAdapter.md)

### documentation/hoistingRigging

- [`hoistingFormLiftPlanHVPSMainTankPlates.md`](hvps/documentation/hoistingRigging/hoistingFormLiftPlanHVPSMainTankPlates.md)
- [`mainTankLiftPlan.md`](hvps/documentation/hoistingRigging/mainTankLiftPlan.md)
- [`mainTankLiftPlan_vsdx.md`](hvps/documentation/hoistingRigging/mainTankLiftPlan_vsdx.md)

### documentation/mechanical

- [`39309 Auto Trans - dwg W39309-.md`](hvps/documentation/mechanical/39309 Auto Trans - dwg W39309-.md)
- [`39309 Auto Trans assy - dwg C36683-E.md`](hvps/documentation/mechanical/39309 Auto Trans assy - dwg C36683-E.md)
- [`39310 rect xfrmr #1 assy - dwg C36776-H.md`](hvps/documentation/mechanical/39310 rect xfrmr #1 assy - dwg C36776-H.md)
- [`39310 rect xfrmr - dwg W39310-.md`](hvps/documentation/mechanical/39310 rect xfrmr - dwg W39310-.md)
- [`39311 rect xfrmr #2 - dwg W39311-.md`](hvps/documentation/mechanical/39311 rect xfrmr #2 - dwg W39311-.md)
- [`39311 rect xfrmr #2 assy - dwg C36800-H.md`](hvps/documentation/mechanical/39311 rect xfrmr #2 assy - dwg C36800-H.md)
- [`39312(L1, L2) filter-current limiting choke - dwg W39312-C.md`](hvps/documentation/mechanical/39312(L1, L2) filter-current limiting choke - dwg W39312-C.md)
- [`39313 Power-filter rect assy - dwg B37020-E.md`](hvps/documentation/mechanical/39313 Power-filter rect assy - dwg B37020-E.md)
- [`Internal Layout - dwg D36942-E.md`](hvps/documentation/mechanical/Internal Layout - dwg D36942-E.md)

### documentation/plc

- [`CasselPLCCode.md`](hvps/documentation/plc/CasselPLCCode.md)
- [`CasselSymbolDatabase.md`](hvps/documentation/plc/CasselSymbolDatabase.md)
- [`Cassel_land.md`](hvps/documentation/plc/Cassel_land.md)
- [`PLC software discusion 1.md`](hvps/documentation/plc/PLC software discusion 1.md)
- [`hvpsMeasurements20220314.md`](hvps/documentation/plc/hvpsMeasurements20220314.md)
- [`hvpsPlcLabels.md`](hvps/documentation/plc/hvpsPlcLabels.md)
- [`plcNotesR1.md`](hvps/documentation/plc/plcNotesR1.md)

### documentation/procedures

- [`B514 HVPS EIP SR444-636-05 R1_20231019 (part 1) - signed.md`](hvps/documentation/procedures/B514 HVPS EIP SR444-636-05 R1_20231019 (part 1) - signed.md)
- [`B514 HVPS EIP SR444-636-05 R1_20231019 - audit.md`](hvps/documentation/procedures/B514 HVPS EIP SR444-636-05 R1_20231019 - audit.md)
- [`B514 SP2 HVPS SR-444-636-07 R1 (part 1) - signed.md`](hvps/documentation/procedures/B514 SP2 HVPS SR-444-636-07 R1 (part 1) - signed.md)
- [`B514 SP2 HVPS SR-444-636-07 R1 - audit.md`](hvps/documentation/procedures/B514 SP2 HVPS SR-444-636-07 R1 - audit.md)
- [`HVPSPJB20231004.md`](hvps/documentation/procedures/HVPSPJB20231004.md)
- [`Modulator6575-Template.md`](hvps/documentation/procedures/Modulator6575-Template.md)
- [`SPEAR HVPS Crowbar EWP 9-12-20203.md`](hvps/documentation/procedures/SPEAR HVPS Crowbar EWP 9-12-20203.md)
- [`SPEAR HVPS Phase Tank EWP 9-12-2023.md`](hvps/documentation/procedures/SPEAR HVPS Phase Tank EWP 9-12-2023.md)
- [`SPEAR HVPS main tank EWP 9-12-2023.md`](hvps/documentation/procedures/SPEAR HVPS main tank EWP 9-12-2023.md)
- [`SPEAR HVPS1 SR-444-636-06 R1_20240330 (part 1) - signed.md`](hvps/documentation/procedures/SPEAR HVPS1 SR-444-636-06 R1_20240330 (part 1) - signed.md)
- [`SPEAR HVPS1 SR-444-636-06 R1_20240330 - audit.md`](hvps/documentation/procedures/SPEAR HVPS1 SR-444-636-06 R1_20240330 - audit.md)
- [`SPEARHVPSCrowbarEWP20231005_bvt.md`](hvps/documentation/procedures/SPEARHVPSCrowbarEWP20231005_bvt.md)
- [`SPEARHVPSCrowbarEWP20231121.md`](hvps/documentation/procedures/SPEARHVPSCrowbarEWP20231121.md)
- [`SPEARHVPSMainTankEWP20231003_bvt.md`](hvps/documentation/procedures/SPEARHVPSMainTankEWP20231003_bvt.md)
- [`SPEARHVPSPhaseTankEWP20231121.md`](hvps/documentation/procedures/SPEARHVPSPhaseTankEWP20231121.md)
- [`SSRL_HVPS_EIP_SR4446360201R1_20230925 (part 1) - signed.md`](hvps/documentation/procedures/SSRL_HVPS_EIP_SR4446360201R1_20230925 (part 1) - signed.md)
- [`SSRL_HVPS_EIP_SR4446360201R1_20230925 - audit.md`](hvps/documentation/procedures/SSRL_HVPS_EIP_SR4446360201R1_20230925 - audit.md)
- [`Spear3HVPSComplexLockoutPermit.md`](hvps/documentation/procedures/Spear3HVPSComplexLockoutPermit.md)
- [`Spear3Spear1HVPSComplexLockoutPermit.md`](hvps/documentation/procedures/Spear3Spear1HVPSComplexLockoutPermit.md)
- [`Spear3Spear2HVPSComplexLockoutPermit.md`](hvps/documentation/procedures/Spear3Spear2HVPSComplexLockoutPermit.md)
- [`crowbarTankMaintenanceOutline.md`](hvps/documentation/procedures/crowbarTankMaintenanceOutline.md)
- [`phaseTankMaintenanceOutline.md`](hvps/documentation/procedures/phaseTankMaintenanceOutline.md)
- [`spear3HvpsHazards.md`](hvps/documentation/procedures/spear3HvpsHazards.md)
- [`spear3HvpsHazards_tex.md`](hvps/documentation/procedures/spear3HvpsHazards_tex.md)
- [`spearRfHvpsSwitchProcedureR0.md`](hvps/documentation/procedures/spearRfHvpsSwitchProcedureR0.md)
- [`sr4446360103jjs.md`](hvps/documentation/procedures/sr4446360103jjs.md)
- [`sr4446360104R0.md`](hvps/documentation/procedures/sr4446360104R0.md)
- [`sr4446360104R1.md`](hvps/documentation/procedures/sr4446360104R1.md)
- [`sr4446360104R2.md`](hvps/documentation/procedures/sr4446360104R2.md)
- [`sr4446360104R3.md`](hvps/documentation/procedures/sr4446360104R3.md)
- [`sr4446360201R1.md`](hvps/documentation/procedures/sr4446360201R1.md)
- [`sr44463602R2.md`](hvps/documentation/procedures/sr44463602R2.md)
- [`sr4446360301R1.md`](hvps/documentation/procedures/sr4446360301R1.md)
- [`sr4446360401R1.md`](hvps/documentation/procedures/sr4446360401R1.md)
- [`sr44463605R1.md`](hvps/documentation/procedures/sr44463605R1.md)
- [`sr44463606R1.md`](hvps/documentation/procedures/sr44463606R1.md)
- [`sr44463607R1.md`](hvps/documentation/procedures/sr44463607R1.md)
- [`SSRL_HVPS_EIP_SR4446360201R1_20230925 VALIDATED.md`](hvps/documentation/procedures/validated procedures/SSRL_HVPS_EIP_SR4446360201R1_20230925 VALIDATED.md)

### documentation/schematics

- [`sd2372301200.md`](hvps/documentation/schematics/sd2372301200.md)
- [`sd2372301401.md`](hvps/documentation/schematics/sd2372301401.md)
- [`sd7307900101.md`](hvps/documentation/schematics/sd7307900101.md)
- [`sd7307900501.md`](hvps/documentation/schematics/sd7307900501.md)
- [`sd7307930304.md`](hvps/documentation/schematics/sd7307930304.md)
- [`sd7307930402.md`](hvps/documentation/schematics/sd7307930402.md)
- [`sd7307930702.md`](hvps/documentation/schematics/sd7307930702.md)
- [`sd7307930801.md`](hvps/documentation/schematics/sd7307930801.md)
- [`sd7307931203.md`](hvps/documentation/schematics/sd7307931203.md)
- [`sd7307931301.md`](hvps/documentation/schematics/sd7307931301.md)
- [`sd7307940400.md`](hvps/documentation/schematics/sd7307940400.md)

### documentation/stackAssemblies

- [`StackDriver1sd73079103.md`](hvps/documentation/stackAssemblies/StackDriver1sd73079103.md)
- [`ad7307920100.md`](hvps/documentation/stackAssemblies/ad7307920100.md)
- [`ad7307920800.md`](hvps/documentation/stackAssemblies/ad7307920800.md)
- [`ad7307941600.md`](hvps/documentation/stackAssemblies/ad7307941600.md)
- [`pf7307921300.md`](hvps/documentation/stackAssemblies/pf7307921300.md)
- [`pf7307921702.md`](hvps/documentation/stackAssemblies/pf7307921702.md)
- [`pf7307922200.md`](hvps/documentation/stackAssemblies/pf7307922200.md)
- [`pf7307922900.md`](hvps/documentation/stackAssemblies/pf7307922900.md)
- [`pf7307932201.md`](hvps/documentation/stackAssemblies/pf7307932201.md)

### documentation/switchgear

- [`DB41-122m    MCO.md`](hvps/documentation/switchgear/DB41-122m    MCO.md)
- [`DOC041421-04142021114320.md`](hvps/documentation/switchgear/DOC041421-04142021114320.md)
- [`gp3085000103.md`](hvps/documentation/switchgear/gp3085000103.md)
- [`gp4397040201.md`](hvps/documentation/switchgear/gp4397040201.md)
- [`id3088010601.md`](hvps/documentation/switchgear/id3088010601.md)
- [`rossEngr713203.md`](hvps/documentation/switchgear/rossEngr713203.md)

### documentation/wiringDiagrams

- [`ei7307900000.md`](hvps/documentation/wiringDiagrams/ei7307900000.md)
- [`hvpsMonitorConnections.md`](hvps/documentation/wiringDiagrams/hvpsMonitorConnections.md)
- [`wd7307900103.md`](hvps/documentation/wiringDiagrams/wd7307900103.md)
- [`wd7307900206.md`](hvps/documentation/wiringDiagrams/wd7307900206.md)
- [`wd7307940200.md`](hvps/documentation/wiringDiagrams/wd7307940200.md)
- [`wd7307940300.md`](hvps/documentation/wiringDiagrams/wd7307940300.md)
- [`wd7307940400.md`](hvps/documentation/wiringDiagrams/wd7307940400.md)
- [`wd7307940503.md`](hvps/documentation/wiringDiagrams/wd7307940503.md)
- [`wd7307940600.md`](hvps/documentation/wiringDiagrams/wd7307940600.md)

### maintenance

- [`HVPSReliability.md`](hvps/maintenance/HVPSReliability.md)
- [`Spear1Tests20220817.md`](hvps/maintenance/Spear1Tests20220817.md)
- [`Spear2Tests2021.md`](hvps/maintenance/Spear2Tests2021.md)
- [`hvpsStackInstallationChecklist.md`](hvps/maintenance/hvpsStackInstallationChecklist.md)
- [`phaseTankMaintenance-20240425jjs.md`](hvps/maintenance/phaseTankMaintenance-20240425jjs.md)
- [`phaseTankScrs.md`](hvps/maintenance/phaseTankScrs.md)


## File Statistics

- **Total markdown files:** 127
- **Categories:** 12

## How to Use This Documentation

An AI reading this documentation should:
1. Start with this index to understand the document structure
2. Read the system overview above for high-level understanding
3. Navigate to specific documents based on the task at hand
4. Cross-reference between schematics, procedures, and design notes
5. The ASCII art in schematic files provides visual understanding of circuits

## Key Documents for Design Understanding

1. **Overall System:** `hvps/documentation/schematics/sd7307900101.md` - Master HVPS schematic
2. **Hazards Analysis:** `hvps/documentation/procedures/spear3HvpsHazards_tex.md` - Detailed hazards and stored energy
3. **Internal Layout:** `hvps/documentation/mechanical/Internal Layout - dwg D36942-E.md`
4. **Equipment Interconnect:** `hvps/documentation/wiringDiagrams/ei7307900000.md`
5. **Controller:** `hvps/documentation/schematics/sd7307900501.md`
6. **Original Specification:** `hvps/architecture/originalDocuments/ps3413600102.md`
7. **SLAC Publication:** `hvps/architecture/originalDocuments/slac-pub-7591.md`
