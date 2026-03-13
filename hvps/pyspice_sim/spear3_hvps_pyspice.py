#!/usr/bin/env python3
"""
SPEAR3 HVPS PySpice Simulation
==============================

Accurate PySpice model of the SPEAR3 High Voltage Power Supply system
based on the real system architecture from technical documentation.

Real System Architecture:
- 12-Pulse Thyristor Rectifier (Two 6-pulse bridges with ±15° phase shift)
- Primary Filter Inductors: L1, L2 = 0.3H each (series = 0.6H total)
- Secondary Rectifiers: 4 diode bridges in series (D1-D24)
- Filter Bank: 8µF capacitor + 500Ω isolation resistors
- Cable Termination: L3, L4 = 200µH each
- Target Performance: <1% peak-to-peak ripple

Reference: hvps/architecture/technical-notes/00-spear3-hvps-legacy-system-design.md
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import sys
import os

# Add PySpice to path
try:
    import PySpice.Logging.Logging as Logging
    logger = Logging.setup_logging()
except ImportError:
    print("PySpice not found. Please install with: pip install PySpice")
    sys.exit(1)

from PySpice.Spice.Netlist import Circuit
from PySpice.Unit import *
from PySpice.Spice.NgSpice.Shared import NgSpiceShared


class SPEAR3_HVPS_PySpice:
    """
    SPEAR3 HVPS PySpice simulation model with exact real system parameters.
    """
    
    def __init__(self):
        """Initialize SPEAR3 HVPS simulation with real system parameters."""
        
        # Real System Parameters (from technical documentation)
        self.params = {
            # AC Input
            'v_ac_rms': 12.47e3,        # 12.47 kV RMS 3-phase
            'f_line': 60.0,             # 60 Hz line frequency
            
            # Phase-Shift Transformer (T0)
            'transformer_ratio': 12.47e3 / 12.5e3,  # 12.47kV to 12.5kV
            'phase_shift_deg': 15.0,    # ±15° phase shift for 12-pulse
            
            # Rectifier Transformers (T1, T2)
            't1_ratio': 12.5e3 / 30e3,  # 12.5kV to 30kV (variable)
            't2_ratio': 12.5e3 / 30e3,  # 12.5kV to 30kV (variable)
            
            # Thyristor Parameters (Powerex T8K7)
            'scr_vt': 1.2,              # Forward voltage drop (V)
            'scr_rt': 0.01,             # On-resistance (Ω)
            'scr_vbo': 8000.0,          # Breakover voltage (V)
            
            # Primary Filter Inductors (Real System Values)
            'L1': 0.3,                  # 0.3H, 85A rated, 1,084 J stored
            'L2': 0.3,                  # 0.3H, 85A rated, 1,084 J stored
            'L_series_resistance': 0.1, # Series resistance of inductors
            
            # Secondary Rectifiers (4 diode bridges in series)
            'diode_vf': 1.0,            # Forward voltage drop (V)
            'diode_rs': 0.001,          # Series resistance (Ω)
            
            # Filter Bank (Real System Values)
            'C_filter': 8e-6,           # 8 µF total capacitance
            'R_isolation': 500.0,       # 500Ω isolation resistors (PEP-II)
            
            # Cable Termination Inductors (Layer 4 Protection)
            'L3': 200e-6,               # 200µH cable termination
            'L4': 200e-6,               # 200µH cable termination
            
            # Load (Klystron)
            'R_load': 3500.0,           # 77kV / 22A = 3500Ω nominal
            
            # Control Parameters
            'firing_angle_deg': 50.0,   # Typical firing angle
            'regulation_target_v': -77e3, # -77 kV target
        }
        
        # Calculate derived parameters
        self.params['omega'] = 2 * np.pi * self.params['f_line']
        self.params['L_total'] = self.params['L1'] + self.params['L2']  # Series connection
        
        # Calculate theoretical filter performance
        self._calculate_filter_performance()
        
        print("SPEAR3 HVPS PySpice Model Initialized")
        print(f"Filter Parameters: L={self.params['L_total']:.1f}H, C={self.params['C_filter']*1e6:.1f}µF, R={self.params['R_isolation']:.0f}Ω")
        print(f"Theoretical fc={self.filter_fc:.1f}Hz, Q={self.filter_Q:.2f}")
        print(f"Expected 720Hz attenuation: {self.attenuation_720hz:.1f}dB ({self.reduction_factor_720hz:.1f}x)")
    
    def _calculate_filter_performance(self):
        """Calculate theoretical filter performance."""
        L = self.params['L_total']
        C = self.params['C_filter']
        R = self.params['R_isolation']
        
        # LC filter cutoff frequency
        self.filter_fc = 1.0 / (2.0 * np.pi * np.sqrt(L * C))
        
        # Quality factor
        self.filter_Q = np.sqrt(L / C) / R
        
        # Attenuation at 720 Hz (12-pulse fundamental)
        f_ripple = 720.0
        ratio = f_ripple / self.filter_fc
        self.attenuation_720hz = 20.0 * np.log10(ratio)
        self.reduction_factor_720hz = 10.0 ** (self.attenuation_720hz / 20.0)
    
    def create_circuit(self):
        """Create the complete SPEAR3 HVPS circuit in PySpice."""
        
        circuit = Circuit('SPEAR3_HVPS')
        
        # Ground reference
        circuit.R('gnd_ref', 'gnd', 'gnd', 1e12@u_Ohm)
        
        # 3-Phase AC Source (12.47 kV RMS)
        v_peak = self.params['v_ac_rms'] * np.sqrt(2)
        omega = self.params['omega']
        
        # Phase A, B, C with 120° separation
        circuit.VCVS('va', 'n_ac_a', 'gnd', 'gnd', 'gnd', 0)  # Will be set by voltage source
        circuit.VCVS('vb', 'n_ac_b', 'gnd', 'gnd', 'gnd', 0)  # Will be set by voltage source  
        circuit.VCVS('vc', 'n_ac_c', 'gnd', 'gnd', 'gnd', 0)  # Will be set by voltage source
        
        # AC voltage sources
        circuit.V('ac_a', 'n_ac_a', 'gnd', f'SIN(0 {v_peak} {self.params["f_line"]} 0 0 0)')
        circuit.V('ac_b', 'n_ac_b', 'gnd', f'SIN(0 {v_peak} {self.params["f_line"]} 0 0 -120)')
        circuit.V('ac_c', 'n_ac_c', 'gnd', f'SIN(0 {v_peak} {self.params["f_line"]} 0 0 -240)')
        
        # Phase-Shift Transformer (T0) - Creates ±15° phase shift for 12-pulse
        # T1 secondary: +15° phase shift
        circuit.VCVS('t1_a', 'n_t1_a', 'gnd', 'n_ac_a', 'n_ac_b', self.params['t1_ratio'])
        circuit.VCVS('t1_b', 'n_t1_b', 'gnd', 'n_ac_b', 'n_ac_c', self.params['t1_ratio'])
        circuit.VCVS('t1_c', 'n_t1_c', 'gnd', 'n_ac_c', 'n_ac_a', self.params['t1_ratio'])
        
        # T2 secondary: -15° phase shift
        circuit.VCVS('t2_a', 'n_t2_a', 'gnd', 'n_ac_c', 'n_ac_b', self.params['t2_ratio'])
        circuit.VCVS('t2_b', 'n_t2_b', 'gnd', 'n_ac_a', 'n_ac_c', self.params['t2_ratio'])
        circuit.VCVS('t2_c', 'n_t2_c', 'gnd', 'n_ac_b', 'n_ac_a', self.params['t2_ratio'])
        
        # 12-Pulse Thyristor Rectifier
        # Bridge 1: 6-Pulse from T1 (SCR1-6)
        self._add_6pulse_thyristor_bridge(circuit, 'br1', 
                                        ['n_t1_a', 'n_t1_b', 'n_t1_c'], 
                                        'n_bridge1_pos', 'n_bridge1_neg')
        
        # Bridge 2: 6-Pulse from T2 (SCR7-12)  
        self._add_6pulse_thyristor_bridge(circuit, 'br2',
                                        ['n_t2_a', 'n_t2_b', 'n_t2_c'],
                                        'n_bridge2_pos', 'n_bridge2_neg')
        
        # Combine bridges for 12-pulse output
        circuit.V('bridge_combine', 'n_12pulse_pos', 'n_bridge1_pos', 0@u_V)
        circuit.V('bridge_neg_ref', 'n_bridge1_neg', 'n_bridge2_neg', 0@u_V)
        circuit.V('bridge2_ref', 'n_bridge2_pos', 'n_12pulse_neg', 0@u_V)
        
        # Primary Filter Inductors (L1, L2 in series)
        circuit.L('L1', 'n_12pulse_pos', 'n_filter_mid', self.params['L1']@u_H)
        circuit.R('L1_r', 'n_filter_mid', 'n_filter_mid_r', self.params['L_series_resistance']@u_Ohm)
        
        circuit.L('L2', 'n_filter_mid_r', 'n_primary_filter_out', self.params['L2']@u_H)
        circuit.R('L2_r', 'n_primary_filter_out', 'n_primary_filter_out_r', self.params['L_series_resistance']@u_Ohm)
        
        # Secondary Rectifiers (4 diode bridges in series for voltage multiplication)
        self._add_secondary_rectifiers(circuit, 'n_primary_filter_out_r', 'n_12pulse_neg', 
                                     'n_secondary_pos', 'n_secondary_neg')
        
        # Filter Bank (8µF capacitor + 500Ω isolation resistors)
        circuit.C('filter_cap', 'n_secondary_pos', 'n_filter_cap_neg', self.params['C_filter']@u_F)
        circuit.V('cap_neg_ref', 'n_filter_cap_neg', 'n_secondary_neg', 0@u_V)
        
        # Isolation resistors (PEP-II innovation for arc protection)
        circuit.R('isolation', 'n_secondary_pos', 'n_isolated_pos', self.params['R_isolation']@u_Ohm)
        
        # Cable Termination Inductors (L3, L4 - Layer 4 protection)
        circuit.L('L3', 'n_isolated_pos', 'n_cable_term', self.params['L3']@u_H)
        circuit.L('L4', 'n_cable_term', 'n_hvps_output_pos', self.params['L4']@u_H)
        
        # Output reference
        circuit.V('output_neg_ref', 'n_hvps_output_neg', 'n_secondary_neg', 0@u_V)
        
        # Load (Klystron)
        circuit.R('load', 'n_hvps_output_pos', 'n_hvps_output_neg', self.params['R_load']@u_Ohm)
        
        # Measurement points
        circuit.V('v_measure', 'n_hvps_output_pos', 'n_measure_pos', 0@u_V)
        circuit.V('v_measure_neg', 'n_measure_neg', 'n_hvps_output_neg', 0@u_V)
        
        return circuit
    
    def _add_6pulse_thyristor_bridge(self, circuit, prefix, ac_nodes, pos_out, neg_out):
        """Add a 6-pulse thyristor bridge to the circuit."""
        
        # Thyristor model parameters
        vt = self.params['scr_vt']
        rt = self.params['scr_rt']
        
        # Upper thyristors (positive half-cycles)
        for i, node in enumerate(ac_nodes):
            scr_name = f'{prefix}_scr_u{i+1}'
            # Simplified thyristor model using diode + switch
            # In real implementation, would use proper thyristor model with gate control
            circuit.D(scr_name, node, pos_out, model='thyristor_model')
        
        # Lower thyristors (negative half-cycles)  
        for i, node in enumerate(ac_nodes):
            scr_name = f'{prefix}_scr_l{i+1}'
            circuit.D(scr_name, neg_out, node, model='thyristor_model')
        
        # Define thyristor diode model (simplified)
        if not hasattr(circuit, '_thyristor_model_added'):
            circuit.model('thyristor_model', 'D', IS=1e-14, RS=rt, N=1.0, VJ=vt)
            circuit._thyristor_model_added = True
    
    def _add_secondary_rectifiers(self, circuit, pos_in, neg_in, pos_out, neg_out):
        """Add secondary rectifier stage (4 diode bridges in series)."""
        
        # Simplified model: Single rectifier stage with voltage multiplication effect
        # In full model, would implement 4 separate diode bridges
        
        # Main rectifier bridge
        circuit.D('sec_d1', pos_in, 'n_sec_mid1', model='secondary_diode')
        circuit.D('sec_d2', 'n_sec_mid1', pos_out, model='secondary_diode')
        circuit.D('sec_d3', neg_out, 'n_sec_mid2', model='secondary_diode')
        circuit.D('sec_d4', 'n_sec_mid2', neg_in, model='secondary_diode')
        
        # Additional filtering effect from secondary bridges
        circuit.L('sec_filter_l', 'n_sec_mid1', 'n_sec_mid2', 10e-3@u_H)  # Small filtering inductance
        
        # Define secondary diode model
        if not hasattr(circuit, '_secondary_diode_model_added'):
            circuit.model('secondary_diode', 'D', IS=1e-12, RS=self.params['diode_rs'], N=1.0, VF=self.params['diode_vf'])
            circuit._secondary_diode_model_added = True
    
    def run_simulation(self, sim_time=0.1, time_step=1e-5):
        """Run the SPEAR3 HVPS simulation."""
        
        print(f"\nRunning SPEAR3 HVPS PySpice Simulation...")
        print(f"Simulation time: {sim_time:.3f}s, Time step: {time_step*1e6:.1f}µs")
        
        # Create circuit
        circuit = self.create_circuit()
        
        # Create simulator
        simulator = circuit.simulator(temperature=25, nominal_temperature=25)
        
        # Run transient analysis
        try:
            analysis = simulator.transient(step_time=time_step@u_s, end_time=sim_time@u_s)
            
            # Extract results
            time = np.array(analysis.time)
            v_output = np.array(analysis['n_measure_pos']) - np.array(analysis['n_measure_neg'])
            
            # Calculate performance metrics
            results = self._analyze_results(time, v_output)
            
            return time, v_output, results
            
        except Exception as e:
            print(f"Simulation failed: {e}")
            return None, None, None
    
    def _analyze_results(self, time, v_output):
        """Analyze simulation results and calculate performance metrics."""
        
        # Skip initial transient (first 20% of simulation)
        skip_samples = int(0.2 * len(time))
        time_steady = time[skip_samples:]
        v_steady = v_output[skip_samples:]
        
        # Calculate metrics
        v_mean = np.mean(v_steady)
        v_min = np.min(v_steady)
        v_max = np.max(v_steady)
        v_pp = v_max - v_min
        v_rms_ripple = np.sqrt(np.mean((v_steady - v_mean)**2))
        
        # Ripple percentages
        ripple_pp_pct = (v_pp / abs(v_mean)) * 100.0
        ripple_rms_pct = (v_rms_ripple / abs(v_mean)) * 100.0
        
        # Current (assuming resistive load)
        i_mean = abs(v_mean) / self.params['R_load']
        power_mean = abs(v_mean) * i_mean / 1e6  # MW
        
        results = {
            'v_mean_kv': v_mean / 1e3,
            'v_min_kv': v_min / 1e3,
            'v_max_kv': v_max / 1e3,
            'v_pp_kv': v_pp / 1e3,
            'ripple_pp_pct': ripple_pp_pct,
            'ripple_rms_pct': ripple_rms_pct,
            'i_mean_a': i_mean,
            'power_mean_mw': power_mean,
            'regulation_error_pct': ((abs(v_mean) - abs(self.params['regulation_target_v'])) / abs(self.params['regulation_target_v'])) * 100.0
        }
        
        return results
    
    def plot_results(self, time, v_output, results, save_path=None):
        """Plot simulation results."""
        
        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))
        
        # Convert to convenient units
        time_ms = time * 1000  # ms
        v_output_kv = v_output / 1000  # kV
        
        # Plot 1: Output voltage vs time
        ax1.plot(time_ms, v_output_kv, 'b-', linewidth=1.0, label='HVPS Output Voltage')
        ax1.axhline(y=results['v_mean_kv'], color='r', linestyle='--', alpha=0.7, label=f'Mean: {results["v_mean_kv"]:.1f} kV')
        ax1.set_xlabel('Time (ms)')
        ax1.set_ylabel('Output Voltage (kV)')
        ax1.set_title('SPEAR3 HVPS PySpice Simulation - Output Voltage')
        ax1.grid(True, alpha=0.3)
        ax1.legend()
        
        # Add performance annotations
        textstr = f"""Performance Metrics:
Mean Voltage: {results['v_mean_kv']:.2f} kV
Peak-to-Peak Ripple: {results['ripple_pp_pct']:.3f}%
RMS Ripple: {results['ripple_rms_pct']:.3f}%
Mean Current: {results['i_mean_a']:.1f} A
Mean Power: {results['power_mean_mw']:.2f} MW
Regulation Error: {results['regulation_error_pct']:.2f}%"""
        
        props = dict(boxstyle='round', facecolor='wheat', alpha=0.8)
        ax1.text(0.02, 0.98, textstr, transform=ax1.transAxes, fontsize=9,
                verticalalignment='top', bbox=props)
        
        # Plot 2: Ripple analysis (zoomed view of steady-state)
        if len(time_ms) > 1000:
            # Show last 20ms for ripple detail
            start_idx = -int(0.02 / (time[1] - time[0]))  # Last 20ms
            time_zoom = time_ms[start_idx:]
            v_zoom = v_output_kv[start_idx:]
            
            ax2.plot(time_zoom, v_zoom, 'g-', linewidth=1.5, label='Output Voltage (Steady-State)')
            ax2.axhline(y=results['v_mean_kv'], color='r', linestyle='--', alpha=0.7, label=f'Mean: {results["v_mean_kv"]:.1f} kV')
            ax2.axhline(y=results['v_min_kv'], color='orange', linestyle=':', alpha=0.7, label=f'Min: {results["v_min_kv"]:.1f} kV')
            ax2.axhline(y=results['v_max_kv'], color='orange', linestyle=':', alpha=0.7, label=f'Max: {results["v_max_kv"]:.1f} kV')
            
            ax2.set_xlabel('Time (ms)')
            ax2.set_ylabel('Output Voltage (kV)')
            ax2.set_title(f'Ripple Detail - P-P: {results["ripple_pp_pct"]:.3f}% (Target: <1.0%)')
            ax2.grid(True, alpha=0.3)
            ax2.legend()
            
            # Highlight target achievement
            if results['ripple_pp_pct'] < 1.0:
                ax2.text(0.5, 0.95, '✅ TARGET ACHIEVED: <1% Ripple!', 
                        transform=ax2.transAxes, fontsize=12, fontweight='bold',
                        ha='center', va='top', color='green',
                        bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
            else:
                ax2.text(0.5, 0.95, f'❌ Target missed: {results["ripple_pp_pct"]:.3f}% > 1.0%', 
                        transform=ax2.transAxes, fontsize=12, fontweight='bold',
                        ha='center', va='top', color='red',
                        bbox=dict(boxstyle='round', facecolor='lightcoral', alpha=0.8))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"Plot saved to: {save_path}")
        
        plt.show()
        
        return fig


def main():
    """Main function to run SPEAR3 HVPS PySpice simulation."""
    
    print("="*60)
    print("SPEAR3 HVPS PySpice Simulation")
    print("="*60)
    
    # Create simulation instance
    hvps = SPEAR3_HVPS_PySpice()
    
    # Run simulation
    time, v_output, results = hvps.run_simulation(sim_time=0.05, time_step=1e-5)  # 50ms simulation
    
    if results is not None:
        # Print results
        print("\n" + "="*60)
        print("SIMULATION RESULTS")
        print("="*60)
        print(f"Mean Output Voltage:     {results['v_mean_kv']:8.2f} kV")
        print(f"Peak-to-Peak Ripple:     {results['ripple_pp_pct']:8.3f} %")
        print(f"RMS Ripple:              {results['ripple_rms_pct']:8.3f} %")
        print(f"Mean Current:            {results['i_mean_a']:8.1f} A")
        print(f"Mean Power:              {results['power_mean_mw']:8.2f} MW")
        print(f"Regulation Error:        {results['regulation_error_pct']:8.2f} %")
        print("="*60)
        
        # Check target achievement
        if results['ripple_pp_pct'] < 1.0:
            print("✅ SUCCESS: <1% ripple target ACHIEVED!")
        else:
            print(f"❌ Target missed: {results['ripple_pp_pct']:.3f}% > 1.0%")
        
        # Create output directory
        output_dir = Path("hvps/pyspice_sim/results")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Plot results
        plot_path = output_dir / "spear3_hvps_pyspice_results.png"
        hvps.plot_results(time, v_output, results, save_path=plot_path)
        
    else:
        print("❌ Simulation failed!")


if __name__ == "__main__":
    main()

