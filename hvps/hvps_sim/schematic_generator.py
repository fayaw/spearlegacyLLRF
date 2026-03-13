#!/usr/bin/env python3
"""
HVPS Schematic Generator

Automated schematic generation for SPEAR3 HVPS system using schemdraw.
Creates professional-quality circuit diagrams for visual validation and documentation.

Author: Codegen AI
Date: 2026-03-13
"""

import schemdraw
import schemdraw.elements as elm
import os
from pathlib import Path
import matplotlib.pyplot as plt

class HVPSSchematicGenerator:
    """
    Generate professional schematics for SPEAR3 HVPS system components.
    
    Features:
    - System overview block diagram
    - Detailed 12-pulse rectifier circuit
    - LC filter topology with component values
    - Control system interfaces
    - Protection system circuits
    """
    
    def __init__(self, output_dir="schematics"):
        """
        Initialize schematic generator.
        
        Args:
            output_dir (str): Directory to save generated schematics
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(exist_ok=True)
        
        # HVPS System Specifications (from documentation review)
        self.specs = {
            'output_voltage': -77,  # kV
            'output_current': 22,   # A
            'power_rating': 1.7,    # MW
            'input_voltage': 12.47, # kV RMS
            'filter_L1': 0.3,       # H
            'filter_L2': 0.3,       # H
            'filter_C': 8e-6,       # F (8 μF)
            'filter_R': 500,        # Ω
            'scr_stacks': 12,       # Total SCR stacks
            'scr_per_stack': 14,    # SCRs per stack
            'transformer_T0': 3.5,  # MVA
            'transformer_T1': 1.5,  # MVA
            'transformer_T2': 1.5,  # MVA
        }
    
    def generate_system_overview(self, save=True):
        """
        Generate complete HVPS system overview block diagram.
        
        Args:
            save (bool): Whether to save the schematic to file
            
        Returns:
            schemdraw.Drawing: The generated schematic
        """
        with schemdraw.Drawing(show=False) as d:
            d.config(fontsize=10)
            
            # Title
            d += elm.Label().label('SPEAR3 HVPS System Overview\n-77 kV @ 22 A (1.7 MW)', 
                                 loc='top', fontsize=14)
            
            # Input power
            d += elm.SourceSin().label('12.47 kV\n3φ 60 Hz\nSubstation 507')
            d += elm.Line().right(1)
            
            # Switchgear
            d += elm.Gap().label('Switchgear\n& Safety', loc='top')
            d += elm.Line().right(1)
            
            # Phase-shift transformer
            d += elm.Transformer(t1=3, t2=3).label('T0\n3.5 MVA\nPhase Shift\n±15°', loc='top')
            d += elm.Line().right(1)
            
            # Split for dual transformers
            d += elm.Dot()
            d.push()
            
            # Upper path - T1
            d += elm.Line().up(1)
            d += elm.Transformer(t1=2, t2=2).right().label('T1\n1.5 MVA\n+15°', loc='top')
            d += elm.Line().right(1)
            d += elm.Gap().label('6-Pulse\nSCR Bridge\n(SCR 1-6)', loc='top')
            d += elm.Line().right(1)
            d += elm.Dot()
            d.push()
            
            # Lower path - T2
            d.pop()
            d += elm.Line().down(1)
            d += elm.Transformer(t1=2, t2=2).right().label('T2\n1.5 MVA\n-15°', loc='bottom')
            d += elm.Line().right(1)
            d += elm.Gap().label('6-Pulse\nSCR Bridge\n(SCR 7-12)', loc='bottom')
            d += elm.Line().right(1)
            d += elm.Dot()
            
            # Combine paths
            d.pop()
            d += elm.Line().down(1)
            d += elm.Line().right(1)
            
            # LC Filter
            d += elm.Inductor().right().label('L1, L2\n0.3H each\n85A rated', loc='top')
            d += elm.Line().right(0.5)
            d += elm.Capacitor().down().label('C\n8μF', loc='right')
            d += elm.Resistor().down().label('R\n500Ω', loc='right')
            d += elm.Ground()
            
            # Continue to secondary rectifiers
            d += elm.Line().up().at(d.here + (0, 2))
            d += elm.Line().right(1)
            d += elm.Gap().label('Secondary\nRectifiers\n4 Diode Bridges', loc='top')
            d += elm.Line().right(1)
            
            # Output
            d += elm.Gap().label('Crowbar\nProtection', loc='top')
            d += elm.Line().right(1)
            d += elm.Gap().label('-77 kV DC\n22 A\nto Klystron', loc='top')
            
            # Control system (below main circuit)
            d += elm.Line().down(3).at((2, -2))
            d += elm.Gap().label('Control System\nEPICS → VXI → PLC → Regulator → Enerpro FCOG1200', 
                                loc='bottom', fontsize=8)
            d += elm.Line().up().to((6, 0))
            
        if save:
            d.save(self.output_dir / 'hvps_system_overview.png', dpi=300)
            print(f"✅ System overview saved to {self.output_dir / 'hvps_system_overview.png'}")
            
        return d
    
    def generate_12pulse_rectifier(self, save=True):
        """
        Generate detailed 12-pulse rectifier circuit diagram.
        
        Args:
            save (bool): Whether to save the schematic to file
            
        Returns:
            schemdraw.Drawing: The generated schematic
        """
        with schemdraw.Drawing(show=False) as d:
            d.config(fontsize=9)
            
            # Title
            d += elm.Label().label('12-Pulse Thyristor Rectifier\nStar Point Controller Configuration', 
                                 loc='top', fontsize=12)
            
            # Phase-shift transformer (simplified)
            d += elm.Transformer(t1=3, t2=6).label('T0\n±15° Phase Shift\n3.5 MVA', loc='top')
            
            # Upper 6-pulse bridge (T1)
            d.push()
            d += elm.Line().right(2).at((2, 1))
            d += elm.Transformer(t1=3, t2=2).label('T1\n+15°\n1.5 MVA', loc='top')
            d += elm.Line().right(1)
            
            # SCR bridge representation
            for i in range(3):
                d += elm.SCR().right().label(f'SCR{i+1}', loc='top')
                if i < 2:
                    d += elm.Line().right(0.5)
            
            d += elm.Line().right(1)
            d += elm.Dot()
            d.push()
            
            # Lower 6-pulse bridge (T2)
            d.pop()
            d += elm.Line().right(2).at((2, -1))
            d += elm.Transformer(t1=3, t2=2).label('T2\n-15°\n1.5 MVA', loc='bottom')
            d += elm.Line().right(1)
            
            # SCR bridge representation
            for i in range(3):
                d += elm.SCR().right().label(f'SCR{i+7}', loc='bottom')
                if i < 2:
                    d += elm.Line().right(0.5)
            
            d += elm.Line().right(1)
            d += elm.Dot()
            
            # Combine outputs
            d.pop()
            d += elm.Line().down(1)
            d += elm.Line().right(1)
            
            # Output annotation
            d += elm.Label().label('12-Pulse Output\n720 Hz Ripple\n~0.5% before filtering', 
                                 loc='right', fontsize=8)
            
            # Control system connection
            d += elm.Line().down(2).at((8, -2))
            d += elm.Gap().label('Enerpro FCOG1200\n12-Pulse Firing Board\n168 SCR Gates Total', 
                                loc='bottom', fontsize=8)
            d += elm.Line().up().to((8, 0))
            
        if save:
            d.save(self.output_dir / 'hvps_12pulse_rectifier.png', dpi=300)
            print(f"✅ 12-pulse rectifier saved to {self.output_dir / 'hvps_12pulse_rectifier.png'}")
            
        return d
    
    def generate_lc_filter(self, save=True):
        """
        Generate LC filter circuit with exact component values.
        
        Args:
            save (bool): Whether to save the schematic to file
            
        Returns:
            schemdraw.Drawing: The generated schematic
        """
        with schemdraw.Drawing(show=False) as d:
            d.config(fontsize=10)
            
            # Title
            d += elm.Label().label('HVPS LC Filter Circuit\nExact Component Values from Documentation', 
                                 loc='top', fontsize=12)
            
            # Input from rectifier
            d += elm.Gap().label('From 12-Pulse\nRectifier\n~0.5% ripple @ 720 Hz', loc='left')
            d += elm.Line().right(1)
            d += elm.Dot()
            d.push()
            
            # Upper inductor L1
            d += elm.Line().up(1)
            d += elm.Inductor().right().label('L1\n0.3 H\n85 A rated\n1,084 J stored', loc='top')
            d += elm.Line().right(1)
            d += elm.Dot()
            d.push()
            
            # Lower inductor L2
            d.pop()
            d += elm.Line().down(1)
            d += elm.Inductor().right().label('L2\n0.3 H\n85 A rated\n1,084 J stored', loc='bottom')
            d += elm.Line().right(1)
            d += elm.Dot()
            
            # Combine inductors
            d.pop()
            d += elm.Line().down(1)
            d += elm.Line().right(1)
            d += elm.Dot()
            d.push()
            
            # Filter capacitor
            d += elm.Capacitor().down().label('C\n8 μF\n~24 kJ stored\n@ 77 kV', loc='right')
            d += elm.Line().down(0.5)
            d += elm.Dot()
            d.push()
            
            # Isolation resistor (PEP-II innovation)
            d += elm.Resistor().down().label('R\n500 Ω\nArc Protection\n(PEP-II Design)', loc='right')
            d += elm.Ground()
            
            # Continue to output
            d.pop()
            d += elm.Line().right(2)
            d += elm.Gap().label('To Secondary\nRectifiers\n<1% P-P ripple\n<0.2% RMS', loc='right')
            
            # Filter analysis annotation
            d += elm.Label().at((4, -3)).label(
                'Filter Analysis:\n'
                'Resonant Freq: 102.7 Hz\n'
                'Attenuation @ 720 Hz: ~48x\n'
                'Expected Output Ripple: 0.01%', 
                fontsize=8, halign='left'
            )
            
        if save:
            d.save(self.output_dir / 'hvps_lc_filter.png', dpi=300)
            print(f"✅ LC filter saved to {self.output_dir / 'hvps_lc_filter.png'}")
            
        return d
    
    def generate_control_system(self, save=True):
        """
        Generate control system interface diagram.
        
        Args:
            save (bool): Whether to save the schematic to file
            
        Returns:
            schemdraw.Drawing: The generated schematic
        """
        with schemdraw.Drawing(show=False) as d:
            d.config(fontsize=9)
            
            # Title
            d += elm.Label().label('HVPS Control System Architecture\nBuilding 118 → Building 514', 
                                 loc='top', fontsize=12)
            
            # Control hierarchy
            d += elm.Gap().label('EPICS IOC\nOperator Interface\nMEDM Screens', loc='top')
            d += elm.Line().right(1)
            d += elm.Gap().label('VXI Crate\n& DCM Module\nDH485 Protocol', loc='top')
            d += elm.Line().right(1)
            d += elm.Gap().label('PLC\nSLC-5/03\nSSRLV6-4-05-10', loc='top')
            d += elm.Line().right(1)
            d += elm.Gap().label('Regulator Card\nPC-237-230-14-C0\nFeedback Conditioning', loc='top')
            d += elm.Line().right(1)
            d += elm.Gap().label('Enerpro FCOG1200\n12-Pulse Firing\n168 SCR Gates', loc='top')
            
            # Feedback signals
            d += elm.Line().down(2).at((8, -1))
            d += elm.Gap().label('Feedback Signals:\n• HV Divider (1000:1)\n• Current Transformer\n• Temperature Monitors', 
                                loc='bottom', fontsize=8)
            d += elm.Line().left().to((0, -1))
            d += elm.Line().up().to((0, 0))
            
            # Performance specifications
            d += elm.Label().at((4, -3)).label(
                'Control Performance:\n'
                '• Regulation: ±0.5% @ >65 kV\n'
                '• Response Time: <10 ms\n'
                '• Resolution: 16-bit DAC (0.1%)\n'
                '• Voltage Range: 0 to -90 kV', 
                fontsize=8, halign='center'
            )
            
        if save:
            d.save(self.output_dir / 'hvps_control_system.png', dpi=300)
            print(f"✅ Control system saved to {self.output_dir / 'hvps_control_system.png'}")
            
        return d
    
    def generate_protection_system(self, save=True):
        """
        Generate multi-layer protection system diagram.
        
        Args:
            save (bool): Whether to save the schematic to file
            
        Returns:
            schemdraw.Drawing: The generated schematic
        """
        with schemdraw.Drawing(show=False) as d:
            d.config(fontsize=9)
            
            # Title
            d += elm.Label().label('Multi-Layer Arc Protection System\nSingle-Fault Tolerance Design', 
                                 loc='top', fontsize=12)
            
            # Layer 1: Primary Crowbar
            d += elm.Gap().label('Layer 1\nPrimary Crowbar\n4 SCR Stacks\n100 kV, 80 A each', loc='top')
            d += elm.Line().right(1)
            
            # Layer 2: Secondary Protection
            d += elm.Gap().label('Layer 2\nSecondary Protection\nBackup Circuits\nFault Detection', loc='top')
            d += elm.Line().right(1)
            
            # Layer 3: Control Interlocks
            d += elm.Gap().label('Layer 3\nControl Interlocks\nPLC Safety Logic\nEmergency Shutdown', loc='top')
            d += elm.Line().right(1)
            
            # Layer 4: Cable Termination
            d += elm.Gap().label('Layer 4\nCable Termination\nL3, L4: 200μH\nDischarge Current\nReduction', loc='top')
            
            # Protection characteristics
            d += elm.Label().at((4, -2)).label(
                'Protection Characteristics:\n'
                '• Response Time: ~1μs (fiber optic)\n'
                '• Energy Handling: 24 kJ (full capacitor)\n'
                '• Single-Fault Tolerance: System survives primary failure\n'
                '• Klystron Protection: Multi-layer redundancy', 
                fontsize=8, halign='center'
            )
            
        if save:
            d.save(self.output_dir / 'hvps_protection_system.png', dpi=300)
            print(f"✅ Protection system saved to {self.output_dir / 'hvps_protection_system.png'}")
            
        return d
    
    def generate_all_schematics(self):
        """
        Generate all HVPS schematics and create summary report.
        
        Returns:
            dict: Dictionary of generated schematic file paths
        """
        print("🔧 Generating HVPS System Schematics...")
        
        schematics = {}
        
        # Generate all schematics
        schematics['system_overview'] = self.generate_system_overview()
        schematics['12pulse_rectifier'] = self.generate_12pulse_rectifier()
        schematics['lc_filter'] = self.generate_lc_filter()
        schematics['control_system'] = self.generate_control_system()
        schematics['protection_system'] = self.generate_protection_system()
        
        # Create summary report
        self._create_summary_report()
        
        print(f"\n✅ All schematics generated successfully!")
        print(f"📁 Output directory: {self.output_dir.absolute()}")
        
        return schematics
    
    def _create_summary_report(self):
        """Create a summary report of all generated schematics."""
        report_path = self.output_dir / 'schematic_summary.md'
        
        with open(report_path, 'w') as f:
            f.write("# HVPS Schematic Generation Summary\n\n")
            from datetime import datetime
            f.write(f"Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
            
            f.write("## Generated Schematics\n\n")
            f.write("1. **System Overview** (`hvps_system_overview.png`)\n")
            f.write("   - Complete HVPS block diagram\n")
            f.write("   - Power flow from input to output\n")
            f.write("   - Control system integration\n\n")
            
            f.write("2. **12-Pulse Rectifier** (`hvps_12pulse_rectifier.png`)\n")
            f.write("   - Detailed thyristor bridge configuration\n")
            f.write("   - Star point controller topology\n")
            f.write("   - Phase shift transformer arrangement\n\n")
            
            f.write("3. **LC Filter Circuit** (`hvps_lc_filter.png`)\n")
            f.write("   - Exact component values from documentation\n")
            f.write("   - Filter analysis and performance\n")
            f.write("   - PEP-II isolation resistor design\n\n")
            
            f.write("4. **Control System** (`hvps_control_system.png`)\n")
            f.write("   - Complete control hierarchy\n")
            f.write("   - Feedback signal paths\n")
            f.write("   - Performance specifications\n\n")
            
            f.write("5. **Protection System** (`hvps_protection_system.png`)\n")
            f.write("   - Multi-layer arc protection\n")
            f.write("   - Single-fault tolerance design\n")
            f.write("   - Response time characteristics\n\n")
            
            f.write("## System Specifications Used\n\n")
            for key, value in self.specs.items():
                f.write(f"- **{key.replace('_', ' ').title()}**: {value}\n")
            
            f.write("\n## Validation Notes\n\n")
            f.write("All component values and system specifications are derived from comprehensive\n")
            f.write("documentation review of SPEAR3 HVPS technical documents. These schematics\n")
            f.write("provide visual validation for simulation implementation.\n")
        
        print(f"📄 Summary report saved to {report_path}")


def main():
    """Main function to demonstrate schematic generation."""
    # Create schematic generator
    generator = HVPSSchematicGenerator()
    
    # Generate all schematics
    schematics = generator.generate_all_schematics()
    
    print("\n🎯 Schematic generation complete!")
    print("Use these schematics to validate simulation implementation against documentation.")


if __name__ == "__main__":
    main()
