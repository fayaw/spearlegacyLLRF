"""
Example Simulation Scenarios
=============================

Runnable demonstrations of the SPEAR3 HVPS simulation package.

Scenarios:
    1. Normal steady-state operation at -77 kV / 22 A
    2. Full startup sequence with soft-start ramp
    3. Klystron arc fault with crowbar protection response
    4. Voltage setpoint step response
    5. Load change transient response
    6. Crowbar test and recovery

Usage:
    python -m hvps.hvps_sim.examples
    or:
    from hvps.hvps_sim.examples import run_all
    run_all()
"""

from hvps.hvps_sim.config import HVPSConfig
from hvps.hvps_sim.simulator import HVPSSimulator


def run_normal_operation(duration: float = 5.0, voltage_kv: float = 77.0,
                         plot: bool = True, save_prefix: str = ""):
    """Scenario 1: Normal steady-state operation.

    Demonstrates the HVPS operating at nominal -77 kV / 22 A,
    showing voltage regulation, ripple, and stable operation.

    Expected results:
        - Voltage: ~-77 kV with <1% ripple P-P
        - Current: ~22 A
        - Power: ~1.7 MW
        - Firing angle: ~45-55° (steady state)
    """
    print("=" * 60)
    print("Scenario 1: Normal Steady-State Operation")
    print("=" * 60)

    config = HVPSConfig()
    sim = HVPSSimulator(config, dt=200e-6)
    result = sim.run(duration=duration, voltage_kv=voltage_kv,
                     startup_delay=0.2)

    print(result.summary())

    if plot:
        try:
            result.plot(save_path=f"{save_prefix}normal_operation.png"
                        if save_prefix else None)
        except Exception as e:
            print(f"Plotting skipped: {e}")

    return result


def run_startup_sequence(target_kv: float = 77.0, duration: float = 12.0,
                         plot: bool = True, save_prefix: str = ""):
    """Scenario 2: Full startup sequence.

    Shows the complete startup from OFF through soft-start to regulation:
        1. System OFF (0 - 0.5 s)
        2. Energize and begin soft-start (0.5 s)
        3. Soft-start ramp (0.5 - 5.5 s, ~5 s ramp time)
        4. Steady-state regulation (5.5+ s)

    Expected results:
        - Smooth voltage ramp from 0 to -77 kV
        - Soft-start progress 0% → 100%
        - Firing angle ramps from 150° → ~50°
        - PLC registers ramp following τ ≈ 0.76 s filter
    """
    print("=" * 60)
    print("Scenario 2: Startup Sequence")
    print("=" * 60)

    config = HVPSConfig()
    sim = HVPSSimulator(config, dt=200e-6)
    result = sim.run_startup(target_kv=target_kv, duration=duration)

    print(result.summary())

    if plot:
        try:
            result.plot(save_path=f"{save_prefix}startup_sequence.png"
                        if save_prefix else None)
            from hvps.hvps_sim.plotting import plot_control_response
            plot_control_response(
                result,
                save_path=f"{save_prefix}startup_control.png"
                if save_prefix else None)
        except Exception as e:
            print(f"Plotting skipped: {e}")

    return result


def run_arc_fault(voltage_kv: float = 77.0, arc_time: float = 4.0,
                  arc_duration_us: float = 50.0, duration: float = 8.0,
                  plot: bool = True, save_prefix: str = ""):
    """Scenario 3: Klystron arc fault.

    Demonstrates the 4-layer protection response:
        1. Arc occurs at t=4.0 s during steady-state operation
        2. Arc detection triggers crowbar (~1 µs)
        3. Crowbar shorts output, thyristors turn off (4-8 ms)
        4. Cable inductors limit discharge current
        5. Arc energy should be <5 J
        6. System recovers after ~100 ms

    Expected results:
        - Rapid voltage drop to near zero during arc
        - Crowbar fires within 1 µs
        - Arc energy < 5 J (critical klystron protection)
        - System recovers and returns to regulation
    """
    print("=" * 60)
    print("Scenario 3: Klystron Arc Fault")
    print("=" * 60)

    config = HVPSConfig()
    sim = HVPSSimulator(config, dt=100e-6)
    result = sim.run_arc_fault(
        steady_state_time=3.0,
        arc_time=arc_time,
        arc_duration_us=arc_duration_us,
        voltage_kv=voltage_kv,
        total_duration=duration
    )

    print(result.summary())

    if plot:
        try:
            result.plot(save_path=f"{save_prefix}arc_fault.png"
                        if save_prefix else None)
            from hvps.hvps_sim.plotting import plot_protection_event
            plot_protection_event(
                result, event_time=arc_time, window_s=0.3,
                save_path=f"{save_prefix}arc_detail.png"
                if save_prefix else None)
        except Exception as e:
            print(f"Plotting skipped: {e}")

    return result


def run_step_response(v_initial_kv: float = 60.0,
                      v_final_kv: float = 77.0,
                      step_time: float = 5.0,
                      duration: float = 15.0,
                      plot: bool = True, save_prefix: str = ""):
    """Scenario 4: Voltage setpoint step response.

    Tests the control loop dynamics by stepping from 60 kV to 77 kV:
        1. System starts and regulates at 60 kV
        2. At t=5 s, setpoint changes to 77 kV
        3. PLC digital filter ramps reference (τ ≈ 0.76 s)
        4. System settles to new operating point

    Expected results:
        - Step response shows τ ≈ 0.76 s time constant
        - 63% of step in ~0.76 s
        - 95% of step in ~2.3 s
        - Voltage regulation maintained throughout transition
    """
    print("=" * 60)
    print("Scenario 4: Voltage Step Response")
    print("=" * 60)

    config = HVPSConfig()
    sim = HVPSSimulator(config, dt=200e-6)
    result = sim.run_step_response(
        v_initial_kv=v_initial_kv,
        v_final_kv=v_final_kv,
        step_time=step_time,
        duration=duration
    )

    print(result.summary())

    if plot:
        try:
            result.plot(save_path=f"{save_prefix}step_response.png"
                        if save_prefix else None)
            from hvps.hvps_sim.plotting import plot_control_response
            plot_control_response(
                result,
                save_path=f"{save_prefix}step_control.png"
                if save_prefix else None)
        except Exception as e:
            print(f"Plotting skipped: {e}")

    return result


def run_power_quality_analysis(voltage_kv: float = 77.0,
                               duration: float = 5.0,
                               plot: bool = True, save_prefix: str = ""):
    """Scenario 5: Output power quality analysis.

    Runs the system at steady state and analyzes:
        - Voltage ripple (P-P and RMS)
        - Current ripple
        - Voltage distribution
        - Ripple frequency spectrum (should show 720 Hz dominant)

    Expected results:
        - Ripple < 1% P-P, < 0.2% RMS
        - Dominant frequency at 720 Hz (12 × 60 Hz)
        - Good voltage stability
    """
    print("=" * 60)
    print("Scenario 5: Power Quality Analysis")
    print("=" * 60)

    config = HVPSConfig()
    sim = HVPSSimulator(config, dt=50e-6)  # Fine dt for ripple analysis
    result = sim.run(duration=duration, voltage_kv=voltage_kv,
                     startup_delay=0.2)

    print(result.summary())

    if plot:
        try:
            from hvps.hvps_sim.plotting import plot_power_quality
            plot_power_quality(
                result,
                save_path=f"{save_prefix}power_quality.png"
                if save_prefix else None)
        except Exception as e:
            print(f"Plotting skipped: {e}")

    return result


def run_crowbar_test(voltage_kv: float = 77.0,
                     crowbar_time: float = 3.0,
                     duration: float = 6.0,
                     plot: bool = True, save_prefix: str = ""):
    """Scenario 6: Forced crowbar test.

    Manually triggers the crowbar to verify protection response:
        1. System at steady state
        2. Crowbar manually fired at t=3.0 s
        3. Observe energy dump and recovery
        4. System should recover within 100 ms

    Expected results:
        - Rapid voltage discharge
        - Thyristors inhibited during crowbar event
        - Controlled recovery to regulation
    """
    print("=" * 60)
    print("Scenario 6: Crowbar Test")
    print("=" * 60)

    config = HVPSConfig()
    sim = HVPSSimulator(config, dt=100e-6)

    # Schedule a forced arc (which triggers crowbar)
    sim.schedule_event(crowbar_time, 'arc', {'duration_us': 10.0})

    result = sim.run(duration=duration, voltage_kv=voltage_kv,
                     startup_delay=0.2)

    print(result.summary())

    if plot:
        try:
            result.plot(save_path=f"{save_prefix}crowbar_test.png"
                        if save_prefix else None)
            from hvps.hvps_sim.plotting import plot_protection_event
            plot_protection_event(
                result, event_time=crowbar_time,
                save_path=f"{save_prefix}crowbar_detail.png"
                if save_prefix else None)
        except Exception as e:
            print(f"Plotting skipped: {e}")

    return result


def run_all(plot: bool = True, save_prefix: str = ""):
    """Run all realistic operational scenarios for SPEAR3 HVPS.
    
    Only includes scenarios that represent actual system operation:
    - Normal steady-state operation (primary operating mode)
    - Startup sequence (system initialization)
    - Arc fault response (actual protection scenario)
    
    Removed unrealistic test/analysis modes:
    - Step response (control system test)
    - Power quality analysis (diagnostic mode)
    - Crowbar test (protection system test)

    Parameters
    ----------
    plot : bool
        Whether to generate plots.
    save_prefix : str
        Prefix for saved plot files (e.g., 'results/').
    """
    print("\n" + "=" * 70)
    print("   SPEAR3 HVPS Legacy System Simulation — Operational Scenarios")
    print("=" * 70 + "\n")

    results = {}

    results['normal'] = run_normal_operation(plot=plot, save_prefix=save_prefix)
    print()

    results['startup'] = run_startup_sequence(plot=plot, save_prefix=save_prefix)
    print()

    results['arc'] = run_arc_fault(plot=plot, save_prefix=save_prefix)
    print()

    # Generate 4-channel monitoring signals plots for real system comparison
    if plot:
        print("🔍 Generating 4-Channel Waveform Buffer System monitoring signals...")
        print("   (These signals are available in the real SPEAR3 system for comparison)")
        print()
        
        try:
            from hvps.hvps_sim.plotting import plot_hvps_monitoring_signals
            
            # Generate monitoring signals for each scenario
            scenarios = [
                ("normal", results['normal'], "Normal Operation"),
                ("startup", results['startup'], "Startup Sequence"), 
                ("arc", results['arc'], "Arc Fault Response")
            ]
            
            for key, result, name in scenarios:
                if result is not None:
                    monitoring_path = f"{save_prefix}{key}_monitoring_signals.png" if save_prefix else None
                    plot_hvps_monitoring_signals(result, save_path=monitoring_path, zoom_duration=0.1)
                    print(f"✅ Generated monitoring signals: {name}")
            
            # Generate comprehensive overview using normal operation
            if results['normal'] is not None:
                overview_path = f"{save_prefix}hvps_monitoring_signals.png" if save_prefix else None
                plot_hvps_monitoring_signals(results['normal'], save_path=overview_path, zoom_duration=0.1)
                print(f"✅ Generated comprehensive monitoring signals overview")
                
        except Exception as e:
            print(f"⚠️  Monitoring signals generation skipped: {e}")
        
        print()

    print("=" * 70)
    print("   All realistic operational scenarios complete!")
    print("   4-Channel monitoring signals ready for real system comparison!")
    print("=" * 70)

    return results


# Quick test function
def quick_test():
    """Quick smoke test — run a short simulation to verify everything works."""
    print("HVPS Simulation Quick Test...")
    config = HVPSConfig()
    print(config.summary())
    print()

    sim = HVPSSimulator(config, dt=500e-6)
    result = sim.run(duration=2.0, voltage_kv=77.0, startup_delay=0.1)
    print(result.summary())
    print("\n✅ Quick test passed!")
    return result


if __name__ == "__main__":
    quick_test()
