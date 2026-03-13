"""
Enhanced Plotting System for SPEAR3 HVPS PySpice Simulation
===========================================================

Plotting functions that match the original hvps_sim visualization style
with system overview plots showing startup behavior and control dynamics.

Functions:
    plot_system_overview    -- Multi-panel system overview (matches original)
    plot_startup_sequence   -- Detailed startup behavior analysis
    plot_control_response   -- Control system dynamics
    plot_ripple_analysis    -- Ripple and filtering performance
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from typing import Optional, Tuple
from pathlib import Path


def plot_system_overview(result, save_path: Optional[str] = None,
                        figsize: Tuple[float, float] = (14, 16)):
    """Generate a comprehensive multi-panel overview matching original hvps_sim style.

    Panels:
        1. Output voltage (kV) with setpoint
        2. Output current (A)
        3. Output power (MW)
        4. SCR firing angle (degrees)
        5. Control signals (SIG HI, soft-start)
        6. System mode and ripple

    Parameters
    ----------
    result : SimulationResult
        Enhanced simulation results to plot.
    save_path : str, optional
        File path to save the figure (e.g., 'system_overview.png').
    figsize : tuple
        Figure size (width, height) in inches.
    """
    fig = plt.figure(figsize=figsize)
    fig.suptitle('SPEAR3 HVPS Enhanced System Simulation Overview', 
                 fontsize=14, fontweight='bold')
    gs = gridspec.GridSpec(6, 1, hspace=0.35)

    t = result.time

    # 1. Voltage with setpoint
    ax1 = fig.add_subplot(gs[0])
    ax1.plot(t, result.voltage_kv, 'b-', linewidth=0.8, label='Output')
    ax1.plot(t, result.setpoint_kv, 'r--', linewidth=0.8,
             alpha=0.7, label='Setpoint')
    ax1.set_ylabel('Voltage (kV)')
    ax1.set_title('Output Voltage')
    ax1.legend(loc='upper right', fontsize=8)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-85, 5)  # Updated for correct voltage range
    
    # Add startup indicator
    startup_indices = [i for i, mode in enumerate(result.mode) if mode == 'STARTUP']
    if startup_indices:
        ax1.axvspan(t[startup_indices[0]], t[startup_indices[-1]], 
                   alpha=0.2, color='yellow', label='Startup')

    # 2. Current
    ax2 = fig.add_subplot(gs[1], sharex=ax1)
    ax2.plot(t, result.current_a, 'g-', linewidth=0.8)
    ax2.set_ylabel('Current (A)')
    ax2.set_title('Output Current')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(-2, 32)  # Updated for correct current range

    # 3. Power
    ax3 = fig.add_subplot(gs[2], sharex=ax1)
    ax3.plot(t, result.power_mw, 'm-', linewidth=0.8)
    ax3.set_ylabel('Power (MW)')
    ax3.set_title('Output Power')
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(-0.1, 2.0)  # Updated for correct power range

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
                  alpha=0.7, label='Soft Start (%)')
    ax5.set_ylabel('SIG HI (V)', color='c')
    ax5_twin.set_ylabel('Soft Start (%)', color='k')
    ax5.set_title('Control Signals')
    ax5.grid(True, alpha=0.3)
    ax5.legend(loc='upper left', fontsize=8)
    ax5_twin.legend(loc='upper right', fontsize=8)

    # 6. System mode and ripple
    ax6 = fig.add_subplot(gs[5], sharex=ax1)
    
    # Plot ripple percentage
    ax6.plot(t, result.ripple_pp_pct, 'r-', linewidth=0.8, label='Ripple P-P (%)')
    ax6.axhline(y=1.0, color='red', linestyle=':', alpha=0.7, label='1% Target')
    ax6.set_ylabel('Ripple (%)', color='r')
    ax6.set_xlabel('Time (s)')
    ax6.set_title('System Status')
    ax6.grid(True, alpha=0.3)
    ax6.legend(loc='upper right', fontsize=8)
    
    # Add mode indicators as colored background
    mode_colors = {'OFF': 'gray', 'STARTUP': 'yellow', 'REGULATING': 'lightgreen', 
                   'FAULT': 'red', 'SHUTDOWN': 'orange'}
    
    current_mode = None
    start_idx = 0
    
    for i, mode in enumerate(result.mode + ['END']):  # Add END to close last segment
        if mode != current_mode:
            if current_mode is not None:
                color = mode_colors.get(current_mode, 'white')
                ax6.axvspan(t[start_idx], t[i-1] if i > 0 else t[-1], 
                           alpha=0.1, color=color)
            current_mode = mode
            start_idx = i

    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"📊 System overview saved to: {save_path}")
    
    return fig


def plot_startup_sequence(result, save_path: Optional[str] = None,
                         figsize: Tuple[float, float] = (12, 10)):
    """Plot detailed startup sequence analysis.
    
    Shows the ramp-up behavior from 0 to final output with control dynamics.
    """
    fig, axes = plt.subplots(2, 2, figsize=figsize)
    fig.suptitle('SPEAR3 HVPS Startup Sequence Analysis', fontsize=14, fontweight='bold')
    
    t = result.time
    
    # Find startup period
    startup_indices = [i for i, mode in enumerate(result.mode) if mode in ['STARTUP', 'REGULATING']]
    if startup_indices:
        t_start = t[startup_indices[0]]
        t_end = min(t[startup_indices[0]] + 12.0, t[-1])  # First 12 seconds of operation
        mask = (t >= t_start) & (t <= t_end)
        t_zoom = t[mask]
        
        # 1. Voltage ramp-up
        axes[0,0].plot(t_zoom, result.voltage_kv[mask], 'b-', linewidth=2, label='Output')
        axes[0,0].plot(t_zoom, result.setpoint_kv[mask], 'r--', linewidth=1.5, 
                      alpha=0.8, label='Setpoint')
        axes[0,0].set_ylabel('Voltage (kV)')
        axes[0,0].set_title('Voltage Ramp-Up')
        axes[0,0].legend()
        axes[0,0].grid(True, alpha=0.3)
        
        # 2. Control response
        axes[0,1].plot(t_zoom, result.firing_angle_deg[mask], 'orange', linewidth=2)
        axes[0,1].set_ylabel('Firing Angle (°)')
        axes[0,1].set_title('Control Response')
        axes[0,1].grid(True, alpha=0.3)
        
        # 3. Soft-start envelope
        axes[1,0].plot(t_zoom, result.soft_start_pct[mask], 'k-', linewidth=2)
        axes[1,0].set_ylabel('Soft Start (%)')
        axes[1,0].set_xlabel('Time (s)')
        axes[1,0].set_title('Soft-Start Envelope')
        axes[1,0].grid(True, alpha=0.3)
        
        # 4. Power ramp
        axes[1,1].plot(t_zoom, result.power_mw[mask], 'm-', linewidth=2)
        axes[1,1].set_ylabel('Power (MW)')
        axes[1,1].set_xlabel('Time (s)')
        axes[1,1].set_title('Power Ramp-Up')
        axes[1,1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"📊 Startup sequence saved to: {save_path}")
    
    return fig


def plot_control_response(result, save_path: Optional[str] = None,
                         figsize: Tuple[float, float] = (12, 8)):
    """Plot control system dynamics and response characteristics."""
    
    fig, axes = plt.subplots(2, 2, figsize=figsize)
    fig.suptitle('SPEAR3 HVPS Control System Response', fontsize=14, fontweight='bold')
    
    t = result.time
    
    # 1. Voltage regulation
    axes[0,0].plot(t, result.voltage_kv, 'b-', linewidth=1, label='Output')
    axes[0,0].plot(t, result.setpoint_kv, 'r--', linewidth=1, alpha=0.7, label='Setpoint')
    axes[0,0].set_ylabel('Voltage (kV)')
    axes[0,0].set_title('Voltage Regulation')
    axes[0,0].legend()
    axes[0,0].grid(True, alpha=0.3)
    
    # 2. Control effort (firing angle)
    axes[0,1].plot(t, result.firing_angle_deg, 'orange', linewidth=1)
    axes[0,1].set_ylabel('Firing Angle (°)')
    axes[0,1].set_title('Control Effort')
    axes[0,1].grid(True, alpha=0.3)
    
    # 3. Control signals
    axes[1,0].plot(t, result.sig_hi_v, 'c-', linewidth=1, label='SIG HI')
    axes[1,0].set_ylabel('SIG HI (V)')
    axes[1,0].set_xlabel('Time (s)')
    axes[1,0].set_title('Control Signals')
    axes[1,0].legend()
    axes[1,0].grid(True, alpha=0.3)
    
    # 4. Regulation error (if steady-state exists)
    steady_start = int(0.7 * len(t))
    if steady_start < len(t):
        error = result.setpoint_kv[steady_start:] - result.voltage_kv[steady_start:]
        axes[1,1].plot(t[steady_start:], error, 'r-', linewidth=1)
        axes[1,1].set_ylabel('Error (kV)')
        axes[1,1].set_xlabel('Time (s)')
        axes[1,1].set_title('Steady-State Regulation Error')
        axes[1,1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"📊 Control response saved to: {save_path}")
    
    return fig


def plot_ripple_analysis(result, save_path: Optional[str] = None,
                        figsize: Tuple[float, float] = (12, 8)):
    """Plot ripple and filtering performance analysis."""
    
    fig, axes = plt.subplots(2, 2, figsize=figsize)
    fig.suptitle('SPEAR3 HVPS Ripple and Filtering Analysis', fontsize=14, fontweight='bold')
    
    t = result.time
    
    # 1. Ripple percentage over time
    axes[0,0].plot(t, result.ripple_pp_pct, 'r-', linewidth=1, label='P-P Ripple')
    axes[0,0].plot(t, result.ripple_rms_pct, 'b-', linewidth=1, label='RMS Ripple')
    axes[0,0].axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='1% P-P Target')
    axes[0,0].axhline(y=0.2, color='blue', linestyle='--', alpha=0.7, label='0.2% RMS Target')
    axes[0,0].set_ylabel('Ripple (%)')
    axes[0,0].set_title('Ripple Performance')
    axes[0,0].legend()
    axes[0,0].grid(True, alpha=0.3)
    
    # 2. Filtering stages comparison
    axes[0,1].plot(t, result.v_unfiltered_kv, 'r-', linewidth=1, alpha=0.7, label='Unfiltered')
    axes[0,1].plot(t, result.v_filtered_kv, 'b-', linewidth=1, label='Filtered')
    axes[0,1].plot(t, result.voltage_kv, 'g-', linewidth=2, label='Output')
    axes[0,1].set_ylabel('Voltage (kV)')
    axes[0,1].set_title('Filtering Stages')
    axes[0,1].legend()
    axes[0,1].grid(True, alpha=0.3)
    
    # 3. Steady-state ripple detail (last 2 seconds)
    if len(t) > 4000:  # Ensure we have enough data
        detail_start = -4000  # Last 2 seconds at 0.5ms timestep
        t_detail = t[detail_start:]
        v_detail = result.voltage_kv[detail_start:]
        
        axes[1,0].plot(t_detail, v_detail, 'b-', linewidth=1)
        v_mean = np.mean(v_detail)
        axes[1,0].axhline(y=v_mean, color='r', linestyle='--', alpha=0.7, 
                         label=f'Mean: {v_mean:.2f} kV')
        axes[1,0].set_ylabel('Voltage (kV)')
        axes[1,0].set_xlabel('Time (s)')
        axes[1,0].set_title('Steady-State Ripple Detail')
        axes[1,0].legend()
        axes[1,0].grid(True, alpha=0.3)
    
    # 4. Ripple statistics
    if len(result.ripple_pp_pct) > 0:
        steady_start = int(0.8 * len(result.ripple_pp_pct))
        steady_ripple = result.ripple_pp_pct[steady_start:]
        
        if len(steady_ripple) > 0:
            ripple_mean = np.mean(steady_ripple)
            ripple_std = np.std(steady_ripple)
            ripple_max = np.max(steady_ripple)
            
            axes[1,1].hist(steady_ripple, bins=30, alpha=0.7, color='blue', edgecolor='black')
            axes[1,1].axvline(x=ripple_mean, color='red', linestyle='--', 
                             label=f'Mean: {ripple_mean:.3f}%')
            axes[1,1].axvline(x=1.0, color='orange', linestyle='--', 
                             label='1% Target')
            axes[1,1].set_xlabel('Ripple (%)')
            axes[1,1].set_ylabel('Frequency')
            axes[1,1].set_title('Steady-State Ripple Distribution')
            axes[1,1].legend()
            axes[1,1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    if save_path:
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        print(f"📊 Ripple analysis saved to: {save_path}")
    
    return fig


def add_plot_methods_to_result():
    """Add plotting methods to SimulationResult class."""
    
    def plot_system_overview_method(self, save_path: Optional[str] = None):
        """Plot system overview (method version)."""
        return plot_system_overview(self, save_path)
    
    def plot_startup_sequence_method(self, save_path: Optional[str] = None):
        """Plot startup sequence (method version)."""
        return plot_startup_sequence(self, save_path)
    
    def plot_control_response_method(self, save_path: Optional[str] = None):
        """Plot control response (method version)."""
        return plot_control_response(self, save_path)
    
    def plot_ripple_analysis_method(self, save_path: Optional[str] = None):
        """Plot ripple analysis (method version)."""
        return plot_ripple_analysis(self, save_path)
    
    # Import the SimulationResult class and add methods
    try:
        from hvps.pyspice_sim.spear3_hvps_system_simulator import SimulationResult
        SimulationResult.plot_system_overview = plot_system_overview_method
        SimulationResult.plot_startup_sequence = plot_startup_sequence_method
        SimulationResult.plot_control_response = plot_control_response_method
        SimulationResult.plot_ripple_analysis = plot_ripple_analysis_method
        SimulationResult.plot_monitor_channels = plot_monitor_channels_method
        SimulationResult.plot_monitor_channels_zoom = plot_monitor_channels_zoom_method
        SimulationResult.plot_all_signals = plot_all_signals_method
        print("✅ Added plotting methods to SimulationResult (including monitor channels)")
    except ImportError:
        print("⚠️ Could not add plotting methods to SimulationResult")


def plot_monitor_channels(result, filename='monitor_channels.png', title_prefix='Enhanced PySpice'):
    """Plot the 4 HVPS monitor channels matching original hvps_sim style."""
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle(f'{title_prefix} - HVPS Monitor Channels (4-Channel Waveform Buffer)', 
                 fontsize=16, fontweight='bold')
    
    # Channel 1: HVPS DC Voltage Monitor
    ax1 = axes[0, 0]
    ax1.plot(result.time, result.hvps_voltage_monitor_kv, 'b-', linewidth=2, label='HVPS Voltage')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Voltage (kV)')
    ax1.set_title('Channel 1: HVPS DC Voltage Monitor\n(0 to -90 kV DC, Voltage Divider 1000:1)', fontweight='bold')
    ax1.grid(True, alpha=0.3)
    ax1.legend()
    ax1.set_ylim(-85, 5)
    
    # Channel 2: HVPS DC Current Monitor
    ax2 = axes[0, 1]
    ax2.plot(result.time, result.hvps_current_monitor_a, 'r-', linewidth=2, label='HVPS Current')
    ax2.set_xlabel('Time (s)')
    ax2.set_ylabel('Current (A)')
    ax2.set_title('Channel 2: HVPS DC Current Monitor\n(0 to 30 A DC, Danfysik DC-CT Sensor)', fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.legend()
    ax2.set_ylim(-2, 32)
    
    # Channel 3: Inductor 2 (T2) Sawtooth Monitor
    ax3 = axes[1, 0]
    ax3.plot(result.time, result.inductor2_sawtooth_monitor_kv, 'g-', linewidth=2, label='T2 Sawtooth')
    ax3.set_xlabel('Time (s)')
    ax3.set_ylabel('Voltage (kV)')
    ax3.set_title('Channel 3: Inductor 2 (T2) Sawtooth Voltage\n(Firing Circuit Timing Diagnosis)', fontweight='bold')
    ax3.grid(True, alpha=0.3)
    ax3.legend()
    ax3.set_ylim(-8, 8)
    
    # Channel 4: Transformer 1 AC Phase Current Monitor
    ax4 = axes[1, 1]
    ax4.plot(result.time, result.transformer1_current_monitor_a, 'm-', linewidth=2, label='T1 AC Current')
    ax4.set_xlabel('Time (s)')
    ax4.set_ylabel('Current (A)')
    ax4.set_title('Channel 4: Transformer 1 AC Phase Current\n(Firing Circuit Health Monitor)', fontweight='bold')
    ax4.grid(True, alpha=0.3)
    ax4.legend()
    ax4.set_ylim(-20, 20)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"📊 Monitor channels plot saved to: {filename}")


def plot_monitor_channels_zoom(result, filename='monitor_channels_zoom.png', title_prefix='Enhanced PySpice', zoom_duration=0.1):
    """Plot the 4 HVPS monitor channels with zoom to last 100ms for detailed view."""
    
    # Find the time range for the last 100ms (or specified zoom_duration)
    max_time = result.time[-1]
    start_time = max_time - zoom_duration
    
    # Find indices for the zoom window
    zoom_indices = (result.time >= start_time) & (result.time <= max_time)
    time_zoom = result.time[zoom_indices]
    
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle(f'{title_prefix} - Monitor Channels Detail View (Last {zoom_duration*1000:.0f}ms)', 
                 fontsize=16, fontweight='bold')
    
    # Channel 1: HVPS DC Voltage Monitor (zoomed)
    ax1 = axes[0, 0]
    voltage_zoom = result.hvps_voltage_monitor_kv[zoom_indices]
    ax1.plot(time_zoom, voltage_zoom, 'b-', linewidth=2, label='HVPS Voltage')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Voltage (kV)')
    ax1.set_title('Channel 1: HVPS DC Voltage (Detail)\nRipple and Regulation Detail', fontweight='bold')
    ax1.grid(True, alpha=0.3)
    ax1.legend()
    # Auto-scale for better detail view
    v_min, v_max = voltage_zoom.min(), voltage_zoom.max()
    v_range = v_max - v_min
    ax1.set_ylim(v_min - 0.1*v_range, v_max + 0.1*v_range)
    
    # Channel 2: HVPS DC Current Monitor (zoomed)
    ax2 = axes[0, 1]
    current_zoom = result.hvps_current_monitor_a[zoom_indices]
    ax2.plot(time_zoom, current_zoom, 'r-', linewidth=2, label='HVPS Current')
    ax2.set_xlabel('Time (s)')
    ax2.set_ylabel('Current (A)')
    ax2.set_title('Channel 2: HVPS DC Current (Detail)\nCurrent Ripple Detail', fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.legend()
    # Auto-scale for better detail view
    i_min, i_max = current_zoom.min(), current_zoom.max()
    i_range = i_max - i_min
    ax2.set_ylim(i_min - 0.1*i_range, i_max + 0.1*i_range)
    
    # Channel 3: Inductor 2 (T2) Sawtooth Monitor (zoomed)
    ax3 = axes[1, 0]
    sawtooth_zoom = result.inductor2_sawtooth_monitor_kv[zoom_indices]
    ax3.plot(time_zoom, sawtooth_zoom, 'g-', linewidth=2, label='T2 Sawtooth')
    ax3.set_xlabel('Time (s)')
    ax3.set_ylabel('Voltage (kV)')
    ax3.set_title('Channel 3: T2 Sawtooth (Detail)\nFiring Circuit Timing', fontweight='bold')
    ax3.grid(True, alpha=0.3)
    ax3.legend()
    ax3.set_ylim(-8, 8)
    
    # Channel 4: Transformer 1 AC Phase Current Monitor (zoomed)
    ax4 = axes[1, 1]
    ac_current_zoom = result.transformer1_current_monitor_a[zoom_indices]
    ax4.plot(time_zoom, ac_current_zoom, 'm-', linewidth=2, label='T1 AC Current')
    ax4.set_xlabel('Time (s)')
    ax4.set_ylabel('Current (A)')
    ax4.set_title('Channel 4: T1 AC Current (Detail)\n12-Pulse Pattern Detail', fontweight='bold')
    ax4.grid(True, alpha=0.3)
    ax4.legend()
    ax4.set_ylim(-20, 20)
    
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"📊 Monitor channels zoom plot saved to: {filename}")


def plot_all_signals(result, filename='complete_system_overview.png', title_prefix='Enhanced PySpice'):
    """Plot comprehensive system overview with all signals including monitor channels."""
    
    fig, axes = plt.subplots(3, 3, figsize=(20, 16))
    fig.suptitle(f'{title_prefix} - Complete HVPS System Overview with Monitor Channels', 
                 fontsize=18, fontweight='bold')
    
    # Main system signals (top row)
    # Voltage
    ax1 = axes[0, 0]
    ax1.plot(result.time, result.voltage_kv, 'b-', linewidth=2, label='HVPS Output')
    ax1.set_xlabel('Time (s)')
    ax1.set_ylabel('Voltage (kV)')
    ax1.set_title('HVPS Output Voltage', fontweight='bold')
    ax1.grid(True, alpha=0.3)
    ax1.legend()
    ax1.set_ylim(-85, 5)
    
    # Current
    ax2 = axes[0, 1]
    ax2.plot(result.time, result.current_a, 'r-', linewidth=2, label='HVPS Current')
    ax2.set_xlabel('Time (s)')
    ax2.set_ylabel('Current (A)')
    ax2.set_title('HVPS Output Current', fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.legend()
    ax2.set_ylim(-2, 32)
    
    # Power
    ax3 = axes[0, 2]
    ax3.plot(result.time, result.power_mw, 'purple', linewidth=2, label='HVPS Power')
    ax3.set_xlabel('Time (s)')
    ax3.set_ylabel('Power (MW)')
    ax3.set_title('HVPS Output Power', fontweight='bold')
    ax3.grid(True, alpha=0.3)
    ax3.legend()
    ax3.set_ylim(-0.1, 2.0)
    
    # Control signals (middle row)
    # Firing angle
    ax4 = axes[1, 0]
    ax4.plot(result.time, result.firing_angle_deg, 'orange', linewidth=2, label='Firing Angle')
    ax4.set_xlabel('Time (s)')
    ax4.set_ylabel('Angle (degrees)')
    ax4.set_title('SCR Firing Angle Control', fontweight='bold')
    ax4.grid(True, alpha=0.3)
    ax4.legend()
    ax4.set_ylim(25, 155)
    
    # Ripple performance
    ax5 = axes[1, 1]
    ax5.plot(result.time, result.ripple_pp_pct, 'brown', linewidth=2, label='Ripple P-P')
    ax5.axhline(y=1.0, color='red', linestyle='--', alpha=0.7, label='1% Target')
    ax5.set_xlabel('Time (s)')
    ax5.set_ylabel('Ripple (%)')
    ax5.set_title('Ripple Performance', fontweight='bold')
    ax5.grid(True, alpha=0.3)
    ax5.legend()
    ax5.set_ylim(0, 2)
    
    # System mode
    ax6 = axes[1, 2]
    mode_colors = {'OFF': 0, 'STARTUP': 1, 'REGULATING': 2}
    mode_values = [mode_colors.get(mode, 0) for mode in result.mode]
    ax6.plot(result.time, mode_values, 'k-', linewidth=3, label='System Mode')
    ax6.set_xlabel('Time (s)')
    ax6.set_ylabel('Mode')
    ax6.set_title('System Operating Mode', fontweight='bold')
    ax6.set_yticks([0, 1, 2])
    ax6.set_yticklabels(['OFF', 'STARTUP', 'REGULATING'])
    ax6.grid(True, alpha=0.3)
    ax6.legend()
    
    # Monitor channels (bottom row)
    # Channel 3: T2 Sawtooth (most interesting)
    ax7 = axes[2, 0]
    ax7.plot(result.time, result.inductor2_sawtooth_monitor_kv, 'g-', linewidth=2, label='T2 Sawtooth')
    ax7.set_xlabel('Time (s)')
    ax7.set_ylabel('Voltage (kV)')
    ax7.set_title('Monitor Ch3: T2 Sawtooth', fontweight='bold')
    ax7.grid(True, alpha=0.3)
    ax7.legend()
    ax7.set_ylim(-8, 8)
    
    # Channel 4: T1 AC Current (most interesting)
    ax8 = axes[2, 1]
    ax8.plot(result.time, result.transformer1_current_monitor_a, 'm-', linewidth=2, label='T1 AC Current')
    ax8.set_xlabel('Time (s)')
    ax8.set_ylabel('Current (A)')
    ax8.set_title('Monitor Ch4: T1 AC Current', fontweight='bold')
    ax8.grid(True, alpha=0.3)
    ax8.legend()
    ax8.set_ylim(-20, 20)
    
    # Performance summary
    ax9 = axes[2, 2]
    ax9.text(0.1, 0.8, f'Final Voltage: {result.voltage_kv[-1]:.2f} kV', fontsize=12, fontweight='bold')
    ax9.text(0.1, 0.7, f'Final Current: {result.current_a[-1]:.2f} A', fontsize=12, fontweight='bold')
    ax9.text(0.1, 0.6, f'Final Power: {result.power_mw[-1]:.3f} MW', fontsize=12, fontweight='bold')
    ax9.text(0.1, 0.5, f'Final Ripple: {result.ripple_pp_pct[-1]:.3f}%', fontsize=12, fontweight='bold')
    ax9.text(0.1, 0.4, f'Target Achievement:', fontsize=12, fontweight='bold')
    voltage_status = '✅ PASS' if abs(result.voltage_kv[-1]) > 75 else '❌ FAIL'
    ripple_status = '✅ PASS' if result.ripple_pp_pct[-1] < 1.0 else '❌ FAIL'
    ax9.text(0.1, 0.3, f'Voltage (>75kV): {voltage_status}', fontsize=11)
    ax9.text(0.1, 0.2, f'Ripple (<1%): {ripple_status}', fontsize=11)
    ax9.set_xlim(0, 1)
    ax9.set_ylim(0, 1)
    ax9.set_title('Performance Summary', fontweight='bold')
    ax9.axis('off')
    
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"📊 Complete system overview saved to: {filename}")


# Method wrappers for SimulationResult class
def plot_monitor_channels_method(self, filename='monitor_channels.png', title_prefix='Enhanced PySpice'):
    """Plot monitor channels method for SimulationResult."""
    return plot_monitor_channels(self, filename, title_prefix)

def plot_monitor_channels_zoom_method(self, filename='monitor_channels_zoom.png', title_prefix='Enhanced PySpice', zoom_duration=0.1):
    """Plot monitor channels zoom method for SimulationResult."""
    return plot_monitor_channels_zoom(self, filename, title_prefix, zoom_duration)

def plot_all_signals_method(self, filename='complete_system_overview.png', title_prefix='Enhanced PySpice'):
    """Plot all signals method for SimulationResult."""
    return plot_all_signals(self, filename, title_prefix)





# Auto-add methods when module is imported
add_plot_methods_to_result()
