# SPEAR3 LLRF Upgrade Project - Complete Implementation Path

> **Based on**: ProjectPath.md analysis and Physical Design Report  
> **Created**: March 2026  
> **Status**: 10 Subsystems, 4 Phases, 9-Month Timeline

---

## 📊 **Project Overview Diagram**

```mermaid
gantt
    title SPEAR3 LLRF Upgrade - Project Timeline
    dateFormat  YYYY-MM-DD
    section Phase 1 - Standalone Dev
    HVPS PLC (Complete)           :done, hvps1, 2026-01-01, 2026-02-01
    Kly MPS PLC (Complete)        :done, mps1, 2026-01-01, 2026-02-01
    LLRF9 Controllers (Complete)  :done, llrf1, 2026-01-01, 2026-02-01
    Galil Motion (Complete)       :done, galil1, 2026-01-01, 2026-02-01
    Enerpro FCOG1200 Boards       :crit, fcog, 2026-03-01, 2026-04-01
    Arc Detection System          :crit, arc1, 2026-03-01, 2026-04-15
    Waveform Buffer System        :active, wfb1, 2026-03-01, 2026-04-15
    Interface Chassis             :crit, ic1, 2026-03-01, 2026-05-01
    Heater SCR Controller         :heater1, 2026-03-15, 2026-05-01
    PPS Interface Box             :pps1, 2026-03-15, 2026-05-15
    Python/EPICS Coordinator     :crit, sw1, 2026-03-01, 2026-06-01
    
    section Phase 2A - TS18 Integration
    Interface Chassis Testing     :ic2, after ic1, 2026-05-15
    HVPS Integration              :hvps2, after sw1, 2026-06-01
    Heater Integration            :heater2, after heater1, 2026-06-01
    Kly MPS Integration           :mps2, after sw1, 2026-06-15
    WFB Integration               :wfb2, after wfb1, 2026-06-15
    TS18 Sub-Integration          :ts18, after ic2, 2026-07-01
    
    section Phase 2B - SPEAR3 Integration
    LLRF9 Installation           :llrf2, after ts18, 2026-07-15
    Arc Detection Installation    :arc2, after arc1, 2026-07-15
    Galil Integration             :galil2, after llrf2, 2026-08-01
    SPEAR3 Full Integration       :spear3, after galil2, 2026-08-15
    
    section Phase 3 - Commissioning
    Dimtel Support Week           :crit, dimtel, after spear3, 2026-09-01
    Power Ramp & Validation       :commission, after dimtel, 2026-09-08
    Operator Training             :training, after commission, 2026-09-15
```

---

## 🔄 **Detailed Subsystem Flow**

```mermaid
flowchart TD
    %% Phase 1 - Standalone Development
    subgraph P1["🔧 PHASE 1: Standalone Development (Months 1-3)"]
        direction TB
        
        subgraph HW["Hardware Streams"]
            HVPS1["✅ HVPS PLC<br/>(CompactLogix)"]
            HVPS2["⬜ HVPS SCR<br/>(FCOG1200)"]
            HTR["⬜ Heater SCR<br/>Controller"]
            MPS["✅ Kly MPS PLC<br/>(ControlLogix)"]
            WFB["🔄 Waveform<br/>Buffer System"]
            IC["⚠️ Interface<br/>Chassis"]
            
            LLRF["✅ LLRF9<br/>Controllers"]
            ARC["⬜ Arc Detection<br/>System"]
            GAL["✅ Galil Motion<br/>Controller"]
            PPS["⬜ PPS Interface<br/>Box"]
        end
        
        subgraph SW["⚠️ Critical Software"]
            PYSW["⚠️ Python/EPICS<br/>Coordinator<br/><b>CRITICAL - START NOW</b>"]
        end
    end
    
    %% Phase 2A - TS18 Integration
    subgraph P2A["⚙️ PHASE 2A: TS18 Sub-Integration (Months 4-6)"]
        TS18["🔗 TS18 Integration<br/>Klystron + Dummy Load<br/>No RF Cavities"]
    end
    
    %% Phase 2B - SPEAR3 Integration  
    subgraph P2B["🔗 PHASE 2B: SPEAR3 Integration (Months 7-8)"]
        SPEAR3["🎯 SPEAR3 Integration<br/>Live RF Cavities<br/>Full RF Chain"]
    end
    
    %% Phase 3 - Commissioning
    subgraph P3["🚀 PHASE 3: Commissioning (Month 9)"]
        DIMTEL["🔧 Dimtel Support Week<br/>LLRF9 Optimization"]
        RAMP["📈 Power Ramp<br/>10% → 100%"]
        VALID["✅ Performance<br/>Validation"]
    end
    
    %% Critical Path Dependencies
    IC --> TS18
    PYSW --> TS18
    HVPS1 --> TS18
    HVPS2 --> TS18
    HTR --> TS18
    MPS --> TS18
    WFB --> TS18
    
    TS18 --> SPEAR3
    LLRF --> SPEAR3
    ARC --> SPEAR3
    GAL --> SPEAR3
    
    SPEAR3 --> DIMTEL
    DIMTEL --> RAMP
    RAMP --> VALID
    
    %% Critical path highlighting
    classDef critical fill:#ffcccc,stroke:#ff0000,stroke-width:3px
    classDef complete fill:#ccffcc,stroke:#00aa00,stroke-width:2px
    classDef inprogress fill:#ffffcc,stroke:#ffaa00,stroke-width:2px
    classDef needed fill:#ffeeee,stroke:#cc0000,stroke-width:1px
    
    class IC,PYSW critical
    class HVPS1,MPS,LLRF,GAL complete
    class WFB inprogress
    class HVPS2,HTR,ARC,PPS needed
```

---

## 🚨 **Critical Risk Matrix**

| Risk Item | Severity | Status | Impact | Mitigation Strategy |
|-----------|----------|--------|--------|-------------------|
| **Python/EPICS Coordinator** | **Critical** | Not Started | Blocks all integration | Start architecture design immediately |
| **Interface Chassis Logic** | **High** | In Progress | Gates all subsystem integration | Complete LLRF9/HVPS feedback loop design |
| **Kly MPS PLC Software** | **High** | Not Started | Blocks fault handling | Begin IOC development with simulated I/O |
| **PPS Interface Approval** | **High** | Not Started | Regulatory bottleneck | Engage protection managers early |
| **Tuner Controller Reliability** | **Medium** | Testing | Affects system performance | Test on Booster cavity first |

---

## 📈 **Success Criteria & Performance Targets**

| Metric | Legacy Performance | Target | Validation Method |
|--------|-------------------|--------|------------------|
| **Amplitude Stability** | <0.1% | Same or better | RF power measurements |
| **Phase Stability** | <0.1 deg | Same or better | Vector analysis |
| **Tuner Resolution** | ~0.002-0.003 mm/step | Improved (256 μsteps) | Motion encoder feedback |
| **Control Loop Response** | ~1 second | Same or better | Step response testing |
| **System Uptime** | >99.5% | Same or better | Operational statistics |
| **Fault Diagnostics** | Limited fault files | 16k-sample waveform + first-fault | Waveform capture validation |
| **Calibration Time** | ~20 minutes | ~3 minutes | LLRF9 digital calibration |

---

## 🎯 **Key Implementation Principles**

### **1. Maximum Standalone Development**
- **Rationale**: Extremely limited integration testing window
- **Strategy**: Complete all possible subsystem testing before installation
- **Benefit**: Minimizes risk during critical integration phases

### **2. Critical Path Focus**
- **Interface Chassis**: Gates all integration testing
- **Python/EPICS Software**: Required for all control functions  
- **Safety Systems First**: PPS and interlock validation before RF power

### **3. Phased Integration Approach**
- **TS18 Sub-Integration**: Test with klystron and dummy load (no cavities)
- **SPEAR3 Integration**: Add cavity-dependent systems incrementally
- **Commissioning**: Optimize vendor support window for LLRF9-specific tasks

### **4. Risk Mitigation Strategy**
- **Parallel Development**: Multiple subsystems developed simultaneously
- **Simulation Testing**: Software development with mock hardware interfaces
- **Backup Plans**: Rollback procedures for each integration step
- **Vendor Optimization**: Pre-complete all work before Dimtel support week

---

## 📋 **Next Immediate Actions**

### **Week 1-2: Critical Path Initiation**
1. **Start Python/EPICS Coordinator architecture design** (highest priority)
2. **Finalize Interface Chassis I/O specifications** 
3. **Order Enerpro FCOG1200 boards** (5 units needed)
4. **Initiate PPS Interface regulatory approval process**

### **Month 1: Foundation Development**
1. **Complete Interface Chassis logic design** (LLRF9/HVPS feedback loop)
2. **Begin Kly MPS PLC software integration** with simulated I/O
3. **Procure Arc Detection system** (10 sensors + 5 processors + spares)
4. **Start Heater SCR controller design** and fabrication

### **Month 2-3: Parallel Subsystem Development**
1. **Waveform Buffer PCB fabrication** and assembly
2. **Python/EPICS Coordinator module development** with mock interfaces
3. **Interface Chassis fabrication** and standalone testing
4. **HVPS PLC integration** and EPICS development

---

**🎯 This comprehensive project path ensures systematic development, risk mitigation, and successful commissioning of the SPEAR3 LLRF upgrade within the 9-month timeline!**

