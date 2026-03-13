#!/usr/bin/env python3
"""
Simple schematic test to verify schemdraw functionality
"""

import schemdraw
import schemdraw.elements as elm

def test_simple_circuit():
    """Test basic schemdraw functionality."""
    print("Testing basic schemdraw functionality...")
    
    try:
        # Create a simple circuit
        with schemdraw.Drawing(show=False) as d:
            d.config(fontsize=12)
            
            # Simple LC filter circuit
            d += elm.Gap().label('Input')
            d += elm.Line().right()
            d += elm.Inductor().right().label('L1\n0.3H')
            d += elm.Line().right()
            d += elm.Dot()
            d.push()
            d += elm.Capacitor().down().label('C\n8μF')
            d += elm.Ground()
            d.pop()
            d += elm.Line().right()
            d += elm.Gap().label('Output')
            
        # Save the drawing
        d.save('test_circuit.png', dpi=150)
        print("✅ Simple circuit generated successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Error generating circuit: {e}")
        return False

def test_scr_element():
    """Test SCR element specifically."""
    print("Testing SCR element...")
    
    try:
        with schemdraw.Drawing(show=False) as d:
            d += elm.SCR().label('SCR1')
            
        d.save('test_scr.png', dpi=150)
        print("✅ SCR element works!")
        return True
        
    except Exception as e:
        print(f"❌ Error with SCR element: {e}")
        return False

def test_transformer_element():
    """Test transformer element."""
    print("Testing transformer element...")
    
    try:
        with schemdraw.Drawing(show=False) as d:
            d += elm.Transformer().label('T1')
            
        d.save('test_transformer.png', dpi=150)
        print("✅ Transformer element works!")
        return True
        
    except Exception as e:
        print(f"❌ Error with transformer element: {e}")
        return False

if __name__ == "__main__":
    print("🔧 Testing schemdraw elements...")
    
    # Test basic functionality
    if test_simple_circuit():
        print("Basic circuit generation works!")
    
    if test_scr_element():
        print("SCR elements work!")
        
    if test_transformer_element():
        print("Transformer elements work!")
    
    print("\n🎯 Schemdraw testing complete!")
