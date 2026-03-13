#!/usr/bin/env python3
"""
HVPS Simplified Schematic Generator

Creates key HVPS circuit diagrams for visual validation.
Simplified version that works reliably with schemdraw.

Author: Codegen AI
Date: 2026-03-13
"""

import schemdraw
import schemdraw.elements as elm
from pathlib import Path

def generate_lc_filter_schematic(save_path="hvps_lc_filter.png"):
    """
    Generate LC filter circuit with exact component values.
    
    Args:
        save_path (str): Path to save the schematic
        
    Returns:
        schemdraw.Drawing: The generated schematic
    """
    print("🔧 Generating LC Filter Schematic...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=11)
        
        # Input
        d += elm.Gap().label('From 12-Pulse\nRectifier\n~0.5% ripple\n@ 720 Hz')
        d += elm.Line().right()
        
        # L1 (upper path)
        d += elm.Dot()
        d.push()
        d += elm.Line().up()
        d += elm.Inductor().right().label('L1: 0.3H\n85A rated\n1,084J stored')
        d += elm.Line().right()
        d += elm.Dot()
        d.push()
        
        # L2 (lower path)
        d.pop()
        d += elm.Line().down()
        d += elm.Inductor().right().label('L2: 0.3H\n85A rated\n1,084J stored')
        d += elm.Line().right()
        d += elm.Dot()
        
        # Combine paths
        d.pop()
        d += elm.Line().down()
        d += elm.Line().right()
        
        # Filter capacitor and resistor
        d += elm.Dot()
        d.push()
        d += elm.Capacitor().down().label('C: 8μF\n~24kJ @ 77kV')
        d += elm.Line().down(0.5)
        d += elm.Resistor().down().label('R: 500Ω\nArc Protection\n(PEP-II Design)')
        d += elm.Ground()
        
        # Output
        d.pop()
        d += elm.Line().right()
        d += elm.Gap().label('To Secondary\nRectifiers\n<1% P-P ripple\n<0.2% RMS')
    
    d.save(save_path, dpi=300)
    print(f"✅ LC Filter schematic saved to {save_path}")
    return d

def generate_12pulse_overview(save_path="hvps_12pulse_overview.png"):
    """
    Generate 12-pulse rectifier overview diagram.
    
    Args:
        save_path (str): Path to save the schematic
        
    Returns:
        schemdraw.Drawing: The generated schematic
    """
    print("🔧 Generating 12-Pulse Rectifier Overview...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=10)
        
        # Input
        d += elm.SourceSin().label('12.47kV\n3φ 60Hz')
        d += elm.Line().right()
        
        # Phase-shift transformer
        d += elm.Transformer().label('T0: 3.5MVA\nPhase Shift ±15°')
        d += elm.Line().right()
        
        # Split for dual bridges
        d += elm.Dot()
        d.push()
        
        # Upper bridge (T1)
        d += elm.Line().up()
        d += elm.Transformer().right().label('T1: 1.5MVA\n+15°')
        d += elm.Line().right()
        d += elm.SCR().right().label('6-Pulse\nSCR Bridge\n(SCR 1-6)')
        d += elm.Line().right()
        d += elm.Dot()
        d.push()
        
        # Lower bridge (T2)
        d.pop()
        d += elm.Line().down()
        d += elm.Transformer().right().label('T2: 1.5MVA\n-15°')
        d += elm.Line().right()
        d += elm.SCR().right().label('6-Pulse\nSCR Bridge\n(SCR 7-12)')
        d += elm.Line().right()
        d += elm.Dot()
        
        # Combine outputs
        d.pop()
        d += elm.Line().down()
        d += elm.Line().right()
        d += elm.Gap().label('12-Pulse Output\n720Hz Ripple\n~0.5% before filter')
    
    d.save(save_path, dpi=300)
    print(f"✅ 12-Pulse overview saved to {save_path}")
    return d

def generate_system_block_diagram(save_path="hvps_system_blocks.png"):
    """
    Generate system-level block diagram.
    
    Args:
        save_path (str): Path to save the schematic
        
    Returns:
        schemdraw.Drawing: The generated schematic
    """
    print("🔧 Generating System Block Diagram...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=9)
        
        # Power flow
        d += elm.Gap().label('Input\n12.47kV 3φ\n2.5MVA max')
        d += elm.Line().right()
        d += elm.Gap().label('Phase-Shift\nTransformer\nT0: ±15°')
        d += elm.Line().right()
        d += elm.Gap().label('12-Pulse\nSCR Bridges\n168 SCRs total')
        d += elm.Line().right()
        d += elm.Gap().label('LC Filter\nL=0.3H, C=8μF\nR=500Ω')
        d += elm.Line().right()
        d += elm.Gap().label('Secondary\nRectifiers\n4 Diode Bridges')
        d += elm.Line().right()
        d += elm.Gap().label('Output\n-77kV @ 22A\n1.7MW')
        
        # Control system (below)
        d += elm.Line().down(2).at((3, -1))
        d += elm.Gap().label('Control System\nEPICS → VXI → PLC → Regulator → Enerpro FCOG1200')
        d += elm.Line().up().to((3, 0))
        
        # Protection system (below)
        d += elm.Line().down(2).at((6, -1))
        d += elm.Gap().label('Protection System\n4-Layer Arc Protection\nSingle-Fault Tolerance')
        d += elm.Line().up().to((6, 0))
    
    d.save(save_path, dpi=300)
    print(f"✅ System block diagram saved to {save_path}")
    return d

def generate_control_hierarchy(save_path="hvps_control_hierarchy.png"):
    """
    Generate control system hierarchy diagram.
    
    Args:
        save_path (str): Path to save the schematic
        
    Returns:
        schemdraw.Drawing: The generated schematic
    """
    print("🔧 Generating Control System Hierarchy...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=9)
        
        # Control chain
        d += elm.Gap().label('EPICS IOC\nOperator Interface\nMEDM Screens')
        d += elm.Line().right()
        d += elm.Gap().label('VXI Crate\nDCM Module\nDH485 Protocol')
        d += elm.Line().right()
        d += elm.Gap().label('PLC\nSLC-5/03\nSSRLV6-4-05-10')
        d += elm.Line().right()
        d += elm.Gap().label('Regulator Card\nPC-237-230-14-C0\nFeedback Conditioning')
        d += elm.Line().right()
        d += elm.Gap().label('Enerpro FCOG1200\n12-Pulse Firing\n168 SCR Gates')
        
        # Feedback path (below)
        d += elm.Line().down(2).at((8, -1))
        d += elm.Gap().label('Feedback Signals\nHV Divider (1000:1)\nCurrent Transformer\nTemperature Monitors')
        d += elm.Line().left().to((0, -1))
        d += elm.Line().up().to((0, 0))
    
    d.save(save_path, dpi=300)
    print(f"✅ Control hierarchy saved to {save_path}")
    return d

def generate_all_hvps_schematics(output_dir="schematics"):
    """
    Generate all HVPS schematics.
    
    Args:
        output_dir (str): Directory to save schematics
        
    Returns:
        dict: Dictionary of generated schematic paths
    """
    print("🎯 Generating All HVPS Schematics...")
    
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)
    
    schematics = {}
    
    # Generate all schematics
    schematics['lc_filter'] = generate_lc_filter_schematic(
        output_path / "hvps_lc_filter.png"
    )
    
    schematics['12pulse_overview'] = generate_12pulse_overview(
        output_path / "hvps_12pulse_overview.png"
    )
    
    schematics['system_blocks'] = generate_system_block_diagram(
        output_path / "hvps_system_blocks.png"
    )
    
    schematics['control_hierarchy'] = generate_control_hierarchy(
        output_path / "hvps_control_hierarchy.png"
    )
    
    # Create summary report
    create_schematic_summary(output_path)
    
    print(f"\n✅ All HVPS schematics generated successfully!")
    print(f"📁 Output directory: {output_path.absolute()}")
    
    return schematics

def create_schematic_summary(output_dir):
    """Create a summary report of generated schematics."""
    from datetime import datetime
    
    summary_path = output_dir / "README.md"
    
    with open(summary_path, 'w') as f:
        f.write("# HVPS Schematic Generation Summary\n\n")
        f.write(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        f.write("## Generated Schematics\n\n")
        
        f.write("### 1. LC Filter Circuit (`hvps_lc_filter.png`)\n")
        f.write("- **Purpose**: Detailed LC filter topology with exact component values\n")
        f.write("- **Components**: L1=0.3H, L2=0.3H, C=8μF, R=500Ω\n")
        f.write("- **Analysis**: Resonant frequency ~103Hz, 48x attenuation @ 720Hz\n")
        f.write("- **Key Feature**: PEP-II isolation resistor design for arc protection\n\n")
        
        f.write("### 2. 12-Pulse Rectifier Overview (`hvps_12pulse_overview.png`)\n")
        f.write("- **Purpose**: Complete 12-pulse rectifier topology\n")
        f.write("- **Components**: Phase-shift transformer T0, rectifier transformers T1/T2\n")
        f.write("- **Configuration**: Star point controller with ±15° phase shift\n")
        f.write("- **Output**: 720Hz ripple frequency, ~0.5% before filtering\n\n")
        
        f.write("### 3. System Block Diagram (`hvps_system_blocks.png`)\n")
        f.write("- **Purpose**: Complete HVPS system overview\n")
        f.write("- **Power Flow**: 12.47kV input → -77kV @ 22A output\n")
        f.write("- **Subsystems**: Power conversion, control, and protection\n")
        f.write("- **Specifications**: 1.7MW nominal, 2.5MW maximum capability\n\n")
        
        f.write("### 4. Control System Hierarchy (`hvps_control_hierarchy.png`)\n")
        f.write("- **Purpose**: Complete control system architecture\n")
        f.write("- **Chain**: EPICS → VXI → PLC → Regulator → Enerpro FCOG1200\n")
        f.write("- **Feedback**: HV divider, current transformer, temperature monitoring\n")
        f.write("- **Performance**: ±0.5% regulation, <10ms response time\n\n")
        
        f.write("## System Specifications\n\n")
        f.write("- **Output**: -77 kV DC @ 22 A (1.7 MW nominal)\n")
        f.write("- **Input**: 12.47 kV RMS, 3-phase, 60 Hz\n")
        f.write("- **Topology**: 12-pulse thyristor phase-controlled rectifier\n")
        f.write("- **Filter**: L1=L2=0.3H, C=8μF, R=500Ω\n")
        f.write("- **Ripple**: <1% P-P, <0.2% RMS (specification)\n")
        f.write("- **Regulation**: ±0.5% at voltages >65 kV\n")
        f.write("- **SCR Count**: 168 total (12 stacks × 14 SCRs each)\n\n")
        
        f.write("## Validation Notes\n\n")
        f.write("All component values and specifications are derived from comprehensive\n")
        f.write("documentation review of SPEAR3 HVPS technical documents. These schematics\n")
        f.write("provide visual validation for simulation implementation and enable\n")
        f.write("comparison with documented system architecture.\n\n")
        
        f.write("**Critical for T1 AC Current Analysis:**\n")
        f.write("- 12-pulse rectification creates 720Hz ripple (not 360Hz)\n")
        f.write("- ±15° phase shift eliminates 5th and 7th harmonics\n")
        f.write("- LC filter provides ~48x attenuation at 720Hz\n")
        f.write("- Expected near-sinusoidal current waveform due to excellent filtering\n")
    
    print(f"📄 Schematic summary saved to {summary_path}")

def main():
    """Main function to generate all schematics."""
    schematics = generate_all_hvps_schematics()
    
    print("\n🎯 HVPS Schematic Generation Complete!")
    print("\nGenerated schematics provide visual validation for:")
    print("• System architecture understanding")
    print("• Component value verification")
    print("• Simulation implementation validation")
    print("• T1 AC current waveform analysis")

if __name__ == "__main__":
    main()
