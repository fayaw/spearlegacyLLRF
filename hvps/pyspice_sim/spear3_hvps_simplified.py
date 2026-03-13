#!/usr/bin/env python3
"""
SPEAR3 HVPS Simplified PySpice Model
====================================

Simplified but accurate PySpice model of the SPEAR3 HVPS focusing on
the key filtering performance with real system parameters.

This model captures the essential behavior:
- 12-pulse rectifier output (720 Hz fundamental ripple)
- Primary filter inductors L1, L2 = 0.3H each (series)
- Filter capacitor bank: 8µF
- Isolation resistors: 500Ω
- Target: <1% peak-to-peak ripple
"""

import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import sys
import os

# Set library path for ngspice
os.environ['LD_LIBRARY_PATH'] = '/usr/lib/x86_64-linux-gnu:' + os.environ.get('LD_LIBRARY_PATH', '')

try:
    import PySpice.Logging.Logging as Logging
    logger = Logging.setup_logging()
    
    from PySpice.Spice.Netlist import Circuit
    from PySpice.Unit import *
    
    print("✅ PySpice imported successfully")
    
except ImportError as e:
    print(f"❌ PySpice import failed: {e}")
    sys.exit(1)


class SPEAR3_HVPS_Simplified:
    """Simplified SPEAR3 HVPS model focusing on filter performance."""
    
    def __init__(self):
        """Initialize with real SPEAR3 parameters."""
        
        # Real system parameters from technical documentation
        self.params = {
            # 12-pulse rectifier output characteristics
            'v_dc_nominal': 77e3,       # 77 kV nominal output
            'f_line': 60.0,             # 60 Hz line frequency
            'f_ripple': 720.0,          # 12-pulse fundamental: 12 × 60 Hz
            
            # Primary filter inductors (real values)
            'L1': 0.3,                  # 0.3H, 85A rated
            'L2': 0.3,                  # 0.3H, 85A rated  
            'L_esr': 0.1,               # Equivalent series resistance
            
            # Filter capacitor bank (real value)
            'C_filter': 8e-6,           # 8 µF total
            'C_esr': 0.01,              # Equivalent series resistance
            
            # Isolation resistors (PEP-II innovation)
            'R_isolation': 500.0,       # 500Ω for arc protection
            
            # Cable termination (Layer 4 protection)
            'L_cable': 400e-6,          # L3 + L4 = 200µH + 200µH
            
            # Load (klystron)
            'R_load': 3500.0,           # 77kV / 22A = 3500Ω
            
            # 12-pulse ripple characteristics
            'ripple_fundamental_pct': 8.0,    # Fundamental ripple before filtering
            'ripple_harmonics': [2, 3, 4],    # Higher harmonics
            'ripple_harmonic_factors': [0.3, 0.15, 0.08],  # Relative amplitudes
        }
        
        # Calculate derived parameters
        self.params['L_total'] = self.params['L1'] + self.params['L2']  # Series
        self.params['omega_line'] = 2 * np.pi * self.params['f_line']
        self.params['omega_ripple'] = 2 * np.pi * self.params['f_ripple']
        
        # Calculate theoretical filter performance
        self._calculate_filter_theory()
        
        print("SPEAR3 HVPS Simplified Model Initialized")
        print(f"Filter: L={self.params['L_total']:.1f}H, C={self.params['C_filter']*1e6:.1f}µF, R={self.params['R_isolation']:.0f}Ω")
        print(f"Theory: fc={self.fc:.1f}Hz, Q={self.Q:.2f}, 720Hz attenuation={self.attenuation_720hz:.1f}dB")
    
    def _calculate_filter_theory(self):
        """Calculate theoretical LC filter performance."""
        L = self.params['L_total']
        C = self.params['C_filter']
        R = self.params['R_isolation']
        
        # LC filter cutoff frequency
        self.fc = 1.0 / (2.0 * np.pi * np.sqrt(L * C))
        
        # Quality factor
        self.Q = np.sqrt(L / C) / R
        
        # Attenuation at 720 Hz
        f_ripple = self.params['f_ripple']
        ratio = f_ripple / self.fc
        self.attenuation_720hz = 20.0 * np.log10(ratio)
        self.reduction_factor = 10.0 ** (self.attenuation_720hz / 20.0)
        
        # Predicted ripple
        unfiltered_ripple = self.params['ripple_fundamental_pct']
        self.predicted_ripple_pct = unfiltered_ripple / self.reduction_factor
    
    def create_circuit(self):
        """Create simplified SPEAR3 HVPS circuit."""
        
        circuit = Circuit('SPEAR3_HVPS_Simplified')
        
        # 12-pulse rectifier output (modeled as voltage source with ripple)
        v_dc = self.params['v_dc_nominal']
        
        # Create 12-pulse ripple waveform
        # Fundamental (720 Hz) + harmonics
        ripple_expr = f"DC {v_dc}"
        
        # Add 720 Hz fundamental ripple
        ripple_amp = v_dc * (self.params['ripple_fundamental_pct'] / 100.0)
        ripple_expr += f" + SIN(0 {ripple_amp} {self.params['f_ripple']} 0 0 0)"
        
        # Add harmonic components
        for i, (harmonic, factor) in enumerate(zip(self.params['ripple_harmonics'], 
                                                  self.params['ripple_harmonic_factors'])):
            harm_freq = self.params['f_ripple'] * harmonic
            harm_amp = ripple_amp * factor
            phase = i * 30  # Phase shift for each harmonic
            ripple_expr += f" + SIN(0 {harm_amp} {harm_freq} 0 0 {phase})"
        
        # 12-pulse rectifier output with internal resistance
        circuit.V('rectifier', 'n_rect_out', 'gnd', ripple_expr)
        circuit.R('rect_internal', 'n_rect_out', 'n_rect_filtered', 1.0@u_Ohm)  # Internal resistance
        
        # Primary filter inductors L1, L2 in series (real configuration)
        circuit.L('L1', 'n_rect_filtered', 'n_l1_out', self.params['L1']@u_H)
        circuit.R('L1_esr', 'n_l1_out', 'n_l1_esr', self.params['L_esr']@u_Ohm)
        
        circuit.L('L2', 'n_l1_esr', 'n_l2_out', self.params['L2']@u_H)
        circuit.R('L2_esr', 'n_l2_out', 'n_filter_in', self.params['L_esr']@u_Ohm)
        
        # Filter capacitor bank (8µF with ESR)
        circuit.C('filter_cap', 'n_filter_in', 'n_cap_esr', self.params['C_filter']@u_F)
        circuit.R('cap_esr', 'n_cap_esr', 'gnd', self.params['C_esr']@u_Ohm)
        
        # Isolation resistors (500Ω - PEP-II arc protection)
        circuit.R('isolation', 'n_filter_in', 'n_isolated', self.params['R_isolation']@u_Ohm)
        
        # Cable termination inductors (L3 + L4)
        circuit.L('cable_term', 'n_isolated', 'n_output', self.params['L_cable']@u_H)
        
        # Load (klystron)
        circuit.R('load', 'n_output', 'gnd', self.params['R_load']@u_Ohm)
        
        return circuit
    
    def run_simulation(self, sim_time=0.1, time_step=50e-6):
        """Run the simplified SPEAR3 HVPS simulation."""
        
        print(f"\n🔧 Running SPEAR3 HVPS Simulation...")
        print(f"Simulation time: {sim_time:.3f}s, Time step: {time_step*1e6:.0f}µs")
        
        # Create circuit
        circuit = self.create_circuit()
        
        try:
            # Create simulator
            simulator = circuit.simulator(temperature=25, nominal_temperature=25)
            
            # Run transient analysis
            analysis = simulator.transient(step_time=time_step@u_s, end_time=sim_time@u_s)
            
            print("✅ Simulation completed successfully")
            
            # Extract results
            time = np.array(analysis.time)
            v_rectifier = np.array(analysis['n_rect_out'])
            v_filter_in = np.array(analysis['n_filter_in'])
            v_output = np.array(analysis['n_output'])
            
            # Calculate performance metrics
            results = self._analyze_results(time, v_rectifier, v_filter_in, v_output)
            
            return time, v_rectifier, v_filter_in, v_output, results
            
        except Exception as e:
            print(f"❌ Simulation failed: {e}")
            import traceback
            traceback.print_exc()
            return None, None, None, None, None
    
    def _analyze_results(self, time, v_rectifier, v_filter_in, v_output):
        """Analyze simulation results."""
        
        # Use last 50% of simulation for steady-state analysis
        steady_start = int(0.5 * len(time))
        time_steady = time[steady_start:]
        v_rect_steady = v_rectifier[steady_start:]
        v_filt_steady = v_filter_in[steady_start:]
        v_out_steady = v_output[steady_start:]
        
        # Calculate metrics for each stage
        def calc_metrics(v_data, stage_name):
            v_mean = np.mean(v_data)
            v_min = np.min(v_data)
            v_max = np.max(v_data)
            v_pp = v_max - v_min
            v_rms_ripple = np.sqrt(np.mean((v_data - v_mean)**2))
            
            ripple_pp_pct = (v_pp / abs(v_mean)) * 100.0 if v_mean != 0 else 0
            ripple_rms_pct = (v_rms_ripple / abs(v_mean)) * 100.0 if v_mean != 0 else 0
            
            return {
                f'{stage_name}_mean_kv': v_mean / 1e3,
                f'{stage_name}_pp_kv': v_pp / 1e3,
                f'{stage_name}_ripple_pp_pct': ripple_pp_pct,
                f'{stage_name}_ripple_rms_pct': ripple_rms_pct,
            }
        
        # Analyze each stage
        results = {}
        results.update(calc_metrics(v_rect_steady, 'rectifier'))
        results.update(calc_metrics(v_filt_steady, 'filter'))
        results.update(calc_metrics(v_out_steady, 'output'))
        
        # Overall system metrics
        v_out_mean = results['output_mean_kv'] * 1e3
        i_mean = abs(v_out_mean) / self.params['R_load']
        power_mean = abs(v_out_mean) * i_mean / 1e6  # MW
        
        results.update({
            'current_mean_a': i_mean,
            'power_mean_mw': power_mean,
            'regulation_error_pct': ((abs(v_out_mean) - self.params['v_dc_nominal']) / self.params['v_dc_nominal']) * 100.0,
            'filter_effectiveness': results['rectifier_ripple_pp_pct'] / results['output_ripple_pp_pct'] if results['output_ripple_pp_pct'] > 0 else float('inf'),
        })
        
        return results
    
    def plot_results(self, time, v_rectifier, v_filter_in, v_output, results, save_path=None):
        """Plot comprehensive simulation results."""
        
        fig, axes = plt.subplots(3, 2, figsize=(15, 12))
        
        # Convert to convenient units
        time_ms = time * 1000
        v_rect_kv = v_rectifier / 1000
        v_filt_kv = v_filter_in / 1000
        v_out_kv = v_output / 1000
        
        # Plot 1: Rectifier output (unfiltered)
        axes[0,0].plot(time_ms, v_rect_kv, 'b-', linewidth=1, label='Rectifier Output')
        axes[0,0].axhline(y=results['rectifier_mean_kv'], color='r', linestyle='--', alpha=0.7, 
                         label=f'Mean: {results["rectifier_mean_kv"]:.1f} kV')
        axes[0,0].set_xlabel('Time (ms)')
        axes[0,0].set_ylabel('Voltage (kV)')
        axes[0,0].set_title(f'12-Pulse Rectifier Output - Ripple: {results["rectifier_ripple_pp_pct"]:.1f}%')
        axes[0,0].grid(True, alpha=0.3)
        axes[0,0].legend()
        
        # Plot 2: Filter input vs output comparison
        axes[0,1].plot(time_ms, v_filt_kv, 'g-', linewidth=1, label='Filter Input', alpha=0.7)
        axes[0,1].plot(time_ms, v_out_kv, 'r-', linewidth=2, label='HVPS Output')
        axes[0,1].set_xlabel('Time (ms)')
        axes[0,1].set_ylabel('Voltage (kV)')
        axes[0,1].set_title('Filter Performance Comparison')
        axes[0,1].grid(True, alpha=0.3)
        axes[0,1].legend()
        
        # Plot 3: Output voltage detail (steady-state)
        if len(time_ms) > 1000:
            start_idx = -1000  # Last 1000 points
            axes[1,0].plot(time_ms[start_idx:], v_out_kv[start_idx:], 'r-', linewidth=2, label='HVPS Output')
            axes[1,0].axhline(y=results['output_mean_kv'], color='b', linestyle='--', alpha=0.7,
                             label=f'Mean: {results["output_mean_kv"]:.2f} kV')
            axes[1,0].set_xlabel('Time (ms)')
            axes[1,0].set_ylabel('Voltage (kV)')
            axes[1,0].set_title(f'Output Ripple Detail - {results["output_ripple_pp_pct"]:.3f}% P-P')
            axes[1,0].grid(True, alpha=0.3)
            axes[1,0].legend()
            
            # Highlight target achievement
            if results['output_ripple_pp_pct'] < 1.0:
                axes[1,0].text(0.5, 0.95, '✅ TARGET ACHIEVED: <1% Ripple!', 
                              transform=axes[1,0].transAxes, fontsize=12, fontweight='bold',
                              ha='center', va='top', color='green',
                              bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
            else:
                axes[1,0].text(0.5, 0.95, f'❌ Target: {results["output_ripple_pp_pct"]:.3f}% > 1.0%', 
                              transform=axes[1,0].transAxes, fontsize=12, fontweight='bold',
                              ha='center', va='top', color='red',
                              bbox=dict(boxstyle='round', facecolor='lightcoral', alpha=0.8))
        
        # Plot 4: Frequency domain analysis
        if len(v_output) > 1024:
            # FFT of output voltage
            dt = time[1] - time[0]
            freqs = np.fft.fftfreq(len(v_output), dt)
            fft_output = np.fft.fft(v_output - np.mean(v_output))
            
            # Plot positive frequencies up to 2 kHz
            pos_freqs = freqs[:len(freqs)//2]
            pos_fft = np.abs(fft_output[:len(freqs)//2])
            
            freq_mask = pos_freqs <= 2000  # Up to 2 kHz
            axes[1,1].semilogy(pos_freqs[freq_mask], pos_fft[freq_mask], 'b-', linewidth=1)
            axes[1,1].axvline(x=720, color='r', linestyle='--', alpha=0.7, label='720 Hz (12-pulse)')
            axes[1,1].axvline(x=self.fc, color='g', linestyle='--', alpha=0.7, label=f'fc = {self.fc:.0f} Hz')
            axes[1,1].set_xlabel('Frequency (Hz)')
            axes[1,1].set_ylabel('Amplitude (V)')
            axes[1,1].set_title('Output Voltage Spectrum')
            axes[1,1].grid(True, alpha=0.3)
            axes[1,1].legend()
        
        # Plot 5: Performance summary
        axes[2,0].axis('off')
        summary_text = f"""SPEAR3 HVPS Simulation Results
        
Real System Parameters:
• Filter Inductors: L1 + L2 = {self.params['L_total']:.1f} H
• Filter Capacitor: {self.params['C_filter']*1e6:.0f} µF
• Isolation Resistance: {self.params['R_isolation']:.0f} Ω
• Cutoff Frequency: {self.fc:.1f} Hz

Performance Metrics:
• Output Voltage: {results['output_mean_kv']:.2f} kV
• Output Current: {results['current_mean_a']:.1f} A
• Output Power: {results['power_mean_mw']:.2f} MW
• Peak-to-Peak Ripple: {results['output_ripple_pp_pct']:.3f}%
• RMS Ripple: {results['output_ripple_rms_pct']:.3f}%
• Filter Effectiveness: {results['filter_effectiveness']:.1f}×

Target Achievement:
• Specification: <1.0% P-P ripple
• Achieved: {results['output_ripple_pp_pct']:.3f}% P-P ripple
• Status: {'✅ PASSED' if results['output_ripple_pp_pct'] < 1.0 else '❌ FAILED'}"""
        
        axes[2,0].text(0.05, 0.95, summary_text, transform=axes[2,0].transAxes, fontsize=10,
                      verticalalignment='top', fontfamily='monospace',
                      bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
        
        # Plot 6: Theoretical vs actual comparison
        axes[2,1].axis('off')
        theory_text = f"""Theoretical Analysis vs Simulation
        
Theoretical Predictions:
• LC Filter fc: {self.fc:.1f} Hz
• Quality Factor Q: {self.Q:.2f}
• 720 Hz Attenuation: {self.attenuation_720hz:.1f} dB
• Reduction Factor: {self.reduction_factor:.1f}×
• Predicted Ripple: {self.predicted_ripple_pct:.2f}%

Simulation Results:
• Actual Ripple: {results['output_ripple_pp_pct']:.3f}%
• Actual Reduction: {results['filter_effectiveness']:.1f}×

Agreement:
• Theory vs Simulation: {abs(self.predicted_ripple_pct - results['output_ripple_pp_pct']):.2f}% difference
• Accuracy: {'✅ Excellent' if abs(self.predicted_ripple_pct - results['output_ripple_pp_pct']) < 0.5 else '⚠️ Moderate' if abs(self.predicted_ripple_pct - results['output_ripple_pp_pct']) < 1.0 else '❌ Poor'}"""
        
        axes[2,1].text(0.05, 0.95, theory_text, transform=axes[2,1].transAxes, fontsize=10,
                      verticalalignment='top', fontfamily='monospace',
                      bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"📊 Plot saved to: {save_path}")
        
        plt.show()
        return fig


def main():
    """Run SPEAR3 HVPS simplified simulation."""
    
    print("="*70)
    print("SPEAR3 HVPS Simplified PySpice Simulation")
    print("="*70)
    
    # Create simulation
    hvps = SPEAR3_HVPS_Simplified()
    
    # Run simulation
    time, v_rect, v_filt, v_out, results = hvps.run_simulation(sim_time=0.08, time_step=25e-6)
    
    if results is not None:
        # Print results
        print("\n" + "="*70)
        print("SIMULATION RESULTS")
        print("="*70)
        print(f"Output Voltage (Mean):      {results['output_mean_kv']:8.2f} kV")
        print(f"Peak-to-Peak Ripple:        {results['output_ripple_pp_pct']:8.3f} %")
        print(f"RMS Ripple:                 {results['output_ripple_rms_pct']:8.3f} %")
        print(f"Output Current:             {results['current_mean_a']:8.1f} A")
        print(f"Output Power:               {results['power_mean_mw']:8.2f} MW")
        print(f"Filter Effectiveness:       {results['filter_effectiveness']:8.1f} ×")
        print(f"Regulation Error:           {results['regulation_error_pct']:8.2f} %")
        print("="*70)
        
        # Check target achievement
        if results['output_ripple_pp_pct'] < 1.0:
            print("🎉 SUCCESS: <1% ripple target ACHIEVED!")
            print(f"   Achieved: {results['output_ripple_pp_pct']:.3f}% vs Target: <1.0%")
        else:
            print(f"❌ Target missed: {results['output_ripple_pp_pct']:.3f}% > 1.0%")
        
        # Compare with theory
        theory_diff = abs(hvps.predicted_ripple_pct - results['output_ripple_pp_pct'])
        print(f"📐 Theory vs Simulation: {theory_diff:.3f}% difference")
        
        # Create output directory and save results
        output_dir = Path("hvps/pyspice_sim/results")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        plot_path = output_dir / "spear3_hvps_simplified_results.png"
        hvps.plot_results(time, v_rect, v_filt, v_out, results, save_path=plot_path)
        
        return results['output_ripple_pp_pct'] < 1.0
        
    else:
        print("❌ Simulation failed!")
        return False


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)

