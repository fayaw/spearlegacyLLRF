#!/usr/bin/env python3
"""
SPEAR3 LLRF Upgrade Project - Corrected Overview (No Duration Assumptions)
Creates a clean overview diagram focusing on project structure and dependencies
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np

def create_corrected_overview():
    """Create overview diagram without duration assumptions"""
    fig, ax = plt.subplots(1, 1, figsize=(18, 12))
    
    # Colors
    colors = {
        'complete': '#27AE60',      # Green
        'in_progress': '#F39C12',   # Orange  
        'not_started': '#E74C3C',   # Red
        'critical': '#8E44AD',      # Purple
        'phase': '#3498DB',         # Blue
        'bg': '#FFFFFF',            # White
        'text': '#2C3E50',          # Dark gray
    }
    
    ax.set_facecolor(colors['bg'])
    
    # Title
    ax.text(9, 11, 'SPEAR3 LLRF Upgrade Project Overview', 
            fontsize=20, fontweight='bold', ha='center', color=colors['text'])
    ax.text(9, 10.5, 'Complete Implementation Structure • No Duration Assumptions', 
            fontsize=12, ha='center', color=colors['text'], style='italic')
    
    # Hardware Readiness Status (Top section)
    status_y = 9.5
    ax.text(9, status_y + 0.5, 'HARDWARE READINESS STATUS', 
            fontsize=14, fontweight='bold', ha='center', color=colors['text'])
    
    # Status summary boxes
    status_boxes = [
        ('✓ COMPLETE\n4 Systems Ready', colors['complete'], 2),
        ('◐ IN PROGRESS\n2 Systems Active', colors['in_progress'], 6),
        ('○ NOT STARTED\n5 Systems Needed', colors['not_started'], 10),
        ('⚠️ CRITICAL PATH\n2 Key Blockers', colors['critical'], 14)
    ]
    
    for label, color, x in status_boxes:
        rect = FancyBboxPatch((x - 1.5, status_y - 0.6), 3, 1.2, 
                             boxstyle="round,pad=0.1", 
                             facecolor=color, alpha=0.2, 
                             edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(x, status_y, label, fontsize=10, ha='center', va='center', 
                color=color, fontweight='bold')
    
    # Implementation Phases (Main section)
    phase_y = 7.5
    ax.text(9, phase_y + 0.5, 'IMPLEMENTATION PHASES', 
            fontsize=14, fontweight='bold', ha='center', color=colors['text'])
    
    # Phase boxes with detailed content
    phases = [
        {
            'title': 'PHASE 1',
            'subtitle': 'Standalone Development',
            'content': '11 Parallel Subsystems\n• Maximum standalone testing\n• Independent development tracks\n• Minimize integration risk',
            'color': colors['phase'],
            'x': 2,
            'width': 3.5
        },
        {
            'title': 'PHASE 2A',
            'subtitle': 'TS18 Sub-Integration',
            'content': '7 Incremental Steps\n• Klystron + dummy load\n• No RF cavity dependency\n• Build up one subsystem at a time',
            'color': colors['in_progress'],
            'x': 6,
            'width': 3.5
        },
        {
            'title': 'PHASE 2B',
            'subtitle': 'SPEAR3 Integration',
            'content': '4 Integration Steps\n• Live RF cavities\n• Full RF chain active\n• Add cavity-dependent systems',
            'color': colors['complete'],
            'x': 10,
            'width': 3.5
        },
        {
            'title': 'PHASE 3&4',
            'subtitle': 'Final Commissioning',
            'content': '6 Commissioning Steps\n• PPS safety approval\n• Performance validation\n• Operator training',
            'color': colors['phase'],
            'x': 14,
            'width': 3.5
        }
    ]
    
    for phase in phases:
        # Main phase box
        rect = FancyBboxPatch((phase['x'] - phase['width']/2, phase_y - 1.2), 
                             phase['width'], 2.4, 
                             boxstyle="round,pad=0.1", 
                             facecolor=phase['color'], alpha=0.2, 
                             edgecolor=phase['color'], linewidth=2)
        ax.add_patch(rect)
        
        # Phase title
        ax.text(phase['x'], phase_y + 0.8, phase['title'], 
                fontsize=12, fontweight='bold', ha='center', color=phase['color'])
        ax.text(phase['x'], phase_y + 0.5, phase['subtitle'], 
                fontsize=11, ha='center', color=colors['text'])
        
        # Phase content
        ax.text(phase['x'], phase_y - 0.2, phase['content'], 
                fontsize=9, ha='center', va='center', color=colors['text'])
        
        # Flow arrows between phases
        if phase['x'] < 14:  # Not the last phase
            ax.annotate('', xy=(phase['x'] + phase['width']/2 + 0.2, phase_y), 
                       xytext=(phase['x'] + phase['width']/2 - 0.2, phase_y),
                       arrowprops=dict(arrowstyle='->', lw=2, color=colors['text']))
    
    # Critical Dependencies (Bottom section)
    dep_y = 4
    ax.text(9, dep_y + 0.5, 'CRITICAL DEPENDENCIES & GATES', 
            fontsize=14, fontweight='bold', ha='center', color=colors['critical'])
    
    # Dependency boxes
    dependencies = [
        {
            'title': 'Interface Chassis (IC5)',
            'desc': 'Gates ALL IC Integration Tests\nCentral interlock hub\nRequired before any integration',
            'x': 4.5,
            'status': 'In Progress'
        },
        {
            'title': 'Python/EPICS Software',
            'desc': 'Enables ALL SW Integration Tests\nLargest untouched scope\nCRITICAL - Start immediately',
            'x': 13.5,
            'status': 'Not Started'
        }
    ]
    
    for dep in dependencies:
        color = colors['in_progress'] if dep['status'] == 'In Progress' else colors['critical']
        
        rect = FancyBboxPatch((dep['x'] - 2, dep_y - 0.8), 4, 1.6, 
                             boxstyle="round,pad=0.1", 
                             facecolor=color, alpha=0.15, 
                             edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        
        ax.text(dep['x'], dep_y + 0.4, dep['title'], 
                fontsize=11, fontweight='bold', ha='center', color=color)
        ax.text(dep['x'], dep_y - 0.2, dep['desc'], 
                fontsize=9, ha='center', va='center', color=colors['text'])
    
    # Key Strategy Box (Bottom)
    strategy_y = 1.5
    rect = FancyBboxPatch((1, strategy_y - 0.6), 16, 1.2, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['phase'], alpha=0.1, 
                         edgecolor=colors['phase'], linewidth=2)
    ax.add_patch(rect)
    ax.text(9, strategy_y + 0.2, '🎯 KEY STRATEGY: Maximum Standalone Development', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase'])
    ax.text(9, strategy_y - 0.2, 'All subsystems developed and tested independently before integration to minimize risk during limited integration windows', 
            fontsize=11, ha='center', color=colors['text'])
    
    # Subsystem Details (Right side annotation)
    subsys_x = 16.5
    subsys_y = 9
    ax.text(subsys_x, subsys_y, 'SUBSYSTEM BREAKDOWN', 
            fontsize=10, fontweight='bold', color=colors['text'])
    
    subsystem_list = [
        'Complete: LLRF9, HVPS PLC, Kly MPS, Galil',
        'In Progress: Waveform Buffer, Interface Chassis',
        'Not Started: HVPS SCR, Heater, Arc Detection,',
        '             PPS Interface, Python/EPICS SW'
    ]
    
    for i, item in enumerate(subsystem_list):
        ax.text(subsys_x, subsys_y - 0.3 - i*0.25, f"• {item}", 
                fontsize=8, color=colors['text'])
    
    # Set axis properties
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    plt.tight_layout()
    return fig

def main():
    """Generate corrected overview diagram"""
    
    print("Creating corrected overview diagram (no duration assumptions)...")
    fig = create_corrected_overview()
    fig.savefig('SPEAR3_LLRF_Corrected_Overview.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none', pad_inches=0.3)
    print("✅ Saved: SPEAR3_LLRF_Corrected_Overview.png")
    
    plt.close('all')
    print("\n🎯 Corrected overview diagram created successfully!")
    print("📊 Focuses on project structure without duration assumptions")
    print("🔄 Emphasizes phases, dependencies, and critical path")

if __name__ == "__main__":
    main()

