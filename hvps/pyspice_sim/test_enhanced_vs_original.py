#!/usr/bin/env python3
"""
Test Enhanced PySpice vs Original Simulation
============================================

Compare the enhanced PySpice system simulator with the original hvps_sim
to validate behavior and identify areas for improvement.
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# Import both simulators
from hvps.hvps_sim import HVPSSimulator
from hvps.pyspice_sim.spear3_hvps_system_simulator import SPEAR3SystemSimulator
from hvps.pyspice_sim.plotting_enhanced import plot_system_overview


def run_comparison_test():
    """Run both simulators and compare results."""
    
    print("="*80)
    print("SPEAR3 HVPS Simulation Comparison Test")
    print("="*80)
    
    # Test parameters
    target_kv = 77.0
    duration = 10.0
    
    print(f"\n🔧 Running Original hvps_sim...")
    original_sim = HVPSSimulator()
    original_result = original_sim.run_startup(target_kv=target_kv, duration=duration)
    
    print(f"\n🔧 Running Enhanced PySpice System Simulator...")
    enhanced_sim = SPEAR3SystemSimulator()
    enhanced_result = enhanced_sim.run_startup(target_kv=target_kv, duration=duration)
    
    # Compare results
    print(f"\n" + "="*80)
    print("COMPARISON RESULTS")
    print("="*80)
    
    print(f"{'Metric':<25} {'Original':<15} {'Enhanced':<15} {'Difference':<15}")
    print("-" * 70)
    
    orig_final_v = original_result.voltage_kv[-1]
    enh_final_v = enhanced_result.voltage_kv[-1]
    v_diff = abs(orig_final_v - enh_final_v)
    print(f"{'Final Voltage (kV)':<25} {orig_final_v:<15.2f} {enh_final_v:<15.2f} {v_diff:<15.2f}")
    
    orig_final_i = original_result.current_a[-1]
    enh_final_i = enhanced_result.current_a[-1]
    i_diff = abs(orig_final_i - enh_final_i)
    print(f"{'Final Current (A)':<25} {orig_final_i:<15.2f} {enh_final_i:<15.2f} {i_diff:<15.2f}")
    
    orig_final_p = original_result.power_mw[-1]
    enh_final_p = enhanced_result.power_mw[-1]
    p_diff = abs(orig_final_p - enh_final_p)
    print(f"{'Final Power (MW)':<25} {orig_final_p:<15.3f} {enh_final_p:<15.3f} {p_diff:<15.3f}")
    
    # Startup behavior comparison
    print(f"\n{'Startup Behavior':<25}")
    print("-" * 25)
    
    # Find when voltage reaches 50% of final value
    orig_50pct = abs(orig_final_v) * 0.5
    enh_50pct = abs(enh_final_v) * 0.5
    
    orig_50pct_time = None
    enh_50pct_time = None
    
    for i, v in enumerate(original_result.voltage_kv):
        if abs(v) >= orig_50pct:
            orig_50pct_time = original_result.time[i]
            break
    
    for i, v in enumerate(enhanced_result.voltage_kv):
        if abs(v) >= enh_50pct:
            enh_50pct_time = enhanced_result.time[i]
            break
    
    if orig_50pct_time and enh_50pct_time:
        time_diff = abs(orig_50pct_time - enh_50pct_time)
        print(f"{'Time to 50% (s)':<25} {orig_50pct_time:<15.3f} {enh_50pct_time:<15.3f} {time_diff:<15.3f}")
    
    # Ripple comparison (steady-state)
    print(f"\n{'Ripple Performance':<25}")
    print("-" * 25)
    
    # Calculate ripple for original (last 20% of simulation)
    orig_steady_start = int(0.8 * len(original_result.voltage_kv))
    orig_steady_v = original_result.voltage_kv[orig_steady_start:]
    if len(orig_steady_v) > 0:
        orig_v_mean = np.mean(orig_steady_v)
        orig_v_pp = np.max(orig_steady_v) - np.min(orig_steady_v)
        orig_ripple_pp_pct = abs(orig_v_pp / orig_v_mean) * 100.0
    else:
        orig_ripple_pp_pct = 0
    
    # Enhanced ripple (from simulation)
    enh_steady_start = int(0.8 * len(enhanced_result.ripple_pp_pct))
    enh_ripple_pp_pct = np.mean(enhanced_result.ripple_pp_pct[enh_steady_start:])
    
    ripple_diff = abs(orig_ripple_pp_pct - enh_ripple_pp_pct)
    print(f"{'Ripple P-P (%)':<25} {orig_ripple_pp_pct:<15.3f} {enh_ripple_pp_pct:<15.3f} {ripple_diff:<15.3f}")
    
    # Target achievement
    print(f"\n{'Target Achievement':<25}")
    print("-" * 25)
    orig_target = "✅ PASS" if abs(orig_final_v) > 75.0 else "❌ FAIL"
    enh_target = "✅ PASS" if abs(enh_final_v) > 75.0 else "❌ FAIL"
    print(f"{'Voltage Target':<25} {orig_target:<15} {enh_target:<15}")
    
    orig_ripple_target = "✅ PASS" if orig_ripple_pp_pct < 1.0 else "❌ FAIL"
    enh_ripple_target = "✅ PASS" if enh_ripple_pp_pct < 1.0 else "❌ FAIL"
    print(f"{'Ripple Target':<25} {orig_ripple_target:<15} {enh_ripple_target:<15}")
    
    return original_result, enhanced_result


def plot_comparison(original_result, enhanced_result, save_dir=None):
    """Create comparison plots."""
    
    if save_dir:
        save_dir = Path(save_dir)
        save_dir.mkdir(parents=True, exist_ok=True)
    
    # 1. Voltage comparison
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    fig.suptitle('SPEAR3 HVPS Simulation Comparison', fontsize=14, fontweight='bold')
    
    # Voltage comparison
    axes[0,0].plot(original_result.time, original_result.voltage_kv, 'b-', 
                  linewidth=1.5, label='Original hvps_sim')
    axes[0,0].plot(enhanced_result.time, enhanced_result.voltage_kv, 'r--', 
                  linewidth=1.5, label='Enhanced PySpice')
    axes[0,0].set_ylabel('Voltage (kV)')
    axes[0,0].set_title('Output Voltage Comparison')
    axes[0,0].legend()
    axes[0,0].grid(True, alpha=0.3)
    
    # Current comparison
    axes[0,1].plot(original_result.time, original_result.current_a, 'b-', 
                  linewidth=1.5, label='Original hvps_sim')
    axes[0,1].plot(enhanced_result.time, enhanced_result.current_a, 'r--', 
                  linewidth=1.5, label='Enhanced PySpice')
    axes[0,1].set_ylabel('Current (A)')
    axes[0,1].set_title('Output Current Comparison')
    axes[0,1].legend()
    axes[0,1].grid(True, alpha=0.3)
    
    # Power comparison
    axes[1,0].plot(original_result.time, original_result.power_mw, 'b-', 
                  linewidth=1.5, label='Original hvps_sim')
    axes[1,0].plot(enhanced_result.time, enhanced_result.power_mw, 'r--', 
                  linewidth=1.5, label='Enhanced PySpice')
    axes[1,0].set_ylabel('Power (MW)')
    axes[1,0].set_xlabel('Time (s)')
    axes[1,0].set_title('Output Power Comparison')
    axes[1,0].legend()
    axes[1,0].grid(True, alpha=0.3)
    
    # Firing angle comparison
    axes[1,1].plot(original_result.time, original_result.firing_angle_deg, 'b-', 
                  linewidth=1.5, label='Original hvps_sim')
    axes[1,1].plot(enhanced_result.time, enhanced_result.firing_angle_deg, 'r--', 
                  linewidth=1.5, label='Enhanced PySpice')
    axes[1,1].set_ylabel('Firing Angle (°)')
    axes[1,1].set_xlabel('Time (s)')
    axes[1,1].set_title('Firing Angle Comparison')
    axes[1,1].legend()
    axes[1,1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    if save_dir:
        comparison_path = save_dir / "simulation_comparison.png"
        plt.savefig(comparison_path, dpi=300, bbox_inches='tight')
        print(f"📊 Comparison plot saved to: {comparison_path}")
    
    return fig


def main():
    """Run the comparison test."""
    
    # Run comparison
    original_result, enhanced_result = run_comparison_test()
    
    # Create plots
    output_dir = Path("hvps/pyspice_sim/simulation_results")
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"\n📊 Generating comparison plots...")
    
    # Comparison plot
    comparison_fig = plot_comparison(original_result, enhanced_result, save_dir=output_dir)
    
    # Enhanced system overview
    enhanced_overview_path = output_dir / "enhanced_system_overview.png"
    plot_system_overview(enhanced_result, save_path=enhanced_overview_path)
    
    print(f"\n✅ Comparison test completed!")
    print(f"📁 Results saved to: {output_dir}")
    
    return original_result, enhanced_result


if __name__ == "__main__":
    original_result, enhanced_result = main()
