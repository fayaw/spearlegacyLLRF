#!/usr/bin/env python3
"""
SPEAR3 LLRF Upgrade Project Path Diagram
Creates a comprehensive diagram showing the complete project implementation path
Based on the actual ProjectPath.md structure without assuming duration
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle, ConnectionPatch
import numpy as np

def create_complete_project_path():
    """Create the complete project path diagram showing all phases and dependencies"""
    fig, ax = plt.subplots(1, 1, figsize=(24, 18))
    
    # Colors
    colors = {
        'complete': '#27AE60',      # Green
        'in_progress': '#F39C12',   # Orange  
        'not_started': '#E74C3C',   # Red
        'critical': '#8E44AD',      # Purple
        'phase1': '#3498DB',        # Blue
        'phase2a': '#E67E22',       # Orange
        'phase2b': '#16A085',       # Teal
        'phase3': '#27AE60',        # Green
        'bg': '#FFFFFF',            # White
        'text': '#2C3E50',          # Dark gray
        'arrow': '#7F8C8D'          # Gray
    }
    
    ax.set_facecolor(colors['bg'])
    
    # Title
    ax.text(12, 17, 'SPEAR3 LLRF Upgrade - Complete Project Path', 
            fontsize=20, fontweight='bold', ha='center', color=colors['text'])
    ax.text(12, 16.5, 'All Phases • All Dependencies • Complete Integration Flow', 
            fontsize=12, ha='center', color=colors['text'], style='italic')
    
    # Hardware Status Summary (Top)
    status_y = 15.5
    ax.text(2, status_y, 'HARDWARE STATUS', fontsize=12, fontweight='bold', color=colors['text'])
    
    # Status boxes - compact horizontal layout
    status_items = [
        ('✓ Complete (4)', colors['complete'], 0.5),
        ('◐ In Progress (2)', colors['in_progress'], 4),
        ('○ Not Started (5)', colors['not_started'], 8),
        ('⚠️ Critical Path (2)', colors['critical'], 12)
    ]
    
    for label, color, x in status_items:
        rect = FancyBboxPatch((x, status_y - 0.3), 3, 0.6, 
                             boxstyle="round,pad=0.05", 
                             facecolor=color, alpha=0.3, 
                             edgecolor=color, linewidth=1)
        ax.add_patch(rect)
        ax.text(x + 1.5, status_y, label, fontsize=10, ha='center', va='center', 
                color=color, fontweight='bold')
    
    # PHASE 1: Standalone Development (Left side - vertical layout)
    phase1_x = 2
    phase1_y = 14
    ax.text(phase1_x + 1, phase1_y, 'PHASE 1: STANDALONE DEVELOPMENT', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase1'])
    ax.text(phase1_x + 1, phase1_y - 0.3, 'Parallel Development Tracks', 
            fontsize=10, ha='center', color=colors['text'])
    
    # Phase 1 subsystems - organized by status
    subsystems_p1 = [
        # Complete systems
        ('LLRF9 (4 units)', colors['complete'], 13.2),
        ('HVPS PLC', colors['complete'], 12.8),
        ('Kly MPS PLC', colors['complete'], 12.4),
        ('Galil Motion', colors['complete'], 12.0),
        
        # In Progress
        ('Waveform Buffer', colors['in_progress'], 11.4),
        ('Interface Chassis ⚠️', colors['critical'], 11.0),
        
        # Not Started
        ('HVPS SCR (FCOG1200)', colors['not_started'], 10.4),
        ('Heater SCR Controller', colors['not_started'], 10.0),
        ('Arc Detection System', colors['not_started'], 9.6),
        ('PPS Interface Box', colors['not_started'], 9.2),
        ('Python/EPICS SW ⚠️', colors['critical'], 8.8)
    ]
    
    for name, color, y in subsystems_p1:
        width = 3.5 if '⚠️' in name else 3
        linewidth = 2 if '⚠️' in name else 1
        
        rect = FancyBboxPatch((phase1_x - 0.2, y - 0.15), width, 0.3, 
                             boxstyle="round,pad=0.02", 
                             facecolor=color, alpha=0.3, 
                             edgecolor=color, linewidth=linewidth)
        ax.add_patch(rect)
        ax.text(phase1_x + width/2 - 0.2, y, name, fontsize=9, ha='center', va='center', 
                color=color, fontweight='bold' if '⚠️' in name else 'normal')
    
    # PHASE 2A: TS18 Sub-Integration (Center-left)
    ts18_x = 7
    ts18_y = 13
    ax.text(ts18_x + 1, ts18_y, 'PHASE 2A: TS18 SUB-INTEGRATION', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase2a'])
    ax.text(ts18_x + 1, ts18_y - 0.3, 'Klystron + Dummy Load • No RF Cavity', 
            fontsize=10, ha='center', color=colors['text'])
    
    # TS18 steps - incremental build-up
    ts18_steps = [
        '① HVPS Combined\n(PLC + SCR + Regulator)',
        '② + Heater Controller\n(Warm-up sequences)',
        '③ + Interface Chassis\n(Hardware interlock loop)',
        '④ + Kly MPS PLC\n(Permit/heartbeat/reset)',
        '⑤ + Waveform Buffer\n(HVPS + RF channels)',
        '⑥ + Software Stack\n(State machine + loops)',
        '⑦ RF Power Ramp\n(Incremental testing)'
    ]
    
    for i, step in enumerate(ts18_steps):
        y_pos = 12.2 - i * 0.4
        rect = FancyBboxPatch((ts18_x, y_pos - 0.15), 3, 0.3, 
                             boxstyle="round,pad=0.02", 
                             facecolor=colors['phase2a'], alpha=0.2, 
                             edgecolor=colors['phase2a'], linewidth=1)
        ax.add_patch(rect)
        ax.text(ts18_x + 1.5, y_pos, step, fontsize=8, ha='center', va='center', 
                color=colors['text'])
        
        # Arrows between steps
        if i < len(ts18_steps) - 1:
            ax.annotate('', xy=(ts18_x + 1.5, y_pos - 0.25), xytext=(ts18_x + 1.5, y_pos - 0.05),
                       arrowprops=dict(arrowstyle='->', lw=1, color=colors['arrow']))
    
    # PHASE 2B: SPEAR3 Integration (Center-right)
    spear_x = 12
    spear_y = 13
    ax.text(spear_x + 1, spear_y, 'PHASE 2B: SPEAR3 INTEGRATION', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase2b'])
    ax.text(spear_x + 1, spear_y - 0.3, 'Live RF Cavities • Full RF Chain', 
            fontsize=10, ha='center', color=colors['text'])
    
    # SPEAR3 steps - adding cavity-dependent systems
    spear_steps = [
        '① + LLRF9 Units 1&2\n(RF fast feedback)',
        '② + Galil Motion\n(Cavity tuner control)',
        '③ + Arc Detection\n(Fast permit + fault ID)',
        '④ End-to-End Verify\n(All protection layers)'
    ]
    
    for i, step in enumerate(spear_steps):
        y_pos = 12.2 - i * 0.4
        rect = FancyBboxPatch((spear_x, y_pos - 0.15), 3, 0.3, 
                             boxstyle="round,pad=0.02", 
                             facecolor=colors['phase2b'], alpha=0.2, 
                             edgecolor=colors['phase2b'], linewidth=1)
        ax.add_patch(rect)
        ax.text(spear_x + 1.5, y_pos, step, fontsize=8, ha='center', va='center', 
                color=colors['text'])
        
        # Arrows between steps
        if i < len(spear_steps) - 1:
            ax.annotate('', xy=(spear_x + 1.5, y_pos - 0.25), xytext=(spear_x + 1.5, y_pos - 0.05),
                       arrowprops=dict(arrowstyle='->', lw=1, color=colors['arrow']))
    
    # PHASE 3&4: Final Commissioning (Right side)
    final_x = 17
    final_y = 13
    ax.text(final_x + 1, final_y, 'PHASE 3&4: COMMISSIONING', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase3'])
    ax.text(final_x + 1, final_y - 0.3, 'Final Validation • Operation', 
            fontsize=10, ha='center', color=colors['text'])
    
    # Final commissioning steps
    final_steps = [
        '① + PPS Box\n(Safety approval)',
        '② SW Full Validation\n(Complete hardware)',
        '③ RF Power Ramp\n(SPEAR3 cavities)',
        '④ Performance Valid.\n(Stability + diagnostics)',
        '⑤ Operator Training\n(Documentation)',
        '⑥ ✓ OPERATION'
    ]
    
    for i, step in enumerate(final_steps):
        y_pos = 12.2 - i * 0.4
        is_final = '✓' in step
        rect = FancyBboxPatch((final_x, y_pos - 0.15), 3, 0.3, 
                             boxstyle="round,pad=0.02", 
                             facecolor=colors['phase3'], alpha=0.3 if is_final else 0.2, 
                             edgecolor=colors['phase3'], linewidth=2 if is_final else 1)
        ax.add_patch(rect)
        ax.text(final_x + 1.5, y_pos, step, fontsize=8, ha='center', va='center', 
                color=colors['phase3'] if is_final else colors['text'], 
                fontweight='bold' if is_final else 'normal')
        
        # Arrows between steps
        if i < len(final_steps) - 1:
            ax.annotate('', xy=(final_x + 1.5, y_pos - 0.25), xytext=(final_x + 1.5, y_pos - 0.05),
                       arrowprops=dict(arrowstyle='->', lw=1, color=colors['arrow']))
    
    # Critical Dependencies (Bottom section)
    dep_y = 7
    ax.text(12, dep_y + 0.5, 'CRITICAL DEPENDENCIES & GATES', 
            fontsize=14, fontweight='bold', ha='center', color=colors['critical'])
    
    # Key dependency flows
    dependencies = [
        'Interface Chassis (IC5) → Gates ALL IC Integration Tests',
        'Python/EPICS SW → Enables ALL SW Integration Tests', 
        'Each Subsystem: SW Test + IC Test → TS18 Integration',
        'TS18 Complete + Cavity Systems → SPEAR3 Integration',
        'SPEAR3 Complete + PPS Approval → Final Commissioning'
    ]
    
    for i, dep in enumerate(dependencies):
        y_pos = dep_y - i * 0.3
        ax.text(12, y_pos, f"• {dep}", fontsize=10, ha='center', va='center', 
                color=colors['text'])
    
    # Major flow arrows
    # Phase 1 to TS18
    ax.annotate('', xy=(6.8, 11), xytext=(5.5, 11),
               arrowprops=dict(arrowstyle='->', lw=3, color=colors['phase2a']))
    ax.text(6, 11.3, 'SW + IC\nTests Pass', fontsize=8, ha='center', color=colors['phase2a'])
    
    # TS18 to SPEAR3
    ax.annotate('', xy=(11.8, 11), xytext=(10.2, 11),
               arrowprops=dict(arrowstyle='->', lw=3, color=colors['phase2b']))
    ax.text(11, 11.3, 'TS18\nComplete', fontsize=8, ha='center', color=colors['phase2b'])
    
    # SPEAR3 to Final
    ax.annotate('', xy=(16.8, 11), xytext=(15.2, 11),
               arrowprops=dict(arrowstyle='->', lw=3, color=colors['phase3']))
    ax.text(16, 11.3, 'SPEAR3\nComplete', fontsize=8, ha='center', color=colors['phase3'])
    
    # Cavity-dependent systems to SPEAR3
    ax.annotate('', xy=(12, 10.5), xytext=(4, 10.5),
               arrowprops=dict(arrowstyle='->', lw=2, color=colors['phase2b'], 
                              connectionstyle="arc3,rad=0.3"))
    ax.text(8, 9.8, 'Cavity-Dependent\nSystems Ready', fontsize=8, ha='center', color=colors['phase2b'])
    
    # PPS to Final
    ax.annotate('', xy=(17, 9.5), xytext=(4, 9.2),
               arrowprops=dict(arrowstyle='->', lw=2, color=colors['phase3'], 
                              connectionstyle="arc3,rad=-0.4"))
    ax.text(10, 8.5, 'PPS Safety Approval', fontsize=8, ha='center', color=colors['phase3'])
    
    # Legend
    legend_y = 3
    ax.text(12, legend_y + 1, 'PROJECT STRUCTURE', 
            fontsize=12, fontweight='bold', ha='center', color=colors['text'])
    
    legend_items = [
        ('Phase 1: Maximum parallel standalone development', colors['phase1']),
        ('Phase 2A: Incremental TS18 integration (7 steps)', colors['phase2a']),
        ('Phase 2B: SPEAR3 cavity integration (4 steps)', colors['phase2b']),
        ('Phase 3&4: Final commissioning (6 steps)', colors['phase3']),
        ('Critical Path: Interface Chassis + Python/EPICS Software', colors['critical'])
    ]
    
    for i, (desc, color) in enumerate(legend_items):
        y_pos = legend_y + 0.5 - i * 0.3
        rect = FancyBboxPatch((2, y_pos - 0.08), 0.3, 0.16, 
                             boxstyle="round,pad=0.02", 
                             facecolor=color, alpha=0.3, edgecolor=color)
        ax.add_patch(rect)
        ax.text(2.5, y_pos, desc, fontsize=10, va='center', color=colors['text'])
    
    # Key insight box
    insight_y = 1
    rect = FancyBboxPatch((1, insight_y - 0.5), 22, 1, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['critical'], alpha=0.1, 
                         edgecolor=colors['critical'], linewidth=2)
    ax.add_patch(rect)
    ax.text(12, insight_y + 0.2, '🎯 KEY INSIGHT: Maximum Standalone Development Strategy', 
            fontsize=14, fontweight='bold', ha='center', color=colors['critical'])
    ax.text(12, insight_y - 0.2, 'All subsystems developed and tested independently before integration to minimize risk during limited integration windows', 
            fontsize=11, ha='center', color=colors['text'])
    
    # Set axis properties
    ax.set_xlim(0, 24)
    ax.set_ylim(0, 18)
    ax.axis('off')
    
    plt.tight_layout()
    return fig

def main():
    """Generate the complete project path diagram"""
    
    print("Creating complete project path diagram...")
    fig = create_complete_project_path()
    fig.savefig('SPEAR3_LLRF_Complete_Project_Path.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none', pad_inches=0.3)
    print("✅ Saved: SPEAR3_LLRF_Complete_Project_Path.png")
    
    plt.close('all')
    print("\n🎯 Complete project path diagram created successfully!")
    print("📊 Shows all phases, dependencies, and integration flow")
    print("🔄 No duration assumptions - focuses on project structure")

if __name__ == "__main__":
    main()

