#!/usr/bin/env python3
"""
Test script for enhanced PySpice simulation with 4 monitor channels.
Generates all plots including the new monitor channel visualizations.
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from spear3_hvps_system_simulator import SPEAR3SystemSimulator
import plotting_enhanced

def main():
    """Test enhanced PySpice simulation with monitor channels and generate all plots."""
    
    print("🔧 Testing Enhanced PySpice Simulation with 4 Monitor Channels")
    print("=" * 80)
    
    # Create simulator
    sim = SPEAR3SystemSimulator()
    
    # Run simulation
    print("🚀 Running enhanced simulation...")
    result = sim.run_startup(target_kv=77.0, duration=10.0)
    
    print(f"\n✅ Simulation completed!")
    print(f"   Final voltage: {result.voltage_kv[-1]:.2f} kV")
    print(f"   Final current: {result.current_a[-1]:.2f} A")
    print(f"   Final power: {result.power_mw[-1]:.3f} MW")
    print(f"   Final ripple: {result.ripple_pp_pct[-1]:.3f}%")
    
    # Create results directory
    results_dir = "hvps/pyspice_sim/simulation_results"
    os.makedirs(results_dir, exist_ok=True)
    
    print(f"\n📊 Generating all plots...")
    
    # 1. System overview (updated with correct voltage ranges)
    plotting_enhanced.plot_system_overview(result, f'{results_dir}/enhanced_system_overview_updated.png')
    
    # 2. Startup sequence analysis
    plotting_enhanced.plot_startup_sequence(result, f'{results_dir}/startup_sequence_updated.png')
    
    # 3. Control response dynamics
    plotting_enhanced.plot_control_response(result, f'{results_dir}/control_response_updated.png')
    
    # 4. Ripple analysis
    plotting_enhanced.plot_ripple_analysis(result, f'{results_dir}/ripple_analysis_updated.png')
    
    # 5. NEW: Monitor channels (4-channel waveform buffer)
    plotting_enhanced.plot_monitor_channels(result, f'{results_dir}/monitor_channels.png')
    
    # 6. NEW: Complete system overview with all signals
    plotting_enhanced.plot_all_signals(result, f'{results_dir}/complete_system_overview.png')
    
    print(f"\n🎯 Monitor Channel Summary:")
    print(f"   Channel 1 (HVPS Voltage): {result.hvps_voltage_monitor_kv[-1]:.2f} kV")
    print(f"   Channel 2 (HVPS Current): {result.hvps_current_monitor_a[-1]:.2f} A")
    print(f"   Channel 3 (T2 Sawtooth): {result.inductor2_sawtooth_monitor_kv[-1]:.2f} kV")
    print(f"   Channel 4 (T1 AC Current): {result.transformer1_current_monitor_a[-1]:.2f} A")
    
    print(f"\n✅ All plots generated successfully!")
    print(f"📁 Results saved to: {results_dir}")
    
    # Print detailed summary
    print(f"\n{result.summary()}")
    
    print(f"\n🎉 Enhanced PySpice simulation with 4 monitor channels: COMPLETE!")


if __name__ == "__main__":
    main()
