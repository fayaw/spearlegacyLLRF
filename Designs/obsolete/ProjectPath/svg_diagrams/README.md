# SPEAR3 LLRF Upgrade Project Diagrams

This directory contains both Mermaid source files (.mmd) and SVG exports for all project path diagrams.

## Files Included

### Mermaid Source Files (.mmd)
These contain the complete diagram definitions with all styling and layout information:

1. **01_project_timeline.mmd** - Gantt chart of all 4 project phases (2026-01 to 2027-09)
2. **02_system_architecture.mmd** - System architecture showing all 10 subsystems
3. **03_protection_chain.mmd** - 4-layer protection chain with timing
4. **04_phase1_streams.mmd** - Phase 1 parallel development streams
5. **05_phase2a_ts18.mmd** - Phase 2A TS18 sub-integration build-up
6. **06_phase2b_spear3.mmd** - Phase 2B SPEAR3 full integration
7. **07_phase3_4_commissioning.mmd** - Phase 3-4 final commissioning flow
8. **08_master_dependency.mmd** - Master dependency network (full project flow)
9. **09_interface_chassis.mmd** - Interface Chassis signal flow detail
10. **10_risk_assessment.mmd** - Technical risk quadrant chart
11. **11_epics_namespace.mmd** - EPICS PV namespace map

### SVG Files (.svg)
Corresponding SVG exports for each diagram, suitable for import into Microsoft Visio.

## Using with Microsoft Visio

### Method 1: Import SVG Files Directly
1. Open Microsoft Visio
2. Create a new blank drawing
3. Go to **Insert** → **Pictures** → **From File**
4. Select the SVG files you want to import
5. Each diagram will be imported as a group that you can resize and position

### Method 2: Create Multi-Page Visio File
1. Open Microsoft Visio
2. Create a new blank drawing
3. For each diagram:
   - Insert a new page: **Page Design** → **New Page**
   - Rename the page to match the diagram (e.g., "Project Timeline", "System Architecture")
   - Import the corresponding SVG file
   - Resize to fit the page

### Method 3: Convert Mermaid to Visio Shapes
1. Use an online Mermaid editor (like mermaid.live) to render the .mmd files
2. Export as SVG from the online editor
3. Import the SVG into Visio
4. Use Visio's **Ungroup** feature to break apart the SVG into individual shapes
5. This allows full editing of individual elements

## Recommended Page Layout for Visio

Create a multi-page Visio document with these pages:

1. **Overview** - Project Timeline (01_project_timeline.svg)
2. **Architecture** - System Architecture (02_system_architecture.svg)
3. **Protection** - Protection Chain (03_protection_chain.svg)
4. **Phase 1** - Standalone Development (04_phase1_streams.svg)
5. **Phase 2A** - TS18 Integration (05_phase2a_ts18.svg)
6. **Phase 2B** - SPEAR3 Integration (06_phase2b_spear3.svg)
7. **Phase 3-4** - Commissioning (07_phase3_4_commissioning.svg)
8. **Dependencies** - Master Dependency Network (08_master_dependency.svg)
9. **Interface Chassis** - Signal Flow Detail (09_interface_chassis.svg)
10. **Risks** - Risk Assessment (10_risk_assessment.svg)
11. **EPICS** - PV Namespace (11_epics_namespace.svg)

## Color Scheme Used

The diagrams use a consistent color scheme:
- **Critical Path**: #fff2cc (light yellow) with black text
- **Integration Phases**: #dae8fc (light blue) with black text  
- **SPEAR3 Phases**: #d5e8d4 (light green) with black text
- **Commissioning**: #ffe6cc (light orange) with black text
- **PPS Safety**: #fce4ec (light pink) with black text

## Font Specifications

- **Timeline**: 16px Arial
- **System Architecture**: 14px Arial
- **Protection Chain**: 14px Arial
- **Master Dependency Network**: 12px Arial
- **Interface Chassis**: 13px Arial
- **Other diagrams**: Default Mermaid sizing

## Source Documents

These diagrams were derived from:
- `Designs/ProjectPath.md` - Project timeline and phase flow
- `Designs/0_PHYSICAL_DESIGN_REPORT.md` - Physical design report

## Notes

- All diagrams use explicit black text (`color:#000000`) for maximum readability
- Timeline spans from 2026-01 to 2027-09 as requested
- Font sizes have been optimized for readability
- SVG files maintain vector quality for scaling in Visio

