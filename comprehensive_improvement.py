import os
import fitz
import pytesseract
from PIL import Image, ImageEnhance, ImageFilter, ImageOps
import pdfplumber
import io
import re
from docx import Document
import openpyxl

class DocumentImprover:
    def __init__(self):
        self.improvements_made = []
    
    def improve_scanned_pdf(self, pdf_path, md_path):
        """Improve scanned PDF conversion using OCR"""
        print(f"Improving scanned PDF: {pdf_path}")
        
        try:
            doc = fitz.open(pdf_path)
            content = []
            
            for i in range(len(doc)):
                page = doc[i]
                
                # Try to extract text first
                text = page.get_text()
                if text and len(text.strip()) > 50:
                    content.append(f"## Page {i+1}\n\n{text}\n")
                    continue
                
                # If no text, try OCR on images
                image_list = page.get_images()
                if image_list:
                    xref = image_list[0][0]
                    pix = fitz.Pixmap(doc, xref)
                    if pix.n - pix.alpha < 4:
                        img_data = pix.tobytes('png')
                        img = Image.open(io.BytesIO(img_data))
                        
                        # Preprocess image
                        if img.mode != 'L':
                            img = img.convert('L')
                        
                        # Try different OCR approaches
                        best_text = ""
                        for config in ['--psm 6', '--psm 4', '--psm 3']:
                            try:
                                text = pytesseract.image_to_string(img, config=config)
                                if len(text.strip()) > len(best_text.strip()):
                                    best_text = text
                            except:
                                continue
                        
                        if best_text.strip():
                            content.append(f"## Page {i+1}\n\n{best_text}\n")
                        else:
                            content.append(f"## Page {i+1}\n\n*[Scanned page - text could not be extracted reliably]*\n")
                        
                        pix = None
                else:
                    content.append(f"## Page {i+1}\n\n*[No content detected]*\n")
            
            doc.close()
            
            if content:
                # Get original header from existing MD file
                header = ""
                if os.path.exists(md_path):
                    with open(md_path, 'r') as f:
                        lines = f.readlines()
                        for line in lines:
                            header += line
                            if line.strip() == "":
                                break
                
                # Write improved content
                with open(md_path, 'w') as f:
                    f.write(header)
                    f.write("\n".join(content))
                
                self.improvements_made.append(f"Improved scanned PDF: {pdf_path}")
                return True
                
        except Exception as e:
            print(f"Error improving {pdf_path}: {e}")
            return False
    
    def improve_empty_conversions(self):
        """Find and improve empty or nearly empty markdown files"""
        empty_files = []
        
        for root, dirs, files in os.walk("hvps/"):
            for file in files:
                if file.endswith('.md'):
                    md_path = os.path.join(root, file)
                    
                    # Check if file is empty or has minimal content
                    with open(md_path, 'r') as f:
                        content = f.read()
                    
                    # Count actual content (excluding headers and metadata)
                    lines = content.split('\n')
                    content_lines = [l for l in lines if l.strip() and not l.startswith('#') and not l.startswith('>')]
                    
                    if len(content_lines) < 5:  # Very little content
                        # Find corresponding source file
                        source_path = None
                        for ext in ['.pdf', '.docx', '.xlsx', '.pptx']:
                            potential_source = md_path.replace('.md', ext)
                            if os.path.exists(potential_source):
                                source_path = potential_source
                                break
                        
                        if source_path:
                            empty_files.append((md_path, source_path))
        
        print(f"Found {len(empty_files)} files with minimal content")
        
        # Improve the most critical ones
        for md_path, source_path in empty_files[:10]:  # Limit to first 10
            if source_path.endswith('.pdf'):
                self.improve_scanned_pdf(source_path, md_path)
    
    def create_summary_report(self):
        """Create a summary of improvements made"""
        report = f"""# HVPS Documentation Improvement Report

## Improvements Made

Total improvements: {len(self.improvements_made)}

"""
        for improvement in self.improvements_made:
            report += f"- {improvement}\n"
        
        with open("hvps/IMPROVEMENT_REPORT.md", "w") as f:
            f.write(report)
        
        print(f"Created improvement report with {len(self.improvements_made)} items")

# Run the improvements
improver = DocumentImprover()

# First, fix the specific file we know is empty
improver.improve_scanned_pdf(
    'hvps/architecture/originalDocuments/ps3413600102.pdf',
    'hvps/architecture/originalDocuments/ps3413600102.md'
)

# Then find and fix other empty conversions
improver.improve_empty_conversions()

# Create summary report
improver.create_summary_report()

print("Improvement process completed!")
