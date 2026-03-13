"""
12-Pulse Thyristor Physics Models

This module implements the thyristor gating and commutation physics to generate
the square-wave current patterns observed in the real SPEAR3 HVPS system.

Real System Characteristics:
- 12-pulse thyristor phase-controlled rectifier
- Two 6-pulse bridges with 30° phase shift
- 12 stacks × 14 Powerex T8K7 thyristors each
- Discrete firing pulses create square-wave current patterns
- Commutation spikes when current switches between thyristors
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass
from enum import Enum


class ThyristorState(Enum):
    """Thyristor conduction states."""
    OFF = 0
    CONDUCTING = 1
    COMMUTATING = 2


@dataclass
class ThyristorStack:
    """Individual thyristor stack in the 12-pulse rectifier."""
    phase: str  # 'A', 'B', 'C'
    bridge: int  # 1 or 2 (for 12-pulse operation)
    firing_angle_deg: float  # Phase control angle
    conduction_angle_deg: float = 120.0  # Typical conduction angle
    
    # State variables
    state: ThyristorState = ThyristorState.OFF
    current_amplitude: float = 0.0
    last_firing_time: float = 0.0


class TwelvePulseThyristorRectifier:
    """
    12-Pulse Thyristor Rectifier Physics Model.
    
    Models the discrete switching behavior that creates square-wave current
    patterns with commutation spikes, matching the real SPEAR3 HVPS.
    """
    
    def __init__(self, line_frequency_hz: float = 60.0):
        """Initialize 12-pulse thyristor rectifier."""
        self.f_line = line_frequency_hz
        self.omega_line = 2.0 * np.pi * self.f_line
        
        # 12-pulse configuration: Two 6-pulse bridges with 30° offset
        self.thyristor_stacks = self._initialize_thyristor_stacks()
        
        # Commutation parameters
        self.commutation_time_us = 50.0  # Typical commutation time
        self.commutation_spike_factor = 1.5  # Current spike during commutation
        
        print(f"12-Pulse Thyristor Rectifier initialized:")
        print(f"  Line frequency: {self.f_line} Hz")
        print(f"  Number of thyristor stacks: {len(self.thyristor_stacks)}")
        print(f"  Firing sequence: 12 pulses per cycle (720 Hz)")
    
    def _initialize_thyristor_stacks(self) -> List[ThyristorStack]:
        """Initialize 12 thyristor stacks for 12-pulse operation."""
        stacks = []
        
        # Bridge 1: Standard 6-pulse (phases A, B, C)
        for i, phase in enumerate(['A', 'B', 'C']):
            # Positive group (0°, 120°, 240°)
            stacks.append(ThyristorStack(
                phase=phase, 
                bridge=1, 
                firing_angle_deg=i * 120.0
            ))
            # Negative group (180°, 300°, 60°)
            stacks.append(ThyristorStack(
                phase=phase, 
                bridge=1, 
                firing_angle_deg=(i * 120.0 + 180.0) % 360.0
            ))
        
        # Bridge 2: 30° phase-shifted 6-pulse (for 12-pulse operation)
        for i, phase in enumerate(['A', 'B', 'C']):
            # Positive group with 30° shift
            stacks.append(ThyristorStack(
                phase=phase, 
                bridge=2, 
                firing_angle_deg=(i * 120.0 + 30.0) % 360.0
            ))
            # Negative group with 30° shift
            stacks.append(ThyristorStack(
                phase=phase, 
                bridge=2, 
                firing_angle_deg=(i * 120.0 + 210.0) % 360.0
            ))
        
        return stacks
    
    def _get_phase_voltage(self, phase: str, t: float, v_peak: float) -> float:
        """Get instantaneous phase voltage for given phase."""
        phase_shifts = {'A': 0.0, 'B': 120.0, 'C': 240.0}
        phase_shift_rad = np.radians(phase_shifts[phase])
        return v_peak * np.sin(self.omega_line * t + phase_shift_rad)
    
    def _is_thyristor_triggered(self, stack: ThyristorStack, t: float, 
                               control_angle_deg: float) -> bool:
        """Determine if thyristor should be triggered at time t."""
        # Calculate phase angle in current AC cycle
        cycle_time = 1.0 / self.f_line
        t_in_cycle = t % cycle_time
        phase_angle_deg = (t_in_cycle / cycle_time) * 360.0
        
        # Check if we're at the firing angle for this stack
        firing_angle = (stack.firing_angle_deg + control_angle_deg) % 360.0
        
        # Trigger window (±2° tolerance)
        angle_diff = abs(phase_angle_deg - firing_angle)
        if angle_diff > 180.0:
            angle_diff = 360.0 - angle_diff
        
        return angle_diff < 2.0
    
    def _calculate_thyristor_current(self, stack: ThyristorStack, t: float, 
                                   v_phase: float, load_current_avg: float) -> float:
        """Calculate current through individual thyristor stack."""
        if stack.state == ThyristorState.OFF:
            return 0.0
        
        # Base current during conduction
        base_current = load_current_avg / 3.0  # Distributed across 3 phases
        
        # Add commutation effects
        if stack.state == ThyristorState.COMMUTATING:
            # Current spike during commutation
            commutation_factor = self.commutation_spike_factor
            base_current *= commutation_factor
        
        # Phase-dependent current modulation
        phase_factor = max(0.0, np.sin(self.omega_line * t))
        
        return base_current * phase_factor
    
    def generate_transformer_ac_current(self, t: np.ndarray, 
                                      control_angle_deg: float = 50.0,
                                      load_current_avg: float = 15.0,
                                      v_line_peak: float = 12470.0) -> np.ndarray:
        """
        Generate Transformer 1 AC Phase Current with thyristor commutation.
        
        This creates the square-wave pattern with commutation spikes that
        matches the real system's Channel 4 monitoring signal.
        """
        current = np.zeros_like(t)
        dt = t[1] - t[0] if len(t) > 1 else 1e-6
        
        for i, time in enumerate(t):
            total_current = 0.0
            
            # Check each thyristor stack
            for stack in self.thyristor_stacks:
                # Only consider Phase A transformer current for Channel 4
                if stack.phase != 'A':
                    continue
                
                # Get phase voltage
                v_phase = self._get_phase_voltage(stack.phase, time, v_line_peak)
                
                # Update thyristor state
                if self._is_thyristor_triggered(stack, time, control_angle_deg):
                    if stack.state == ThyristorState.OFF:
                        stack.state = ThyristorState.COMMUTATING
                        stack.last_firing_time = time
                elif stack.state == ThyristorState.COMMUTATING:
                    # Commutation period (typically 50 µs)
                    if time - stack.last_firing_time > self.commutation_time_us * 1e-6:
                        stack.state = ThyristorState.CONDUCTING
                elif stack.state == ThyristorState.CONDUCTING:
                    # Check for natural commutation (current zero crossing)
                    if v_phase < 0 and stack.current_amplitude > 0:
                        stack.state = ThyristorState.OFF
                        stack.current_amplitude = 0.0
                
                # Calculate current contribution
                stack_current = self._calculate_thyristor_current(
                    stack, time, v_phase, load_current_avg
                )
                stack.current_amplitude = stack_current
                total_current += stack_current
            
            current[i] = total_current
        
        # Add some realistic noise and harmonics
        noise_factor = 0.05
        harmonic_content = (
            0.1 * np.sin(3 * self.omega_line * t) +  # 3rd harmonic
            0.05 * np.sin(5 * self.omega_line * t)   # 5th harmonic
        )
        
        current += noise_factor * np.random.normal(0, 1, len(t))
        current += load_current_avg * harmonic_content
        
        return current
    
    def generate_gating_pulses(self, t: np.ndarray, 
                              control_angle_deg: float = 50.0) -> np.ndarray:
        """
        Generate 12-pulse gating pattern for visualization.
        
        Shows the discrete firing pulses that create the square-wave behavior.
        """
        pulses = np.zeros_like(t)
        pulse_width_deg = 15.0  # Typical gate pulse width
        
        for time_idx, time in enumerate(t):
            cycle_time = 1.0 / self.f_line
            t_in_cycle = time % cycle_time
            phase_angle_deg = (t_in_cycle / cycle_time) * 360.0
            
            # Check if any thyristor should be firing
            for stack in self.thyristor_stacks:
                firing_angle = (stack.firing_angle_deg + control_angle_deg) % 360.0
                
                # Check if we're within the pulse width
                angle_diff = abs(phase_angle_deg - firing_angle)
                if angle_diff > 180.0:
                    angle_diff = 360.0 - angle_diff
                
                if angle_diff < pulse_width_deg / 2.0:
                    pulses[time_idx] = 1.0
                    break
        
        return pulses


class ThyristorCurrentAnalyzer:
    """Analyze thyristor current characteristics for validation."""
    
    @staticmethod
    def analyze_current_waveform(current: np.ndarray, t: np.ndarray, 
                               f_line: float = 60.0) -> dict:
        """Analyze current waveform characteristics."""
        dt = t[1] - t[0] if len(t) > 1 else 1e-6
        fs = 1.0 / dt
        
        # FFT analysis
        fft = np.fft.fft(current)
        freqs = np.fft.fftfreq(len(current), dt)
        magnitude = np.abs(fft)
        
        # Find dominant frequencies
        positive_freqs = freqs[:len(freqs)//2]
        positive_magnitude = magnitude[:len(magnitude)//2]
        
        # Identify harmonics
        fundamental_idx = np.argmin(np.abs(positive_freqs - f_line))
        fundamental_magnitude = positive_magnitude[fundamental_idx]
        
        harmonics = {}
        for n in [3, 5, 7, 9, 11]:
            harmonic_freq = n * f_line
            harmonic_idx = np.argmin(np.abs(positive_freqs - harmonic_freq))
            if harmonic_idx < len(positive_magnitude):
                harmonic_magnitude = positive_magnitude[harmonic_idx]
                harmonics[n] = harmonic_magnitude / fundamental_magnitude if fundamental_magnitude > 0 else 0
        
        # Calculate THD
        thd = np.sqrt(sum(harmonics.values())) if harmonics else 0
        
        # Waveform characteristics
        rms_current = np.sqrt(np.mean(current**2))
        peak_current = np.max(np.abs(current))
        crest_factor = peak_current / rms_current if rms_current > 0 else 0
        
        return {
            'rms_current': rms_current,
            'peak_current': peak_current,
            'crest_factor': crest_factor,
            'thd_percent': thd * 100,
            'harmonics': harmonics,
            'dominant_frequency_hz': positive_freqs[np.argmax(positive_magnitude)]
        }


def test_thyristor_physics():
    """Test the thyristor physics model."""
    print("=== Testing 12-Pulse Thyristor Physics ===")
    
    # Create test time vector
    duration = 0.1  # 100 ms
    fs = 50000  # 50 kHz sampling
    t = np.linspace(0, duration, int(duration * fs))
    
    # Initialize thyristor rectifier
    rectifier = TwelvePulseThyristorRectifier()
    
    # Generate transformer AC current
    current = rectifier.generate_transformer_ac_current(
        t, control_angle_deg=50.0, load_current_avg=15.0
    )
    
    # Analyze waveform
    analyzer = ThyristorCurrentAnalyzer()
    analysis = analyzer.analyze_current_waveform(current, t)
    
    print(f"\nCurrent Waveform Analysis:")
    print(f"  RMS Current: {analysis['rms_current']:.2f} A")
    print(f"  Peak Current: {analysis['peak_current']:.2f} A")
    print(f"  Crest Factor: {analysis['crest_factor']:.2f}")
    print(f"  THD: {analysis['thd_percent']:.1f}%")
    print(f"  Dominant Frequency: {analysis['dominant_frequency_hz']:.1f} Hz")
    
    print(f"\nHarmonic Content:")
    for harmonic, magnitude in analysis['harmonics'].items():
        print(f"  {harmonic}rd harmonic: {magnitude*100:.1f}% of fundamental")


if __name__ == "__main__":
    test_thyristor_physics()
