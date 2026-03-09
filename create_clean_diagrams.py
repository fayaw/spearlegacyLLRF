#!/usr/bin/env python3
"""
SPEAR3 LLRF Upgrade Project - Clean Professional Diagrams
Creates well-organized diagrams with proper spacing and clear text
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np

def create_clean_overview_diagram():
    """Create a clean, well-organized project overview diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(20, 14))
    
    # Define colors
    colors = {
        'complete': '#2E8B57',      # Sea Green
        'in_progress': '#FF8C00',   # Dark Orange  
        'not_started': '#DC143C',   # Crimson
        'critical': '#8B0000',      # Dark Red
        'phase1': '#4682B4',        # Steel Blue
        'phase2': '#9370DB',        # Medium Purple
        'phase3': '#228B22',        # Forest Green
        'background': '#F8F9FA',    # Light gray
        'text': '#2C3E50'           # Dark blue-gray
    }
    
    # Set background
    ax.set_facecolor(colors['background'])
    
    # Title section
    title_y = 12.5
    ax.text(10, title_y, 'SPEAR3 LLRF Upgrade Project', 
            fontsize=24, fontweight='bold', ha='center', color=colors['text'])
    ax.text(10, title_y-0.4, 'Complete Implementation Overview: 10 Subsystems • 4 Phases • 9 Months', 
            fontsize=14, ha='center', color=colors['text'], style='italic')
    
    # Hardware Readiness Status (Left Column)
    hw_start_y = 11
    ax.text(2, hw_start_y, 'HARDWARE READINESS STATUS', 
            fontsize=16, fontweight='bold', color=colors['text'])
    
    # Complete systems
    complete_systems = [
        'LLRF9 Controllers (4 units)',
        'HVPS PLC (CompactLogix)', 
        'Kly MPS PLC (ControlLogix)',
        'Galil Motion Controller'
    ]
    
    y_pos = hw_start_y - 0.8
    for i, system in enumerate(complete_systems):
        rect = Rectangle((0.5, y_pos - 0.15), 6, 0.3, 
                        facecolor=colors['complete'], alpha=0.3, 
                        edgecolor=colors['complete'], linewidth=1)
        ax.add_patch(rect)
        ax.text(0.7, y_pos, f"✓ {system}", fontsize=11, va='center', 
                color=colors['complete'], fontweight='bold')
        y_pos -= 0.4
    
    # In Progress systems
    y_pos -= 0.3
    ax.text(0.7, y_pos, 'IN PROGRESS:', fontsize=12, fontweight='bold', 
            color=colors['in_progress'])
    y_pos -= 0.4
    
    inprogress_systems = [
        'Waveform Buffer System',
        'Interface Chassis'
    ]
    
    for system in inprogress_systems:
        rect = Rectangle((0.5, y_pos - 0.15), 6, 0.3, 
                        facecolor=colors['in_progress'], alpha=0.3, 
                        edgecolor=colors['in_progress'], linewidth=1)
        ax.add_patch(rect)
        ax.text(0.7, y_pos, f"◐ {system}", fontsize=11, va='center', 
                color=colors['in_progress'], fontweight='bold')
        y_pos -= 0.4
    
    # Not Started systems
    y_pos -= 0.3
    ax.text(0.7, y_pos, 'NOT STARTED:', fontsize=12, fontweight='bold', 
            color=colors['not_started'])
    y_pos -= 0.4
    
    notstarted_systems = [
        'Enerpro FCOG1200 Boards',
        'Arc Detection System',
        'Heater SCR Controller',
        'PPS Interface Box',
        'Python/EPICS Coordinator ⚠️'
    ]
    
    for system in notstarted_systems:
        color = colors['critical'] if '⚠️' in system else colors['not_started']
        rect = Rectangle((0.5, y_pos - 0.15), 6, 0.3, 
                        facecolor=color, alpha=0.3, 
                        edgecolor=color, linewidth=2 if '⚠️' in system else 1)
        ax.add_patch(rect)
        ax.text(0.7, y_pos, f"○ {system}", fontsize=11, va='center', 
                color=color, fontweight='bold' if '⚠️' in system else 'normal')
        y_pos -= 0.4
    
    # Implementation Timeline (Right Column)
    timeline_x = 11
    timeline_y = 11
    ax.text(timeline_x, timeline_y, 'IMPLEMENTATION TIMELINE', 
            fontsize=16, fontweight='bold', color=colors['text'])
    
    # Phase 1
    phase1_y = timeline_y - 1
    rect = Rectangle((timeline_x - 0.5, phase1_y - 0.8), 8, 1.6, 
                    facecolor=colors['phase1'], alpha=0.2, 
                    edgecolor=colors['phase1'], linewidth=2)
    ax.add_patch(rect)
    ax.text(timeline_x, phase1_y + 0.4, 'PHASE 1: Standalone Development', 
            fontsize=14, fontweight='bold', color=colors['phase1'])
    ax.text(timeline_x, phase1_y, 'Months 1-3 • Maximum Parallel Development', 
            fontsize=11, color=colors['text'])
    ax.text(timeline_x, phase1_y - 0.4, '• Complete all subsystem testing offline', 
            fontsize=10, color=colors['text'])
    
    # Phase 2A
    phase2a_y = phase1_y - 2.5
    rect = Rectangle((timeline_x - 0.5, phase2a_y - 0.8), 8, 1.6, 
                    facecolor=colors['phase2'], alpha=0.2, 
                    edgecolor=colors['phase2'], linewidth=2)
    ax.add_patch(rect)
    ax.text(timeline_x, phase2a_y + 0.4, 'PHASE 2A: TS18 Sub-Integration', 
            fontsize=14, fontweight='bold', color=colors['phase2'])
    ax.text(timeline_x, phase2a_y, 'Months 4-6 • Klystron + Dummy Load', 
            fontsize=11, color=colors['text'])
    ax.text(timeline_x, phase2a_y - 0.4, '• HVPS + Heater + MPS + WFB + Interface Chassis', 
            fontsize=10, color=colors['text'])
    
    # Phase 2B
    phase2b_y = phase2a_y - 2.5
    rect = Rectangle((timeline_x - 0.5, phase2b_y - 0.8), 8, 1.6, 
                    facecolor=colors['phase2'], alpha=0.2, 
                    edgecolor=colors['phase2'], linewidth=2)
    ax.add_patch(rect)
    ax.text(timeline_x, phase2b_y + 0.4, 'PHASE 2B: SPEAR3 Integration', 
            fontsize=14, fontweight='bold', color=colors['phase2'])
    ax.text(timeline_x, phase2b_y, 'Months 7-8 • Live RF Cavities', 
            fontsize=11, color=colors['text'])
    ax.text(timeline_x, phase2b_y - 0.4, '• Add LLRF9 + Arc Detection + Galil', 
            fontsize=10, color=colors['text'])
    
    # Phase 3
    phase3_y = phase2b_y - 2.5
    rect = Rectangle((timeline_x - 0.5, phase3_y - 0.8), 8, 1.6, 
                    facecolor=colors['phase3'], alpha=0.2, 
                    edgecolor=colors['phase3'], linewidth=2)
    ax.add_patch(rect)
    ax.text(timeline_x, phase3_y + 0.4, 'PHASE 3: Commissioning', 
            fontsize=14, fontweight='bold', color=colors['phase3'])
    ax.text(timeline_x, phase3_y, 'Month 9 • Dimtel Support + Validation', 
            fontsize=11, color=colors['text'])
    ax.text(timeline_x, phase3_y - 0.4, '• Power ramp 10% → 100% + Operator training', 
            fontsize=10, color=colors['text'])
    
    # Critical Risks Section (Bottom)
    risk_y = 2.5
    rect = Rectangle((1, risk_y - 1), 18, 2, 
                    facecolor=colors['critical'], alpha=0.1, 
                    edgecolor=colors['critical'], linewidth=2)
    ax.add_patch(rect)
    ax.text(10, risk_y + 0.6, '🚨 CRITICAL RISKS REQUIRING IMMEDIATE ACTION', 
            fontsize=16, fontweight='bold', ha='center', color=colors['critical'])
    
    risks = [
        '1. Python/EPICS Coordinator Software (CRITICAL - Not Started) - Blocks all integration testing',
        '2. Interface Chassis Logic Design (HIGH - In Progress) - Gates all subsystem integration',
        '3. Kly MPS PLC Software Integration (HIGH - Not Started) - Complex fault handling required',
        '4. PPS Interface Regulatory Approval (HIGH - Not Started) - Potential timeline bottleneck'
    ]
    
    risk_x = 1.5
    for i, risk in enumerate(risks):
        ax.text(risk_x, risk_y + 0.1 - i*0.3, risk, fontsize=11, va='center', 
                color=colors['critical'])
    
    # Success Criteria Section (Bottom)
    success_y = 0.5
    rect = Rectangle((1, success_y - 0.8), 18, 1.6, 
                    facecolor=colors['phase3'], alpha=0.1, 
                    edgecolor=colors['phase3'], linewidth=2)
    ax.add_patch(rect)
    ax.text(10, success_y + 0.4, '🎯 SUCCESS CRITERIA & PERFORMANCE TARGETS', 
            fontsize=16, fontweight='bold', ha='center', color=colors['phase3'])
    
    success_items = [
        'Amplitude Stability: <0.1% • Phase Stability: <0.1° • System Uptime: >99.5%',
        '16k-Sample Waveform Capture • First-Fault Detection • Auto-Recovery • 3-min Calibration'
    ]
    
    for i, item in enumerate(success_items):
        ax.text(10, success_y - i*0.3, item, fontsize=12, ha='center', va='center', 
                color=colors['phase3'], fontweight='bold')
    
    # Set axis properties
    ax.set_xlim(0, 20)
    ax.set_ylim(-1, 13.5)
    ax.axis('off')
    
    plt.tight_layout()
    return fig

def create_clean_flow_diagram():
    """Create a clean subsystem flow diagram with proper spacing"""
    fig, ax = plt.subplots(1, 1, figsize=(24, 16))
    
    # Define colors
    colors = {
        'complete': '#2E8B57',
        'in_progress': '#FF8C00',
        'not_started': '#DC143C',
        'critical': '#8B0000',
        'phase': '#4682B4',
        'integration': '#9370DB',
        'background': '#F8F9FA',
        'text': '#2C3E50'
    }
    
    ax.set_facecolor(colors['background'])
    
    # Title
    ax.text(12, 14.5, 'SPEAR3 LLRF Upgrade - Detailed Subsystem Flow', 
            fontsize=20, fontweight='bold', ha='center', color=colors['text'])
    ax.text(12, 14, 'Complete Integration Sequence: Phase 1 → Phase 2A → Phase 2B → Phase 3', 
            fontsize=12, ha='center', color=colors['text'], style='italic')
    
    # Phase 1 - Standalone Development (Left side)
    phase1_x = 4
    phase1_y = 12
    ax.text(phase1_x, phase1_y, 'PHASE 1: STANDALONE DEVELOPMENT', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase'])
    ax.text(phase1_x, phase1_y - 0.3, 'Months 1-3', 
            fontsize=11, ha='center', color=colors['text'])
    
    # Hardware subsystems - organized in clean grid
    subsystems_p1 = [
        ('HVPS PLC\n(CompactLogix)', 2, 10.5, colors['complete']),
        ('HVPS SCR\n(FCOG1200)', 6, 10.5, colors['not_started']),
        ('Heater SCR\nController', 2, 9, colors['not_started']),
        ('Kly MPS PLC\n(ControlLogix)', 6, 9, colors['complete']),
        ('Waveform Buffer\nSystem', 2, 7.5, colors['in_progress']),
        ('Interface Chassis\n⚠️ CRITICAL', 6, 7.5, colors['critical']),
        ('Python/EPICS\nCoordinator\n⚠️ CRITICAL', 4, 6, colors['critical'])
    ]
    
    for label, x, y, color in subsystems_p1:
        width = 2.5 if '⚠️' in label else 2
        height = 1 if '⚠️' in label else 0.8
        linewidth = 3 if '⚠️' in label else 1
        
        rect = Rectangle((x - width/2, y - height/2), width, height, 
                        facecolor=color, alpha=0.3, 
                        edgecolor=color, linewidth=linewidth)
        ax.add_patch(rect)
        ax.text(x, y, label, fontsize=10, ha='center', va='center', 
                color=color, fontweight='bold' if '⚠️' in label else 'normal')
    
    # Cavity-dependent systems (Middle)
    cavity_x = 12
    cavity_y = 12
    ax.text(cavity_x, cavity_y, 'CAVITY-DEPENDENT SYSTEMS', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase'])
    ax.text(cavity_x, cavity_y - 0.3, 'Ready for Phase 2B', 
            fontsize=11, ha='center', color=colors['text'])
    
    subsystems_cavity = [
        ('LLRF9\nControllers', 10, 10.5, colors['complete']),
        ('Arc Detection\nSystem', 14, 10.5, colors['not_started']),
        ('Galil Motion\nController', 10, 9, colors['complete']),
        ('PPS Interface\nBox', 14, 9, colors['not_started'])
    ]
    
    for label, x, y, color in subsystems_cavity:
        rect = Rectangle((x - 1, y - 0.4), 2, 0.8, 
                        facecolor=color, alpha=0.3, 
                        edgecolor=color, linewidth=1)
        ax.add_patch(rect)
        ax.text(x, y, label, fontsize=10, ha='center', va='center', color=color)
    
    # Integration phases (Right side)
    integration_x = 20
    
    # Phase 2A
    phase2a_y = 10.5
    rect = Rectangle((integration_x - 2, phase2a_y - 1), 4, 2, 
                    facecolor=colors['integration'], alpha=0.2, 
                    edgecolor=colors['integration'], linewidth=2)
    ax.add_patch(rect)
    ax.text(integration_x, phase2a_y + 0.5, 'PHASE 2A', 
            fontsize=12, fontweight='bold', ha='center', color=colors['integration'])
    ax.text(integration_x, phase2a_y, 'TS18 Integration', 
            fontsize=11, ha='center', color=colors['text'])
    ax.text(integration_x, phase2a_y - 0.5, 'Klystron + Dummy Load', 
            fontsize=10, ha='center', color=colors['text'])
    
    # Phase 2B
    phase2b_y = 7.5
    rect = Rectangle((integration_x - 2, phase2b_y - 1), 4, 2, 
                    facecolor=colors['integration'], alpha=0.2, 
                    edgecolor=colors['integration'], linewidth=2)
    ax.add_patch(rect)
    ax.text(integration_x, phase2b_y + 0.5, 'PHASE 2B', 
            fontsize=12, fontweight='bold', ha='center', color=colors['integration'])
    ax.text(integration_x, phase2b_y, 'SPEAR3 Integration', 
            fontsize=11, ha='center', color=colors['text'])
    ax.text(integration_x, phase2b_y - 0.5, 'Live RF Cavities', 
            fontsize=10, ha='center', color=colors['text'])
    
    # Phase 3
    phase3_y = 4.5
    rect = Rectangle((integration_x - 2, phase3_y - 1), 4, 2, 
                    facecolor=colors['phase'], alpha=0.2, 
                    edgecolor=colors['phase'], linewidth=2)
    ax.add_patch(rect)
    ax.text(integration_x, phase3_y + 0.5, 'PHASE 3', 
            fontsize=12, fontweight='bold', ha='center', color=colors['phase'])
    ax.text(integration_x, phase3_y, 'Commissioning', 
            fontsize=11, ha='center', color=colors['text'])
    ax.text(integration_x, phase3_y - 0.5, 'Dimtel Support + Validation', 
            fontsize=10, ha='center', color=colors['text'])
    
    # Clean arrows showing flow
    # Phase 1 to Phase 2A
    ax.annotate('', xy=(18, phase2a_y), xytext=(8, 8.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['integration']))
    
    # Phase 2A to Phase 2B
    ax.annotate('', xy=(integration_x, phase2b_y + 1), xytext=(integration_x, phase2a_y - 1),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['integration']))
    
    # Cavity systems to Phase 2B
    ax.annotate('', xy=(18, phase2b_y), xytext=(14, 9.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['integration']))
    
    # Phase 2B to Phase 3
    ax.annotate('', xy=(integration_x, phase3_y + 1), xytext=(integration_x, phase2b_y - 1),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['integration']))
    
    # Legend
    legend_y = 2
    ax.text(2, legend_y + 0.5, 'STATUS LEGEND:', fontsize=12, fontweight='bold', color=colors['text'])
    
    legend_items = [
        ('✓ Complete', colors['complete']),
        ('◐ In Progress', colors['in_progress']),
        ('○ Not Started', colors['not_started']),
        ('⚠️ Critical Path', colors['critical'])
    ]
    
    for i, (label, color) in enumerate(legend_items):
        rect = Rectangle((2 + i*3, legend_y - 0.2), 0.3, 0.3, 
                        facecolor=color, alpha=0.3, edgecolor=color)
        ax.add_patch(rect)
        ax.text(2.5 + i*3, legend_y, label, fontsize=10, va='center', color=color, fontweight='bold')
    
    # Timeline at bottom
    timeline_y = 0.5
    ax.text(12, timeline_y, 'PROJECT TIMELINE: 9 Months Total', 
            fontsize=14, fontweight='bold', ha='center', color=colors['text'])
    
    timeline_phases = [
        ('Months 1-3\nStandalone Dev', 4),
        ('Months 4-6\nTS18 Integration', 8),
        ('Months 7-8\nSPEAR3 Integration', 16),
        ('Month 9\nCommissioning', 20)
    ]
    
    for label, x in timeline_phases:
        ax.text(x, timeline_y - 0.8, label, fontsize=10, ha='center', va='center', 
                color=colors['text'], bbox=dict(boxstyle="round,pad=0.3", 
                facecolor='white', edgecolor=colors['phase'], alpha=0.8))
    
    # Set axis properties
    ax.set_xlim(0, 24)
    ax.set_ylim(-1, 15)
    ax.axis('off')
    
    plt.tight_layout()
    return fig

def main():
    """Generate clean, professional diagrams"""
    
    print("Creating clean project overview diagram...")
    fig1 = create_clean_overview_diagram()
    fig1.savefig('SPEAR3_LLRF_Clean_Overview.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none', pad_inches=0.2)
    print("✅ Saved: SPEAR3_LLRF_Clean_Overview.png")
    
    print("Creating clean flow diagram...")
    fig2 = create_clean_flow_diagram()
    fig2.savefig('SPEAR3_LLRF_Clean_Flow.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none', pad_inches=0.2)
    print("✅ Saved: SPEAR3_LLRF_Clean_Flow.png")
    
    plt.close('all')
    print("\n🎯 Clean project diagrams created successfully!")
    print("📊 Improved layout with proper spacing and clear text")
    print("🔄 No overlapping elements or messy text flow")

if __name__ == "__main__":
    main()

