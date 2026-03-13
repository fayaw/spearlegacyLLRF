# HVPS Simulation Tools Evaluation

> **Comprehensive analysis of simulation packages for SPEAR3 HVPS power electronics modeling**

## Executive Summary

Based on research and analysis, the optimal approach for SPEAR3 HVPS simulation is a **hybrid architecture** combining **PySpice** for circuit-level accuracy with **schemdraw** for schematic generation, while maintaining Python for system-level control and analysis.

## Simulation Tool Comparison Matrix

| **Tool** | **Pros** | **Cons** | **HVPS Suitability** | **Score** |
|----------|----------|----------|----------------------|-----------|
| **PySpice** | ✅ Python integration<br>✅ Full SPICE capability<br>✅ Thyristor/SCR models<br>✅ Open source | ❌ Learning curve<br>❌ Setup complexity | ⭐⭐⭐⭐⭐ Excellent | **9/10** |
| **PLECS** | ✅ Power electronics focus<br>✅ 12-pulse examples<br>✅ Professional tool | ❌ Commercial license<br>❌ Limited Python integration | ⭐⭐⭐⭐ Very Good | **8/10** |
| **ngspice** | ✅ Mature SPICE engine<br>✅ Open source<br>✅ Well documented | ❌ No Python integration<br>❌ Manual netlist creation | ⭐⭐⭐ Good | **6/10** |
| **LTspice** | ✅ Free<br>✅ Excellent GUI<br>✅ Good models | ❌ Windows-centric<br>❌ No Python integration | ⭐⭐⭐ Good | **6/10** |
| **Pure Python** | ✅ Full control<br>✅ Easy integration | ❌ Limited accuracy<br>❌ Manual modeling | ⭐⭐ Fair | **4/10** |

## Recommended Architecture: Hybrid PySpice + Schemdraw

### **Core Simulation Engine: PySpice**

**Why PySpice is Optimal for HVPS:**
- **Native Python Integration**: Seamless integration with existing codebase
- **Full SPICE Capability**: Access to mature SPICE models and algorithms
- **Thyristor/SCR Support**: Built-in models for power electronics devices
- **12-Pulse Rectifier Modeling**: Capable of accurate harmonic analysis
- **Open Source**: No licensing constraints for research/development

**PySpice Capabilities for SPEAR3 HVPS:**
```python
# Example PySpice circuit definition
circuit = Circuit('SPEAR3_HVPS')

# 12-pulse rectifier with proper SCR models
circuit.XSCR('SCR1', 'anode1', 'cathode1', 'gate1', model='PowerexT8K7')
circuit.XSCR('SCR2', 'anode2', 'cathode2', 'gate2', model='PowerexT8K7')
# ... 12 SCR stacks

# LC Filter with exact component values
circuit.L('L1', 'bridge1_out', 'filter_node', 0.3)  # 0.3H
circuit.L('L2', 'bridge2_out', 'filter_node', 0.3)  # 0.3H
circuit.C('C1', 'filter_node', 'ground', 8e-6)      # 8μF
circuit.R('R1', 'filter_node', 'ground', 500)       # 500Ω

# Transformer models with phase shift
circuit.K('K1', 'L_primary1', 'L_secondary1', 0.98)  # T1 coupling
circuit.K('K2', 'L_primary2', 'L_secondary2', 0.98)  # T2 coupling
```

### **Schematic Generation: Schemdraw**

**Why Schemdraw for Circuit Visualization:**
- **Python Native**: Perfect integration with PySpice
- **Professional Quality**: Publication-ready schematics
- **Programmatic Control**: Automated generation from circuit definitions
- **Power Electronics Support**: Thyristor, transformer, and filter symbols

**Schemdraw Capabilities for HVPS:**
```python
import schemdraw
import schemdraw.elements as elm

# Generate 12-pulse rectifier schematic
with schemdraw.Drawing() as d:
    # Phase-shift transformer
    d += elm.Transformer().label('T0\n3.5MVA\n±15°')
    
    # Rectifier transformers
    d += elm.Transformer().right().label('T1\n1.5MVA\n+15°')
    d += elm.Transformer().right().label('T2\n1.5MVA\n-15°')
    
    # SCR bridges
    d += elm.Thyristor().down().label('SCR1-6')
    d += elm.Thyristor().down().label('SCR7-12')
    
    # LC Filter
    d += elm.Inductor().right().label('L1\n0.3H')
    d += elm.Inductor().right().label('L2\n0.3H')
    d += elm.Capacitor().down().label('C\n8μF')
    d += elm.Resistor().down().label('R\n500Ω')
```

### **System Integration: Python Framework**

**Hybrid Architecture Benefits:**
- **Circuit Accuracy**: PySpice provides SPICE-level precision
- **Visual Validation**: Schemdraw enables schematic review
- **System Control**: Python handles control systems and analysis
- **Flexibility**: Easy modification and parameter sweeps
- **Documentation**: Automated report generation with schematics

## Implementation Plan

### **Phase 1: PySpice Integration**
1. **Install PySpice**: `pip install PySpice`
2. **Create HVPS Circuit Model**: Define complete 12-pulse rectifier
3. **Validate Component Models**: Verify SCR, transformer, and filter models
4. **Run Baseline Simulation**: Compare with current Python results

### **Phase 2: Schemdraw Integration**
1. **Install Schemdraw**: `pip install schemdraw`
2. **Create Schematic Generator**: Automated circuit diagram generation
3. **Generate System Schematics**: Complete HVPS visual documentation
4. **Validation Framework**: Compare schematics with documentation

### **Phase 3: Hybrid System Development**
1. **PySpice-Python Bridge**: Interface between SPICE and control systems
2. **Automated Analysis**: Parameter sweeps and optimization
3. **Report Generation**: Integrated simulation and schematic reports
4. **Validation Suite**: Comprehensive testing against specifications

## Alternative Tools Analysis

### **PLECS (Professional Option)**
- **Strengths**: Specialized for power electronics, excellent 12-pulse examples
- **Limitations**: Commercial license (~$3000+), limited Python integration
- **Use Case**: If budget allows and standalone simulation is acceptable

### **MATLAB/Simulink + Power Systems Toolbox**
- **Strengths**: Industry standard, excellent power electronics library
- **Limitations**: Expensive license, limited open-source integration
- **Use Case**: If institutional MATLAB license is available

### **OpenModelica (Open Source Alternative)**
- **Strengths**: Free, Modelica standard, power electronics support
- **Limitations**: Steeper learning curve, less Python integration
- **Use Case**: Long-term alternative if PySpice proves insufficient

## Schematic Generation Capabilities

### **Schemdraw Features for HVPS**
- **Power Electronics Symbols**: Thyristors, transformers, inductors, capacitors
- **Custom Elements**: Can create specialized HVPS symbols
- **Automatic Layout**: Intelligent component placement
- **Export Formats**: PNG, SVG, PDF for documentation
- **Annotation Support**: Component values, ratings, and labels

### **Example Schematic Outputs**
1. **System Overview**: Complete HVPS block diagram
2. **12-Pulse Rectifier**: Detailed SCR bridge configuration
3. **Filter Circuit**: LC filter with component values
4. **Control System**: Interface and feedback loops
5. **Protection System**: Multi-layer arc protection

## Validation Strategy

### **Simulation Validation Steps**
1. **Component-Level Testing**: Individual SCR, transformer, filter validation
2. **Subsystem Validation**: 12-pulse rectifier performance
3. **System Integration**: Complete HVPS simulation
4. **Specification Compliance**: Verify against documented requirements
5. **Waveform Comparison**: Match with real system measurements

### **Schematic Validation Steps**
1. **Component Accuracy**: Verify symbols match real components
2. **Topology Verification**: Compare with documented schematics
3. **Value Validation**: Ensure all component values are correct
4. **Connection Verification**: Validate all electrical connections
5. **Documentation Alignment**: Match with official HVPS documentation

## Conclusion

The **PySpice + Schemdraw hybrid approach** provides the optimal balance of:
- **Simulation Accuracy**: SPICE-level circuit modeling
- **Visual Validation**: Professional schematic generation
- **Python Integration**: Seamless workflow with existing code
- **Open Source**: No licensing constraints
- **Flexibility**: Easy modification and extension

This architecture addresses all user requirements:
✅ **Deep system understanding** through accurate SPICE modeling
✅ **Alternative to pure Python** with professional simulation tools
✅ **Schematic generation** for efficient visual review
✅ **Validation capability** against real system specifications

**Next Steps**: Implement PySpice integration for 12-pulse rectifier modeling and schemdraw for automated schematic generation.

