# 02 — Hardware Specifications

> **Sources**: `OP-0111_C FCOG1200 (F&K) Operating Manual - Copy.pdf`, `OP-0102_FCOG6100_Op_Manual.pdf`, `E640_L FCOG1200 Schematic (03-01-21).pdf`, `E640_K FCOG1200 Schematic (09-30-09).pdf`, `E128_R_Schematic_11-14.pdf`, `enerproDiscussion07072022.docx`

## FCOG1200 Complete Specifications

### Electrical Specifications

| Parameter | Specification | Notes |
|-----------|---------------|-------|
| **Control Input (SIG HI)** | 0.9-5.9 VDC (default) | R25 = 249 kΩ |
| | 0-5 VDC (optional) | R25 = 150 kΩ |
| | 4-20 mA (current mode) | Max 50 mA, select R40 |
| **Input Impedance** | 10.0 kΩ typical | R40 setting |
| **Power Supply Input** | 24 VAC, 24 VA, single phase | Customer supplied |
| **Generated Voltages** | ±30 VDC (unregulated) | Gate drive power |
| | ±12 VDC (regulated) | Logic circuits |
| | ±5 VDC (regulated) | ASIC power |
| **Gate Outputs** | 12 isolated channels | 30° spacing |
| **Output Current** | High current capability | Thyristor gate drive |
| **Frequency Range** | 50/60 Hz selectable | Via J5 and component selection |
| **Phase Shift** | 0° or 30° selectable | Via component selection |
| **Operating Temperature** | Industrial range | Specific range not documented |

### Physical Specifications

| Parameter | Specification |
|-----------|---------------|
| **Board Size** | Standard PCB format |
| **Mounting** | PCB standoffs and connectors |
| **Connectors** | Multiple keyed connectors for safety |
| **Indicators** | 3 LEDs (Phase Loss, Power On, Inhibit) |
| **Test Points** | Multiple TP locations for diagnostics |

---

## Connector Specifications

### Gate/Cathode Connectors (J1-J4)

**FCOG1200**: 8-position Mate-N-Lok™ right-angle connectors
- **J1, J3**: Gates and cathodes for load-connected cathode SCRs
- **J2, J4**: Gates and cathodes for line-connected cathode SCRs  
- **Keyed design** prevents incorrect installation or reversal
- **High current capability** for thyristor gate drive

**Pin Assignments (J1, J3 - Load-Connected Cathodes)**:
| Pin | Function |
|-----|----------|
| 1 | +Ax Gate |
| 2 | +Ax Cathode |
| 3 | +Bx Gate |
| 4 | +Bx Cathode |
| 5 | +Cx Gate |
| 6 | +Cx Cathode |
| 7 | Key Pin |
| 8 | Not Connected |

**Pin Assignments (J2, J4 - Line-Connected Cathodes)**:
| Pin | Function |
|-----|----------|
| 1 | -Ax Gate |
| 2 | -Ax Cathode |
| 3 | -Bx Gate |
| 4 | -Bx Cathode |
| 5 | -Cx Gate |
| 6 | -Cx Cathode |
| 7 | Key Pin |
| 8 | Not Connected |

### Phase Reference Test Signal Input (J7)

**8-position MTA header** for low-power testing and external references:

| Pin | Function | Description |
|-----|----------|-------------|
| 1-3 | Phase Set 1 | First three-phase reference (5 VPP) |
| 4-6 | Phase Set 2 | Second three-phase reference (30° shifted) |
| 7 | Common | Circuit common connection |
| 8 | +15VDC | Unregulated supply (10 mA max) |

### Frequency Selection Connector (J5)

**3-position header** for 50/60 Hz operation:

| Position | Frequency | Configuration |
|----------|-----------|---------------|
| Pins 1-2 | 60 Hz | Default position |
| Pins 2-3 | 50 Hz | Move jumper P5 |

**Associated Components**:
- **60 Hz**: RN4 = 120 kΩ, C23/C29 = 0.27 μF
- **50 Hz**: RN4 = 150 kΩ, C23/C29 = 0.33 μF (matched ±1%)

### Control Signal Connector (J6)

**Multi-pin connector** for system integration:

| Pin | Signal | Function |
|-----|--------|----------|
| 9 | L1 | +12/PL# signal |
| 10 | SIG HI | Delay angle command input |
| 12 | I2# | Additional control signal |
| 13 | CK2# | Clock signal (inverted) |
| 14 | Ixy/B | Auto-balance signal |
| 15 | Ix/CK2 | Clock signal / auto-balance |

---

## Component Specifications

### Key Integrated Circuits

| Component | Part Number | Function | Package |
|-----------|-------------|----------|---------|
| **U1** | W02M | Bridge rectifier | DIP |
| **U2** | LM78L12CZL | 12V regulator | TO-92 |
| **U3** | EP1014 | Custom ASIC #1 | 24-pin DIP |
| **U4** | EP1015 | Custom ASIC #2 | 24-pin DIP |
| **U5** | EP1016 | Support ASIC | 24-pin DIP |
| **U6** | LM239N | Quad comparator | DIP |
| **U7** | MC34074BC | Quad op-amp | DIP |
| **U8** | MC34074BC | Quad op-amp | DIP |
| **U9** | MC14073BCP | Triple 3-input AND | DIP |
| **U10-U11** | ULN2004A | Darlington driver | DIP |
| **U12** | MC14070BCP | Quad XOR gate | DIP |

### Critical Passive Components

#### Resistor Networks
| Component | Value | Function |
|-----------|-------|----------|
| **RN1** | 3.3 kΩ | Phase reference attenuation |
| **RN2** | 47 kΩ | Signal conditioning |
| **RN3** | 100 kΩ | Bias setting |
| **RN4** | 120 kΩ (60Hz) / 150 kΩ (50Hz) | Frequency compensation |
| **RN5-RN6** | 15 kΩ | Reference processing |
| **RN7** | 33 kΩ | Alternative frequency setting |
| **RN8** | 100 kΩ | Bias network |
| **RN9** | 47 kΩ | Signal processing |

#### Critical Capacitors
| Component | Value | Tolerance | Function |
|-----------|-------|-----------|----------|
| **C1** | 1000 μF | - | Power supply filtering |
| **C2-C3** | 2.2 μF | - | Regulation |
| **C4** | 22 μF | - | Power supply |
| **C5** | 2.2 μF | - | Stability (Rev K+) |
| **C6** | 470 μF | - | Stability (Rev K+) |
| **C17-C22** | 0.033 μF | 5% | Phase reference filtering |
| **C23** | 0.27 μF (60Hz) / 0.33 μF (50Hz) | ±1% | Frequency compensation |
| **C29** | 0.27 μF (60Hz) / 0.33 μF (50Hz) | ±1% | Frequency compensation (matched to C23) |
| **C33-C38** | - | - | Comparator hysteresis (Rev K+) |
| **C39** | - | - | Additional stability (Rev K+) |

#### Power Resistors
| Component | Value | Power | Function |
|-----------|-------|-------|----------|
| **R1-R6** | 250 Ω | 2W | Gate drive current limiting |
| **R7-R8** | 10 Ω | 2W | Current sensing |
| **R9** | 100 Ω | 2W | Power dissipation |
| **R10** | 200 Ω | 5W | Power regulation |

### Precision Components

#### Control Signal Processing
| Component | Value | Tolerance | Function |
|-----------|-------|-----------|----------|
| **R25** | 249 kΩ (default) / 150 kΩ (0-5V) | 1% | SIG HI range setting |
| **R40** | 10.0 kΩ | 1% | Input impedance |
| **R47** | 47.5 kΩ | 1% | Signal conditioning |

#### Auto-Balance Circuit
| Component | Value | Function |
|-----------|-------|----------|
| **R11** | 25 kΩ trimpot | Manual balance adjustment |
| **R48** | 10.0 kΩ | Auto-balance signal |
| **R49** | 10.0 kΩ | Auto-balance signal |
| **R50** | 100 kΩ | Auto-balance feedback |
| **R51** | 100 kΩ | Auto-balance feedback |

---

## FCOG6100 Specifications

### Electrical Specifications

| Parameter | Specification | Notes |
|-----------|---------------|-------|
| **Control Input (SIG HI)** | Similar to FCOG1200 | Voltage or current command |
| **Power Supply Input** | 24 VAC, single phase | Customer supplied |
| **Generated Voltages** | ±30V, ±12V, ±5V | Same as FCOG1200 |
| **Gate Outputs** | 6 isolated channels | 60° spacing |
| **Frequency Range** | 50/60 Hz selectable | Component selection |
| **Phase Shift** | Programmable | Application dependent |

### Key Differences from FCOG1200

| Feature | FCOG1200 | FCOG6100 |
|---------|-----------|----------|
| **Gate Outputs** | 12 (30° spacing) | 6 (60° spacing) |
| **ASICs** | Dual (U3, U4) | Single ASIC |
| **Auto-Balance** | 3 methods available | Not documented |
| **Complexity** | Higher | Simplified |
| **Applications** | 12-pulse converters | 6-pulse controllers |
| **Cost** | Higher | Lower |

---

## Configuration Options

### Phase Reference Shift Selection

#### 30° Lagging (Converter Applications)
- **RN4**: 120 kΩ
- **C17-C22**: 0.033 μF film capacitors
- **Application**: DC converters, rectifiers

#### 0° Shift (Controller Applications)
**Option 1**:
- **RN4**: 120 kΩ  
- **C17-C22**: 0.01 μF film capacitors

**Option 2**:
- **RN4**: 33 kΩ
- **C17-C22**: 0.033 μF film capacitors
- **Advantage**: Same capacitors, change resistor network only

### Gate Pulse Profile Selection

#### Two 30° Burst Mode (Default)
- **JU1**: Installed
- **JU2**: Installed
- **Profile**: Two 30°-wide bursts with picket fence sustaining pulses
- **Application**: Normal load inductance

#### Single 120° Burst Mode
- **JU1**: Omitted
- **JU2**: Omitted  
- **Profile**: Single 120°-wide burst
- **Application**: High inductance loads

### Auto-Balance Configuration (FCOG1200)

#### Manual Balance
- **Install**: R11 (25 kΩ trimpot)
- **Omit**: JU4, JU5, R48, R49, U12
- **Method**: Manual adjustment via potentiometer

#### On-Board Auto-Balance
- **Install**: U12, R48, R49
- **Omit**: R11, JU4, JU5
- **Method**: Automatic 6×fmains square wave injection

#### External Auto-Balance
- **Install**: JU4, JU5, R48
- **Omit**: R11, R49, U12
- **Method**: External control via J6 pin 14

---

## Test Points and Diagnostics

### Oscilloscope Test Points

| Test Point | Signal | Function |
|------------|--------|----------|
| **TP1** | Buffer amplifier output | Signal verification |
| **TP2** | 5.0 VDC reference | Voltage regulation check |
| **TP3-TP6** | Phase reference signals | Phase timing verification |
| **TP7** | Control signal | SIG HI monitoring |
| **TP8-TP13** | Gate drive signals | Output verification |
| **TP14** | Auto-balance signal | Balance circuit monitoring |
| **TP15** | X phase summing | Phase loss detection |
| **TP16** | Y phase summing | Phase loss detection |
| **TP18** | Auto-balance output | Balance circuit output |

### LED Indicators

| LED | Color | Function |
|-----|-------|----------|
| **PD1** | Red | Phase Loss indication |
| **PD2** | Red | Inhibit status |
| **PD3** | Green | Power On indication |

### Waveform Verification Points

All waveforms documented in operating manual with:
- **Calibrated time base** for phase measurements at 60 Hz
- **Voltage scales** for amplitude verification  
- **Phase relationships** between signals
- **Normal operating conditions** baseline references

---

## Environmental Specifications

### Operating Conditions
- **Temperature Range**: Industrial standard (specific range not documented)
- **Humidity**: Standard industrial environment
- **Vibration**: PCB-mounted components, standard industrial
- **EMI/RFI**: Designed for industrial power conversion environment

### Storage Conditions
- **Temperature Range**: Extended range for component storage
- **Humidity**: Controlled environment recommended
- **Handling**: ESD precautions for ASIC components

---

## Compliance and Standards

### Safety Standards
- **Isolation**: High-voltage isolation between control and power circuits
- **Connector Keying**: Prevents incorrect connections
- **Component Ratings**: Industrial-grade components throughout

### EMC Considerations
- **Ground Plane**: Proper grounding for EMI reduction (improved in Rev K)
- **Filtering**: Input and output filtering for conducted emissions
- **Layout**: PCB layout optimized for noise immunity

### Quality Standards
- **Component Selection**: Industrial-grade components
- **Manufacturing**: Standard PCB assembly processes
- **Testing**: Factory checkout procedures documented
- **Documentation**: Comprehensive technical documentation package
