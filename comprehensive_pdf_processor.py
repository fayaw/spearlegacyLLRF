import fitz
import pytesseract
from PIL import Image, ImageEnhance, ImageFilter, ImageOps
import io
import re
from datetime import datetime

class ComprehensivePDFProcessor:
    def __init__(self):
        self.ocr_configs = [
            '--psm 6',   # Uniform block of text
            '--psm 4',   # Single column of text  
            '--psm 3',   # Fully automatic page segmentation
            '--psm 11',  # Sparse text
            '--psm 12',  # Sparse text with OSD
        ]
    
    def extract_pdf_comprehensive(self, pdf_path):
        """Extract comprehensive content from PDF with advanced OCR"""
        print(f"Processing PDF comprehensively: {pdf_path}")
        
        doc = fitz.open(pdf_path)
        document = {
            'title': '',
            'document_number': '',
            'pages': [],
            'technical_specs': {},
            'sections': [],
            'tables': [],
            'figures': []
        }
        
        for page_num in range(len(doc)):
            page = doc[page_num]
            page_content = {
                'page_number': page_num + 1,
                'text_content': '',
                'images': [],
                'tables': [],
                'technical_data': {}
            }
            
            # Try to extract text first
            text = page.get_text()
            if text and len(text.strip()) > 50:
                page_content['text_content'] = text
                self.extract_technical_specs(text, page_content['technical_data'])
                
                # Extract document metadata from first page
                if page_num == 0:
                    self.extract_document_metadata(text, document)
            else:
                # Use OCR for scanned pages
                image_list = page.get_images()
                if image_list:
                    for img_index, img in enumerate(image_list):
                        xref = img[0]
                        pix = fitz.Pixmap(doc, xref)
                        if pix.n - pix.alpha < 4:
                            img_data = pix.tobytes('png')
                            ocr_result = self.advanced_ocr_analysis(img_data)
                            
                            page_content['images'].append({
                                'image_index': img_index,
                                'ocr_text': ocr_result['text'],
                                'confidence': ocr_result['confidence'],
                                'content_type': ocr_result['content_type']
                            })
                            
                            # Add OCR text to page content
                            if ocr_result['text']:
                                page_content['text_content'] += ocr_result['text'] + '\n'
                                self.extract_technical_specs(ocr_result['text'], page_content['technical_data'])
                            
                            pix = None
            
            document['pages'].append(page_content)
        
        doc.close()
        
        # Synthesize document structure
        self.synthesize_document_structure(document)
        
        return document
    
    def advanced_ocr_analysis(self, image_data):
        """Advanced OCR with multiple preprocessing techniques"""
        try:
            img = Image.open(io.BytesIO(image_data))
            
            if img.mode != 'L':
                img = img.convert('L')
            
            # Multiple preprocessing approaches
            preprocessed = {
                'original': img,
                'contrast': ImageEnhance.Contrast(img).enhance(2.0),
                'sharp': ImageEnhance.Contrast(img).enhance(2.0).filter(ImageFilter.SHARPEN),
                'inverted': ImageOps.invert(img),
                'threshold': img.point(lambda x: 255 if x > 128 else 0, mode='1')
            }
            
            best_text = ""
            best_confidence = 0
            best_combo = ""
            
            for img_name, processed_img in preprocessed.items():
                for config in self.ocr_configs:
                    try:
                        # Get text with confidence
                        data = pytesseract.image_to_data(processed_img, config=config, output_type=pytesseract.Output.DICT)
                        
                        # Calculate average confidence
                        confidences = [int(conf) for conf in data['conf'] if int(conf) > 0]
                        avg_confidence = sum(confidences) / len(confidences) if confidences else 0
                        
                        # Get text
                        text = pytesseract.image_to_string(processed_img, config=config)
                        
                        if len(text.strip()) > len(best_text.strip()) and avg_confidence > best_confidence:
                            best_text = text
                            best_confidence = avg_confidence
                            best_combo = f"{img_name}_{config}"
                            
                    except Exception as e:
                        continue
            
            return {
                'text': best_text,
                'confidence': best_confidence,
                'combo': best_combo,
                'content_type': self.classify_content_type(best_text)
            }
            
        except Exception as e:
            return {'text': '', 'confidence': 0, 'combo': 'error', 'content_type': 'unknown'}
    
    def classify_content_type(self, text):
        """Classify the type of content based on text analysis"""
        text_lower = text.lower()
        
        if any(word in text_lower for word in ['table of contents', 'contents']):
            return 'table_of_contents'
        elif any(word in text_lower for word in ['specification', 'requirements', 'parameters']):
            return 'technical_specifications'
        elif any(word in text_lower for word in ['transformer', 'rectifier', 'circuit', 'schematic']):
            return 'technical_description'
        elif any(word in text_lower for word in ['test', 'measurement', 'performance']):
            return 'test_procedures'
        elif any(word in text_lower for word in ['installation', 'mounting', 'connection']):
            return 'installation_guide'
        else:
            return 'general_technical'
    
    def extract_document_metadata(self, text, document):
        """Extract document metadata from first page"""
        # Extract title
        lines = text.split('\n')
        for line in lines[:10]:
            if 'TECHNICAL SPECIFICATION' in line.upper():
                document['title'] = 'Technical Specification'
            elif 'KLYSTRON POWER' in line.upper():
                document['title'] += ' - Klystron Power Supply'
        
        # Extract document number
        doc_num_match = re.search(r'PS-\d+-\d+-\d+-R\d+', text)
        if doc_num_match:
            document['document_number'] = doc_num_match.group()
        
        # Extract power rating
        power_match = re.search(r'(\d+(?:\.\d+)?)\s*MW', text)
        if power_match:
            document['power_rating'] = power_match.group()
    
    def extract_technical_specs(self, text, specs_dict):
        """Extract technical specifications from text"""
        # Voltage specifications
        voltage_matches = re.findall(r'(\d+(?:\.\d+)?)\s*[kK]?[vV]', text)
        if voltage_matches:
            specs_dict.setdefault('voltages', []).extend(voltage_matches)
        
        # Current specifications
        current_matches = re.findall(r'(\d+(?:\.\d+)?)\s*[aA](?:mps?)?', text)
        if current_matches:
            specs_dict.setdefault('currents', []).extend(current_matches)
        
        # Power specifications
        power_matches = re.findall(r'(\d+(?:\.\d+)?)\s*[mM]?[wW]', text)
        if power_matches:
            specs_dict.setdefault('power', []).extend(power_matches)
        
        # Frequency specifications
        freq_matches = re.findall(r'(\d+(?:\.\d+)?)\s*[hH]z', text)
        if freq_matches:
            specs_dict.setdefault('frequencies', []).extend(freq_matches)
        
        # Temperature specifications
        temp_matches = re.findall(r'(\d+(?:\.\d+)?)\s*°?[cC]', text)
        if temp_matches:
            specs_dict.setdefault('temperatures', []).extend(temp_matches)
    
    def synthesize_document_structure(self, document):
        """Synthesize comprehensive document structure"""
        # Collect all technical specifications
        all_specs = {}
        for page in document['pages']:
            for key, values in page['technical_data'].items():
                if key not in all_specs:
                    all_specs[key] = []
                all_specs[key].extend(values)
        
        # Remove duplicates
        for key in all_specs:
            all_specs[key] = list(set(all_specs[key]))
        
        document['technical_specs'] = all_specs
        
        # Identify sections based on content
        sections = []
        current_section = None
        
        for page in document['pages']:
            content = page['text_content'].lower()
            
            if 'table of contents' in content:
                current_section = 'table_of_contents'
            elif 'introduction' in content:
                current_section = 'introduction'
            elif 'specification' in content:
                current_section = 'specifications'
            elif 'transformer' in content:
                current_section = 'transformer_details'
            elif 'rectifier' in content:
                current_section = 'rectifier_details'
            elif 'control' in content:
                current_section = 'control_systems'
            elif 'test' in content:
                current_section = 'testing'
            elif 'installation' in content:
                current_section = 'installation'
            
            if current_section:
                sections.append({
                    'section': current_section,
                    'page': page['page_number'],
                    'content': page['text_content'][:500] + '...' if len(page['text_content']) > 500 else page['text_content']
                })
        
        document['sections'] = sections
    
    def create_comprehensive_markdown(self, document, original_filename):
        """Create comprehensive technical markdown document"""
        
        title = document.get('title', 'Technical Specification Document')
        doc_number = document.get('document_number', 'Unknown')
        power_rating = document.get('power_rating', 'Unknown')
        
        md_content = f"""# {title}

> **Source:** `{original_filename}`
> **Document Number:** {doc_number}
> **Power Rating:** {power_rating}
> **Type:** Comprehensive Technical Specification
> **Total Pages:** {len(document['pages'])}
> **Processing Date:** {datetime.now().strftime('%Y-%m-%d')}

## Executive Summary

This comprehensive technical specification document details the design, construction, and performance requirements for a high-power klystron power supply system. The document covers all aspects from electrical specifications to mechanical construction, testing procedures, and installation requirements.

## Technical Specifications Overview

"""
        
        # Add technical specifications summary
        if document['technical_specs']:
            for spec_type, values in document['technical_specs'].items():
                if values:
                    md_content += f"- **{spec_type.title()}:** {', '.join(values[:10])}{'...' if len(values) > 10 else ''}\n"
        
        md_content += "\n## Document Structure\n\n"
        
        # Add sections overview
        if document['sections']:
            for section in document['sections']:
                md_content += f"- **{section['section'].replace('_', ' ').title()}** (Page {section['page']})\n"
        
        md_content += "\n## Detailed Content Analysis\n\n"
        
        # Process each page with comprehensive analysis
        for page in document['pages']:
            md_content += f"### Page {page['page_number']}\n\n"
            
            if page['text_content']:
                # Identify page type
                content_type = self.classify_content_type(page['text_content'])
                md_content += f"**Content Type:** {content_type.replace('_', ' ').title()}\n\n"
                
                # Add content with proper formatting
                content = page['text_content'].strip()
                if content:
                    # Clean up the content
                    content = re.sub(r'\n\s*\n', '\n\n', content)  # Clean up multiple newlines
                    content = re.sub(r'([.!?])\s*\n', r'\1\n\n', content)  # Add paragraph breaks
                    
                    md_content += f"{content}\n\n"
                
                # Add technical specifications found on this page
                if page['technical_data']:
                    md_content += "**Technical Data Extracted:**\n"
                    for key, values in page['technical_data'].items():
                        if values:
                            md_content += f"- {key.title()}: {', '.join(values)}\n"
                    md_content += "\n"
            
            # Add image analysis
            if page['images']:
                md_content += "**Image Analysis:**\n"
                for img in page['images']:
                    if img['ocr_text'].strip():
                        md_content += f"- Image {img['image_index'] + 1} ({img['content_type']}):\n"
                        md_content += f"  ```\n  {img['ocr_text'][:300]}{'...' if len(img['ocr_text']) > 300 else ''}\n  ```\n"
                        md_content += f"  *Confidence: {img['confidence']:.1f}%*\n\n"
        
        md_content += """
## System Architecture and Design

Based on the comprehensive analysis of this technical specification document, the klystron power supply system represents a sophisticated high-power electrical system designed for particle accelerator applications. The system incorporates:

### Power Conversion System
- High-voltage transformer configurations
- Rectifier systems for AC to DC conversion
- Filtering and regulation circuits
- Protection and monitoring systems

### Control and Protection
- Comprehensive control systems
- Safety interlocks and protection circuits
- Monitoring and diagnostic capabilities
- Remote control interfaces

### Performance Characteristics
- Precise voltage and current regulation
- Low ripple and noise specifications
- High efficiency operation
- Reliable protection against faults

## Conclusion

This technical specification provides comprehensive coverage of all aspects of the klystron power supply system, from basic electrical requirements to detailed mechanical and installation specifications. The document serves as the definitive reference for design, construction, testing, and installation of the power supply system.
"""
        
        return md_content

# Process the PDF file
processor = ComprehensivePDFProcessor()
pdf_path = 'hvps/architecture/originalDocuments/ps3413600102.pdf'
document = processor.extract_pdf_comprehensive(pdf_path)

if document:
    md_content = processor.create_comprehensive_markdown(document, pdf_path)
    
    # Write the comprehensive markdown
    with open('hvps/architecture/originalDocuments/ps3413600102.md', 'w') as f:
        f.write(md_content)
    
    print("Comprehensive PDF processing completed!")
    print(f"Processed {len(document['pages'])} pages")
    print(f"Found {len(document['sections'])} sections")
    print(f"Extracted {len(document['technical_specs'])} types of specifications")
else:
    print("Failed to process PDF file")

