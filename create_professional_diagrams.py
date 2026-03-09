#!/usr/bin/env python3
"""
SPEAR3 LLRF Upgrade Project - Professional Clean Diagrams
Creates publication-quality diagrams with minimal text overlap
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Rectangle
import numpy as np

def create_professional_overview():
    """Create a professional overview with clean layout"""
    fig, ax = plt.subplots(1, 1, figsize=(16, 12))
    
    # Colors
    colors = {
        'complete': '#27AE60',      # Green
        'in_progress': '#F39C12',   # Orange  
        'not_started': '#E74C3C',   # Red
        'critical': '#8E44AD',      # Purple
        'phase': '#3498DB',         # Blue
        'bg': '#FFFFFF',            # White
        'text': '#2C3E50',          # Dark gray
        'light_bg': '#ECF0F1'       # Light gray
    }
    
    ax.set_facecolor(colors['bg'])
    
    # Main title
    ax.text(8, 11, 'SPEAR3 LLRF Upgrade Project', 
            fontsize=22, fontweight='bold', ha='center', color=colors['text'])
    ax.text(8, 10.5, '10 Subsystems • 4 Phases • 9 Months', 
            fontsize=14, ha='center', color=colors['text'])
    
    # Hardware Status Summary (Top section)
    status_y = 9.5
    
    # Complete systems box
    rect = FancyBboxPatch((0.5, status_y - 0.8), 4.5, 1.5, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['complete'], alpha=0.2, 
                         edgecolor=colors['complete'], linewidth=2)
    ax.add_patch(rect)
    ax.text(2.75, status_y + 0.2, 'COMPLETE ✓', fontsize=12, fontweight='bold', 
            ha='center', color=colors['complete'])
    ax.text(2.75, status_y - 0.1, '4 Systems Ready', fontsize=10, 
            ha='center', color=colors['text'])
    ax.text(2.75, status_y - 0.4, 'LLRF9 • HVPS PLC • Kly MPS • Galil', fontsize=9, 
            ha='center', color=colors['text'])
    
    # In Progress box
    rect = FancyBboxPatch((5.5, status_y - 0.8), 4.5, 1.5, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['in_progress'], alpha=0.2, 
                         edgecolor=colors['in_progress'], linewidth=2)
    ax.add_patch(rect)
    ax.text(7.75, status_y + 0.2, 'IN PROGRESS ◐', fontsize=12, fontweight='bold', 
            ha='center', color=colors['in_progress'])
    ax.text(7.75, status_y - 0.1, '2 Systems Active', fontsize=10, 
            ha='center', color=colors['text'])
    ax.text(7.75, status_y - 0.4, 'Waveform Buffer • Interface Chassis', fontsize=9, 
            ha='center', color=colors['text'])
    
    # Not Started box
    rect = FancyBboxPatch((10.5, status_y - 0.8), 4.5, 1.5, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['not_started'], alpha=0.2, 
                         edgecolor=colors['not_started'], linewidth=2)
    ax.add_patch(rect)
    ax.text(12.75, status_y + 0.2, 'NOT STARTED ○', fontsize=12, fontweight='bold', 
            ha='center', color=colors['not_started'])
    ax.text(12.75, status_y - 0.1, '5 Systems Needed', fontsize=10, 
            ha='center', color=colors['text'])
    ax.text(12.75, status_y - 0.4, 'FCOG1200 • Arc Det • Heater • PPS • Software', fontsize=9, 
            ha='center', color=colors['text'])
    
    # Critical Path Alert
    critical_y = 7.5
    rect = FancyBboxPatch((1, critical_y - 0.6), 14, 1.2, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['critical'], alpha=0.15, 
                         edgecolor=colors['critical'], linewidth=3)
    ax.add_patch(rect)
    ax.text(8, critical_y + 0.2, '⚠️ CRITICAL PATH ITEMS', fontsize=16, fontweight='bold', 
            ha='center', color=colors['critical'])
    ax.text(8, critical_y - 0.2, 'Python/EPICS Coordinator (CRITICAL - Start Now) • Interface Chassis (Gates Integration)', 
            fontsize=11, ha='center', color=colors['text'])
    
    # Implementation Phases (Bottom section)
    phase_y = 5.5
    phase_width = 3.5
    phase_spacing = 0.2
    
    phases = [
        ('PHASE 1', 'Standalone\nDevelopment', 'Months 1-3', colors['phase']),
        ('PHASE 2A', 'TS18\nIntegration', 'Months 4-6', colors['phase']),
        ('PHASE 2B', 'SPEAR3\nIntegration', 'Months 7-8', colors['phase']),
        ('PHASE 3', 'Commissioning\n& Validation', 'Month 9', colors['complete'])
    ]
    
    for i, (phase_num, phase_name, timeline, color) in enumerate(phases):
        x_pos = 0.5 + i * (phase_width + phase_spacing)
        
        rect = FancyBboxPatch((x_pos, phase_y - 1.2), phase_width, 2.4, 
                             boxstyle="round,pad=0.1", 
                             facecolor=color, alpha=0.2, 
                             edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        
        ax.text(x_pos + phase_width/2, phase_y + 0.6, phase_num, 
                fontsize=12, fontweight='bold', ha='center', color=color)
        ax.text(x_pos + phase_width/2, phase_y + 0.1, phase_name, 
                fontsize=11, ha='center', color=colors['text'])
        ax.text(x_pos + phase_width/2, phase_y - 0.4, timeline, 
                fontsize=10, ha='center', color=colors['text'])
        
        # Add arrows between phases
        if i < len(phases) - 1:
            arrow_x = x_pos + phase_width + phase_spacing/2
            ax.annotate('', xy=(arrow_x + 0.1, phase_y), xytext=(arrow_x - 0.1, phase_y),
                       arrowprops=dict(arrowstyle='->', lw=2, color=colors['text']))
    
    # Success Metrics
    success_y = 2
    rect = FancyBboxPatch((1, success_y - 0.8), 14, 1.6, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['complete'], alpha=0.1, 
                         edgecolor=colors['complete'], linewidth=2)
    ax.add_patch(rect)
    ax.text(8, success_y + 0.4, '🎯 SUCCESS TARGETS', fontsize=14, fontweight='bold', 
            ha='center', color=colors['complete'])
    ax.text(8, success_y, 'Amplitude/Phase Stability: <0.1% / <0.1° • System Uptime: >99.5%', 
            fontsize=11, ha='center', color=colors['text'])
    ax.text(8, success_y - 0.4, '16k-Sample Waveform Capture • First-Fault Detection • 3-min Calibration', 
            fontsize=11, ha='center', color=colors['text'])
    
    # Set axis properties
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off')
    
    plt.tight_layout()
    return fig

def create_professional_flow():
    """Create a professional flow diagram with clean hierarchy"""
    fig, ax = plt.subplots(1, 1, figsize=(20, 14))
    
    # Colors
    colors = {
        'complete': '#27AE60',
        'in_progress': '#F39C12',
        'not_started': '#E74C3C',
        'critical': '#8E44AD',
        'phase': '#3498DB',
        'bg': '#FFFFFF',
        'text': '#2C3E50'
    }
    
    ax.set_facecolor(colors['bg'])
    
    # Title
    ax.text(10, 13, 'SPEAR3 LLRF Upgrade - Implementation Flow', 
            fontsize=20, fontweight='bold', ha='center', color=colors['text'])
    
    # Phase 1 Subsystems (Left column)
    phase1_x = 3
    ax.text(phase1_x, 12, 'PHASE 1: STANDALONE DEVELOPMENT', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase'])
    
    # Hardware subsystems in clean vertical layout
    subsystems = [
        ('HVPS PLC', colors['complete']),
        ('HVPS SCR', colors['not_started']),
        ('Heater SCR', colors['not_started']),
        ('Kly MPS PLC', colors['complete']),
        ('Waveform Buffer', colors['in_progress']),
        ('Interface Chassis', colors['critical']),
        ('Python/EPICS SW', colors['critical'])
    ]
    
    y_start = 11
    for i, (name, color) in enumerate(subsystems):
        y_pos = y_start - i * 0.8
        width = 3 if color == colors['critical'] else 2.5
        
        rect = FancyBboxPatch((phase1_x - width/2, y_pos - 0.25), width, 0.5, 
                             boxstyle="round,pad=0.05", 
                             facecolor=color, alpha=0.3, 
                             edgecolor=color, linewidth=2 if color == colors['critical'] else 1)
        ax.add_patch(rect)
        
        prefix = '⚠️ ' if color == colors['critical'] else ('✓ ' if color == colors['complete'] else '○ ')
        ax.text(phase1_x, y_pos, f'{prefix}{name}', 
                fontsize=10, ha='center', va='center', color=color, 
                fontweight='bold' if color == colors['critical'] else 'normal')
    
    # Cavity-dependent systems (Middle column)
    cavity_x = 8
    ax.text(cavity_x, 12, 'CAVITY-DEPENDENT SYSTEMS', 
            fontsize=14, fontweight='bold', ha='center', color=colors['phase'])
    
    cavity_systems = [
        ('LLRF9 Controllers', colors['complete']),
        ('Arc Detection', colors['not_started']),
        ('Galil Motion', colors['complete']),
        ('PPS Interface', colors['not_started'])
    ]
    
    for i, (name, color) in enumerate(cavity_systems):
        y_pos = 11 - i * 0.8
        
        rect = FancyBboxPatch((cavity_x - 1.25, y_pos - 0.25), 2.5, 0.5, 
                             boxstyle="round,pad=0.05", 
                             facecolor=color, alpha=0.3, 
                             edgecolor=color, linewidth=1)
        ax.add_patch(rect)
        
        prefix = '✓ ' if color == colors['complete'] else '○ '
        ax.text(cavity_x, y_pos, f'{prefix}{name}', 
                fontsize=10, ha='center', va='center', color=color)
    
    # Integration phases (Right column)
    integration_x = 15
    
    # Phase 2A
    rect = FancyBboxPatch((integration_x - 2, 10.5), 4, 1.5, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['phase'], alpha=0.2, 
                         edgecolor=colors['phase'], linewidth=2)
    ax.add_patch(rect)
    ax.text(integration_x, 11.5, 'PHASE 2A', fontsize=12, fontweight='bold', 
            ha='center', color=colors['phase'])
    ax.text(integration_x, 11.1, 'TS18 Integration', fontsize=11, 
            ha='center', color=colors['text'])
    ax.text(integration_x, 10.8, 'Klystron + Dummy Load', fontsize=9, 
            ha='center', color=colors['text'])
    
    # Phase 2B
    rect = FancyBboxPatch((integration_x - 2, 8.5), 4, 1.5, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['phase'], alpha=0.2, 
                         edgecolor=colors['phase'], linewidth=2)
    ax.add_patch(rect)
    ax.text(integration_x, 9.5, 'PHASE 2B', fontsize=12, fontweight='bold', 
            ha='center', color=colors['phase'])
    ax.text(integration_x, 9.1, 'SPEAR3 Integration', fontsize=11, 
            ha='center', color=colors['text'])
    ax.text(integration_x, 8.8, 'Live RF Cavities', fontsize=9, 
            ha='center', color=colors['text'])
    
    # Phase 3
    rect = FancyBboxPatch((integration_x - 2, 6.5), 4, 1.5, 
                         boxstyle="round,pad=0.1", 
                         facecolor=colors['complete'], alpha=0.2, 
                         edgecolor=colors['complete'], linewidth=2)
    ax.add_patch(rect)
    ax.text(integration_x, 7.5, 'PHASE 3', fontsize=12, fontweight='bold', 
            ha='center', color=colors['complete'])
    ax.text(integration_x, 7.1, 'Commissioning', fontsize=11, 
            ha='center', color=colors['text'])
    ax.text(integration_x, 6.8, 'Dimtel Support + Validation', fontsize=9, 
            ha='center', color=colors['text'])
    
    # Clean flow arrows
    # Phase 1 to Phase 2A
    ax.annotate('', xy=(13, 11.2), xytext=(5, 8.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['phase']))
    
    # Cavity systems to Phase 2B
    ax.annotate('', xy=(13, 9.2), xytext=(9.5, 9.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['phase']))
    
    # Phase 2A to Phase 2B
    ax.annotate('', xy=(integration_x, 8.5), xytext=(integration_x, 10.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['phase']))
    
    # Phase 2B to Phase 3
    ax.annotate('', xy=(integration_x, 6.5), xytext=(integration_x, 8.5),
                arrowprops=dict(arrowstyle='->', lw=2, color=colors['phase']))
    
    # Timeline at bottom
    timeline_y = 4
    ax.text(10, timeline_y + 0.5, 'PROJECT TIMELINE', 
            fontsize=14, fontweight='bold', ha='center', color=colors['text'])
    
    timeline_items = [
        ('Months 1-3\nStandalone Dev', 3),
        ('Months 4-6\nTS18 Integration', 8),
        ('Months 7-8\nSPEAR3 Integration', 13),
        ('Month 9\nCommissioning', 17)
    ]
    
    for label, x in timeline_items:
        rect = FancyBboxPatch((x - 1.5, timeline_y - 0.5), 3, 1, 
                             boxstyle="round,pad=0.1", 
                             facecolor=colors['phase'], alpha=0.1, 
                             edgecolor=colors['phase'], linewidth=1)
        ax.add_patch(rect)
        ax.text(x, timeline_y, label, fontsize=10, ha='center', va='center', 
                color=colors['text'])
    
    # Legend
    legend_y = 2
    ax.text(2, legend_y, 'STATUS:', fontsize=12, fontweight='bold', color=colors['text'])
    
    legend_items = [
        ('✓ Complete', colors['complete'], 4),
        ('○ Not Started', colors['not_started'], 7),
        ('⚠️ Critical Path', colors['critical'], 11)
    ]
    
    for label, color, x in legend_items:
        rect = FancyBboxPatch((x - 0.8, legend_y - 0.2), 1.6, 0.4, 
                             boxstyle="round,pad=0.05", 
                             facecolor=color, alpha=0.3, edgecolor=color)
        ax.add_patch(rect)
        ax.text(x, legend_y, label, fontsize=10, ha='center', va='center', 
                color=color, fontweight='bold')
    
    # Set axis properties
    ax.set_xlim(0, 20)
    ax.set_ylim(1, 14)
    ax.axis('off')
    
    plt.tight_layout()
    return fig

def main():
    """Generate professional, clean diagrams"""
    
    print("Creating professional overview diagram...")
    fig1 = create_professional_overview()
    fig1.savefig('SPEAR3_LLRF_Professional_Overview.png', dpi=300, bbox_inches='tight', 
                facecolor='white', edgecolor='none', pad_inches=0.3)
    print("✅ Saved: SPEAR3_LLRF_Professional_Overview.png")
    
    print("Creating professional flow diagram...")
    fig2 = create_professional_flow()
    fig2.savefig('SPEAR3_LLRF_Professional_Flow.png', dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none', pad_inches=0.3)
    print("✅ Saved: SPEAR3_LLRF_Professional_Flow.png")
    
    plt.close('all')
    print("\n🎯 Professional diagrams created successfully!")
    print("📊 Clean layout with no overlapping text")
    print("🔄 Publication-quality formatting")

if __name__ == "__main__":
    main()

