#!/usr/bin/env python3
"""
Generate HVPS Monitoring Signals Plots
======================================

This script generates the 4-channel Waveform Buffer System monitoring signals
that are actually available in the real SPEAR3 HVPS system for comparison.

The 4 monitoring channels are:
- Channel 1: HVPS DC Voltage Monitor (0 to -90 kV DC)
- Channel 2: HVPS DC Current Monitor (0 to 30 A DC) 
- Channel 3: Inductor 2 (T2) Sawtooth Voltage (firing circuit timing)
- Channel 4: Transformer 1 AC Phase Current (firing circuit health)

These signals can be directly compared with real SPEAR3 system recordings.
"""

import os
import sys
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from hvps.hvps_sim.examples import run_normal_operation, run_startup_sequence, run_arc_fault
from hvps.hvps_sim.plotting import plot_hvps_monitoring_signals


def generate_all_monitoring_signals():
    """Generate monitoring signals plots for all realistic operational scenarios."""
    
    print("=" * 80)
    print("   SPEAR3 HVPS Monitoring Signals Generation")
    print("   4-Channel Waveform Buffer System - Real System Comparison")
    print("=" * 80)
    print()
    
    # Create results directory if it doesn't exist
    results_dir = "hvps/hvps_sim/simulation_results"
    os.makedirs(results_dir, exist_ok=True)
    
    # Generate monitoring signals for each realistic operational scenario
    scenarios = [
        ("Normal Operation", run_normal_operation, "normal_operation"),
        ("Startup Sequence", run_startup_sequence, "startup_sequence"), 
        ("Arc Fault Response", run_arc_fault, "arc_fault")
    ]
    
    for scenario_name, run_func, file_prefix in scenarios:
        print(f"🔍 Generating monitoring signals for: {scenario_name}")
        print("-" * 60)
        
        # Run the simulation
        if scenario_name == "Normal Operation":
            result = run_func(duration=5.0, plot=False)
        elif scenario_name == "Startup Sequence":
            result = run_func(duration=12.0, plot=False)
        elif scenario_name == "Arc Fault Response":
            result = run_func(duration=8.0, plot=False)
        
        # Generate the 4-channel monitoring signals plot
        monitoring_path = f"{results_dir}/{file_prefix}_monitoring_signals.png"
        plot_hvps_monitoring_signals(
            result, 
            save_path=monitoring_path,
            zoom_duration=0.1  # 100ms zoom view
        )
        
        print(f"✅ Generated: {monitoring_path}")
        
        # Also generate zoom view
        zoom_path = f"{results_dir}/{file_prefix}_monitoring_signals_zoom.png"
        if os.path.exists(zoom_path):
            print(f"✅ Generated: {zoom_path}")
        
        print()
    
    # Generate comprehensive monitoring signals plot using normal operation
    print("🔍 Generating comprehensive monitoring signals overview")
    print("-" * 60)
    
    # Use normal operation for the comprehensive view
    result = run_normal_operation(duration=5.0, plot=False)
    
    # Generate comprehensive monitoring signals plot
    comprehensive_path = f"{results_dir}/hvps_monitoring_signals.png"
    plot_hvps_monitoring_signals(
        result,
        save_path=comprehensive_path,
        zoom_duration=0.1
    )
    
    print(f"✅ Generated: {comprehensive_path}")
    
    # Check for zoom file
    zoom_path = f"{results_dir}/hvps_monitoring_signals_zoom.png"
    if os.path.exists(zoom_path):
        print(f"✅ Generated: {zoom_path}")
    
    print()
    print("=" * 80)
    print("   4-Channel Waveform Buffer System Monitoring Signals Complete!")
    print("=" * 80)
    print()
    print("📊 Generated monitoring signals plots:")
    print("• normal_operation_monitoring_signals.png - Normal operation monitoring")
    print("• startup_sequence_monitoring_signals.png - Startup monitoring")  
    print("• arc_fault_monitoring_signals.png - Arc fault monitoring")
    print("• hvps_monitoring_signals.png - Comprehensive monitoring overview")
    print("• *_zoom.png files - 100ms stabilized period views")
    print()
    print("🎯 These signals can be directly compared with real SPEAR3 system recordings!")
    print("📋 Each plot shows statistical data (Mean, Std, Peak-to-Peak) for validation")


if __name__ == "__main__":
    generate_all_monitoring_signals()

