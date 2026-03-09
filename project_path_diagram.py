#!/usr/bin/env python3
"""
SPEAR3 LLRF Upgrade Project Path Visualization
Creates comprehensive diagrams showing the full project implementation path
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, ConnectionPatch
import numpy as np

def create_project_overview_diagram():
    """Create a high-level project overview diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    
    # Define colors for different phases and status
    colors = {
        'complete': '#2E8B57',      # Sea Green
        'in_progress': '#FF8C00',   # Dark Orange  
        'not_started': '#DC143C',   # Crimson
        'critical': '#8B0000',      # Dark Red
        'phase1': '#4682B4',        # Steel Blue
        'phase2': '#9370DB',        # Medium Purple
        'phase3': '#228B22',        # Forest Green
        'integration': '#FF6347'    # Tomato
    }
    
    # Phase 1: Standalone Development (Months 1-3)
    phase1_y = 9
    ax.text(1, phase1_y + 0.5, 'PHASE 1: Standalone Development (Months 1-3)', 
            fontsize=14, fontweight='bold', color=colors['phase1'])
    
    # Hardware streams
    hardware_systems = [
        ('LLRF9 Controllers', '✅ Complete', colors['complete']),
        ('HVPS PLC (CompactLogix)', '✅ Complete', colors['complete']),
        ('Kly MPS PLC (ControlLogix)', '✅ Complete', colors['complete']),
        ('Galil Motion Controller', '✅ Complete', colors['complete']),
        ('Enerpro FCOG1200 Boards', '⬜ Needed', colors['not_started']),
        ('Arc Detection System', '⬜ Needed', colors['not_started']),
        ('Waveform Buffer System', '🔄 In Progress', colors['in_progress']),
        ('Interface Chassis', '🔄 In Progress', colors['in_progress']),
        ('Heater SCR Controller', '⬜ Needed', colors['not_started']),
        ('PPS Interface Box', '⬜ Needed', colors['not_started'])
    ]
    
    for i, (system, status, color) in enumerate(hardware_systems):
        y_pos = phase1_y - 0.4 - (i * 0.3)
        rect = FancyBboxPatch((1, y_pos-0.1), 4, 0.25, 
                             boxstyle="round,pad=0.02", 
                             facecolor=color, alpha=0.3, edgecolor=color)
        ax.add_patch(rect)
        ax.text(1.1, y_pos, f"{system}: {status}", fontsize=10, va='center')
    
    # Critical Software Stream
    sw_y = phase1_y - 0.4
    rect = FancyBboxPatch((6, sw_y-0.1), 4, 0.25, 
                         boxstyle="round,pad=0.02", 
                         facecolor=colors['critical'], alpha=0.3, edgecolor=colors['critical'])
    ax.add_patch(rect)
    ax.text(6.1, sw_y, "⚠️ Python/EPICS Coordinator: ⬜ CRITICAL - Not Started", 
            fontsize=10, va='center', fontweight='bold')
    
    # Phase 2: Integration (Months 4-8)
    phase2_y = 5.5
    ax.text(1, phase2_y + 0.5, 'PHASE 2: Integration Testing (Months 4-8)', 
            fontsize=14, fontweight='bold', color=colors['phase2'])
    
    # Phase 2A: TS18 Sub-Integration
    rect = FancyBboxPatch((1, phase2_y-0.5), 4.5, 1, 
                         boxstyle="round,pad=0.05", 
                         facecolor=colors['phase2'], alpha=0.2, edgecolor=colors['phase2'])
    ax.add_patch(rect)
    ax.text(1.1, phase2_y, "Phase 2A: TS18 Sub-Integration", fontsize=12, fontweight='bold')
    ax.text(1.1, phase2_y-0.3, "• HVPS + Heater + Kly MPS + WFB", fontsize=10)
    ax.text(1.1, phase2_y-0.5, "• Interface Chassis Integration", fontsize=10)
    
    # Phase 2B: SPEAR3 Integration
    rect = FancyBboxPatch((6, phase2_y-0.5), 4.5, 1, 
                         boxstyle="round,pad=0.05", 
                         facecolor=colors['phase2'], alpha=0.2, edgecolor=colors['phase2'])
    ax.add_patch(rect)
    ax.text(6.1, phase2_y, "Phase 2B: SPEAR3 Integration", fontsize=12, fontweight='bold')
    ax.text(6.1, phase2_y-0.3, "• Add LLRF9 + Arc Detection + Galil", fontsize=10)
    ax.text(6.1, phase2_y-0.5, "• Live RF Cavities Integration", fontsize=10)
    
    # Phase 3: Commissioning (Month 9)
    phase3_y = 3
    ax.text(1, phase3_y + 0.5, 'PHASE 3: Commissioning (Month 9)', 
            fontsize=14, fontweight='bold', color=colors['phase3'])
    
    commissioning_steps = [
        "Dimtel Support Week (LLRF9 Optimization)",
        "Incremental Power Ramp (10% → 100%)",
        "Performance Validation & Operator Training"
    ]
    
    for i, step in enumerate(commissioning_steps):
        rect = FancyBboxPatch((1 + i*3.5, phase3_y-0.3), 3, 0.4, 
                             boxstyle="round,pad=0.02", 
                             facecolor=colors['phase3'], alpha=0.2, edgecolor=colors['phase3'])
        ax.add_patch(rect)
        ax.text(1.1 + i*3.5, phase3_y-0.1, step, fontsize=10, va='center')
    
    # Critical Path Arrows
    # Phase 1 to Phase 2A
    arrow1 = ConnectionPatch((3.25, phase1_y-3.5), (3.25, phase2_y+0.5), 
                           "data", "data", arrowstyle="->", 
                           shrinkA=5, shrinkB=5, mutation_scale=20, 
                           fc=colors['integration'], ec=colors['integration'], lw=2)
    ax.add_patch(arrow1)
    
    # Phase 2A to Phase 2B
    arrow2 = ConnectionPatch((5.5, phase2_y-0.25), (6, phase2_y-0.25), 
                           "data", "data", arrowstyle="->", 
                           shrinkA=5, shrinkB=5, mutation_scale=20, 
                           fc=colors['integration'], ec=colors['integration'], lw=2)
    ax.add_patch(arrow2)
    
    # Phase 2B to Phase 3
    arrow3 = ConnectionPatch((8.25, phase2_y-0.5), (8.25, phase3_y+0.5), 
                           "data", "data", arrowstyle="->", 
                           shrinkA=5, shrinkB=5, mutation_scale=20, 
                           fc=colors['integration'], ec=colors['integration'], lw=2)
    ax.add_patch(arrow3)
    
    # Critical Risks Box
    risk_y = 0.5
    rect = FancyBboxPatch((1, risk_y), 10, 1.5, 
                         boxstyle="round,pad=0.05", 
                         facecolor=colors['critical'], alpha=0.1, edgecolor=colors['critical'])
    ax.add_patch(rect)
    ax.text(1.1, risk_y + 1.2, "🚨 CRITICAL RISKS", fontsize=12, fontweight='bold', color=colors['critical'])
    
    risks = [
        "1. Python/EPICS Coordinator Software (Critical - Not Started)",
        "2. Interface Chassis Logic Design (High - Complex LLRF9/HVPS feedback)",
        "3. Kly MPS PLC Software Integration (High - Not Started)", 
        "4. PPS Interface Regulatory Approval (High - Timeline Risk)"
    ]
    
    for i, risk in enumerate(risks):
        ax.text(1.2, risk_y + 0.9 - i*0.2, risk, fontsize=9, va='center')
    
    # Success Criteria Box
    success_y = -1.5
    rect = FancyBboxPatch((1, success_y), 10, 1, 
                         boxstyle="round,pad=0.05", 
                         facecolor=colors['phase3'], alpha=0.1, edgecolor=colors['phase3'])
    ax.add_patch(rect)
    ax.text(1.1, success_y + 0.7, "🎯 SUCCESS CRITERIA", fontsize=12, fontweight='bold', color=colors['phase3'])
    
    criteria = [
        "Amplitude Stability: <0.1% | Phase Stability: <0.1° | Uptime: >99.5%",
        "16k-Sample Waveform Capture | First-Fault Detection | Auto-Recovery"
    ]
    
    for i, criterion in enumerate(criteria):
        ax.text(1.2, success_y + 0.4 - i*0.2, criterion, fontsize=9, va='center')
    
    # Set axis properties
    ax.set_xlim(0, 12)
    ax.set_ylim(-3, 11)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    ax.text(6, 10.5, 'SPEAR3 LLRF Upgrade Project - Implementation Overview', 
            fontsize=16, fontweight='bold', ha='center')
    ax.text(6, 10.1, 'Complete RF System Modernization: 10 Subsystems, 4 Phases, 9 Months', 
            fontsize=12, ha='center', style='italic')
    
    plt.tight_layout()
    return fig

def create_detailed_flow_diagram():
    """Create a detailed subsystem flow diagram"""
    fig, ax = plt.subplots(1, 1, figsize=(20, 14))
    
    # Define positions for subsystems in a flow layout
    subsystems = {
        # Phase 1 - Standalone Development
        'HVPS_PLC': (2, 12, '✅ HVPS PLC\n(CompactLogix)', '#2E8B57'),
        'HVPS_SCR': (2, 10.5, '⬜ HVPS SCR\n(FCOG1200)', '#DC143C'),
        'HEATER': (2, 9, '⬜ Heater SCR\nController', '#DC143C'),
        'KLY_MPS': (2, 7.5, '✅ Kly MPS PLC\n(ControlLogix)', '#2E8B57'),
        'WFB': (2, 6, '🔄 Waveform\nBuffer System', '#FF8C00'),
        'INTERFACE': (2, 4.5, '⚠️ Interface\nChassis', '#8B0000'),
        'SOFTWARE': (2, 3, '⚠️ Python/EPICS\nCoordinator', '#8B0000'),
        
        # Cavity-dependent systems
        'LLRF9': (6, 12, '✅ LLRF9\nControllers', '#2E8B57'),
        'ARC_DET': (6, 10.5, '⬜ Arc Detection\nSystem', '#DC143C'),
        'GALIL': (6, 9, '✅ Galil Motion\nController', '#2E8B57'),
        'PPS': (6, 7.5, '⬜ PPS Interface\nBox', '#DC143C'),
        
        # Integration phases
        'TS18': (10, 9, 'Phase 2A:\nTS18 Integration', '#9370DB'),
        'SPEAR3': (14, 9, 'Phase 2B:\nSPEAR3 Integration', '#9370DB'),
        'COMMISSION': (18, 9, 'Phase 3:\nCommissioning', '#228B22')
    }
    
    # Draw subsystem boxes
    for name, (x, y, label, color) in subsystems.items():
        if '⚠️' in label:
            # Critical path items - larger boxes
            rect = FancyBboxPatch((x-0.8, y-0.6), 1.6, 1.2, 
                                 boxstyle="round,pad=0.1", 
                                 facecolor=color, alpha=0.3, edgecolor=color, linewidth=3)
        else:
            rect = FancyBboxPatch((x-0.7, y-0.5), 1.4, 1, 
                                 boxstyle="round,pad=0.05", 
                                 facecolor=color, alpha=0.3, edgecolor=color)
        ax.add_patch(rect)
        ax.text(x, y, label, fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Draw integration flow arrows
    integration_flows = [
        # Phase 1 to TS18
        ('HVPS_PLC', 'TS18'),
        ('HEATER', 'TS18'),
        ('KLY_MPS', 'TS18'),
        ('WFB', 'TS18'),
        ('INTERFACE', 'TS18'),
        ('SOFTWARE', 'TS18'),
        
        # TS18 to SPEAR3
        ('TS18', 'SPEAR3'),
        
        # Cavity-dependent to SPEAR3
        ('LLRF9', 'SPEAR3'),
        ('ARC_DET', 'SPEAR3'),
        ('GALIL', 'SPEAR3'),
        
        # SPEAR3 to Commissioning
        ('SPEAR3', 'COMMISSION')
    ]
    
    for start, end in integration_flows:
        start_pos = subsystems[start]
        end_pos = subsystems[end]
        
        # Calculate arrow positions
        if start_pos[0] < end_pos[0]:  # Left to right
            start_x, start_y = start_pos[0] + 0.7, start_pos[1]
            end_x, end_y = end_pos[0] - 0.7, end_pos[1]
        else:  # Same column or other direction
            start_x, start_y = start_pos[0], start_pos[1] - 0.5
            end_x, end_y = end_pos[0], end_pos[1] + 0.5
        
        arrow = ConnectionPatch((start_x, start_y), (end_x, end_y), 
                               "data", "data", arrowstyle="->", 
                               shrinkA=5, shrinkB=5, mutation_scale=15, 
                               fc='#4682B4', ec='#4682B4', lw=1.5)
        ax.add_patch(arrow)
    
    # Add phase labels
    ax.text(2, 13.5, 'PHASE 1: Standalone Development', 
            fontsize=14, fontweight='bold', ha='center', color='#4682B4')
    ax.text(6, 13.5, 'Cavity-Dependent Systems', 
            fontsize=14, fontweight='bold', ha='center', color='#4682B4')
    ax.text(14, 13.5, 'PHASE 2 & 3: Integration & Commissioning', 
            fontsize=14, fontweight='bold', ha='center', color='#9370DB')
    
    # Add timeline
    timeline_y = 1.5
    ax.text(10, timeline_y + 0.5, 'PROJECT TIMELINE', 
            fontsize=12, fontweight='bold', ha='center')
    
    timeline_items = [
        (2, 'Months 1-3\nStandalone Dev'),
        (6, 'Months 4-6\nIntegration Prep'),
        (10, 'Months 7-8\nTS18 Integration'),
        (14, 'Month 8-9\nSPEAR3 Integration'),
        (18, 'Month 9\nCommissioning')
    ]
    
    for x, label in timeline_items:
        rect = FancyBboxPatch((x-1, timeline_y-0.4), 2, 0.8, 
                             boxstyle="round,pad=0.05", 
                             facecolor='#F0F8FF', alpha=0.8, edgecolor='#4682B4')
        ax.add_patch(rect)
        ax.text(x, timeline_y, label, fontsize=9, ha='center', va='center')
    
    # Add critical path indicators
    ax.text(1, 0.5, '⚠️ Critical Path Items (Must Start Immediately)', 
            fontsize=12, fontweight='bold', color='#8B0000')
    ax.text(1, 0.1, '• Interface Chassis: Gates all integration testing', fontsize=10)
    ax.text(1, -0.2, '• Python/EPICS Software: Required for all control functions', fontsize=10)
    
    # Set axis properties
    ax.set_xlim(0, 20)
    ax.set_ylim(-1, 15)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Title
    ax.text(10, 14.5, 'SPEAR3 LLRF Upgrade - Detailed Implementation Flow', 
            fontsize=16, fontweight='bold', ha='center')
    
    plt.tight_layout()
    return fig

def main():
    """Generate both diagrams and save them"""
    
    # Create overview diagram
    print("Creating project overview diagram...")
    fig1 = create_project_overview_diagram()
    fig1.savefig('SPEAR3_LLRF_Project_Overview.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    print("✅ Saved: SPEAR3_LLRF_Project_Overview.png")
    
    # Create detailed flow diagram  
    print("Creating detailed flow diagram...")
    fig2 = create_detailed_flow_diagram()
    fig2.savefig('SPEAR3_LLRF_Detailed_Flow.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    print("✅ Saved: SPEAR3_LLRF_Detailed_Flow.png")
    
    plt.close('all')
    print("\n🎯 Project path diagrams created successfully!")
    print("📊 Overview diagram shows phases, risks, and success criteria")
    print("🔄 Detailed flow diagram shows subsystem dependencies and integration sequence")

if __name__ == "__main__":
    main()

