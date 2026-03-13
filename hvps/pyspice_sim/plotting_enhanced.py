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
        print("✅ Added plotting methods to SimulationResult")
    except ImportError:
        print("⚠️ Could not add plotting methods to SimulationResult")


# Auto-add methods when module is imported
add_plot_methods_to_result()
