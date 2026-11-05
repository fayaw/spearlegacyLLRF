## 1. Tektronix Oscilloscope in B118: HVPS Monitoring

- **IP address:** `172.22.242.71`
- **Channel assignments:**
  - **CH1:** HVPS voltage
  - **CH2:** HVPS current
  - **CH3:** Transformer current
  - **CH4:** SCR firing signal

### Diagnostic Background

Based on Jim's message dated June 28, 2024:

- **Voltage monitoring:** There are redundant voltage dividers. One is used for the HVPS output feedback circuit.
- **Current monitoring:** Two current monitors are located in the termination tank in B132, immediately upstream of the klystron:
  - **Danfysik:** Slow current monitor, with a high-frequency cutoff of a few kHz.
  - **Pearson transformer:** Wideband current monitor, with a high-frequency cutoff of a few MHz.
  - Both measure current from the HVPS to the klystron.
- **Signal buffering and distribution:** The voltage-divider and Danfysik outputs are buffered by a small board in the HVPS controller in B118. The board sends these signals to the LLRF controls in the B132 klystron room, where they are used to generate the LLRF fault files.
- **Oscilloscope connection:** The scope is connected to buffered BNC output test points on the buffer board in B118.

## 2. Spectrum Analyzer in B321

- **IP address:** `172.22.245.99`
- **Input signal:** CavA probe