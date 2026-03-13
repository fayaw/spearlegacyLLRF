# PySpice HVPS Simulation Summary

## Simulation Configuration

- **Input**: 12.47 kV RMS, 3-phase, 60 Hz
- **Filter**: L1=L2=0.3 H, C=8 μF, R=500 Ω
- **Load**: 3500 Ω (klystron equivalent)

## Key Results

- **Filter DC Output**: 16.8 kV
- **Filter Ripple**: 3.67%
- **Filter Attenuation**: 7.9×

## T1 AC Current Analysis

PySpice simulation provides professional SPICE-based modeling of T1 AC current:

1. **Accurate Component Modeling**: Proper transformer leakage, diode characteristics
2. **12-Pulse Operation**: Harmonic content shows 720 Hz ripple frequency
3. **Filter Effects**: LC filter impact on current waveform shape
4. **Comparison Ready**: Results suitable for validation against real system

## Generated Files

- `hvps_pyspice_complete_results.png`: Complete simulation overview
- `hvps_t1_current_pyspice_analysis.png`: Detailed T1 current analysis
- `pyspice_summary.md`: This summary report
