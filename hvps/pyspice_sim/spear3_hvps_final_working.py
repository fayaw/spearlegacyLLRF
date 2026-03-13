#!/usr/bin/env python3
"""
SPEAR3 HVPS Final Working Simulation
====================================

Working PySpice simulation that demonstrates the <1% ripple achievement
with real SPEAR3 system parameters.
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


def create_spear3_circuit():
    """Create simplified but accurate SPEAR3 HVPS circuit."""
    
    circuit = Circuit('SPEAR3_HVPS_Final')
    
    # Real system parameters
    v_dc = 77000.0  # 77 kV nominal
    ripple_pct = 8.0  # 8% unfiltered ripple from 12-pulse
    f_ripple = 720.0  # 720 Hz fundamental
    
    # Filter parameters (real system values)
    L_total = 0.6  # 0.3H + 0.3H in series
    C_filter = 8e-6  # 8 µF
    R_isolation = 500.0  # 500Ω
    R_load = 3500.0  # 77kV / 22A
    
    # DC source
    circuit.V('dc', 'n_dc', 'gnd', v_dc@u_V)
    
    # 720 Hz ripple source
    ripple_amp = v_dc * (ripple_pct / 100.0)
    circuit.V('ripple', 'n_ripple', 'gnd', f'SIN(0 {ripple_amp} {f_ripple} 0 0 0)')
    
    # Series combination of DC + ripple
    circuit.R('r_dc', 'n_dc', 'n_combined', 0.1@u_Ohm)
    circuit.R('r_ripple', 'n_ripple', 'n_combined', 0.1@u_Ohm)
    
    # Primary filter inductors (L1 + L2 in series)
    circuit.L('L1', 'n_combined', 'n_l1_out', 0.3@u_H)
    circuit.R('L1_esr', 'n_l1_out', 'n_l1_filtered', 0.05@u_Ohm)
    
    circuit.L('L2', 'n_l1_filtered', 'n_l2_out', 0.3@u_H)
    circuit.R('L2_esr', 'n_l2_out', 'n_filter_in', 0.05@u_Ohm)
    
    # Filter capacitor (8µF - real system value)
    circuit.C('filter_cap', 'n_filter_in', 'gnd', C_filter@u_F)
    
    # Isolation resistors (500Ω - PEP-II innovation)
    circuit.R('isolation', 'n_filter_in', 'n_isolated', R_isolation@u_Ohm)
    
    # Cable termination inductors
    circuit.L('cable_term', 'n_isolated', 'n_output', 400e-6@u_H)
    
    # Load (klystron)
    circuit.R('load', 'n_output', 'gnd', R_load@u_Ohm)
    
    return circuit


def run_simulation():
    """Run the SPEAR3 HVPS simulation."""
    
    print("\n🔧 Running SPEAR3 HVPS Final Simulation...")
    
    # Create circuit
    circuit = create_spear3_circuit()
    
    try:
        # Create simulator
        simulator = circuit.simulator(temperature=25, nominal_temperature=25)
        
        # Run transient analysis
        sim_time = 0.1  # 100ms
        time_step = 50e-6  # 50µs
        
        print(f"Simulation: {sim_time:.3f}s duration, {time_step*1e6:.0f}µs time step")
        
        analysis = simulator.transient(step_time=time_step@u_s, end_time=sim_time@u_s)
        
        print("✅ Simulation completed successfully")
        
        # Extract results
        time = np.array(analysis.time)
        v_combined = np.array(analysis['n_combined'])
        v_filter_in = np.array(analysis['n_filter_in'])
        v_output = np.array(analysis['n_output'])
        
        return time, v_combined, v_filter_in, v_output
        
    except Exception as e:
        print(f"❌ Simulation failed: {e}")
        return None, None, None, None


def analyze_results(time, v_combined, v_filter_in, v_output):
    """Analyze simulation results."""
    
    if time is None:
        return None
    
    # Use last 60% for steady-state analysis
    steady_start = int(0.4 * len(time))
    
    def analyze_signal(v_signal, name):
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
            f'{name}_pp_kv': v_pp / 1e3,
            f'{name}_ripple_pp_pct': ripple_pp_pct,
            f'{name}_ripple_rms_pct': ripple_rms_pct,
        }
    
    results = {}
    results.update(analyze_signal(v_combined, 'unfiltered'))
    results.update(analyze_signal(v_filter_in, 'primary_filter'))
    results.update(analyze_signal(v_output, 'output'))
    
    # System metrics
    v_out_mean = results['output_mean_kv'] * 1e3
    i_mean = abs(v_out_mean) / 3500.0  # Load resistance
    power_mean = abs(v_out_mean) * i_mean / 1e6  # MW
    
    results.update({
        'current_mean_a': i_mean,
        'power_mean_mw': power_mean,
        'filter_effectiveness': results['unfiltered_ripple_pp_pct'] / results['output_ripple_pp_pct'] if results['output_ripple_pp_pct'] > 0 else float('inf'),
        'target_achieved': results['output_ripple_pp_pct'] < 1.0,
    })
    
    return results


def plot_comprehensive_results(time, v_combined, v_filter_in, v_output, results, save_dir=None):
    """Generate comprehensive plots similar to hvps_sim package."""
    
    if time is None:
        return None
    
    plots = {}
    
    # Convert to convenient units
    time_ms = time * 1000
    v_comb_kv = v_combined / 1000
    v_filt_kv = v_filter_in / 1000
    v_out_kv = v_output / 1000
    
    # 1. Multi-stage filtering performance
    fig1, ax = plt.subplots(figsize=(12, 8))
    ax.plot(time_ms, v_comb_kv, 'b-', linewidth=1, alpha=0.8, label='Unfiltered (12-pulse)')
    ax.plot(time_ms, v_filt_kv, 'g-', linewidth=1.5, alpha=0.8, label='After Primary Filter')
    ax.plot(time_ms, v_out_kv, 'r-', linewidth=2, label='HVPS Output')
    ax.set_xlabel('Time (ms)')
    ax.set_ylabel('Voltage (kV)')
    ax.set_title('SPEAR3 HVPS - Multi-Stage Filtering Performance')
    ax.grid(True, alpha=0.3)
    ax.legend()
    plots['filtering_stages'] = fig1
    
    # 2. Output ripple detail (working point analysis)
    fig2, ax = plt.subplots(figsize=(12, 8))
    if len(time_ms) > 1000:
        # Show last 50ms for steady-state detail
        start_idx = -int(0.05 / (time[1] - time[0]))  # Last 50ms
        ax.plot(time_ms[start_idx:], v_out_kv[start_idx:], 'r-', linewidth=2, label='HVPS Output')
        ax.axhline(y=results['output_mean_kv'], color='b', linestyle='--', alpha=0.7,
                  label=f'Mean: {results["output_mean_kv"]:.2f} kV')
        
        # Add min/max lines
        v_out_steady = v_out_kv[int(0.4 * len(v_out_kv)):]
        v_min = np.min(v_out_steady)
        v_max = np.max(v_out_steady)
        ax.axhline(y=v_min, color='orange', linestyle=':', alpha=0.7, label=f'Min: {v_min:.2f} kV')
        ax.axhline(y=v_max, color='orange', linestyle=':', alpha=0.7, label=f'Max: {v_max:.2f} kV')
        
        ax.set_xlabel('Time (ms)')
        ax.set_ylabel('Voltage (kV)')
        ax.set_title(f'Output Ripple Detail - {results["output_ripple_pp_pct"]:.3f}% P-P')
        ax.grid(True, alpha=0.3)
        ax.legend()
        
        # Target achievement indicator
        if results['target_achieved']:
            ax.text(0.5, 0.95, '✅ TARGET ACHIEVED: <1% Ripple!', 
                   transform=ax.transAxes, fontsize=14, fontweight='bold',
                   ha='center', va='top', color='green',
                   bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
    plots['ripple_detail'] = fig2
    
    # 3. Frequency domain analysis
    fig3, ax = plt.subplots(figsize=(12, 8))
    if len(v_output) > 1024:
        dt = time[1] - time[0]
        freqs = np.fft.fftfreq(len(v_output), dt)
        fft_output = np.fft.fft(v_output - np.mean(v_output))
        
        # Plot positive frequencies up to 3 kHz
        pos_freqs = freqs[:len(freqs)//2]
        pos_fft = np.abs(fft_output[:len(freqs)//2])
        
        freq_mask = (pos_freqs > 0) & (pos_freqs <= 3000)
        ax.semilogy(pos_freqs[freq_mask], pos_fft[freq_mask], 'b-', linewidth=1)
        ax.axvline(x=720, color='r', linestyle='--', alpha=0.7, label='720 Hz (12-pulse)')
        ax.axvline(x=72.6, color='g', linestyle='--', alpha=0.7, label='fc = 72.6 Hz')
        ax.set_xlabel('Frequency (Hz)')
        ax.set_ylabel('Amplitude (V)')
        ax.set_title('Output Voltage Frequency Spectrum')
        ax.grid(True, alpha=0.3)
        ax.legend()
    plots['frequency_spectrum'] = fig3
    
    # 4. Ripple reduction comparison
    fig4, ax = plt.subplots(figsize=(10, 6))
    stages = ['Unfiltered\n(12-pulse)', 'Primary Filter\n(LC)', 'Output\n(Final)']
    ripple_values = [
        results['unfiltered_ripple_pp_pct'],
        results['primary_filter_ripple_pp_pct'],
        results['output_ripple_pp_pct']
    ]
    
    bars = ax.bar(stages, ripple_values, color=['red', 'orange', 'green'], alpha=0.7)
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='1% Target')
    ax.set_ylabel('Ripple (%)')
    ax.set_title('Ripple Reduction Through Filter Stages')
    ax.grid(True, alpha=0.3)
    ax.legend()
    
    # Add value labels and reduction factors
    for i, (bar, value) in enumerate(zip(bars, ripple_values)):
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.1,
               f'{value:.3f}%', ha='center', va='bottom', fontweight='bold')
        if i > 0:
            reduction = ripple_values[i-1] / value
            ax.text(bar.get_x() + bar.get_width()/2., height/2,
                   f'{reduction:.1f}× reduction', ha='center', va='center',
                   fontsize=9, color='white', fontweight='bold')
    plots['ripple_reduction'] = fig4
    
    # 5. Working point analysis
    fig5, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # Voltage vs time (zoomed)
    steady_start = int(0.6 * len(time))
    axes[0,0].plot(time_ms[steady_start:], v_out_kv[steady_start:], 'r-', linewidth=2)
    axes[0,0].set_xlabel('Time (ms)')
    axes[0,0].set_ylabel('Voltage (kV)')
    axes[0,0].set_title('Working Point - Output Voltage')
    axes[0,0].grid(True, alpha=0.3)
    
    # Current calculation and plot
    i_out = v_output / 3500.0  # Load resistance
    i_out_a = i_out / 1000  # Convert to A
    axes[0,1].plot(time_ms[steady_start:], i_out_a[steady_start:], 'b-', linewidth=2)
    axes[0,1].set_xlabel('Time (ms)')
    axes[0,1].set_ylabel('Current (A)')
    axes[0,1].set_title('Working Point - Output Current')
    axes[0,1].grid(True, alpha=0.3)
    
    # Power calculation and plot
    p_out = v_output * i_out / 1e6  # MW
    axes[1,0].plot(time_ms[steady_start:], p_out[steady_start:], 'g-', linewidth=2)
    axes[1,0].set_xlabel('Time (ms)')
    axes[1,0].set_ylabel('Power (MW)')
    axes[1,0].set_title('Working Point - Output Power')
    axes[1,0].grid(True, alpha=0.3)
    
    # Performance summary
    axes[1,1].axis('off')
    summary_text = f"""Working Point Analysis

Steady-State Performance:
• Mean Voltage: {results['output_mean_kv']:.2f} kV
• Mean Current: {results['current_mean_a']:.1f} A  
• Mean Power: {results['power_mean_mw']:.2f} MW

Ripple Performance:
• P-P Ripple: {results['output_ripple_pp_pct']:.3f}%
• RMS Ripple: {results['output_ripple_rms_pct']:.3f}%
• Filter Effectiveness: {results['filter_effectiveness']:.1f}×

Target Compliance:
• P-P Spec: <1.0% → {'✅ PASS' if results['target_achieved'] else '❌ FAIL'}
• RMS Spec: <0.2% → {'✅ PASS' if results['output_ripple_rms_pct'] < 0.2 else '❌ FAIL'}

System Health:
• Regulation: ±{abs(results['output_mean_kv'] - 77)/77*100:.2f}%
• Load Match: {3500*results['current_mean_a']/1000/results['output_mean_kv']:.3f}
• Efficiency: ~92% (estimated)"""
    
    axes[1,1].text(0.05, 0.95, summary_text, transform=axes[1,1].transAxes, fontsize=11,
                  verticalalignment='top', fontfamily='monospace',
                  bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))
    
    plt.tight_layout()
    plots['working_point'] = fig5
    
    # Save all plots if directory provided
    if save_dir:
        save_dir = Path(save_dir)
        save_dir.mkdir(parents=True, exist_ok=True)
        
        for name, fig in plots.items():
            save_path = save_dir / f"spear3_hvps_{name}.png"
            fig.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"📊 Saved {name} plot to: {save_path}")
    
    return plots


def run_working_point_analysis():
    """Run simulation at different working points around nominal."""
    
    print("\n🔧 Running Working Point Analysis...")
    
    # Define working points around nominal (77 kV, 22 A)
    working_points = [
        {'voltage_scale': 0.8, 'name': '62 kV (80% nominal)'},
        {'voltage_scale': 0.9, 'name': '69 kV (90% nominal)'},
        {'voltage_scale': 1.0, 'name': '77 kV (100% nominal)'},
        {'voltage_scale': 1.1, 'name': '85 kV (110% nominal)'},
        {'voltage_scale': 1.2, 'name': '92 kV (120% nominal)'},
    ]
    
    working_point_results = []
    
    for wp in working_points:
        print(f"  Simulating {wp['name']}...")
        
        # Create modified circuit with scaled voltage
        circuit = Circuit('SPEAR3_HVPS_WorkingPoint')
        
        # Real system parameters
        v_dc = 77000.0 * wp['voltage_scale']
        ripple_pct = 8.0  # 8% unfiltered ripple from 12-pulse
        f_ripple = 720.0  # 720 Hz fundamental
        
        # Filter parameters (real system values)
        L_total = 0.6  # 0.3H + 0.3H in series
        C_filter = 8e-6  # 8 µF
        R_isolation = 500.0  # 500Ω
        R_load = 3500.0  # 77kV / 22A
        
        # DC source
        circuit.V('dc', 'n_dc', 'gnd', v_dc@u_V)
        
        # 720 Hz ripple source
        ripple_amp = v_dc * (ripple_pct / 100.0)
        circuit.V('ripple', 'n_ripple', 'gnd', f'SIN(0 {ripple_amp} {f_ripple} 0 0 0)')
        
        # Series combination of DC + ripple
        circuit.R('r_dc', 'n_dc', 'n_combined', 0.1@u_Ohm)
        circuit.R('r_ripple', 'n_ripple', 'n_combined', 0.1@u_Ohm)
        
        # Primary filter inductors (L1 + L2 in series)
        circuit.L('L1', 'n_combined', 'n_l1_out', 0.3@u_H)
        circuit.R('L1_esr', 'n_l1_out', 'n_l1_filtered', 0.05@u_Ohm)
        
        circuit.L('L2', 'n_l1_filtered', 'n_l2_out', 0.3@u_H)
        circuit.R('L2_esr', 'n_l2_out', 'n_filter_in', 0.05@u_Ohm)
        
        # Filter capacitor (8µF - real system value)
        circuit.C('filter_cap', 'n_filter_in', 'gnd', C_filter@u_F)
        
        # Isolation resistors (500Ω - PEP-II innovation)
        circuit.R('isolation', 'n_filter_in', 'n_isolated', R_isolation@u_Ohm)
        
        # Cable termination inductors
        circuit.L('cable_term', 'n_isolated', 'n_output', 400e-6@u_H)
        
        # Load (klystron)
        circuit.R('load', 'n_output', 'gnd', R_load@u_Ohm)
        
        try:
            # Create simulator
            simulator = circuit.simulator(temperature=25, nominal_temperature=25)
            
            # Run shorter simulation for working point analysis
            sim_time = 0.05  # 50ms
            time_step = 25e-6  # 25µs
            
            analysis = simulator.transient(step_time=time_step@u_s, end_time=sim_time@u_s)
            
            # Extract results
            time = np.array(analysis.time)
            v_output = np.array(analysis['n_output'])
            
            # Analyze steady-state (last 60%)
            steady_start = int(0.4 * len(time))
            v_steady = v_output[steady_start:]
            
            v_mean = np.mean(v_steady)
            v_min = np.min(v_steady)
            v_max = np.max(v_steady)
            v_pp = v_max - v_min
            v_rms_ripple = np.sqrt(np.mean((v_steady - v_mean)**2))
            
            ripple_pp_pct = (v_pp / abs(v_mean)) * 100.0 if v_mean != 0 else 0
            ripple_rms_pct = (v_rms_ripple / abs(v_mean)) * 100.0 if v_mean != 0 else 0
            
            i_mean = abs(v_mean) / R_load
            power_mean = abs(v_mean) * i_mean / 1e6  # MW
            
            wp_result = {
                'name': wp['name'],
                'voltage_scale': wp['voltage_scale'],
                'voltage_kv': v_mean / 1e3,
                'current_a': i_mean,
                'power_mw': power_mean,
                'ripple_pp_pct': ripple_pp_pct,
                'ripple_rms_pct': ripple_rms_pct,
                'target_achieved': ripple_pp_pct < 1.0,
            }
            
            working_point_results.append(wp_result)
            print(f"    ✅ {wp['name']}: {ripple_pp_pct:.3f}% ripple")
            
        except Exception as e:
            print(f"    ❌ {wp['name']}: Simulation failed - {e}")
            continue
    
    return working_point_results


def plot_working_point_analysis(wp_results, save_dir=None):
    """Plot working point analysis results."""
    
    if not wp_results:
        return None
    
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # Extract data
    voltage_scales = [wp['voltage_scale'] for wp in wp_results]
    voltages = [wp['voltage_kv'] for wp in wp_results]
    currents = [wp['current_a'] for wp in wp_results]
    powers = [wp['power_mw'] for wp in wp_results]
    ripples = [wp['ripple_pp_pct'] for wp in wp_results]
    
    # Plot 1: Voltage vs Scale
    axes[0,0].plot(voltage_scales, voltages, 'bo-', linewidth=2, markersize=8)
    axes[0,0].set_xlabel('Voltage Scale Factor')
    axes[0,0].set_ylabel('Output Voltage (kV)')
    axes[0,0].set_title('Output Voltage vs Operating Point')
    axes[0,0].grid(True, alpha=0.3)
    
    # Plot 2: Current vs Scale
    axes[0,1].plot(voltage_scales, currents, 'go-', linewidth=2, markersize=8)
    axes[0,1].set_xlabel('Voltage Scale Factor')
    axes[0,1].set_ylabel('Output Current (A)')
    axes[0,1].set_title('Output Current vs Operating Point')
    axes[0,1].grid(True, alpha=0.3)
    
    # Plot 3: Power vs Scale
    axes[1,0].plot(voltage_scales, powers, 'ro-', linewidth=2, markersize=8)
    axes[1,0].set_xlabel('Voltage Scale Factor')
    axes[1,0].set_ylabel('Output Power (MW)')
    axes[1,0].set_title('Output Power vs Operating Point')
    axes[1,0].grid(True, alpha=0.3)
    
    # Plot 4: Ripple vs Scale
    axes[1,1].plot(voltage_scales, ripples, 'mo-', linewidth=2, markersize=8)
    axes[1,1].axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='1% Target')
    axes[1,1].set_xlabel('Voltage Scale Factor')
    axes[1,1].set_ylabel('Ripple (%)')
    axes[1,1].set_title('Ripple Performance vs Operating Point')
    axes[1,1].grid(True, alpha=0.3)
    axes[1,1].legend()
    
    # Color code points that meet target
    for i, wp in enumerate(wp_results):
        color = 'green' if wp['target_achieved'] else 'red'
        axes[1,1].plot(wp['voltage_scale'], wp['ripple_pp_pct'], 'o', 
                      color=color, markersize=10, alpha=0.7)
    
    plt.tight_layout()
    
    if save_dir:
        save_path = Path(save_dir) / "spear3_hvps_working_point_analysis.png"
        fig.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"📊 Saved working point analysis to: {save_path}")
    
    return fig


def main():
    """Run complete SPEAR3 HVPS simulation with comprehensive analysis."""
    
    print("="*80)
    print("SPEAR3 HVPS Comprehensive PySpice Simulation")
    print("="*80)
    
    # 1. Run main simulation at nominal point
    print("🔧 Running Main Simulation at Nominal Operating Point...")
    time, v_combined, v_filter_in, v_output = run_simulation()
    
    if time is not None:
        # Analyze results
        results = analyze_results(time, v_combined, v_filter_in, v_output)
        
        # Print main results
        print("\n" + "="*80)
        print("MAIN SIMULATION RESULTS")
        print("="*80)
        print(f"Output Voltage (Mean):      {results['output_mean_kv']:8.2f} kV")
        print(f"Peak-to-Peak Ripple:        {results['output_ripple_pp_pct']:8.3f} %")
        print(f"RMS Ripple:                 {results['output_ripple_rms_pct']:8.3f} %")
        print(f"Output Current:             {results['current_mean_a']:8.1f} A")
        print(f"Output Power:               {results['power_mean_mw']:8.2f} MW")
        print(f"Filter Effectiveness:       {results['filter_effectiveness']:8.1f} ×")
        print("="*80)
        
        # Target achievement
        if results['target_achieved']:
            print("🎉 SUCCESS: <1% ripple target ACHIEVED!")
            print(f"   Achieved: {results['output_ripple_pp_pct']:.3f}% vs Target: <1.0%")
        else:
            print(f"❌ Target missed: {results['output_ripple_pp_pct']:.3f}% > 1.0%")
        
        # 2. Run working point analysis
        wp_results = run_working_point_analysis()
        
        # 3. Create output directory and generate comprehensive plots
        output_dir = Path("hvps/pyspice_sim/simulation_results")
        output_dir.mkdir(parents=True, exist_ok=True)
        
        print(f"\n📊 Generating Comprehensive Plots...")
        plots = plot_comprehensive_results(time, v_combined, v_filter_in, v_output, results, save_dir=output_dir)
        
        # 4. Generate working point analysis plot
        if wp_results:
            print(f"📊 Generating Working Point Analysis...")
            wp_plot = plot_working_point_analysis(wp_results, save_dir=output_dir)
        
        # 5. Save numerical results
        results_path = output_dir / "spear3_hvps_comprehensive_results.txt"
        with open(results_path, 'w') as f:
            f.write("SPEAR3 HVPS Comprehensive Simulation Results\n")
            f.write("="*60 + "\n\n")
            
            f.write("MAIN SIMULATION (Nominal Operating Point)\n")
            f.write("-"*50 + "\n")
            f.write("Real System Parameters:\n")
            f.write("  L1 + L2 = 0.6 H (series)\n")
            f.write("  C_filter = 8 µF\n")
            f.write("  R_isolation = 500 Ω\n")
            f.write("  Target: <1% P-P ripple\n\n")
            
            f.write("Performance Results:\n")
            for key, value in results.items():
                if isinstance(value, (int, float)):
                    f.write(f"  {key}: {value:.6f}\n")
                else:
                    f.write(f"  {key}: {value}\n")
            
            if wp_results:
                f.write(f"\n\nWORKING POINT ANALYSIS\n")
                f.write("-"*50 + "\n")
                f.write(f"{'Operating Point':<20} {'Voltage (kV)':<12} {'Current (A)':<12} {'Power (MW)':<12} {'Ripple (%)':<12} {'Target':<8}\n")
                f.write("-"*80 + "\n")
                for wp in wp_results:
                    status = "✅ PASS" if wp['target_achieved'] else "❌ FAIL"
                    f.write(f"{wp['name']:<20} {wp['voltage_kv']:<12.2f} {wp['current_a']:<12.1f} {wp['power_mw']:<12.2f} {wp['ripple_pp_pct']:<12.3f} {status:<8}\n")
        
        print(f"📄 Comprehensive results saved to: {results_path}")
        
        # 6. Print working point summary
        if wp_results:
            print(f"\n" + "="*80)
            print("WORKING POINT ANALYSIS SUMMARY")
            print("="*80)
            passed_points = sum(1 for wp in wp_results if wp['target_achieved'])
            print(f"Operating Points Tested: {len(wp_results)}")
            print(f"Points Meeting <1% Target: {passed_points}/{len(wp_results)}")
            print(f"Success Rate: {passed_points/len(wp_results)*100:.1f}%")
            
            for wp in wp_results:
                status = "✅" if wp['target_achieved'] else "❌"
                print(f"  {status} {wp['name']}: {wp['ripple_pp_pct']:.3f}% ripple")
        
        return results['target_achieved']
        
    else:
        print("❌ Main simulation failed!")
        return False


if __name__ == "__main__":
    success = main()
    print(f"\n{'='*80}")
    print(f"FINAL RESULT: {'✅ SUCCESS - <1% ripple target achieved!' if success else '❌ FAILED - Target not achieved'}")
    print(f"{'='*80}")
    sys.exit(0 if success else 1)
