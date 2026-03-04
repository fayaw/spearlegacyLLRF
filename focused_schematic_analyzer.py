import os
import fitz
import pytesseract
from PIL import Image, ImageEnhance, ImageFilter, ImageOps
import io
import re
from pathlib import Path
from datetime import datetime

class FocusedSchematicAnalyzer:
    def __init__(self):
        self.processed_schematics = []
        self.failed_schematics = []
        
    def analyze_all_schematics_focused(self):
        """Focused deep analysis to extract REAL circuit topology"""
        schematic_pdfs = list(Path('hvps/documentation/schematics').glob('*.pdf'))
        
        print(f"🎯 FOCUSED DEEP ANALYSIS: Processing {len(schematic_pdfs)} critical schematic PDFs...")
        print("🔍 Goal: Extract REAL circuit topology and create ACCURATE ASCII diagrams")
        
        for pdf_path in schematic_pdfs:
            try:
                print(f"\n📋 ANALYZING: {pdf_path.name}")
                success = self.focused_deep_analyze_schematic(pdf_path)
                if success:
                    self.processed_schematics.append(pdf_path)
                    print(f"✅ Successfully analyzed: {pdf_path.name}")
                else:
                    self.failed_schematics.append(pdf_path)
                    print(f"❌ Failed to analyze: {pdf_path.name}")
            except Exception as e:
                self.failed_schematics.append(pdf_path)
                print(f"❌ Error analyzing {pdf_path.name}: {e}")
        
        print(f"\n=== FOCUSED ANALYSIS RESULTS ===")
        print(f"Successfully analyzed: {len(self.processed_schematics)}")
        print(f"Failed to analyze: {len(self.failed_schematics)}")
        
        return self.processed_schematics
    
    def focused_deep_analyze_schematic(self, pdf_path):
        """Focused deep analysis of a single schematic PDF"""
        try:
            doc = fitz.open(pdf_path)
            
            # Extract comprehensive circuit information
            circuit_data = {
                'filename': pdf_path.stem,
                'real_components': {},
                'extracted_text': '',
                'technical_values': {},
                'circuit_notes': [],
                'component_count': 0
            }
            
            print(f"  📄 Processing {len(doc)} pages...")
            
            all_text = []
            for page_num in range(len(doc)):
                page = doc[page_num]
                
                # Extract text with maximum methods
                page_text = self.maximum_text_extraction(page, page_num)
                all_text.append(page_text)
            
            doc.close()
            
            # Combine all text
            circuit_data['extracted_text'] = '\n'.join(all_text)
            
            # Extract real components with values
            print("  🔧 Extracting real component specifications...")
            circuit_data['real_components'] = self.extract_detailed_components(circuit_data['extracted_text'])
            circuit_data['component_count'] = len(circuit_data['real_components'])
            
            # Extract technical values
            print("  ⚡ Extracting technical specifications...")
            circuit_data['technical_values'] = self.extract_technical_values(circuit_data['extracted_text'])
            
            # Extract circuit notes
            circuit_data['circuit_notes'] = self.extract_circuit_notes(circuit_data['extracted_text'])
            
            # Generate REAL circuit ASCII based on schematic type
            print("  🎨 Creating accurate ASCII circuit diagram...")
            circuit_ascii = self.create_schematic_specific_ascii(circuit_data)
            
            # Create comprehensive markdown
            print("  📝 Creating comprehensive markdown...")
            md_content = self.create_focused_schematic_markdown(circuit_data, circuit_ascii, pdf_path)
            
            # Write to corresponding .md file
            md_path = str(pdf_path).replace('.pdf', '.md')
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(md_content)
            
            print(f"  ✅ Extracted {circuit_data['component_count']} components")
            return True
            
        except Exception as e:
            print(f"❌ Error in focused analysis of {pdf_path}: {e}")
            return False
    
    def maximum_text_extraction(self, page, page_num):
        """Extract maximum text using all available methods"""
        all_text = []
        
        # Method 1: Standard text extraction
        try:
            text1 = page.get_text()
            if text1 and len(text1.strip()) > 5:
                all_text.append(f"=== PAGE {page_num + 1} STANDARD TEXT ===")
                all_text.append(text1)
        except:
            pass
        
        # Method 2: Dictionary-based extraction with positioning
        try:
            text_dict = page.get_text("dict")
            if text_dict and 'blocks' in text_dict:
                dict_text = self.extract_positioned_text(text_dict)
                if dict_text:
                    all_text.append(f"=== PAGE {page_num + 1} POSITIONED TEXT ===")
                    all_text.append(dict_text)
        except:
            pass
        
        # Method 3: High-resolution OCR with multiple preprocessing
        try:
            # Get very high-resolution image
            pix = page.get_pixmap(matrix=fitz.Matrix(4, 4))  # 4x zoom for maximum detail
            img_data = pix.tobytes("png")
            img = Image.open(io.BytesIO(img_data))
            
            all_text.append(f"=== PAGE {page_num + 1} OCR ANALYSIS ===")
            
            # Multiple OCR attempts with different settings
            ocr_methods = [
                ('Standard OCR', '--psm 6'),
                ('Single Column', '--psm 4'),
                ('Single Block', '--psm 8'),
                ('Single Line', '--psm 7'),
                ('Single Word', '--psm 8'),
                ('Sparse Text', '--psm 11')
            ]
            
            for method_name, config in ocr_methods:
                try:
                    ocr_text = pytesseract.image_to_string(img, config=config)
                    if ocr_text and len(ocr_text.strip()) > 10:
                        all_text.append(f"--- {method_name} ---")
                        all_text.append(ocr_text.strip())
                except:
                    pass
            
            # Enhanced preprocessing OCR
            try:
                # High contrast
                enhanced = ImageEnhance.Contrast(img).enhance(3.0)
                ocr_enhanced = pytesseract.image_to_string(enhanced, config='--psm 6')
                if ocr_enhanced and len(ocr_enhanced.strip()) > 10:
                    all_text.append("--- Enhanced Contrast OCR ---")
                    all_text.append(ocr_enhanced.strip())
                
                # Sharpened
                sharpened = enhanced.filter(ImageFilter.SHARPEN)
                ocr_sharp = pytesseract.image_to_string(sharpened, config='--psm 6')
                if ocr_sharp and len(ocr_sharp.strip()) > 10:
                    all_text.append("--- Sharpened OCR ---")
                    all_text.append(ocr_sharp.strip())
                
                # Inverted (for white text on dark background)
                inverted = ImageOps.invert(img.convert('RGB'))
                ocr_inverted = pytesseract.image_to_string(inverted, config='--psm 6')
                if ocr_inverted and len(ocr_inverted.strip()) > 10:
                    all_text.append("--- Inverted OCR ---")
                    all_text.append(ocr_inverted.strip())
                    
            except Exception as e:
                print(f"    ⚠️  Enhanced OCR failed: {e}")
            
        except Exception as e:
            print(f"    ⚠️  OCR extraction failed: {e}")
        
        return '\n'.join(all_text)
    
    def extract_positioned_text(self, text_dict):
        """Extract text with position information from PyMuPDF dictionary"""
        positioned_text = []
        
        try:
            for block in text_dict.get('blocks', []):
                if 'lines' in block:
                    block_text = []
                    for line in block['lines']:
                        if 'spans' in line:
                            line_text = ''
                            for span in line['spans']:
                                if 'text' in span:
                                    line_text += span['text']
                            if line_text.strip():
                                block_text.append(line_text.strip())
                    
                    if block_text:
                        positioned_text.extend(block_text)
        except:
            pass
        
        return '\n'.join(positioned_text)
    
    def extract_detailed_components(self, text):
        """Extract detailed component specifications with actual values"""
        components = {}
        
        # Comprehensive component patterns with values
        component_patterns = [
            # Resistors with values - multiple formats
            (r'(R\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?)\s*([kKmM]?)\s*([Oo]hm|Ω|ohm)', 'R'),
            (r'(R\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?)\s*([kKmM]?)Ω', 'R'),
            (r'(R\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?[kKmM]?)\s*(?:OHM|ohm)', 'R'),
            
            # Capacitors with values - multiple formats
            (r'(C\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?)\s*([pnμumM]?)[fF]', 'C'),
            (r'(C\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?)\s*([pnμu])F', 'C'),
            (r'(C\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?[pnμumM]?F)', 'C'),
            
            # Inductors with values
            (r'(L\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?)\s*([mμun]?)[hH]', 'L'),
            (r'(L\d+)\s*[=:,]?\s*(\d+(?:\.\d+)?[mμun]?H)', 'L'),
            
            # Diodes with part numbers
            (r'(D\d+)\s*[=:,]?\s*([A-Z]\d+[A-Z]?\d*)', 'D'),
            (r'(D\d+)\s*[=:,]?\s*(1N\d+)', 'D'),
            
            # Transistors with part numbers
            (r'(Q\d+)\s*[=:,]?\s*(2N\d+)', 'Q'),
            (r'(Q\d+)\s*[=:,]?\s*([A-Z]+\d+)', 'Q'),
            
            # ICs with part numbers
            (r'(U\d+)\s*[=:,]?\s*(LM\d+[A-Z]*)', 'U'),
            (r'(U\d+)\s*[=:,]?\s*(TL\d+[A-Z]*)', 'U'),
            (r'(U\d+)\s*[=:,]?\s*(MC\d+[A-Z]*)', 'U'),
            (r'(U\d+)\s*[=:,]?\s*(AD\d+[A-Z]*)', 'U'),
            (r'(U\d+)\s*[=:,]?\s*(OP\d+[A-Z]*)', 'U'),
            
            # Transformers
            (r'(T\d+|XFMR\d*)\s*[=:,]?\s*([A-Z0-9:/-]+)?', 'T'),
        ]
        
        for pattern, comp_type in component_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                if len(match) >= 2:
                    comp_id = match[0]
                    comp_value = match[1] if len(match) > 1 else ''
                    comp_unit = match[2] if len(match) > 2 else ''
                    comp_extra = match[3] if len(match) > 3 else ''
                    
                    # Build full specification
                    full_spec = comp_value
                    if comp_unit:
                        full_spec += comp_unit
                    if comp_extra and comp_extra not in full_spec:
                        full_spec += comp_extra
                    
                    components[comp_id] = {
                        'designator': comp_id,
                        'type': comp_type,
                        'value': comp_value,
                        'unit': comp_unit,
                        'full_spec': full_spec if full_spec else 'See schematic'
                    }
        
        # Extract standalone component designators
        standalone_patterns = [
            r'\b([RLCDTQUFKJPNM]\d+)\b',
            r'\b([RLCDTQUFKJPNM]\d+[A-Z]?)\b'
        ]
        
        for pattern in standalone_patterns:
            standalone_matches = re.findall(pattern, text)
            for comp_id in standalone_matches:
                if comp_id not in components:
                    components[comp_id] = {
                        'designator': comp_id,
                        'type': comp_id[0],
                        'value': '',
                        'unit': '',
                        'full_spec': 'See schematic for value'
                    }
        
        return components
    
    def extract_technical_values(self, text):
        """Extract technical specifications and values"""
        values = {}
        
        # Voltage specifications
        voltage_patterns = [
            r'(\d+(?:\.\d+)?)\s*[kK][vV](?:\s*[dD][cC])?',
            r'(\d+(?:\.\d+)?)\s*[vV](?:olts?)?\s*[dD][cC]',
            r'(\d+(?:\.\d+)?)\s*[vV](?:olts?)?'
        ]
        
        voltages = set()
        for pattern in voltage_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            voltages.update(matches)
        
        if voltages:
            values['voltages'] = sorted(list(voltages), key=lambda x: float(x) if x.replace('.','').isdigit() else 0, reverse=True)
        
        # Current specifications
        current_patterns = [
            r'(\d+(?:\.\d+)?)\s*[aA](?:mps?)?',
            r'(\d+(?:\.\d+)?)\s*[mM][aA]'
        ]
        
        currents = set()
        for pattern in current_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            currents.update(matches)
        
        if currents:
            values['currents'] = sorted(list(currents), key=lambda x: float(x) if x.replace('.','').isdigit() else 0, reverse=True)
        
        # Power specifications
        power_patterns = [
            r'(\d+(?:\.\d+)?)\s*[MmKk]?[wW](?:atts?)?',
            r'(\d+(?:\.\d+)?)\s*[wW]'
        ]
        
        power = set()
        for pattern in power_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            power.update(matches)
        
        if power:
            values['power'] = sorted(list(power), key=lambda x: float(x) if x.replace('.','').isdigit() else 0, reverse=True)
        
        # Frequency specifications
        freq_patterns = [
            r'(\d+(?:\.\d+)?)\s*[kKmM]?[hH][zZ]',
            r'(\d+(?:\.\d+)?)\s*[hH][zZ]'
        ]
        
        frequencies = set()
        for pattern in freq_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            frequencies.update(matches)
        
        if frequencies:
            values['frequencies'] = sorted(list(frequencies), key=lambda x: float(x) if x.replace('.','').isdigit() else 0, reverse=True)
        
        return values
    
    def extract_circuit_notes(self, text):
        """Extract circuit notes and annotations"""
        notes = []
        
        # Note patterns
        note_patterns = [
            r'NOTE[:\s]+(.+?)(?:\n|$)',
            r'NOTES?[:\s]+(.+?)(?:\n|$)',
            r'SEE\s+(.+?)(?:\n|$)',
            r'REF[:\s]+(.+?)(?:\n|$)',
            r'TYP\.?\s+(.+?)(?:\n|$)',
            r'TYPICAL[:\s]+(.+?)(?:\n|$)'
        ]
        
        for pattern in note_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE | re.MULTILINE)
            for match in matches:
                if len(match.strip()) > 5:
                    notes.append(match.strip())
        
        return notes[:10]  # Limit to first 10 notes
    
    def create_schematic_specific_ascii(self, circuit_data):
        """Create schematic-specific ASCII based on filename and components"""
        filename = circuit_data['filename'].lower()
        components = circuit_data['real_components']
        values = circuit_data['technical_values']
        
        # Get component counts by type
        comp_counts = {}
        for comp in components.values():
            comp_type = comp['type']
            comp_counts[comp_type] = comp_counts.get(comp_type, 0) + 1
        
        # Create specific ASCII based on schematic type
        if 'sd7307900101' in filename:
            return self.create_main_hvps_ascii(components, values, comp_counts)
        elif 'sd7307930801' in filename:
            return self.create_rectifier_ascii(components, values, comp_counts)
        elif 'sd7307931301' in filename:
            return self.create_filter_ascii(components, values, comp_counts)
        elif 'sd7307930402' in filename:
            return self.create_control_ascii(components, values, comp_counts)
        elif 'sd2372301200' in filename:
            return self.create_power_circuit_ascii(components, values, comp_counts)
        elif 'sd2372301401' in filename:
            return self.create_support_circuit_ascii(components, values, comp_counts)
        elif 'sd7307930304' in filename:
            return self.create_protection_ascii(components, values, comp_counts)
        elif 'sd7307940400' in filename:
            return self.create_interface_ascii(components, values, comp_counts)
        elif 'sd7307900501' in filename:
            return self.create_auxiliary_ascii(components, values, comp_counts)
        elif 'sd7307930702' in filename:
            return self.create_monitoring_ascii(components, values, comp_counts)
        else:
            return self.create_generic_ascii(filename, components, values, comp_counts)

# Continue with specific ASCII creation methods...
analyzer = FocusedSchematicAnalyzer()
processed = analyzer.analyze_all_schematics_focused()

