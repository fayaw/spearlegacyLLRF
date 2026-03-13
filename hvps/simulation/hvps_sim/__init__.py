"""
SPEAR3 HVPS Legacy System Simulation Package
=============================================

A physics-based simulation of the SPEAR3 High Voltage Power Supply (HVPS) system
at SLAC National Accelerator Laboratory.

System: 12-pulse thyristor phase-controlled rectifier
Output: -77 kV DC @ 22 A (1.7 MW nominal)
Architecture: Based on PEP-II klystron power supply design (1997)

Modules
-------
config      -- System parameters and default configuration
power       -- Power conversion chain models (transformers, SCRs, filters)
controls    -- Control system (PLC, regulator board, Enerpro firing boards)
protection  -- Protection systems (crowbar, interlocks, arc detection)
simulator   -- Main simulation engine and result containers
plotting    -- Visualization and analysis tools
examples    -- Runnable demonstration scenarios
"""

__version__ = "0.1.0"
__author__ = "SSRL/SLAC Engineering"

from hvps.simulation.hvps_sim.config import HVPSConfig
from hvps.simulation.hvps_sim.simulator import HVPSSimulator, SimulationResult

