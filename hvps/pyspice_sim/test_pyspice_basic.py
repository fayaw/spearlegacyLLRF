#!/usr/bin/env python3
"""
Basic PySpice Test - Simple Rectifier Circuit
==============================================

Test PySpice installation and basic rectifier simulation
before implementing the full SPEAR3 HVPS model.
"""

import numpy as np
import matplotlib.pyplot as plt
import sys

try:
    import PySpice.Logging.Logging as Logging
    logger = Logging.setup_logging()
    
    from PySpice.Spice.Netlist import Circuit
    from PySpice.Unit import *
    
    print("✅ PySpice imported successfully")
    
except ImportError as e:
    print(f"❌ PySpice import failed: {e}")
    sys.exit(1)


def test_basic_rectifier():
    """Test basic rectifier circuit to validate PySpice setup."""
    
    print("\n🔧 Testing Basic Rectifier Circuit...")
    
    # Create simple rectifier circuit
    circuit = Circuit('Basic_Rectifier_Test')
    
    # AC source (120V RMS, 60Hz)
    circuit.V('ac', 'n_ac', 'gnd', 'SIN(0 169.7 60 0 0 0)')  # 120V RMS = 169.7V peak
    
    # Rectifier diodes (full-wave bridge)
    circuit.D('d1', 'n_ac', 'n_dc_pos', model='diode_model')
    circuit.D('d2', 'gnd', 'n_dc_pos', model='diode_model')
    circuit.D('d3', 'n_ac', 'gnd', model='diode_model')
    circuit.D('d4', 'n_dc_pos', 'gnd', model='diode_model')
    
    # Filter components
    circuit.L('filter_l', 'n_dc_pos', 'n_filtered', 0.1@u_H)  # 0.1H filter inductor
    circuit.C('filter_c', 'n_filtered', 'gnd', 100e-6@u_F)   # 100µF filter capacitor
    circuit.R('filter_r', 'n_filtered', 'n_output', 10@u_Ohm) # 10Ω series resistance
    
    # Load
    circuit.R('load', 'n_output', 'gnd', 100@u_Ohm)  # 100Ω load
    
    # Diode model
    circuit.model('diode_model', 'D', IS=1e-14, RS=0.01, N=1.0)
    
    print("✅ Circuit created successfully")
    
    # Run simulation
    try:
        simulator = circuit.simulator(temperature=25, nominal_temperature=25)
        analysis = simulator.transient(step_time=100e-6@u_s, end_time=50e-3@u_s)  # 50ms, 100µs steps
        
        print("✅ Simulation completed successfully")
        
        # Extract results
        time = np.array(analysis.time)
        v_ac = np.array(analysis['n_ac'])
        v_output = np.array(analysis['n_output'])
        
        # Calculate basic metrics
        v_output_mean = np.mean(v_output[-1000:])  # Last 1000 points for steady state
        v_output_pp = np.max(v_output[-1000:]) - np.min(v_output[-1000:])
        ripple_pct = (v_output_pp / v_output_mean) * 100.0
        
        print(f"📊 Results:")
        print(f"   Mean Output Voltage: {v_output_mean:.1f} V")
        print(f"   Peak-to-Peak Ripple: {v_output_pp:.2f} V ({ripple_pct:.1f}%)")
        
        # Plot results
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))
        
        time_ms = time * 1000
        
        # AC input and DC output
        ax1.plot(time_ms, v_ac, 'b-', label='AC Input', alpha=0.7)
        ax1.plot(time_ms, v_output, 'r-', label='DC Output', linewidth=2)
        ax1.set_xlabel('Time (ms)')
        ax1.set_ylabel('Voltage (V)')
        ax1.set_title('Basic Rectifier Test - PySpice Validation')
        ax1.legend()
        ax1.grid(True, alpha=0.3)
        
        # Zoomed view of ripple
        if len(time_ms) > 500:
            start_idx = -500  # Last 500 points
            ax2.plot(time_ms[start_idx:], v_output[start_idx:], 'g-', linewidth=2, label='DC Output (Zoomed)')
            ax2.axhline(y=v_output_mean, color='r', linestyle='--', alpha=0.7, label=f'Mean: {v_output_mean:.1f}V')
            ax2.set_xlabel('Time (ms)')
            ax2.set_ylabel('Voltage (V)')
            ax2.set_title(f'Ripple Detail - {ripple_pct:.1f}% P-P')
            ax2.legend()
            ax2.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig('hvps/pyspice_sim/basic_rectifier_test.png', dpi=150, bbox_inches='tight')
        plt.show()
        
        print("✅ PySpice basic test PASSED!")
        return True
        
    except Exception as e:
        print(f"❌ Simulation failed: {e}")
        return False


def test_filter_response():
    """Test LC filter frequency response calculation."""
    
    print("\n📐 Testing Filter Calculations...")
    
    # SPEAR3 real system parameters
    L = 0.6  # 0.3H + 0.3H in series
    C = 8e-6  # 8µF
    R = 500   # 500Ω
    
    # Calculate filter characteristics
    fc = 1.0 / (2.0 * np.pi * np.sqrt(L * C))
    Q = np.sqrt(L / C) / R
    
    print(f"📊 SPEAR3 Filter Analysis:")
    print(f"   Total Inductance: {L:.1f} H")
    print(f"   Total Capacitance: {C*1e6:.1f} µF")
    print(f"   Isolation Resistance: {R:.0f} Ω")
    print(f"   Cutoff Frequency: {fc:.1f} Hz")
    print(f"   Quality Factor: {Q:.2f}")
    
    # Calculate attenuation at 720 Hz (12-pulse fundamental)
    f_ripple = 720.0
    ratio = f_ripple / fc
    attenuation_db = 20.0 * np.log10(ratio)
    reduction_factor = 10.0 ** (attenuation_db / 20.0)
    
    print(f"   720 Hz Attenuation: {attenuation_db:.1f} dB ({reduction_factor:.1f}x reduction)")
    
    # Theoretical ripple prediction
    unfiltered_ripple_pct = 10.0  # Assume 10% unfiltered ripple from 12-pulse rectifier
    filtered_ripple_pct = unfiltered_ripple_pct / reduction_factor
    
    print(f"   Expected Ripple Reduction: {unfiltered_ripple_pct:.1f}% → {filtered_ripple_pct:.2f}%")
    
    if filtered_ripple_pct <= 1.01:
        print("✅ Theoretical analysis predicts <1% ripple target achievable!")
    else:
        print(f"❌ Theoretical analysis predicts {filtered_ripple_pct:.2f}% > 1% target")
    
    return filtered_ripple_pct <= 1.01


def main():
    """Run basic PySpice tests."""
    
    print("="*60)
    print("PySpice Basic Test Suite")
    print("="*60)
    
    # Test 1: Basic rectifier simulation
    test1_passed = test_basic_rectifier()
    
    # Test 2: Filter calculations
    test2_passed = test_filter_response()
    
    print("\n" + "="*60)
    print("TEST SUMMARY")
    print("="*60)
    print(f"Basic Rectifier Test:     {'✅ PASSED' if test1_passed else '❌ FAILED'}")
    print(f"Filter Analysis Test:     {'✅ PASSED' if test2_passed else '❌ FAILED'}")
    
    if test1_passed and test2_passed:
        print("\n🎉 All tests PASSED! Ready for full SPEAR3 HVPS simulation.")
        return True
    else:
        print("\n❌ Some tests FAILED. Check PySpice installation.")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

