"""
Visualization and Analysis Tools
=================================

Plotting utilities for HVPS simulation results.
Uses matplotlib for static plots.

Functions:
    plot_system_overview    -- Multi-panel system overview
    plot_waveforms          -- AC/DC waveform details
    plot_control_response   -- Control loop dynamics
    plot_protection_event   -- Arc/fault event detail
    plot_power_quality      -- Ripple and regulation analysis
    plot_plc_registers      -- PLC register time series
"""

import numpy as np
from typing import Optional, Tuple


def _check_matplotlib():
    """Ensure matplotlib is available."""
    try:
        import matplotlib
        return True
    except ImportError:
        print("WARNING: matplotlib not installed. Install with: pip install matplotlib")
        return False


def plot_system_overview(result, save_path: Optional[str] = None,
                         figsize: Tuple[float, float] = (14, 16)):
    """Generate a comprehensive multi-panel overview of the simulation.

    Panels:
        1. Output voltage (kV) with setpoint
        2. Output current (A)
        3. Output power (MW)
        4. SCR firing angle (degrees)
        5. Control signals (SIG HI, soft-start)
        6. Protection state

    Parameters
    ----------
    result : SimulationResult
        Simulation results to plot.
    save_path : str, optional
        File path to save the figure (e.g., 'overview.png').
    figsize : tuple
        Figure size (width, height) in inches.
    """
    if not _check_matplotlib():
        return None

    import matplotlib.pyplot as plt
    import matplotlib.gridspec as gridspec

    fig = plt.figure(figsize=figsize)
    fig.suptitle('SPEAR3 HVPS Simulation Overview', fontsize=14, fontweight='bold')
    gs = gridspec.GridSpec(6, 1, hspace=0.35)

    t = result.time

    # 1. Voltage
    ax1 = fig.add_subplot(gs[0])
    ax1.plot(t, result.voltage_kv, 'b-', linewidth=0.8, label='Output')
    ax1.plot(t, -np.abs(result.setpoint_kv), 'r--', linewidth=0.8,
             alpha=0.7, label='Setpoint')
    ax1.set_ylabel('Voltage (kV)')
    ax1.set_title('Output Voltage')
    ax1.legend(loc='upper right', fontsize=8)
    ax1.grid(True, alpha=0.3)

    # 2. Current
    ax2 = fig.add_subplot(gs[1], sharex=ax1)
    ax2.plot(t, result.current_a, 'g-', linewidth=0.8)
    ax2.set_ylabel('Current (A)')
    ax2.set_title('Output Current')
    ax2.grid(True, alpha=0.3)

    # 3. Power
    ax3 = fig.add_subplot(gs[2], sharex=ax1)
    ax3.plot(t, result.power_mw, 'm-', linewidth=0.8)
    ax3.set_ylabel('Power (MW)')
    ax3.set_title('Output Power')
    ax3.grid(True, alpha=0.3)

    # 4. Firing angle
    ax4 = fig.add_subplot(gs[3], sharex=ax1)
    ax4.plot(t, result.firing_angle_deg, 'orange', linewidth=0.8)
    ax4.set_ylabel('Angle (°)')
    ax4.set_title('SCR Firing Angle')
    ax4.set_ylim(0, 180)
    ax4.grid(True, alpha=0.3)

    # 5. Control signals
    ax5 = fig.add_subplot(gs[4], sharex=ax1)
    ax5.plot(t, result.sig_hi_v, 'c-', linewidth=0.8, label='SIG HI (V)')
    ax5_twin = ax5.twinx()
    ax5_twin.plot(t, result.soft_start_pct, 'k--', linewidth=0.8,
                  alpha=0.5, label='Soft-start %')
    ax5.set_ylabel('SIG HI (V)')
    ax5_twin.set_ylabel('Soft-start %')
    ax5.set_title('Control Signals')
    lines1, labels1 = ax5.get_legend_handles_labels()
    lines2, labels2 = ax5_twin.get_legend_handles_labels()
    ax5.legend(lines1 + lines2, labels1 + labels2, loc='upper right', fontsize=8)
    ax5.grid(True, alpha=0.3)

    # 6. Protection
    ax6 = fig.add_subplot(gs[5], sharex=ax1)
    # Color-code protection states
    state_colors = {
        'NORMAL': 0, 'ARC_DETECTED': 1, 'CROWBAR_FIRING': 2,
        'THYRISTOR_TURNOFF': 3, 'RECOVERING': 4, 'TRIPPED': 5, 'LOCKOUT': 6
    }
    state_values = np.array([state_colors.get(s, 0)
                              for s in result.protection_state])
    ax6.fill_between(t, state_values, alpha=0.3, color='red',
                      step='post', label='Protection State')
    ax6.plot(t, result.crowbar_active * 5, 'r-', linewidth=1.5,
             label='Crowbar Active')
    ax6.set_ylabel('State')
    ax6.set_xlabel('Time (s)')
    ax6.set_title('Protection System')
    ax6.legend(loc='upper right', fontsize=8)
    ax6.grid(True, alpha=0.3)
    ax6.set_yticks(list(state_colors.values()))
    ax6.set_yticklabels(list(state_colors.keys()), fontsize=7)

    plt.tight_layout()

    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"Saved: {save_path}")

    return fig


def plot_control_response(result, save_path: Optional[str] = None,
                          figsize: Tuple[float, float] = (14, 10)):
    """Plot control loop dynamics in detail.

    Panels:
        1. PLC registers N7:10 and N7:11
        2. SIG HI voltage and firing angle
        3. Voltage error (setpoint - measured)
        4. Regulator output
    """
    if not _check_matplotlib():
        return None

    import matplotlib.pyplot as plt

    fig, axes = plt.subplots(4, 1, figsize=figsize, sharex=True)
    fig.suptitle('HVPS Control Loop Response', fontsize=14, fontweight='bold')
    t = result.time

    # PLC registers
    ax = axes[0]
    ax.plot(t, result.n7_10_ref, 'b-', linewidth=0.8, label='N7:10 (Ref Out)')
    ax_twin = ax.twinx()
    ax_twin.plot(t, result.n7_11_phase, 'r-', linewidth=0.8,
                 label='N7:11 (Phase Out)')
    ax.set_ylabel('N7:10')
    ax_twin.set_ylabel('N7:11')
    ax.set_title('PLC Registers')
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax_twin.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    # SIG HI and firing angle
    ax = axes[1]
    ax.plot(t, result.sig_hi_v, 'c-', linewidth=0.8, label='SIG HI (V)')
    ax_twin = ax.twinx()
    ax_twin.plot(t, result.firing_angle_deg, 'orange', linewidth=0.8,
                 label='Firing Angle (°)')
    ax.set_ylabel('SIG HI (V)')
    ax_twin.set_ylabel('Angle (°)')
    ax.set_title('Firing Control')
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax_twin.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    # Voltage error
    ax = axes[2]
    v_error = -np.abs(result.setpoint_kv) - result.voltage_kv
    ax.plot(t, v_error, 'r-', linewidth=0.8)
    ax.set_ylabel('V Error (kV)')
    ax.set_title('Voltage Error (Setpoint - Measured)')
    ax.axhline(y=0, color='k', linestyle='--', linewidth=0.5)
    ax.grid(True, alpha=0.3)

    # Soft-start
    ax = axes[3]
    ax.plot(t, result.soft_start_pct, 'g-', linewidth=0.8,
            label='Soft-start Progress')
    ax.set_ylabel('Progress (%)')
    ax.set_xlabel('Time (s)')
    ax.set_title('Soft-Start Sequence')
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


def plot_protection_event(result, event_time: Optional[float] = None,
                          window_s: float = 0.5,
                          save_path: Optional[str] = None,
                          figsize: Tuple[float, float] = (14, 12)):
    """Plot detailed view of an arc/fault protection event.

    Centers on the event time and shows ±window_s seconds around it.

    Panels:
        1. Voltage during event
        2. Current during event
        3. Arc energy accumulation
        4. Crowbar and protection states
    """
    if not _check_matplotlib():
        return None

    import matplotlib.pyplot as plt

    # Find event time automatically if not specified
    if event_time is None:
        fault_indices = [i for i, s in enumerate(result.protection_state)
                         if s != 'NORMAL']
        if not fault_indices:
            print("No fault events found in simulation results.")
            return None
        event_time = result.time[fault_indices[0]]

    # Window around event
    t_start = max(0, event_time - window_s)
    t_end = min(result.duration, event_time + window_s)
    mask = (result.time >= t_start) & (result.time <= t_end)
    t = result.time[mask]

    fig, axes = plt.subplots(4, 1, figsize=figsize, sharex=True)
    fig.suptitle(f'Protection Event Detail (t={event_time:.3f} s)',
                 fontsize=14, fontweight='bold')

    # Voltage
    ax = axes[0]
    ax.plot(t, result.voltage_kv[mask], 'b-', linewidth=1.0)
    ax.axvline(x=event_time, color='r', linestyle='--', alpha=0.7,
               label='Event')
    ax.set_ylabel('Voltage (kV)')
    ax.set_title('Output Voltage During Event')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Current
    ax = axes[1]
    ax.plot(t, result.current_a[mask], 'g-', linewidth=1.0)
    ax.axvline(x=event_time, color='r', linestyle='--', alpha=0.7)
    ax.set_ylabel('Current (A)')
    ax.set_title('Output Current During Event')
    ax.grid(True, alpha=0.3)

    # Arc energy
    ax = axes[2]
    ax.plot(t, result.arc_energy_j[mask], 'r-', linewidth=1.0)
    ax.axhline(y=5.0, color='orange', linestyle='--', alpha=0.7,
               label='5 J Limit')
    ax.axhline(y=20.0, color='red', linestyle='--', alpha=0.7,
               label='20 J Limit')
    ax.set_ylabel('Energy (J)')
    ax.set_title('Arc Energy Accumulation')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Protection state
    ax = axes[3]
    state_colors = {
        'NORMAL': 0, 'ARC_DETECTED': 1, 'CROWBAR_FIRING': 2,
        'THYRISTOR_TURNOFF': 3, 'RECOVERING': 4, 'TRIPPED': 5
    }
    states = [result.protection_state[i] for i, m in enumerate(mask) if m]
    state_values = np.array([state_colors.get(s, 0) for s in states])
    ax.fill_between(t, state_values, alpha=0.4, color='red', step='post')
    ax.plot(t, result.crowbar_active[mask] * 4, 'r-', linewidth=2,
            label='Crowbar')
    ax.set_ylabel('State')
    ax.set_xlabel('Time (s)')
    ax.set_title('Protection System State')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


def plot_power_quality(result, save_path: Optional[str] = None,
                       figsize: Tuple[float, float] = (14, 8)):
    """Analyze output power quality — ripple, regulation, THD.

    Focuses on the steady-state portion of the simulation.
    """
    if not _check_matplotlib():
        return None

    import matplotlib.pyplot as plt

    # Use last 50% of data (assumed steady state)
    n = len(result.time)
    ss_start = n // 2
    t_ss = result.time[ss_start:]
    v_ss = result.voltage_kv[ss_start:]
    i_ss = result.current_a[ss_start:]

    fig, axes = plt.subplots(2, 2, figsize=figsize)
    fig.suptitle('HVPS Output Power Quality Analysis',
                 fontsize=14, fontweight='bold')

    # Voltage ripple
    ax = axes[0, 0]
    v_mean = np.mean(v_ss)
    v_detrended = v_ss - v_mean
    ax.plot(t_ss, v_detrended * 1000, 'b-', linewidth=0.5)
    ax.set_ylabel('Ripple (V)')
    ax.set_xlabel('Time (s)')
    ax.set_title(f'Voltage Ripple (mean={v_mean:.2f} kV)')
    v_pp = np.max(v_ss) - np.min(v_ss)
    v_rms = np.std(v_ss)
    if abs(v_mean) > 0.1:
        ax.text(0.02, 0.95,
                f'P-P: {v_pp*1000:.1f} V ({v_pp/abs(v_mean)*100:.3f}%)\n'
                f'RMS: {v_rms*1000:.1f} V ({v_rms/abs(v_mean)*100:.3f}%)',
                transform=ax.transAxes, fontsize=8, va='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax.grid(True, alpha=0.3)

    # Current ripple
    ax = axes[0, 1]
    i_mean = np.mean(i_ss)
    i_detrended = i_ss - i_mean
    ax.plot(t_ss, i_detrended, 'g-', linewidth=0.5)
    ax.set_ylabel('Ripple (A)')
    ax.set_xlabel('Time (s)')
    ax.set_title(f'Current Ripple (mean={i_mean:.2f} A)')
    ax.grid(True, alpha=0.3)

    # Voltage histogram
    ax = axes[1, 0]
    if len(v_ss) > 10:
        ax.hist(v_ss, bins=50, color='blue', alpha=0.7, edgecolor='black',
                linewidth=0.5)
    ax.set_xlabel('Voltage (kV)')
    ax.set_ylabel('Count')
    ax.set_title('Voltage Distribution')
    ax.grid(True, alpha=0.3)

    # FFT of voltage (ripple spectrum)
    ax = axes[1, 1]
    if len(v_ss) > 100 and result.dt > 0:
        fs = 1.0 / result.dt
        n_fft = len(v_ss)
        fft_vals = np.fft.rfft(v_detrended * 1000)  # In volts
        freqs = np.fft.rfftfreq(n_fft, d=result.dt)
        magnitude = 2.0 / n_fft * np.abs(fft_vals)
        # Plot up to 2000 Hz (above 12-pulse ripple at 720 Hz)
        mask = freqs <= 2000
        ax.plot(freqs[mask], magnitude[mask], 'b-', linewidth=0.5)
        ax.set_xlabel('Frequency (Hz)')
        ax.set_ylabel('Magnitude (V)')
        ax.set_title('Voltage Ripple Spectrum')
        # Mark expected harmonics
        for h, label in [(720, '12f'), (1440, '24f')]:
            ax.axvline(x=h, color='r', linestyle='--', alpha=0.3)
            ax.text(h, ax.get_ylim()[1] * 0.9, label, fontsize=7,
                    ha='center', color='red')
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


def plot_plc_registers(result, save_path: Optional[str] = None,
                       figsize: Tuple[float, float] = (14, 8)):
    """Plot PLC register values over time.

    Shows N7:10 (voltage reference) and N7:11 (phase angle) with
    their relationship to the analog outputs and firing angle.
    """
    if not _check_matplotlib():
        return None

    import matplotlib.pyplot as plt

    fig, axes = plt.subplots(3, 1, figsize=figsize, sharex=True)
    fig.suptitle('PLC Register Time Series', fontsize=14, fontweight='bold')
    t = result.time

    # N7:10 with output voltage overlay
    ax = axes[0]
    ax.plot(t, result.n7_10_ref, 'b-', linewidth=0.8, label='N7:10 (Ref Out)')
    ax_twin = ax.twinx()
    ax_twin.plot(t, np.abs(result.voltage_kv), 'r-', linewidth=0.5,
                 alpha=0.5, label='|V_out| (kV)')
    ax.set_ylabel('N7:10 (counts)')
    ax_twin.set_ylabel('|V_out| (kV)')
    ax.set_title('Voltage Reference vs Output')
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax_twin.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    # N7:11 with firing angle
    ax = axes[1]
    ax.plot(t, result.n7_11_phase, 'b-', linewidth=0.8,
            label='N7:11 (Phase Out)')
    ax_twin = ax.twinx()
    ax_twin.plot(t, result.firing_angle_deg, 'orange', linewidth=0.5,
                 alpha=0.7, label='Firing Angle (°)')
    ax.set_ylabel('N7:11 (counts)')
    ax_twin.set_ylabel('Angle (°)')
    ax.set_title('Phase Reference vs Firing Angle')
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax_twin.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    # Transfer function: N7:10 → N7:11
    ax = axes[2]
    # Expected: N7:11 = 0.3662 × N7:10 + 6000
    n7_10_range = np.linspace(0, 32000, 100)
    n7_11_expected = 0.3662 * n7_10_range + 6000
    ax.plot(result.n7_10_ref, result.n7_11_phase, 'b.', markersize=1,
            alpha=0.3, label='Actual')
    ax.plot(n7_10_range, n7_11_expected, 'r--', linewidth=1.0,
            label='Expected: 0.3662×N7:10+6000')
    ax.set_xlabel('N7:10 (Ref Out)')
    ax.set_ylabel('N7:11 (Phase Out)')
    ax.set_title('Phase Angle Transfer Function')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    if save_path:
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
    return fig


def plot_hvps_monitoring_signals(result, save_path: Optional[str] = None,
                                 figsize: Tuple[float, float] = (14, 12),
                                 zoom_duration: float = 0.1):
    """Plot the 4 HVPS monitoring signals from the Waveform Buffer System.
    
    These are the 4 constantly monitored HVPS signals as specified in the
    technical documentation:
    
    Channel 1: HVPS DC Voltage (0 to -90 kV DC)
    Channel 2: HVPS DC Current (0 to 30 A DC) 
    Channel 3: Inductor 2 (T2) Sawtooth voltage (firing circuit timing)
    Channel 4: Transformer 1 AC Phase Current (firing circuit health)
    
    Parameters
    ----------
    result : SimulationResult
        Simulation results containing the monitoring signals.
    save_path : str, optional
        File path to save the figure.
    figsize : tuple
        Figure size (width, height) in inches.
        
    Returns
    -------
    matplotlib.figure.Figure
        The created figure object.
    """
    if not _check_matplotlib():
        return None
        
    import matplotlib.pyplot as plt
    
    fig, axes = plt.subplots(4, 1, figsize=figsize, sharex=True)
    fig.suptitle('HVPS Monitoring Signals (Waveform Buffer System)', fontsize=16, fontweight='bold')
    
    t = result.time
    
    # Channel 1: HVPS Voltage Monitor
    axes[0].plot(t, result.hvps_voltage_monitor_kv, 'b-', linewidth=1.5, label='HVPS Voltage')
    axes[0].set_ylabel('Voltage (kV)', fontweight='bold')
    axes[0].set_title('Channel 1: HVPS Voltage Monitor (Regulation)', fontweight='bold')
    axes[0].grid(True, alpha=0.3)
    axes[0].legend()
    
    # Add statistics
    v_mean = np.mean(result.hvps_voltage_monitor_kv)
    v_std = np.std(result.hvps_voltage_monitor_kv)
    v_pp = np.max(result.hvps_voltage_monitor_kv) - np.min(result.hvps_voltage_monitor_kv)
    axes[0].text(0.02, 0.95, f'Mean: {v_mean:.1f} kV\nStd: {v_std:.2f} kV\nP-P: {v_pp:.2f} kV', 
                transform=axes[0].transAxes, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    # Channel 2: HVPS Current Monitor  
    axes[1].plot(t, result.hvps_current_monitor_a, 'r-', linewidth=1.5, label='HVPS Current')
    axes[1].set_ylabel('Current (A)', fontweight='bold')
    axes[1].set_title('Channel 2: HVPS Current Monitor (Load)', fontweight='bold')
    axes[1].grid(True, alpha=0.3)
    axes[1].legend()
    
    # Add statistics
    i_mean = np.mean(result.hvps_current_monitor_a)
    i_std = np.std(result.hvps_current_monitor_a)
    i_pp = np.max(result.hvps_current_monitor_a) - np.min(result.hvps_current_monitor_a)
    axes[1].text(0.02, 0.95, f'Mean: {i_mean:.1f} A\nStd: {i_std:.2f} A\nP-P: {i_pp:.2f} A', 
                transform=axes[1].transAxes, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    # Channel 3: Inductor 2 (T2) Sawtooth Voltage Monitor
    axes[2].plot(t, result.inductor2_sawtooth_monitor_kv, 'g-', linewidth=1.5, label='T2 Sawtooth')
    axes[2].set_ylabel('Voltage (kV)', fontweight='bold')
    axes[2].set_title('Channel 3: Inductor 2 (T2) Sawtooth - Firing Circuit Timing', fontweight='bold')
    axes[2].grid(True, alpha=0.3)
    axes[2].legend()
    
    # Add statistics
    t2_mean = np.mean(result.inductor2_sawtooth_monitor_kv)
    t2_std = np.std(result.inductor2_sawtooth_monitor_kv)
    t2_pp = np.max(result.inductor2_sawtooth_monitor_kv) - np.min(result.inductor2_sawtooth_monitor_kv)
    axes[2].text(0.02, 0.95, f'Mean: {t2_mean:.1f} kV\nStd: {t2_std:.2f} kV\nP-P: {t2_pp:.2f} kV', 
                transform=axes[2].transAxes, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    # Channel 4: Transformer 1 AC Phase Current Monitor
    axes[3].plot(t, result.transformer1_current_monitor_a, 'm-', linewidth=1.5, label='T1 AC Current')
    axes[3].set_ylabel('Current (A)', fontweight='bold')
    axes[3].set_xlabel('Time (s)', fontweight='bold')
    axes[3].set_title('Channel 4: Transformer 1 AC Phase Current - Firing Circuit Health', fontweight='bold')
    axes[3].grid(True, alpha=0.3)
    axes[3].legend()
    
    # Add statistics
    t1_mean = np.mean(result.transformer1_current_monitor_a)
    t1_std = np.std(result.transformer1_current_monitor_a)
    t1_pp = np.max(result.transformer1_current_monitor_a) - np.min(result.transformer1_current_monitor_a)
    axes[3].text(0.02, 0.95, f'Mean: {t1_mean:.1f} A\nStd: {t1_std:.2f} A\nP-P: {t1_pp:.2f} A', 
                transform=axes[3].transAxes, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    
    # Add zoom-in subplot for final stabilized period if requested
    if zoom_duration > 0 and len(t) > 0:
        # Find the last zoom_duration seconds of data
        t_max = t[-1]
        zoom_start = max(0, t_max - zoom_duration)
        zoom_mask = t >= zoom_start
        
        if np.sum(zoom_mask) > 10:  # Only if we have enough data points
            # Create a second figure for zoom-in view
            fig_zoom, axes_zoom = plt.subplots(4, 1, figsize=(14, 12), sharex=True)
            fig_zoom.suptitle(f'HVPS Monitoring Signals - Final {zoom_duration*1000:.0f} ms (Stabilized)', 
                             fontsize=16, fontweight='bold')
            
            t_zoom = t[zoom_mask]
            
            # Channel 1 zoom
            axes_zoom[0].plot(t_zoom, result.hvps_voltage_monitor_kv[zoom_mask], 'b-', linewidth=1.5)
            axes_zoom[0].set_ylabel('Voltage (kV)', fontweight='bold')
            axes_zoom[0].set_title('Channel 1: HVPS Voltage (Stabilized)', fontweight='bold')
            axes_zoom[0].grid(True, alpha=0.3)
            
            # Channel 2 zoom
            axes_zoom[1].plot(t_zoom, result.hvps_current_monitor_a[zoom_mask], 'r-', linewidth=1.5)
            axes_zoom[1].set_ylabel('Current (A)', fontweight='bold')
            axes_zoom[1].set_title('Channel 2: HVPS Current (Stabilized)', fontweight='bold')
            axes_zoom[1].grid(True, alpha=0.3)
            
            # Channel 3 zoom
            axes_zoom[2].plot(t_zoom, result.inductor2_sawtooth_monitor_kv[zoom_mask], 'g-', linewidth=1.5)
            axes_zoom[2].set_ylabel('Voltage (kV)', fontweight='bold')
            axes_zoom[2].set_title('Channel 3: T2 Sawtooth (Stabilized)', fontweight='bold')
            axes_zoom[2].grid(True, alpha=0.3)
            
            # Channel 4 zoom
            axes_zoom[3].plot(t_zoom, result.transformer1_current_monitor_a[zoom_mask], 'm-', linewidth=1.5)
            axes_zoom[3].set_ylabel('Current (A)', fontweight='bold')
            axes_zoom[3].set_xlabel('Time (s)', fontweight='bold')
            axes_zoom[3].set_title('Channel 4: T1 AC Current (Stabilized)', fontweight='bold')
            axes_zoom[3].grid(True, alpha=0.3)
            
            plt.tight_layout()
            if save_path:
                zoom_path = save_path.replace('.png', '_zoom.png')
                fig_zoom.savefig(zoom_path, dpi=150, bbox_inches='tight')
                print(f"Saved zoom plot: {zoom_path}")

    # Make sure we're working with the main figure for the full plot
    plt.figure(fig.number)
    plt.tight_layout()
    if save_path:
        fig.savefig(save_path, dpi=150, bbox_inches='tight')
        print(f"Saved full plot: {save_path}")
    return fig
