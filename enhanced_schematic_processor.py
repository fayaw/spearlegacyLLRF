import fitz
import pytesseract
from PIL import Image, ImageEnhance, ImageFilter, ImageOps
import os
import json
import re
import io

class SchematicProcessor:
    def __init__(self):
        self.ocr_configs = [
            '--psm 6',   # Uniform block of text
            '--psm 4',   # Single column of text  
            '--psm 3',   # Fully automatic page segmentation
            '--psm 11',  # Sparse text
            '--psm 12',  # Sparse text with OSD
            '--psm 8',   # Single word
            '--psm 13'   # Raw line
        ]
    
    def extract_pdf_image(self, pdf_path):
        """Extract high-resolution image from PDF"""
        doc = fitz.open(pdf_path)
        page = doc[0]
        
        # Try to get embedded image first
        image_list = page.get_images()
        if image_list:
            xref = image_list[0][0]
            pix = fitz.Pixmap(doc, xref)
            if pix.n - pix.alpha < 4:  # GRAY or RGB
                img_data = pix.tobytes('png')
                img = Image.open(io.BytesIO(img_data))
                pix = None
                doc.close()
                return img
        
        # Fallback: render page at high DPI
        mat = fitz.Matrix(3.0, 3.0)  # 3x zoom = 216 DPI
        pix = page.get_pixmap(matrix=mat)
        img_data = pix.tobytes('png')
        img = Image.open(io.BytesIO(img_data))
        pix = None
        doc.close()
        return img
    
    def extract_text_comprehensive(self, img):
        """Extract text using multiple preprocessing and OCR approaches"""
        # Convert to grayscale
        if img.mode != 'L':
            img = img.convert('L')
        
        # Try different preprocessing
        preprocessed = {
            'original': img,
            'contrast': ImageEnhance.Contrast(img).enhance(2.0),
            'inverted': ImageOps.invert(img),
            'threshold': img.point(lambda x: 255 if x > 128 else 0, mode='1')
        }
        
        # Add sharpened version
        preprocessed['sharp'] = preprocessed['contrast'].filter(ImageFilter.SHARPEN)
        
        best_text = ''
        best_length = 0
        best_combo = ''
        all_results = {}
        
        for img_name, processed_img in preprocessed.items():
            for config in self.ocr_configs:
                try:
                    text = pytesseract.image_to_string(processed_img, config=config)
                    combo_name = f'{img_name}_{config.replace(" ", "").replace("-", "")}'
                    all_results[combo_name] = {
                        'text': text,
                        'length': len(text.strip())
                    }
                    
                    if len(text.strip()) > best_length:
                        best_text = text
                        best_length = len(text.strip())
                        best_combo = combo_name
                        
                except Exception as e:
                    continue
        
        # Get structured data from best image
        try:
            best_preprocessing = best_combo.split('_')[0] if best_combo else 'sharp'
            best_img = preprocessed.get(best_preprocessing, preprocessed['sharp'])
            data = pytesseract.image_to_data(best_img, output_type=pytesseract.Output.DICT)
            
            words = []
            for i, word in enumerate(data['text']):
                if word.strip() and data['conf'][i] > 30:
                    words.append({
                        'text': word.strip(),
                        'x': data['left'][i],
                        'y': data['top'][i],
                        'conf': data['conf'][i]
                    })
            
        except Exception as e:
            words = []
        
        return {
            'best_text': best_text,
            'best_combo': best_combo,
            'words': words,
            'all_results': all_results
        }
    
    def analyze_components(self, text, words):
        """Extract component information from OCR results"""
        components = {
            'voltages': re.findall(r'(\d+(?:\.\d+)?)\s*[Kk]?[Vv]', text, re.IGNORECASE),
            'currents': re.findall(r'(\d+(?:\.\d+)?)\s*[Aa](?:mps?)?', text, re.IGNORECASE),
            'powers': re.findall(r'(\d+(?:\.\d+)?)\s*[Kk]?[Ww]', text, re.IGNORECASE),
            'capacitors': re.findall(r'(\d+(?:\.\d+)?)\s*[uμ]?[Ff](?:[Dd])?', text, re.IGNORECASE),
            'resistors': re.findall(r'(\d+(?:\.\d+)?)\s*[Kk]?\s*[Oo]hms?', text, re.IGNORECASE),
            'drawing_number': None
        }
        
        # Extract drawing number
        drawing_match = re.search(r'(?:sd|wd|ad|pf)[-\s]*(\d+[-\d]*)', text, re.IGNORECASE)
        if drawing_match:
            components['drawing_number'] = drawing_match.group(1)
        
        # High confidence words
        high_conf_words = [w['text'] for w in words if w['conf'] > 60]
        components['high_conf_words'] = high_conf_words
        
        return components

# Test with the main schematic
processor = SchematicProcessor()

# Process the main schematic
pdf_path = 'hvps/documentation/schematics/sd7307900101.pdf'
print(f"Processing: {pdf_path}")

img = processor.extract_pdf_image(pdf_path)
print(f"Extracted image size: {img.size}")

ocr_results = processor.extract_text_comprehensive(img)
print(f"Best OCR combo: {ocr_results['best_combo']}")
print(f"Text length: {len(ocr_results['best_text'])}")
print(f"Words extracted: {len(ocr_results['words'])}")

components = processor.analyze_components(ocr_results['best_text'], ocr_results['words'])

print("\n=== OCR TEXT ===")
print(ocr_results['best_text'][:2000])

print("\n=== COMPONENTS FOUND ===")
for comp_type, values in components.items():
    if values:
        print(f"{comp_type}: {values}")

