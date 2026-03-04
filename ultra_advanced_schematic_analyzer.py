import os
import fitz
import pytesseract
from PIL import Image, ImageEnhance, ImageFilter, ImageOps, ImageDraw
import io
import re
from pathlib import Path
from datetime import datetime
import numpy as np
import cv2

class UltraAdvancedSchematicAnalyzer:
    def __init__(self):
        self.processed_schematics = []
        self.failed_schematics = []
        self.circuit_database = {}
    
    def analyze_all_schematics_ultra_deep(self):
        """Ultra-deep analysis of all schematic PDFs to extract real circuit topology"""
        schematic_pdfs = list(Path('hvps/documentation/schematics').glob('*.pdf'))
        
        print(f"🔬 ULTRA-DEEP ANALYSIS: Processing {len(schematic_pdfs)} critical schematic PDFs...")
        print("🎯 Goal: Extract REAL circuit topology and create ACCURATE ASCII diagrams")
        
        for pdf_path in schematic_pdfs:
            try:
                print(f"\n🔍 ANALYZING: {pdf_path}")
                success = self.ultra_deep_analyze_schematic(pdf_path)
                if success:
                    self.processed_schematics.append(pdf_path)
                    print(f"✅ Successfully analyzed: {pdf_path}")
                else:
                    self.failed_schematics.append(pdf_path)
                    print(f"❌ Failed to analyze: {pdf_path}")
            except Exception as e:
                self.failed_schematics.append(pdf_path)
                print(f"❌ Error analyzing {pdf_path}: {e}")
        
        print(f"\n=== ULTRA-DEEP ANALYSIS RESULTS ===")
        print(f"Successfully analyzed: {len(self.processed_schematics)}")
        print(f"Failed to analyze: {len(self.failed_schematics)}")
        
        return self.processed_schematics
    
    def ultra_deep_analyze_schematic(self, pdf_path):
        """Ultra-deep analysis of a single schematic PDF"""
        try:
            doc = fitz.open(pdf_path)
            
            # Extract comprehensive circuit information with ultra-deep analysis
            circuit_data = {
                'filename': pdf_path.stem,
                'pages': [],
                'real_components': {},
                'actual_connections': [],
                'circuit_blocks': {},
                'signal_flow': {},
                'power_flow': {},
                'extracted_text': '',
                'circuit_topology': '',
                'component_locations': {}
            }
            
            print(f"📄 Processing {len(doc)} pages...")
            
            for page_num in range(len(doc)):
                page = doc[page_num]
                print(f"  🔍 Analyzing page {page_num + 1}...")
                
                page_data = self.ultra_deep_page_analysis(page, page_num)
                circuit_data['pages'].append(page_data)
                
                # Merge all extracted data
                circuit_data['real_components'].update(page_data.get('real_components', {}))
                circuit_data['actual_connections'].extend(page_data.get('actual_connections', []))
                circuit_data['circuit_blocks'].update(page_data.get('circuit_blocks', {}))
                circuit_data['extracted_text'] += page_data.get('extracted_text', '')
                circuit_data['component_locations'].update(page_data.get('component_locations', {}))
            
            doc.close()
            
            # Generate REAL circuit topology based on extracted data
            print("  🎨 Generating accurate ASCII circuit diagram...")
            circuit_data['circuit_topology'] = self.generate_real_circuit_ascii(circuit_data)
            
            # Create ultra-comprehensive markdown
            print("  📝 Creating comprehensive markdown...")
            md_content = self.create_ultra_detailed_schematic_markdown(circuit_data, pdf_path)
            
            # Write to corresponding .md file
            md_path = str(pdf_path).replace('.pdf', '.md')
            with open(md_path, 'w', encoding='utf-8') as f:
                f.write(md_content)
            
            return True
            
        except Exception as e:
            print(f"❌ Error in ultra-deep analysis of {pdf_path}: {e}")
            return False
    
    def ultra_deep_page_analysis(self, page, page_num):
        """Ultra-comprehensive analysis of a single page"""
        page_data = {
            'page_number': page_num + 1,
            'real_components': {},
            'actual_connections': [],
            'circuit_blocks': {},
            'component_locations': {},
            'extracted_text': '',
            'images_processed': 0
        }
        
        # Extract ALL text with maximum methods
        print(f"    📝 Extracting text with multiple OCR methods...")
        text_content = self.ultra_comprehensive_text_extraction(page)
        page_data['extracted_text'] = text_content
        
        # Extract REAL component information with values
        print(f"    🔧 Extracting real component specifications...")
        page_data['real_components'] = self.extract_real_component_specs(text_content)
        
        # Analyze ALL images for circuit topology
        print(f"    🖼️  Analyzing circuit diagram images...")
        image_list = page.get_images()
        for img_index, img in enumerate(image_list):
            try:
                image_analysis = self.ultra_deep_image_analysis(page, img, img_index)
                if image_analysis:
                    # Merge image analysis results
                    page_data['real_components'].update(image_analysis.get('components', {}))
                    page_data['actual_connections'].extend(image_analysis.get('connections', []))
                    page_data['circuit_blocks'].update(image_analysis.get('circuit_blocks', {}))
                    page_data['component_locations'].update(image_analysis.get('locations', {}))
                    page_data['images_processed'] += 1
            except Exception as e:
                print(f"      ⚠️  Error analyzing image {img_index}: {e}")
        
        print(f"    ✅ Page {page_num + 1}: {len(page_data['real_components'])} components, {page_data['images_processed']} images")
        return page_data
    
    def ultra_comprehensive_text_extraction(self, page):
        """Extract text using ALL available methods"""
        all_text = []
        
        # Method 1: Standard text extraction
        try:
            text1 = page.get_text()
            if text1 and len(text1.strip()) > 5:
                all_text.append(text1)
        except:
            pass
        
        # Method 2: Layout-preserving text extraction
        try:
            text2 = page.get_text("text")
            if text2 and len(text2.strip()) > 5:
                all_text.append(text2)
        except:
            pass
        
        # Method 3: Dictionary-based text extraction
        try:
            text_dict = page.get_text("dict")
            if text_dict and 'blocks' in text_dict:
                dict_text = self.extract_text_from_dict(text_dict)
                if dict_text:
                    all_text.append(dict_text)
        except:
            pass
        
        # Method 4: High-resolution OCR with multiple preprocessing
        try:
            # Get high-resolution image
            pix = page.get_pixmap(matrix=fitz.Matrix(3, 3))  # 3x zoom for maximum detail
            img_data = pix.tobytes("png")
            img = Image.open(io.BytesIO(img_data))
            
            # Multiple OCR attempts with different preprocessing
            ocr_results = []
            
            # Standard OCR
            ocr1 = pytesseract.image_to_string(img, config='--psm 6 -c tessedit_char_whitelist=0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,-+()[]{}:;/\\|_=<>?!@#$%^&*~`"\'')
            if ocr1 and len(ocr1.strip()) > 5:
                ocr_results.append(ocr1)
            
            # Enhanced contrast OCR
            enhanced = ImageEnhance.Contrast(img).enhance(3.0)
            ocr2 = pytesseract.image_to_string(enhanced, config='--psm 6')
            if ocr2 and len(ocr2.strip()) > 5:
                ocr_results.append(ocr2)
            
            # Sharpened OCR
            sharpened = enhanced.filter(ImageFilter.SHARPEN)
            ocr3 = pytesseract.image_to_string(sharpened, config='--psm 6')
            if ocr3 and len(ocr3.strip()) > 5:
                ocr_results.append(ocr3)
            
            # Inverted OCR (for white text on dark background)
            inverted = ImageOps.invert(img.convert('RGB'))
            ocr4 = pytesseract.image_to_string(inverted, config='--psm 6')
            if ocr4 and len(ocr4.strip()) > 5:
                ocr_results.append(ocr4)
            
            all_text.extend(ocr_results)
            
        except Exception as e:
            print(f"      ⚠️  OCR extraction failed: {e}")
        
        # Combine all text methods
        combined_text = '\n'.join(all_text)
        return combined_text
    
    def extract_text_from_dict(self, text_dict):
        """Extract text from PyMuPDF text dictionary"""
        extracted_text = []
        
        try:
            for block in text_dict.get('blocks', []):
                if 'lines' in block:
                    for line in block['lines']:
                        if 'spans' in line:
                            line_text = ''
                            for span in line['spans']:
                                if 'text' in span:
                                    line_text += span['text']
                            if line_text.strip():
                                extracted_text.append(line_text.strip())
        except:
            pass
        
        return '\n'.join(extracted_text)
    
    def extract_real_component_specs(self, text):
        """Extract REAL component specifications with actual values"""
        components = {}
        
        # Enhanced component designator patterns with values
        component_patterns = [
            # Resistors with values
            r'(R\d+)\s*[=:]?\s*(\d+(?:\.\d+)?)\s*([kKmM]?[Oo]hm|Ω|ohm)',
            r'(R\d+)\s*[=:]?\s*(\d+(?:\.\d+)?)\s*([kKmM]?)Ω',
            
            # Capacitors with values
            r'(C\d+)\s*[=:]?\s*(\d+(?:\.\d+)?)\s*([pnμumM]?[fF])',
            r'(C\d+)\s*[=:]?\s*(\d+(?:\.\d+)?)\s*([pnμu]F)',
            
            # Inductors with values
            r'(L\d+)\s*[=:]?\s*(\d+(?:\.\d+)?)\s*([mμun]?[hH])',
            
            # Diodes with part numbers
            r'(D\d+)\s*[=:]?\s*([A-Z0-9]+)',
            
            # Transistors with part numbers
            r'(Q\d+)\s*[=:]?\s*([A-Z0-9]+)',
            
            # ICs with part numbers
            r'(U\d+)\s*[=:]?\s*(LM\d+|TL\d+|MC\d+|AD\d+|OP\d+|\d+N\d+)',
            
            # Transformers
            r'(T\d+|XFMR\d*)\s*[=:]?\s*([A-Z0-9:]+)?',
        ]
        
        for pattern in component_patterns:
            matches = re.findall(pattern, text, re.IGNORECASE)
            for match in matches:
                if len(match) >= 2:
                    comp_id = match[0]
                    comp_value = match[1] if len(match) > 1 else ''
                    comp_unit = match[2] if len(match) > 2 else ''
                    
                    components[comp_id] = {
                        'designator': comp_id,
                        'type': comp_id[0],
                        'value': comp_value,
                        'unit': comp_unit,
                        'full_spec': f"{comp_value}{comp_unit}" if comp_value and comp_unit else comp_value
                    }
        
        # Extract standalone component designators
        standalone_pattern = r'\b([RLCDTQUFKJPNM]\d+)\b'
        standalone_matches = re.findall(standalone_pattern, text)
        
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
    
    def ultra_deep_image_analysis(self, page, img, img_index):
        """Ultra-deep analysis of circuit diagram images"""
        try:
            xref = img[0]
            pix = fitz.Pixmap(page.parent, xref)
            
            if pix.n - pix.alpha < 4:  # GRAY or RGB
                img_data = pix.tobytes("png")
                img_pil = Image.open(io.BytesIO(img_data))
                
                # Perform comprehensive image analysis
                image_analysis = self.comprehensive_circuit_image_analysis(img_pil, img_index)
                
                pix = None
                return image_analysis
            
            pix = None
            return None
            
        except Exception as e:
            print(f"      ❌ Error extracting image {img_index}: {e}")
            return None
    
    def comprehensive_circuit_image_analysis(self, img, img_index):
        """Comprehensive analysis of circuit diagram image"""
        analysis = {
            'components': {},
            'connections': [],
            'circuit_blocks': {},
            'locations': {}
        }
        
        try:
            # Convert PIL image to OpenCV format for advanced processing
            img_cv = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
            
            # Multiple OCR attempts on the image
            ocr_configs = [
                '--psm 6',
                '--psm 8',
                '--psm 11',
                '--psm 13'
            ]
            
            all_ocr_text = []
            for config in ocr_configs:
                try:
                    ocr_text = pytesseract.image_to_string(img, config=config)
                    if ocr_text and len(ocr_text.strip()) > 3:
                        all_ocr_text.append(ocr_text)
                except:
                    pass
            
            combined_ocr = '\n'.join(all_ocr_text)
            
            # Extract components from OCR text
            analysis['components'] = self.extract_real_component_specs(combined_ocr)
            
            # Try to detect circuit topology from image (basic line detection)
            try:
                analysis['connections'] = self.detect_circuit_connections(img_cv)
            except:
                pass
            
        except Exception as e:
            print(f"        ⚠️  Error in comprehensive image analysis: {e}")
        
        return analysis
    
    def detect_circuit_connections(self, img_cv):
        """Detect circuit connections using computer vision"""
        connections = []
        
        try:
            # Convert to grayscale
            gray = cv2.cvtColor(img_cv, cv2.COLOR_BGR2GRAY)
            
            # Apply edge detection
            edges = cv2.Canny(gray, 50, 150, apertureSize=3)
            
            # Detect lines using Hough transform
            lines = cv2.HoughLines(edges, 1, np.pi/180, threshold=100)
            
            if lines is not None:
                for i, line in enumerate(lines[:20]):  # Limit to first 20 lines
                    rho, theta = line[0]
                    connections.append({
                        'type': 'line',
                        'rho': float(rho),
                        'theta': float(theta),
                        'line_id': i
                    })
        
        except Exception as e:
            print(f"        ⚠️  Line detection failed: {e}")
        
        return connections
    
    def generate_real_circuit_ascii(self, circuit_data):
        """Generate REAL ASCII circuit diagram based on extracted data"""
        filename = circuit_data['filename'].lower()
        components = circuit_data['real_components']
        
        print(f"    🎨 Creating ASCII for {filename} with {len(components)} components")
        
        # Determine circuit type and create specific ASCII
        if 'sd7307900101' in filename:
            return self.create_main_hvps_real_ascii(components, circuit_data)
        elif 'sd7307930801' in filename:
            return self.create_rectifier_real_ascii(components, circuit_data)
        elif 'sd7307931301' in filename:
            return self.create_filter_real_ascii(components, circuit_data)
        elif 'sd7307930402' in filename:
            return self.create_control_real_ascii(components, circuit_data)
        elif 'sd2372301200' in filename:
            return self.create_power_circuit_real_ascii(components, circuit_data)
        elif 'sd2372301401' in filename:
            return self.create_support_circuit_real_ascii(components, circuit_data)
        elif 'sd7307930304' in filename:
            return self.create_protection_real_ascii(components, circuit_data)
        elif 'sd7307940400' in filename:
            return self.create_interface_real_ascii(components, circuit_data)
        elif 'sd7307900501' in filename:
            return self.create_auxiliary_real_ascii(components, circuit_data)
        elif 'sd7307930702' in filename:
            return self.create_monitoring_real_ascii(components, circuit_data)
        else:
            return self.create_generic_real_ascii(filename, components, circuit_data)

# Continue with specific ASCII creation methods...
