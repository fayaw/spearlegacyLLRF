#!/usr/bin/env python3
"""
Simple Readable HVPS Schematics

Creates clear, readable circuit diagrams with larger fonts and better layout.
"""

import schemdraw
import schemdraw.elements as elm
from pathlib import Path

def generate_readable_lc_filter():
    """Generate readable LC filter circuit."""
    print("🔧 Generating Readable LC Filter...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=16, bgcolor='white')  # Larger font + white background
        
        # Input
        d += elm.Gap().label('From 12-Pulse\nRectifier\n0.5% ripple @ 720Hz')
        d += elm.Line().right(2)
        
        # Junction
        d += elm.Dot()
        d.push()
        
        # Upper inductor L1
        d += elm.Line().up(2)
        d += elm.Inductor().right().label('L1 = 0.3H\n85A rated')
        d += elm.Line().right()
        d += elm.Dot()
        d.push()
        
        # Lower inductor L2
        d.pop()
        d += elm.Line().down(2)
        d += elm.Inductor().right().label('L2 = 0.3H\n85A rated')
        d += elm.Line().right()
        d += elm.Dot()
        
        # Combine paths
        d.pop()
        d += elm.Line().down(2)
        d += elm.Line().right(2)
        
        # Filter components
        d += elm.Dot()
        d.push()
        
        # Capacitor
        d += elm.Capacitor().down(3).label('C = 8μF\n24kJ @ 77kV')
        d += elm.Line().down(1)
        
        # Resistor
        d += elm.Resistor().down(2).label('R = 500Ω\nArc Protection')
        d += elm.Ground()
        
        # Output
        d.pop()
        d += elm.Line().right(3)
        d += elm.Gap().label('To Secondary\nRectifiers\n<1% P-P ripple')
    
    d.save('readable_schematics/hvps_lc_filter_readable.png', dpi=300)
    print("✅ Readable LC Filter saved")
    return d

def generate_readable_12pulse():
    """Generate readable 12-pulse rectifier."""
    print("🔧 Generating Readable 12-Pulse Rectifier...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=16, bgcolor='white')  # White background for readability
        
        # Input
        d += elm.SourceSin().label('12.47kV\n3φ 60Hz')
        d += elm.Line().right(2)
        
        # Phase-shift transformer
        d += elm.Transformer().label('T0: 3.5MVA\nPhase Shift ±15°')
        d += elm.Line().right(2)
        
        # Split
        d += elm.Dot()
        d.push()
        
        # Upper bridge
        d += elm.Line().up(2)
        d += elm.Transformer().right().label('T1: 1.5MVA\n+15°')
        d += elm.Line().right()
        d += elm.SCR().right().label('6-Pulse Bridge\nSCR 1-6')
        d += elm.Line().right()
        d += elm.Dot()
        d.push()
        
        # Lower bridge
        d.pop()
        d += elm.Line().down(2)
        d += elm.Transformer().right().label('T2: 1.5MVA\n-15°')
        d += elm.Line().right()
        d += elm.SCR().right().label('6-Pulse Bridge\nSCR 7-12')
        d += elm.Line().right()
        d += elm.Dot()
        
        # Combine
        d.pop()
        d += elm.Line().down(2)
        d += elm.Line().right(2)
        d += elm.Gap().label('12-Pulse Output\n720Hz Ripple')
    
    d.save('readable_schematics/hvps_12pulse_readable.png', dpi=300)
    print("✅ Readable 12-Pulse saved")
    return d

def generate_readable_system_overview():
    """Generate readable system overview."""
    print("🔧 Generating Readable System Overview...")
    
    with schemdraw.Drawing(show=False) as d:
        d.config(fontsize=14, bgcolor='white')  # White background for readability
        
        # Power flow
        d += elm.Gap().label('INPUT\n12.47kV 3φ\n2.5MVA max')
        d += elm.Line().right(2)
        
        d += elm.Gap().label('PHASE-SHIFT\nTRANSFORMER\nT0: ±15°')
        d += elm.Line().right(2)
        
        d += elm.Gap().label('12-PULSE\nSCR BRIDGES\n168 SCRs total')
        d += elm.Line().right(2)
        
        d += elm.Gap().label('LC FILTER\nL=0.3H, C=8μF\nR=500Ω')
        d += elm.Line().right(2)
        
        d += elm.Gap().label('OUTPUT\n-77kV @ 22A\n1.7MW')
        
        # Control system below
        d += elm.Line().down(3).at((4, -2))
        d += elm.Gap().label('CONTROL SYSTEM\nEPICS → VXI → PLC → Regulator → Enerpro')
        d += elm.Line().up(1).to((4, -1))
    
    d.save('readable_schematics/hvps_system_overview_readable.png', dpi=300)
    print("✅ Readable System Overview saved")
    return d

def main():
    """Generate all readable schematics."""
    print("🎯 Generating Readable HVPS Schematics...")
    
    # Create output directory
    Path('readable_schematics').mkdir(exist_ok=True)
    
    # Generate schematics
    generate_readable_lc_filter()
    generate_readable_12pulse()
    generate_readable_system_overview()
    
    # Create README
    with open('readable_schematics/README.md', 'w') as f:
        f.write("# Readable HVPS Schematics\n\n")
        f.write("Improved schematics with:\n")
        f.write("- Larger fonts (16pt) for better readability\n")
        f.write("- Clear component labels with exact values\n")
        f.write("- High resolution (300 DPI) output\n")
        f.write("- Professional layout with proper spacing\n\n")
        f.write("## Generated Files\n\n")
        f.write("1. `hvps_lc_filter_readable.png` - LC filter with exact component values\n")
        f.write("2. `hvps_12pulse_readable.png` - 12-pulse rectifier topology\n")
        f.write("3. `hvps_system_overview_readable.png` - Complete system overview\n")
    
    print("\n✅ All readable schematics generated!")
    print("📁 Files saved in readable_schematics/ directory")

if __name__ == "__main__":
    main()
