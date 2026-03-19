# EPICS Database & PV Architecture

**Document**: 07 of 08 | **Series**: SPEAR3 LLRF Legacy Code Analysis
**(Rev 2 — corrected with upgrade PV namespace and PEP-II module identification)**

---

## UPGRADE CONTEXT

Legacy PV databases are a **critical reference for the upgrade**. The upgrade preserves the `SRF1:` prefix and uses structured subsystem prefixes:

| Upgrade Subsystem | PV Prefix | Source |
|-------------------|-----------|--------|
| LLRF9 Unit 1 | `LLRF1:` | Built-in EPICS IOC (Dmitry) |
| LLRF9 Unit 2 | `LLRF2:` | Built-in EPICS IOC (Dmitry) |
| HVPS (CompactLogix) | `SRF1:HVPS:` | EPICS gateway |
| RF MPS (ControlLogix) | `SRF1:MPS:` | EPICS gateway |
| Tuner motors (Galil) | `SRF1:MTR:` | EPICS motor record IOC |
| Waveform Buffer | `SRF1:WFBUF:` | Dedicated IOC |

**Key deliverable**: Create a PV alias/migration mapping from legacy `SRF1:*` PVs to new PV names, preserving operator interface continuity.

---

## 1. Database Organization

The EPICS database is split across 76 files in `rfApp/Db/`, organized by function.

### 1.1 VXI Module Records (Custom Record Types)

| File | Record Type | Instance(s) | Active in SPEAR3? | Description |
|------|-------------|-------------|-------------------|-------------|
| `rfp.db` | p2RfRfpRecord | 1 per station | **Yes** (slot 4) | RF Processor module — **ELIMINATED by LLRF9** |
| `iqa.db` | p2RfIqaRecord | 3 per station (fwd, refl, cav) | **Yes** (slots 7/9/11) | I/Q & Amplitude Detectors — **ELIMINATED by LLRF9** |
| `aim.db` | p2RfAimRecord | 1 per station | **Yes** (slot 12) | Arc Interlock Module — **ELIMINATED by Interface Chassis** |
| `clk.db` | p2RfClkRecord | 1 per station | **Yes** (slot 2) | Clock Module — **ELIMINATED by LLRF9** |
| `gvf.db` | p2RfGvfRecord | 1 per station | **No** (slot 3 empty) | **PEP-II ONLY** — GVF module not installed in SRF1 |
| `cf2.db` | p2RfCf2Record | 1 per station | **No** (slot 5 = MPS Shutoff) | **PEP-II ONLY** — CF2 module not installed in SRF1 |
| `cfm.db` | p2RfCfmRecord | 1 per station | **No** (not in SRF1 crate) | **PEP-II ONLY** — CFM comb filter not installed in SRF1 |

### 1.2 I/Q Signal Processing

| File | Description |
|------|-------------|
| `rf_iqa.db` | IQA phase, power, gap voltage, amplitude fault calculations |
| `rf_iqa_module.db` | IQA data acquisition and channel selection logic |
| `rf_iqa_scale.db` | IQA calibration, scale factors, amplitude thresholds |
| `rf_iqa_All.substitutions` | Macro substitutions for all IQA instances |
| `rf_iqa_4CV.substitutions` | 4-cavity variant |

### 1.3 Station Control

| File | Description |
|------|-------------|
| `rf_stn.db` | Remote/local control, DCM record, AB reset, region/ring ID, station reset, state control, SIP summary, fault files, NIRP, beam abort |
| `rf_stn_cav.db` | Tuner loop control, load angle, gap voltage calculations, calibration, direct/comb loop phase, cavity parameter limits |
| `rf_stn_All.substitutions` | Substitutions for station PVs |
| `rf_stn_2CV.substitutions` | 2-cavity variant |
| `rf_stn_4CV.substitutions` | 4-cavity variant |

### 1.4 Feedback Control

| File | Description |
|------|-------------|
| `rf_fbck.db` | DAC loop, comb loop, direct loop controls, ripple loop tracking, TAXI link status, tune drive power, gap feed-forward, RFP diff node voltage |

### 1.5 HVPS

| File | Description |
|------|-------------|
| `rf_hvps.db` | Contactor control logic, HVPS analog I/O, binary outputs, max voltage logic, power/perveance calculations, DCM table status, voltage loop constants, oil temperature |

### 1.6 Klystron & Drive

| File | Description |
|------|-------------|
| `rf_klys.db` | Drive/forward power histories, klystron gain, collector power, efficiency, filament power, ripple amplitude, PLC analog inputs, power constants, delta counts |

### 1.7 Cavity Control

| File | Description |
|------|-------------|
| `rf_cav.db` | Directivity calculations, cavity power/coupling/strength/frequency offset, tuner loop status, phase/frequency histories, load angle offset, stepper motor control/disable/init/stop logic |

### 1.8 DAC Configuration

| File | Description |
|------|-------------|
| `rf_rfp_fourdacs.db` | RFP DAC calc and set for II, IQ, QI, QQ (per cavity) |
| `rf_rfp_twodacs.db` | RFP DAC calc and set for I and Q |
| `rf_dac.substitutions` | DAC substitutions across cavities |

### 1.9 PLC Analog & Digital I/O

| File | Description |
|------|-------------|
| `rf_analog.db` | PLC analog inputs with interlocks (except vacuum, ion pump) |
| `rf_analog_log.db` | Vacuum and ion pump current (log scale) |
| `rf_temp.db` | PLC temperature inputs |
| `rf_digital_hvps.db` | HVPS VXI digital inputs |
| `rf_digital_modu.db` | PLC digital I/O module status |
| `rf_digital_plc.db` | PLC non-interlocked digital inputs |
| `rf_interlock.db` | PLC interlocked digital inputs |
| `rf_interlock_vxi.db` | VXI module interlocked digital (except amplitude/arc) |
| `rf_interlock_arc.db` | AIM arc fault inputs |
| `rf_ab_module.db` | Thermocouple and analog module read status |

### 1.10 Beam & Summary

| File | Description |
|------|-------------|
| `rf_beam_spr.db` | SPEAR beam current and status |
| `rf_beam.db` | Generic beam database (PEP-II variant) |
| `rf_sumy_*.db` | Summary and fanout PVs (2CV, 4CV, arc, cavity, circuit, HVPS, klystron, PLC, station, waveguide) |

### 1.11 AB Adapter/VXI Crate

| File | Description |
|------|-------------|
| `ab_adapter.db` | AB adapter card status |
| `ab_adapter_card.db` | AB adapter card details |
| `ab_dcm_table.db` | DCM block transfer table |
| `crat_vxi_13slot.template` | 13-slot VXI crate record template |

### 1.12 Lab/Test Variants

| File | Description |
|------|-------------|
| `iqGet.db` | IQA data acquisition (lab IOCs only) |
| `iqCvt.db` | IQ conversion database |
| `rfp_dacs.db` | RFP DAC testing (lab IOCs only) |

---

## 2. Substitution Architecture

### 2.1 Station-Level Substitution (srf1.substitutions)

```
file rf_ab_4CV.db           {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_analog_All.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_analog_4CV.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_beam_spear.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1, PS=RF-SOLN-MAIN}}
file rf_dac.db              {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_digital_All.db      {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_digital_4CV.db      {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_iqa_All.db          {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_iqa_4CV.db          {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_stn_All.db          {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1, PS=RF-SOLN-MAIN}}
file rf_stn_4CVAll.db       {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1, PS=RF-SOLN-MAIN}}
file rf_temp_All.db         {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_temp_4CV.db         {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_vxi_modules_All.db  {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file rf_vxi_modules_4CV.db  {{RRRS=SRF1, RNG=SPEAR, ID=2, REG=1}}
file crat_vxi_13slot.db     { ... slot assignments ... }
```

### 2.2 VXI Module Slot Assignments

From `crat_vxi_13slot.template` in `srf1.substitutions`:

| Slot | Assignment |
|------|-----------|
| 0 | B132-IOCRF (KSC V152 CPU) |
| 1 | AB Scanner |
| 2 | Clock |
| 3 | (empty) |
| 4 | RF Processing |
| 5 | MPS Shutoff |
| 6 | Link Passthru |
| 7 | IQA1 |
| 8 | (empty) |
| 9 | IQA2 |
| 10 | (empty) |
| 11 | IQA3 |
| 12 | Arc Interlock |

### 2.3 Station Configurations

The codebase supports multiple configurations:
- `*_All.substitutions` — All features enabled
- `*_4CV.substitutions` — 4-cavity configuration (SPEAR3)
- `*_4CVAll.substitutions` — 4-cavity with all arc channels
- `*_2CV.substitutions` — 2-cavity configuration
- `*_LAB.substitutions` — Lab testing (reduced feature set)

---

## 3. Table/Coefficient Files (iocBoot/tbl/ — 57 files)

These files contain pre-computed data loaded into VXI module memories at boot time.

### 3.1 File Categories

| Pattern | Count | Description | Format |
|---------|-------|-------------|--------|
| `DRIVE_*_I`, `DRIVE_*_Q` | ~10 | Drive waveform tables | Binary 16-bit words |
| `NOISE_*_I`, `NOISE_*_Q` | ~8 | Noise injection for system ID | Binary 16-bit words |
| `SWEEP_*_I`, `SWEEP_*_Q` | ~8 | Frequency sweep tables | Binary 16-bit words |
| `SINE_I`, `SINE_Q` | 2 | Sinusoidal waveforms | Binary 16-bit words |
| `TICKLE_I`, `TICKLE_Q` | 2 | Small-signal excitation | Binary 16-bit words |
| `iqaDdf_*.rpt` | ~4 | IQA digital filter definitions | Text: F, FC[N], H1, H2 |
| `cfmIirCoefs*.tbl` | ~4 | Comb filter IIR coefficients | Binary coefficient pairs |
| `detunEq*.tbl` | ~4 | Detuning equalizer tables | Binary coefficients |
| `aimDas*.inst` | ~4 | AIM data acquisition instructions | Text instruction format |

### 3.2 Upgrade Status

These files encode **physics** — they define waveforms, filter characteristics, and measurement parameters that are independent of the control system implementation.

- **Binary table files**: Can be reused if the new hardware uses the same word width (16-bit) and data format
- **DDF files**: May need format conversion if FPGA filter architecture differs
- **IIR coefficient files**: Reusable if filter topology matches
- **DAS instruction files**: Must be adapted to new fault capture mechanism

---

## 4. Upgrade Impact

### 4.1 What Must Be Preserved

1. **PV names**: Every operator-facing PV must exist in the new system (or have an alias)
2. **Substitution macros**: STN, CAV, RNG, ID, REG pattern must work
3. **Subroutine records**: subIQ.c and subSys.c functions linked to .db records
4. **Summary/fanout structure**: Alarm rollup and display support
5. **Interlock logic**: Safety-critical PV links and calculations

### 4.2 What Will Change

1. **Custom record types** → Standard records with new device support (or asynRecord-based)
2. **DTYP fields** → New device support names
3. **INP/OUT links** → New hardware addressing (not VXI addresses)
4. **AB device support type** → New PLC communication method
5. **Module-specific fields** → New register set for FPGA
