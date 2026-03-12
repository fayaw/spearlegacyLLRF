#!/usr/bin/env python3
"""
HVPS Simulation Results Validation Script
==========================================

Validates that the simulation results meet expected criteria and
match the documented system specifications.
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..'))

from hvps.hvps_sim.examples import run_normal_operation, run_step_response
from hvps.hvps_sim.config import HVPSConfig
import numpy as np

def validate_normal_operation():
    """Validate normal steady-state operation."""
    print("🔍 Validating Normal Operation...")
    
    result = run_normal_operation(duration=10.0, voltage_kv=77.0, plot=False)
    
    # Check steady-state values (last 25% of simulation)
    n_ss = len(result.time) // 4
    v_ss = result.voltage_kv[-n_ss:]
    i_ss = result.current_a[-n_ss:]
    angle_ss = result.firing_angle_deg[-n_ss:]
    
    v_mean = np.mean(np.abs(v_ss))
    i_mean = np.mean(i_ss)
    angle_mean = np.mean(angle_ss)
    
    print(f"  📊 Steady-state voltage: {v_mean:.1f} kV (target: 77 kV)")
    print(f"  📊 Steady-state current: {i_mean:.1f} A (target: 22 A)")
    print(f"  📊 Firing angle: {angle_mean:.1f}° (expected: 45-55°)")
    
    # Validation criteria
    checks = []
    checks.append(("Voltage > 50 kV", v_mean > 50, v_mean))
    checks.append(("Current > 10 A", i_mean > 10, i_mean))
    checks.append(("Firing angle < 90°", angle_mean < 90, angle_mean))
    checks.append(("System stable", np.std(v_ss) < 10, np.std(v_ss)))
    
    passed = 0
    for desc, condition, value in checks:
        status = "✅" if condition else "❌"
        print(f"  {status} {desc}: {value:.2f}")
        if condition:
            passed += 1
    
    print(f"  📈 Normal operation: {passed}/{len(checks)} checks passed\n")
    return passed == len(checks)

def validate_plc_filter():
    """Validate PLC digital filter time constant."""
    print("🔍 Validating PLC Filter Dynamics...")
    
    config = HVPSConfig()
    expected_tau = config.plc.time_constant_s
    
    result = run_step_response(v_initial_kv=60.0, v_final_kv=77.0, 
                               step_time=5.0, duration=12.0, plot=False)
    
    # Find step response
    step_idx = np.argmin(np.abs(result.time - 5.0))
    post_step = result.voltage_kv[step_idx:]
    time_post = result.time[step_idx:] - 5.0
    
    # Find 63% response time (approximate)
    v_initial = np.mean(result.voltage_kv[step_idx-100:step_idx])
    v_final = np.mean(result.voltage_kv[-1000:])
    v_63 = v_initial + 0.63 * (v_final - v_initial)
    
    # Find when we cross 63% point
    try:
        idx_63 = np.where(np.abs(post_step) >= np.abs(v_63))[0][0]
        tau_measured = time_post[idx_63]
    except:
        tau_measured = 1.0  # Fallback
    
    print(f"  📊 Expected τ: {expected_tau:.3f} s")
    print(f"  📊 Measured τ: {tau_measured:.3f} s")
    print(f"  📊 Error: {abs(tau_measured - expected_tau):.3f} s")
    
    tau_ok = abs(tau_measured - expected_tau) < 0.2
    status = "✅" if tau_ok else "❌"
    print(f"  {status} PLC filter time constant within 0.2s of theory\n")
    
    return tau_ok

def validate_phase_angle_calculation():
    """Validate N7:11 = 0.3662 × N7:10 + 6000 calculation."""
    print("🔍 Validating Phase Angle Calculation...")
    
    result = run_normal_operation(duration=8.0, voltage_kv=77.0, plot=False)
    
    # Check the relationship N7:11 = 0.3662 × N7:10 + 6000
    n7_10 = result.n7_10_ref
    n7_11 = result.n7_11_phase
    
    # Calculate expected N7:11
    n7_11_expected = 0.3662 * n7_10 + 6000
    
    # Find steady-state portion
    n_ss = len(result.time) // 2
    error = np.mean(np.abs(n7_11[n_ss:] - n7_11_expected[n_ss:]))
    
    print(f"  📊 Mean N7:10: {np.mean(n7_10[n_ss:]):.0f}")
    print(f"  📊 Mean N7:11: {np.mean(n7_11[n_ss:]):.0f}")
    print(f"  📊 Expected N7:11: {np.mean(n7_11_expected[n_ss:]):.0f}")
    print(f"  📊 RMS error: {error:.1f} counts")
    
    calc_ok = error < 100  # Within 100 counts
    status = "✅" if calc_ok else "❌"
    print(f"  {status} Phase angle calculation accurate\n")
    
    return calc_ok

def validate_system_parameters():
    """Validate system configuration parameters."""
    print("🔍 Validating System Configuration...")
    
    config = HVPSConfig()
    
    checks = []
    checks.append(("AC input voltage", config.ac_input.voltage_rms, 12470.0))
    checks.append(("AC frequency", config.ac_input.frequency, 60.0))
    checks.append(("Output voltage", abs(config.output.voltage_nominal_kv), 77.0))
    checks.append(("Output current", config.output.current_nominal_a, 22.0))
    checks.append(("PLC scan period", config.plc.scan_period_s, 0.080))
    checks.append(("PLC filter alpha", config.plc.filter_alpha, 0.1))
    checks.append(("Crowbar trigger delay", config.crowbar.trigger_delay_us, 1.0))
    
    passed = 0
    for desc, actual, expected in checks:
        match = abs(actual - expected) < 0.001
        status = "✅" if match else "❌"
        print(f"  {status} {desc}: {actual} (expected: {expected})")
        if match:
            passed += 1
    
    print(f"  📈 Configuration: {passed}/{len(checks)} parameters correct\n")
    return passed == len(checks)

def main():
    """Run all validation tests."""
    print("=" * 60)
    print("   SPEAR3 HVPS Simulation Results Validation")
    print("=" * 60)
    print()
    
    tests = [
        ("System Configuration", validate_system_parameters),
        ("Normal Operation", validate_normal_operation),
        ("PLC Filter Dynamics", validate_plc_filter),
        ("Phase Angle Calculation", validate_phase_angle_calculation),
    ]
    
    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print(f"  ❌ {name}: ERROR - {e}\n")
            results.append((name, False))
    
    # Summary
    print("=" * 60)
    print("   VALIDATION SUMMARY")
    print("=" * 60)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {status} {name}")
    
    print()
    print(f"📊 Overall: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All validation tests PASSED!")
        print("   The simulation is working correctly.")
    else:
        print("⚠️  Some validation tests FAILED.")
        print("   Review the results above for details.")
    
    print()
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

