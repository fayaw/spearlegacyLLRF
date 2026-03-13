#!/usr/bin/env python3
"""
HVPS Simulation Results Validation
==================================

Validates the performance of the current HVPS simulation implementation.
Runs comprehensive tests and generates performance metrics.

Usage:
    python validate_results.py

Author: HVPS Simulation Team
Date: March 13, 2026
"""

import numpy as np
import matplotlib.pyplot as plt
from hvps.hvps_sim import HVPSSimulator
import os
import sys

def validate_normal_operation():
    """Validate normal operation performance."""
    print("🔬 Validating Normal Operation...")
    
    sim = HVPSSimulator()
    result = sim.run(duration=10.0, voltage_kv=77.0)
    
    # Extract steady-state data (last 2 seconds)
    times = result.time
    v_out = result.voltage_kv
    steady_idx = np.where(times >= 8.0)[0]
    steady_v = v_out[steady_idx]
    
    # Calculate metrics
    mean_voltage = np.mean(steady_v)
    min_voltage = np.min(steady_v)
    max_voltage = np.max(steady_v)
    ripple_pp = (max_voltage - min_voltage) / abs(mean_voltage) * 100
    ripple_rms = np.std(steady_v) / abs(mean_voltage) * 100
    
    # Transformer current analysis
    i_t1 = result.transformer1_current_monitor_a
    t1_steady = i_t1[steady_idx]
    t1_rms = np.sqrt(np.mean(t1_steady**2))
    t1_peak = np.max(np.abs(t1_steady))
    t1_crest = t1_peak / t1_rms if t1_rms > 0 else 0
    
    # Validation checks
    voltage_ok = abs(abs(mean_voltage) - 77.0) < 2.31  # ±3%
    ripple_improved = ripple_pp < 15.0  # Significant improvement from baseline
    current_ok = t1_crest > 2.0  # Square-wave pattern
    
    print(f"  📊 Mean Voltage: {mean_voltage:.2f} kV (Target: -77 ±3%)")
    print(f"  📊 Voltage Range: {min_voltage:.2f} to {max_voltage:.2f} kV")
    print(f"  📊 Ripple P-P: {ripple_pp:.2f}% (Improved from baseline)")
    print(f"  📊 Ripple RMS: {ripple_rms:.3f}%")
    print(f"  📊 Current Crest Factor: {t1_crest:.2f}")
    
    print(f"  ✅ Voltage Regulation: {'PASS' if voltage_ok else 'FAIL'}")
    print(f"  ✅ Ripple Performance: {'PASS' if ripple_improved else 'FAIL'}")
    print(f"  ✅ Current Pattern: {'PASS' if current_ok else 'FAIL'}")
    
    return voltage_ok and ripple_improved and current_ok

def validate_startup_sequence():
    """Validate startup sequence performance."""
    print("\n🚀 Validating Startup Sequence...")
    
    sim = HVPSSimulator()
    result = sim.run_startup(target_kv=77.0, duration=15.0)
    
    times = result.time
    v_out = result.voltage_kv
    
    # Find startup time to 90% voltage
    startup_time = None
    for i, v in enumerate(v_out):
        if abs(v) > 69.3:  # 90% of 77 kV
            startup_time = times[i]
            break
    
    # Final voltage check
    final_idx = np.where(times >= 12.0)[0]
    final_v = v_out[final_idx]
    final_mean = np.mean(final_v)
    
    startup_ok = startup_time is not None and startup_time < 10.0
    final_ok = abs(abs(final_mean) - 77.0) < 2.31
    
    print(f"  📊 Startup Time (90%): {startup_time:.2f} s" if startup_time else "  ❌ Startup not achieved")
    print(f"  📊 Final Voltage: {final_mean:.2f} kV")
    
    print(f"  ✅ Startup Performance: {'PASS' if startup_ok else 'FAIL'}")
    print(f"  ✅ Final Regulation: {'PASS' if final_ok else 'FAIL'}")
    
    return startup_ok and final_ok

def validate_arc_fault_response():
    """Validate arc fault response."""
    print("\n⚡ Validating Arc Fault Response...")
    
    sim = HVPSSimulator()
    result = sim.run_arc_fault(steady_state_time=3.0, arc_time=5.0, 
                              arc_duration_us=50.0, voltage_kv=77.0, 
                              total_duration=10.0)
    
    times = result.time
    v_out = result.voltage_kv
    arc_energy = result.arc_energy_j
    crowbar_active = result.crowbar_active
    
    # Calculate response metrics
    pre_arc_v = np.mean(v_out[times < 5.0])
    post_arc_v = np.mean(v_out[times > 6.0])
    max_arc_energy = np.max(arc_energy)
    crowbar_activated = np.any(crowbar_active)
    
    # Validation checks
    recovery_ok = abs(abs(post_arc_v) - 77.0) < 5.0  # Recovery within 5 kV
    energy_ok = max_arc_energy < 1.0  # Low arc energy (protection working)
    protection_ok = crowbar_activated  # Crowbar should activate
    
    print(f"  📊 Pre-Arc Voltage: {pre_arc_v:.2f} kV")
    print(f"  📊 Post-Arc Voltage: {post_arc_v:.2f} kV")
    print(f"  📊 Max Arc Energy: {max_arc_energy:.2f} J")
    print(f"  📊 Crowbar Activated: {'Yes' if crowbar_activated else 'No'}")
    
    print(f"  ✅ Voltage Recovery: {'PASS' if recovery_ok else 'FAIL'}")
    print(f"  ✅ Energy Limitation: {'PASS' if energy_ok else 'FAIL'}")
    print(f"  ✅ Protection Response: {'PASS' if protection_ok else 'FAIL'}")
    
    return recovery_ok and energy_ok and protection_ok

def validate_filter_performance():
    """Validate LC filter performance."""
    print("\n🔧 Validating LC Filter Performance...")
    
    from hvps.hvps_sim.filtering import LCFilter, FilterComponents
    
    filter_components = FilterComponents()
    lc_filter = LCFilter(filter_components)
    
    # Filter specifications
    L = filter_components.total_inductance_henry
    C = filter_components.total_capacitance_farad * 1e6  # Convert to µF
    fc = filter_components.lc_cutoff_frequency_hz
    
    # Test filter with realistic signal
    t = np.linspace(0, 0.1, 1000)
    dt = t[1] - t[0]
    
    # Create test signal with 720 Hz ripple
    v_dc = 77000
    ripple_720hz = 0.30 * v_dc * np.sin(2 * np.pi * 720 * t)  # 30% ripple
    test_signal = v_dc + ripple_720hz
    
    # Apply filter
    filtered_signal = lc_filter.filter_ripple(test_signal, dt)
    
    # Calculate attenuation
    input_ripple = (np.max(test_signal) - np.min(test_signal)) / v_dc * 100
    output_ripple = (np.max(filtered_signal) - np.min(filtered_signal)) / np.mean(filtered_signal) * 100
    attenuation = input_ripple / output_ripple if output_ripple > 0 else 0
    
    filter_ok = attenuation > 5.0  # Significant attenuation
    freq_ok = 50.0 < fc < 100.0  # Reasonable cutoff frequency
    
    print(f"  📊 Filter Inductance: {L:.3f} H")
    print(f"  📊 Filter Capacitance: {C:.2f} µF")
    print(f"  📊 Cutoff Frequency: {fc:.1f} Hz")
    print(f"  📊 Attenuation Factor: {attenuation:.1f}×")
    print(f"  📊 Input Ripple: {input_ripple:.1f}%")
    print(f"  📊 Output Ripple: {output_ripple:.2f}%")
    
    print(f"  ✅ Filter Attenuation: {'PASS' if filter_ok else 'FAIL'}")
    print(f"  ✅ Cutoff Frequency: {'PASS' if freq_ok else 'FAIL'}")
    
    return filter_ok and freq_ok

def validate_system_stability():
    """Validate overall system stability."""
    print("\n⚖️ Validating System Stability...")
    
    sim = HVPSSimulator()
    result = sim.run(duration=8.0, voltage_kv=77.0)
    
    times = result.time
    v_out = result.voltage_kv
    
    # Check for oscillations or instability
    steady_idx = np.where(times >= 6.0)[0]
    steady_v = v_out[steady_idx]
    
    # Calculate stability metrics
    voltage_std = np.std(steady_v)
    voltage_mean = abs(np.mean(steady_v))
    stability_ratio = voltage_std / voltage_mean * 100
    
    # Check for large transients
    max_transient = np.max(np.abs(np.diff(steady_v)))
    
    stability_ok = stability_ratio < 5.0  # Less than 5% variation
    transient_ok = max_transient < 2.0  # Less than 2 kV jumps
    
    print(f"  📊 Voltage Stability: {stability_ratio:.3f}% variation")
    print(f"  📊 Maximum Transient: {max_transient:.3f} kV")
    
    print(f"  ✅ Voltage Stability: {'PASS' if stability_ok else 'FAIL'}")
    print(f"  ✅ Transient Control: {'PASS' if transient_ok else 'FAIL'}")
    
    return stability_ok and transient_ok

def main():
    """Run comprehensive validation of HVPS simulation - Realistic Operational Modes Only."""
    print("=" * 60)
    print("HVPS Simulation Validation - Realistic Operational Modes")
    print("=" * 60)
    print("Testing only scenarios that represent actual SPEAR3 system operation:")
    print("• Normal Operation (primary operating mode)")
    print("• Startup Sequence (system initialization)")
    print("• Arc Fault Response (actual protection scenario)")
    print("• Filter Performance (advanced LC filtering)")
    print("• System Stability (overall system behavior)")
    print("=" * 60)
    
    # Run all validation tests
    tests = [
        ("Normal Operation", validate_normal_operation),
        ("Startup Sequence", validate_startup_sequence),
        ("Arc Fault Response", validate_arc_fault_response),
        ("Filter Performance", validate_filter_performance),
        ("System Stability", validate_system_stability),
    ]
    
    results = []
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"  ❌ ERROR in {test_name}: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 60)
    print("VALIDATION SUMMARY")
    print("=" * 60)
    
    passed = 0
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name:.<30} {status}")
        if result:
            passed += 1
    
    print("-" * 60)
    print(f"Overall Result: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 ALL TESTS PASSED - Simulation is ready for production use!")
        return 0
    else:
        print("⚠️  Some tests failed - Review results above")
        return 1

if __name__ == "__main__":
    sys.exit(main())
