#!/usr/bin/env python3
"""
SPEAR3 HVPS Working PySpice Model
=================================

Working PySpice model of the SPEAR3 HVPS with real system parameters.
Focuses on demonstrating the <1% ripple achievement with correct filter design.
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


class SPEAR3_HVPS_Working:
    """Working SPEAR3 HVPS model with real system parameters."""
    
    def __init__(self):
        """Initialize with real SPEAR3 parameters."""
        
        # Real system parameters from technical documentation
        self.params = {
            # System specifications
            'v_dc_nominal': 77e3,       # 77 kV nominal output
            'i_nominal': 22.0,          # 22 A nominal current
            'f_line': 60.0,             # 60 Hz line frequency
            'f_ripple': 720.0,          # 12-pulse fundamental: 12 × 60 Hz
            
            # Primary filter inductors (real values from documentation)
            'L1': 0.3,                  # 0.3H, 85A rated, 1,084 J stored
            'L2': 0.3,                  # 0.3H, 85A rated, 1,084 J stored  
            'L_esr': 0.05,              # Inductor series resistance
            
            # Filter capacitor bank (real value from documentation)
            'C_filter': 8e-6,           # 8 µF total capacitance
            
            # Isolation resistors (PEP-II innovation for arc protection)
            'R_isolation': 500.0,       # 500Ω isolation resistors
            
            # Cable termination inductors (Layer 4 protection)
            'L3': 200e-6,               # 200µH cable termination
            'L4': 200e-6,               # 200µH cable termination
            
            # Load (klystron equivalent)
            'R_load': 3500.0,           # 77kV / 22A = 3500Ω
            
            # 12-pulse ripple characteristics (before filtering)
            'ripple_amplitude_pct': 8.0,  # 8% ripple amplitude before filtering
        }
        
        # Calculate derived parameters
        self.params['L_total'] = self.params['L1'] + self.params['L2']  # Series connection
        self.params['L_cable_total'] = self.params['L3'] + self.params['L4']  # Series
        
        # Calculate theoretical filter performance
        self._calculate_filter_theory()
        
        print("SPEAR3 HVPS Working Model Initialized")
        print(f"Real System Filter: L={self.params['L_total']:.1f}H, C={self.params['C_filter']*1e6:.1f}µF, R={self.params['R_isolation']:.0f}Ω")
        print(f"Theoretical Performance: fc={self.fc:.1f}Hz, Q={self.Q:.2f}")
        print(f"720Hz Attenuation: {self.attenuation_720hz:.1f}dB ({self.reduction_factor:.1f}× reduction)")
        print(f"Predicted Ripple: {self.predicted_ripple_pct:.2f}% (Target: <1.0%)")
    
    def _calculate_filter_theory(self):
        """Calculate theoretical LC filter performance with real system parameters."""
        L = self.params['L_total']
        C = self.params['C_filter']
        R = self.params['R_isolation']
        
        # LC filter cutoff frequency
        self.fc = 1.0 / (2.0 * np.pi * np.sqrt(L * C))
        
        # Quality factor
        self.Q = np.sqrt(L / C) / R
        
        # Attenuation at 720 Hz (12-pulse fundamental)
        f_ripple = self.params['f_ripple']
        ratio = f_ripple / self.fc
        self.attenuation_720hz = 20.0 * np.log10(ratio)
        self.reduction_factor = 10.0 ** (self.attenuation_720hz / 20.0)
        
        # Predicted ripple after filtering
        unfiltered_ripple = self.params['ripple_amplitude_pct']
        self.predicted_ripple_pct = unfiltered_ripple / self.reduction_factor
    
    def create_circuit(self):
        """Create SPEAR3 HVPS circuit with real system topology."""
        
        circuit = Circuit('SPEAR3_HVPS_Real_System')
        
        # 12-pulse rectifier output (simplified as DC + 720Hz ripple)
        v_dc = self.params['v_dc_nominal']
        ripple_amplitude = v_dc * (self.params['ripple_amplitude_pct'] / 100.0)
        
        # DC component
        circuit.V('dc_source', 'n_dc', 'gnd', v_dc@u_V)
        
        # 720 Hz ripple component (12-pulse fundamental)
        circuit.V('ripple_source', 'n_ripple', 'gnd', f'SIN(0 {ripple_amplitude} {self.params["f_ripple"]} 0 0 0)')
        
        # Combine DC and ripple (series connection)
        circuit.V('combine', 'n_rectifier_out', 'n_dc', 0@u_V)
        circuit.V('ripple_add', 'n_dc', 'n_ripple', 0@u_V)
        
        # Internal rectifier resistance
        circuit.R('rect_internal', 'n_rectifier_out', 'n_rect_filtered', 0.5@u_Ohm)
        
        # Primary Filter Inductors (L1, L2 in series - Real System Configuration)
        circuit.L('L1', 'n_rect_filtered', 'n_l1_out', self.params['L1']@u_H)
        circuit.R('L1_esr', 'n_l1_out', 'n_l1_filtered', self.params['L_esr']@u_Ohm)
        
        circuit.L('L2', 'n_l1_filtered', 'n_l2_out', self.params['L2']@u_H)
        circuit.R('L2_esr', 'n_l2_out', 'n_primary_filtered', self.params['L_esr']@u_Ohm)
        
        # Filter Capacitor Bank (8µF - Real System Value)
        circuit.C('filter_cap', 'n_primary_filtered', 'gnd', self.params['C_filter']@u_F)
        
        # Isolation Resistors (500Ω - PEP-II Arc Protection Innovation)
        circuit.R('isolation', 'n_primary_filtered', 'n_isolated', self.params['R_isolation']@u_Ohm)
        
        # Cable Termination Inductors (L3, L4 - Layer 4 Protection)
        circuit.L('L3', 'n_isolated', 'n_cable_mid', self.params['L3']@u_H)
        circuit.L('L4', 'n_cable_mid', 'n_hvps_output', self.params['L4']@u_H)
        
        # Load (Klystron equivalent)
        circuit.R('load', 'n_hvps_output', 'gnd', self.params['R_load']@u_Ohm)
        
        return circuit
    
    def run_simulation(self, sim_time=0.1, time_step=50e-6):
        """Run the SPEAR3 HVPS simulation."""
        
        print(f"\n🔧 Running SPEAR3 HVPS Simulation...")
        print(f"Simulation: {sim_time:.3f}s duration, {time_step*1e6:.0f}µs time step")
        
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
            v_rectifier = np.array(analysis['n_rectifier_out'])
            v_primary_filtered = np.array(analysis['n_primary_filtered'])
            v_isolated = np.array(analysis['n_isolated'])
            v_output = np.array(analysis['n_hvps_output'])
            
            # Calculate performance metrics
            results = self._analyze_results(time, v_rectifier, v_primary_filtered, v_isolated, v_output)
            
            return time, v_rectifier, v_primary_filtered, v_isolated, v_output, results
            
        except Exception as e:
            print(f"❌ Simulation failed: {e}")
            import traceback
            traceback.print_exc()
            return None, None, None, None, None, None
    
    def _analyze_results(self, time, v_rectifier, v_primary_filtered, v_isolated, v_output):
        """Analyze simulation results and calculate performance metrics."""
        
        # Use last 60% of simulation for steady-state analysis
        steady_start = int(0.4 * len(time))
        time_steady = time[steady_start:]
        
        def analyze_signal(v_signal, name):
            """Analyze a voltage signal for ripple metrics."""
            v_steady = v_signal[steady_start:]
            
            v_mean = np.mean(v_steady)
            v_min = np.min(v_steady)
            v_max = np.max(v_steady)
            v_pp = v_max - v_min
            v_rms_ripple = np.sqrt(np.mean((v_steady - v_mean)**2))
            
            ripple_pp_pct = (v_pp / abs(v_mean)) * 100.0 if v_mean != 0 else 0
            ripple_rms_pct = (v_rms_ripple / abs(v_mean)) * 100.0 if v_mean != 0 else 0
            
            return {
                f'{name}_mean_kv': v_mean / 1e3,
                f'{name}_min_kv': v_min / 1e3,
                f'{name}_max_kv': v_max / 1e3,
                f'{name}_pp_kv': v_pp / 1e3,
                f'{name}_ripple_pp_pct': ripple_pp_pct,
                f'{name}_ripple_rms_pct': ripple_rms_pct,
            }
        
        # Analyze each stage
        results = {}
        results.update(analyze_signal(v_rectifier, 'rectifier'))
        results.update(analyze_signal(v_primary_filtered, 'primary_filter'))
        results.update(analyze_signal(v_isolated, 'isolated'))
        results.update(analyze_signal(v_output, 'output'))
        
        # System-level metrics
        v_out_mean = results['output_mean_kv'] * 1e3
        i_mean = abs(v_out_mean) / self.params['R_load']
        power_mean = abs(v_out_mean) * i_mean / 1e6  # MW
        
        # Performance metrics
        results.update({
            'current_mean_a': i_mean,
            'power_mean_mw': power_mean,
            'regulation_error_pct': ((abs(v_out_mean) - self.params['v_dc_nominal']) / self.params['v_dc_nominal']) * 100.0,
            'filter_effectiveness': results['rectifier_ripple_pp_pct'] / results['output_ripple_pp_pct'] if results['output_ripple_pp_pct'] > 0 else float('inf'),
            'target_achieved': results['output_ripple_pp_pct'] < 1.0,
        })
        
        return results
    
    def plot_results(self, time, v_rectifier, v_primary_filtered, v_isolated, v_output, results, save_path=None):
        """Plot comprehensive simulation results."""
        
        fig, axes = plt.subplots(3, 2, figsize=(16, 14))
        
        # Convert to convenient units
        time_ms = time * 1000
        v_rect_kv = v_rectifier / 1000
        v_prim_kv = v_primary_filtered / 1000
        v_iso_kv = v_isolated / 1000
        v_out_kv = v_output / 1000
        
        # Plot 1: All voltage stages comparison
        axes[0,0].plot(time_ms, v_rect_kv, 'b-', linewidth=1, alpha=0.8, label='Rectifier Output')
        axes[0,0].plot(time_ms, v_prim_kv, 'g-', linewidth=1.5, alpha=0.8, label='After Primary Filter')
        axes[0,0].plot(time_ms, v_out_kv, 'r-', linewidth=2, label='HVPS Output')
        axes[0,0].set_xlabel('Time (ms)')
        axes[0,0].set_ylabel('Voltage (kV)')
        axes[0,0].set_title('SPEAR3 HVPS - Multi-Stage Filtering Performance')
        axes[0,0].grid(True, alpha=0.3)
        axes[0,0].legend()
        
        # Plot 2: Output voltage detail (steady-state ripple)
        if len(time_ms) > 1000:
            start_idx = -1000  # Last 1000 points for detail
            axes[0,1].plot(time_ms[start_idx:], v_out_kv[start_idx:], 'r-', linewidth=2, label='HVPS Output')
            axes[0,1].axhline(y=results['output_mean_kv'], color='b', linestyle='--', alpha=0.7,
                             label=f'Mean: {results["output_mean_kv"]:.2f} kV')
            axes[0,1].axhline(y=results['output_min_kv'], color='orange', linestyle=':', alpha=0.7,
                             label=f'Min: {results["output_min_kv"]:.2f} kV')
            axes[0,1].axhline(y=results['output_max_kv'], color='orange', linestyle=':', alpha=0.7,
                             label=f'Max: {results["output_max_kv"]:.2f} kV')
            
            axes[0,1].set_xlabel('Time (ms)')
            axes[0,1].set_ylabel('Voltage (kV)')
            axes[0,1].set_title(f'Output Ripple Detail - {results["output_ripple_pp_pct"]:.3f}% P-P')
            axes[0,1].grid(True, alpha=0.3)
            axes[0,1].legend()
            
            # Target achievement indicator
            if results['target_achieved']:
                axes[0,1].text(0.5, 0.95, '✅ TARGET ACHIEVED: <1% Ripple!', 
                              transform=axes[0,1].transAxes, fontsize=12, fontweight='bold',
                              ha='center', va='top', color='green',
                              bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
            else:
                axes[0,1].text(0.5, 0.95, f'❌ Target: {results["output_ripple_pp_pct"]:.3f}% > 1.0%', 
                              transform=axes[0,1].transAxes, fontsize=12, fontweight='bold',
                              ha='center', va='top', color='red',
                              bbox=dict(boxstyle='round', facecolor='lightcoral', alpha=0.8))
        
        # Plot 3: Ripple reduction through stages
        stages = ['Rectifier', 'Primary Filter', 'Isolated', 'Output']
        ripple_values = [
            results['rectifier_ripple_pp_pct'],
            results['primary_filter_ripple_pp_pct'],
            results['isolated_ripple_pp_pct'],
            results['output_ripple_pp_pct']
        ]
        
        bars = axes[1,0].bar(stages, ripple_values, color=['red', 'orange', 'yellow', 'green'], alpha=0.7)
        axes[1,0].axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='1% Target')
        axes[1,0].set_ylabel('Ripple (%)')
        axes[1,0].set_title('Ripple Reduction Through Filter Stages')
        axes[1,0].grid(True, alpha=0.3)
        axes[1,0].legend()
        
        # Add value labels on bars
        for bar, value in zip(bars, ripple_values):
            height = bar.get_height()
            axes[1,0].text(bar.get_x() + bar.get_width()/2., height + 0.05,
                          f'{value:.3f}%', ha='center', va='bottom', fontweight='bold')
        
        # Plot 4: Frequency domain analysis
        if len(v_output) > 1024:
            dt = time[1] - time[0]
            freqs = np.fft.fftfreq(len(v_output), dt)
            fft_output = np.fft.fft(v_output - np.mean(v_output))
            
            # Plot positive frequencies up to 3 kHz
            pos_freqs = freqs[:len(freqs)//2]
            pos_fft = np.abs(fft_output[:len(freqs)//2])
            
            freq_mask = (pos_freqs > 0) & (pos_freqs <= 3000)
            axes[1,1].semilogy(pos_freqs[freq_mask], pos_fft[freq_mask], 'b-', linewidth=1)
            axes[1,1].axvline(x=720, color='r', linestyle='--', alpha=0.7, label='720 Hz (12-pulse)')
            axes[1,1].axvline(x=self.fc, color='g', linestyle='--', alpha=0.7, label=f'fc = {self.fc:.0f} Hz')
            axes[1,1].set_xlabel('Frequency (Hz)')
            axes[1,1].set_ylabel('Amplitude (V)')
            axes[1,1].set_title('Output Voltage Frequency Spectrum')
            axes[1,1].grid(True, alpha=0.3)
            axes[1,1].legend()
        
        # Plot 5: Performance summary
        axes[2,0].axis('off')
        summary_text = f"""SPEAR3 HVPS Simulation Results Summary

Real System Parameters (from Technical Documentation):
• Primary Filter Inductors: L1 = L2 = 0.3H (series = 0.6H total)
• Filter Capacitor Bank: {self.params['C_filter']*1e6:.0f} µF
• Isolation Resistors: {self.params['R_isolation']:.0f} Ω (PEP-II innovation)
• Cable Termination: L3 + L4 = {self.params['L_cable_total']*1e6:.0f} µH
• Filter Cutoff Frequency: {self.fc:.1f} Hz
• Quality Factor: {self.Q:.2f}

Performance Metrics:
• Output Voltage: {results['output_mean_kv']:.2f} kV (Target: -77 kV)
• Output Current: {results['current_mean_a']:.1f} A (Target: 22 A)
• Output Power: {results['power_mean_mw']:.2f} MW (Target: 1.7 MW)
• Peak-to-Peak Ripple: {results['output_ripple_pp_pct']:.3f}% (Target: <1.0%)
• RMS Ripple: {results['output_ripple_rms_pct']:.3f}% (Target: <0.2%)
• Filter Effectiveness: {results['filter_effectiveness']:.1f}× reduction
• Regulation Error: {results['regulation_error_pct']:.2f}%

Target Achievement:
• Ripple Specification: <1.0% peak-to-peak
• Simulation Result: {results['output_ripple_pp_pct']:.3f}% peak-to-peak
• Status: {'✅ SPECIFICATION MET' if results['target_achieved'] else '❌ SPECIFICATION NOT MET'}"""
        
        axes[2,0].text(0.05, 0.95, summary_text, transform=axes[2,0].transAxes, fontsize=9,
                      verticalalignment='top', fontfamily='monospace',
                      bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
        
        # Plot 6: Theory vs simulation comparison
        axes[2,1].axis('off')
        theory_text = f"""Theoretical Analysis vs PySpice Simulation

Theoretical Predictions:
• LC Filter Cutoff: {self.fc:.1f} Hz
• 720 Hz Attenuation: {self.attenuation_720hz:.1f} dB
• Theoretical Reduction: {self.reduction_factor:.1f}×
• Predicted Ripple: {self.predicted_ripple_pct:.3f}%

PySpice Simulation Results:
• Actual Ripple: {results['output_ripple_pp_pct']:.3f}%
• Actual Reduction: {results['filter_effectiveness']:.1f}×
• Difference: {abs(self.predicted_ripple_pct - results['output_ripple_pp_pct']):.3f}%

Model Validation:
• Theory-Simulation Agreement: {'✅ Excellent' if abs(self.predicted_ripple_pct - results['output_ripple_pp_pct']) < 0.2 else '⚠️ Good' if abs(self.predicted_ripple_pct - results['output_ripple_pp_pct']) < 0.5 else '❌ Poor'}
• Filter Design Accuracy: {'✅ Validated' if results['target_achieved'] else '❌ Needs Revision'}

Real System Comparison:
• SPEAR3 Specification: <1% P-P, <0.2% RMS ripple
• Simulation Achievement: {results['output_ripple_pp_pct']:.3f}% P-P, {results['output_ripple_rms_pct']:.3f}% RMS
• Real System Match: {'✅ Matches Specification' if results['target_achieved'] and results['output_ripple_rms_pct'] < 0.2 else '⚠️ Partial Match' if results['target_achieved'] else '❌ Does Not Match'}"""
        
        axes[2,1].text(0.05, 0.95, theory_text, transform=axes[2,1].transAxes, fontsize=9,
                      verticalalignment='top', fontfamily='monospace',
                      bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"📊 Results plot saved to: {save_path}")
        
        plt.show()
        return fig


def main():
    """Run SPEAR3 HVPS working simulation."""
    
    print("="*80)
    print("SPEAR3 HVPS PySpice Simulation - Real System Parameters")
    print("="*80)
    
    # Create simulation
    hvps = SPEAR3_HVPS_Working()
    
    # Run simulation
    time, v_rect, v_prim, v_iso, v_out, results = hvps.run_simulation(sim_time=0.1, time_step=25e-6)
    
    if results is not None:
        # Print detailed results
        print("\n" + "="*80)
        print("DETAILED SIMULATION RESULTS")
        print("="*80)
        print(f"Output Voltage (Mean):        {results['output_mean_kv']:8.2f} kV")
        print(f"Output Voltage (Min):         {results['output_min_kv']:8.2f} kV")
        print(f"Output Voltage (Max):         {results['output_max_kv']:8.2f} kV")
        print(f"Peak-to-Peak Ripple:          {results['output_ripple_pp_pct']:8.3f} %")
        print(f"RMS Ripple:                   {results['output_ripple_rms_pct']:8.3f} %")
        print(f"Output Current:               {results['current_mean_a']:8.1f} A")
        print(f"Output Power:                 {results['power_mean_mw']:8.2f} MW")
        print(f"Filter Effectiveness:         {results['filter_effectiveness']:8.1f} ×")
        print(f"Regulation Error:             {results['regulation_error_pct']:8.2f} %")
        print("="*80)
        
        # Target achievement analysis
        print("TARGET ACHIEVEMENT ANALYSIS:")
        print(f"• Peak-to-Peak Ripple Target: <1.0%")
        print(f"• Achieved P-P Ripple:        {results['output_ripple_pp_pct']:.3f}%")
        print(f"• RMS Ripple Target:          <0.2%")
        print(f"• Achieved RMS Ripple:        {results['output_ripple_rms_pct']:.3f}%")
        
        if results['target_achieved'] and results['output_ripple_rms_pct'] < 0.2:
            print("🎉 COMPLETE SUCCESS: Both P-P and RMS ripple targets ACHIEVED!")
            print("   Real SPEAR3 system performance successfully modeled!")
        elif results['target_achieved']:
            print("✅ PRIMARY SUCCESS: P-P ripple target achieved!")
            print(f"   RMS ripple: {results['output_ripple_rms_pct']:.3f}% (slightly above 0.2% target)")
        else:
            print(f"❌ Target not achieved: {results['output_ripple_pp_pct']:.3f}% > 1.0%")
        
        # Theory validation
        theory_diff = abs(hvps.predicted_ripple_pct - results['output_ripple_pp_pct'])
        print(f"\n📐 THEORETICAL VALIDATION:")
        print(f"• Predicted Ripple:           {hvps.predicted_ripple_pct:.3f}%")
        print(f"• Simulated Ripple:           {results['output_ripple_pp_pct']:.3f}%")
        print(f"• Theory-Simulation Diff:     {theory_diff:.3f}%")
        print(f"• Model Accuracy:             {'✅ Excellent' if theory_diff < 0.2 else '⚠️ Good' if theory_diff < 0.5 else '❌ Poor'}")
        
        # Create output directory and save results
        output_dir = Path("hvps/pyspice_sim/results")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        plot_path = output_dir / "spear3_hvps_real_system_results.png"
        hvps.plot_results(time, v_rect, v_prim, v_iso, v_out, results, save_path=plot_path)
        
        # Save numerical results
        results_path = output_dir / "spear3_hvps_numerical_results.txt"
        with open(results_path, 'w') as f:
            f.write("SPEAR3 HVPS PySpice Simulation Results\n")
            f.write("="*50 + "\n\n")
            f.write(f"Real System Parameters:\n")
            f.write(f"  L1 + L2 = {hvps.params['L_total']:.1f} H\n")
            f.write(f"  C_filter = {hvps.params['C_filter']*1e6:.0f} µF\n")
            f.write(f"  R_isolation = {hvps.params['R_isolation']:.0f} Ω\n")
            f.write(f"  Filter fc = {hvps.fc:.1f} Hz\n")
            f.write(f"  Filter Q = {hvps.Q:.2f}\n\n")
            f.write(f"Performance Results:\n")
            for key, value in results.items():
                if isinstance(value, (int, float)):
                    f.write(f"  {key}: {value:.6f}\n")
                else:
                    f.write(f"  {key}: {value}\n")
        
        print(f"📄 Numerical results saved to: {results_path}")
        
        return results['target_achieved']
        
    else:
        print("❌ Simulation failed!")
        return False


if __name__ == "__main__":
    success = main()
    print(f"\n{'='*80}")
    print(f"FINAL RESULT: {'✅ SUCCESS - SPEAR3 <1% ripple target achieved!' if success else '❌ FAILED - Target not achieved'}")
    print(f"{'='*80}")
    sys.exit(0 if success else 1)

