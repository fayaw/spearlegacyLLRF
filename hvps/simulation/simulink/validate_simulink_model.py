#!/usr/bin/env python3
"""
SPEAR3 HVPS Simulink Model — Pre-push Static Validation
=========================================================

Parses spear3_hvps_simulink_model.m and checks for common SPS pitfalls
without requiring MATLAB.  Intended to be run before committing to catch:

  1. Display-label-as-parameter-name mistakes
  2. Invalid or deprecated library paths
  3. Value format issues (string vs. numeric)
  4. Missing error handling (bare set_param without try-catch)
  5. Candidate coverage gaps in setParamMultiCandidate calls

Usage:
    python validate_simulink_model.py
    python validate_simulink_model.py --strict   # treat warnings as errors

Exit code 0 = clean, 1 = issues found in strict mode.
"""

import re
import sys
from pathlib import Path

# ── Known-good reference data ────────────────────────────────────────

# Parameter names that are KNOWN VALID across MATLAB versions.
# Short names come from runtime-confirmed blocks; long names from docs.
KNOWN_VALID_PARAMS = {
    'Universal Bridge': {
        'Device', 'PowerElectronicDevice',
        'Arms', 'NumberOfBridgeArms', 'Narms',
        'Ron', 'Lon',
        'Vf', 'ForwardVoltage', 'Vfd', 'ForwardVoltages',
        'Rs', 'SnubberResistance', 'Snubber_resistance',
        'Cs', 'SnubberCapacitance', 'Snubber_capacitance',
    },
    'Three-Phase Source': {
        'Voltage', 'Frequency', 'PhaseAngle',
    },
    'Three-Phase Transformer (Two Windings)': {
        'NominalPower', 'Winding1', 'Winding2',
        'Winding1Connection', 'Winding2Connection',
    },
    'Series RLC Branch': {
        'Resistance', 'Inductance', 'Capacitance', 'BranchType',
    },
    'Breaker': {
        'BreakerResistance', 'InitialState', 'SwitchingTimes',
    },
    'Pulse Generator': {
        'Frequency', 'PulseWidth', 'Pulse_width',
        'DoublePulsing', 'Double_pulsing',
        'GeneratorType', 'SampleTime',
    },
    # Simulink core blocks — these are well-documented and stable
    'Simulink': {
        'Solver', 'StopTime', 'MaxStep', 'RelTol', 'AbsTol',
        'SimulationMode', 'SimulationMode',
        'Value', 'Slope', 'StartTime', 'InitialOutput',
        'UpperLimit', 'LowerLimit', 'Gain', 'Inputs',
        'Numerator', 'Denominator', 'SampleTime',
        'Controller', 'P', 'I', 'UpperSaturationLimit', 'LowerSaturationLimit',
        'Time', 'Before', 'After', 'Port',
        'VariableName', 'MaxDataPoints', 'NumInputPorts',
        'Position',
    },
}

# Library paths known to be valid in at least some MATLAB version
KNOWN_VALID_PATHS = [
    # SPS Power Electronics
    'powerlib/Power Electronics/Universal Bridge',
    'powerlib/Elements/Universal Bridge',
    # SPS Sources
    'powerlib/Electrical Sources/Three-Phase Source',
    'powerlib/Sources/Three-Phase Source',
    # SPS Elements
    'powerlib/Elements/Three-Phase Transformer (Two Windings)',
    'powerlib/Elements/Series RLC Branch',
    'powerlib/Elements/Breaker',
    'powerlib/Elements/Pi Section Line',
    # SPS Measurements
    'powerlib/Measurements/Voltage Measurement',
    'powerlib/Measurements/Current Measurement',
    # SPS powergui
    'powerlib/powergui',
    # Legacy extras (deprecated but still valid on older MATLAB)
    'powerlib_extras/Control Blocks/Synchronized 6-Pulse Generator',
    # Modern SPS
    'powerlib/Power Electronics/Power Electronics Control/Pulse Generator (Thyristor)',
    # Alternative prefix (sps_lib)
    'sps_lib/Power Electronics/Pulse Generator (Thyristor)',
    'sps_lib/Sources/Three-Phase Source',
    'sps_lib/Power Grid Elements/Three-Phase Transformer (Two Windings)',
    # Simscape Electrical
    'ee_lib/Control/Pulse Width Modulation/Thyristor 6-Pulse Generator',
    # Simulink core
    'simulink/Sources/Constant',
    'simulink/Sources/Step',
    'simulink/Sources/In1',
    'simulink/Sources/Ramp',
    'simulink/Sinks/Out1',
    'simulink/Sinks/Scope',
    'simulink/Sinks/To Workspace',
    'simulink/Math Operations/Gain',
    'simulink/Math Operations/Product',
    'simulink/Math Operations/Sum',
    'simulink/Math Operations/Add',
    'simulink/Continuous/PID Controller',
    'simulink/Discrete/Discrete Transfer Fcn',
    'simulink/Discontinuities/Saturation',
    'simulink/Ports & Subsystems/Subsystem',
    'simulink/Commonly Used Blocks/Scope',
    'simulink/Sources/Clock',
    'simulink/Math Operations/Math Function',
    'simulink/Math Operations/Abs',
    'simulink/User-Defined Functions/MATLAB Function',
    'simulink/Signal Routing/Switch',
]

# Parameter names that look like display labels (suspect)
SUSPECT_DISPLAY_LABEL_PATTERNS = [
    r'^Snubber\s',           # "Snubber resistance Rs (Ohms)"
    r'^Forward\s+voltage',   # "Forward voltage Vf (V)"
    r'^Number\s+of\s+bridge',
    r'^Internal\s+resistance',
    r'^Internal\s+inductance',
    r'\(Ohms?\)',
    r'\(V\)',
    r'\(H\)',
    r'\(F\)',
]


# ── Parsing helpers ──────────────────────────────────────────────────

def extract_add_block_calls(text):
    """Extract all add_block('lib/path', ...) calls."""
    # Match: add_block('path', 'dest', ...)
    pattern = r"add_block\(\s*'([^']+)'"
    return re.findall(pattern, text)


def extract_set_param_calls(text):
    """Extract set_param(blk, 'ParamName', ...) calls."""
    # Match: set_param(anything, 'ParamName', value)
    pattern = r"set_param\([^,]+,\s*'([^']+)'"
    return re.findall(pattern, text)


def extract_trySP_calls(text):
    """Extract trySP(blk, 'ParamName', value) calls."""
    pattern = r"trySP\([^,]+,\s*'([^']+)'"
    return re.findall(pattern, text)


def extract_multi_candidate_calls(text):
    """Extract setParamMultiCandidate(blk, {candidates}, value) calls."""
    # Match the cell array of candidates
    pattern = r"setParamMultiCandidate\([^,]+,\s*\{([^}]+)\}"
    matches = re.findall(pattern, text)
    results = []
    for m in matches:
        # Parse individual candidates: 'name1', 'name2', ...
        candidates = re.findall(r"'([^']+)'", m)
        results.append(candidates)
    return results


# ── Validation checks ────────────────────────────────────────────────

def check_library_paths(text, issues):
    """Check that all add_block library paths are in the known-valid list."""
    paths = extract_add_block_calls(text)
    for p in paths:
        if p not in KNOWN_VALID_PATHS:
            issues.append(('WARN', f"Library path not in known-valid list: '{p}'"))


def check_bare_set_param(text, issues):
    """Check for set_param calls outside of try-catch or trySP/setParamMultiCandidate."""
    lines = text.split('\n')
    in_try = False
    for i, line in enumerate(lines, 1):
        stripped = line.strip()
        if stripped.startswith('try'):
            in_try = True
        if stripped.startswith('catch') or stripped == 'end':
            in_try = False

        # Look for bare set_param that's NOT inside a function definition
        # and NOT inside a try block
        if 'set_param(' in stripped and not in_try:
            # Skip if it's inside trySP or setParamMultiCandidate (helper funcs)
            if 'function ' in stripped:
                continue
            # Skip model-level set_param (solver config, etc.)
            if 'modelName' in stripped or "Solver'" in stripped or "StopTime'" in stripped:
                continue
            # Skip lines that are in function bodies (indented set_param in trySP etc.)
            if stripped.startswith('set_param') and 'blk' in stripped:
                issues.append(('INFO', f"Line {i}: Bare set_param (not in try-catch): {stripped[:80]}"))


def check_suspect_display_labels(text, issues):
    """Check for parameter names that look like display labels, not mask vars."""
    # Only check trySP and set_param calls
    params_trySP = extract_trySP_calls(text)
    params_set = extract_set_param_calls(text)
    all_params = set(params_trySP + params_set)

    for p in all_params:
        for pat in SUSPECT_DISPLAY_LABEL_PATTERNS:
            if re.search(pat, p, re.IGNORECASE):
                issues.append(('ERROR', f"Suspect display label used as parameter name: '{p}' — "
                               f"this is likely a GUI label, not a mask variable name"))


def check_candidate_coverage(text, issues):
    """Check that multi-candidate calls cover known variants."""
    candidates_list = extract_multi_candidate_calls(text)
    for cands in candidates_list:
        # Check for suspiciously short lists
        if len(cands) < 2:
            issues.append(('WARN', f"setParamMultiCandidate with only {len(cands)} candidate: {cands}"))


def check_device_value(text, issues):
    """Check that Device parameter uses correct value string."""
    # Find all places where 'Thyristors' is set
    thyristor_refs = re.findall(r"'(Thyristor[s]?)'", text)
    for val in thyristor_refs:
        if val == 'Thyristor':  # singular
            issues.append(('ERROR', f"Found 'Thyristor' (singular) — "
                           f"MathWorks docs require 'Thyristors' (plural)"))


def check_file_structure(text, issues):
    """Check basic MATLAB file structure."""
    # Count function declarations
    func_matches = re.findall(r'^function\s+', text, re.MULTILINE)
    end_matches = re.findall(r'^\s*end\s*$', text, re.MULTILINE)

    if len(func_matches) == 0:
        issues.append(('WARN', "No function declarations found"))

    # Check for global SPS_PARAM_WARNINGS usage
    if 'global SPS_PARAM_WARNINGS' not in text:
        issues.append(('WARN', "Missing 'global SPS_PARAM_WARNINGS' — error tracking disabled"))

    # Check for discovery mode
    if 'DEBUG_PARAMETER_DISCOVERY' not in text:
        issues.append(('INFO', "No DEBUG_PARAMETER_DISCOVERY mode — add for easier debugging"))

    # Check for setParamMultiCandidate usage
    if 'setParamMultiCandidate' not in text:
        issues.append(('WARN', "No setParamMultiCandidate found — vulnerable to mask name mismatches"))

    # Check for powergui
    if 'powergui' not in text:
        issues.append(('ERROR', "Missing powergui block — SPS models require this"))


# ── Main ─────────────────────────────────────────────────────────────

def main():
    strict = '--strict' in sys.argv

    script_dir = Path(__file__).parent
    m_file = script_dir / 'spear3_hvps_simulink_model.m'

    if not m_file.exists():
        print(f"ERROR: {m_file} not found")
        sys.exit(1)

    text = m_file.read_text(encoding='utf-8')
    issues = []

    print("=" * 65)
    print("  SPEAR3 HVPS Simulink Model — Static Validation")
    print("=" * 65)
    print(f"  File: {m_file}")
    print(f"  Lines: {len(text.splitlines())}")
    print()

    # Run all checks
    check_library_paths(text, issues)
    check_bare_set_param(text, issues)
    check_suspect_display_labels(text, issues)
    check_candidate_coverage(text, issues)
    check_device_value(text, issues)
    check_file_structure(text, issues)

    # Report
    errors = [i for i in issues if i[0] == 'ERROR']
    warns  = [i for i in issues if i[0] == 'WARN']
    infos  = [i for i in issues if i[0] == 'INFO']

    if errors:
        print("❌ ERRORS:")
        for _, msg in errors:
            print(f"   {msg}")
        print()

    if warns:
        print("⚠️  WARNINGS:")
        for _, msg in warns:
            print(f"   {msg}")
        print()

    if infos:
        print("ℹ️  INFO:")
        for _, msg in infos:
            print(f"   {msg}")
        print()

    if not issues:
        print("✅ All checks passed — no issues found.\n")

    # Summary
    print(f"  Errors: {len(errors)}  Warnings: {len(warns)}  Info: {len(infos)}")
    print("=" * 65)

    if strict and errors:
        sys.exit(1)


if __name__ == '__main__':
    main()

