"""OCR the schematic images to extract text labels"""
import pytesseract
from PIL import Image
import os
import json

image_dir = "/tmp/schematic_images"
results = {}

for fname in sorted(os.listdir(image_dir)):
    if not fname.endswith('.png'):
        continue
    img_path = os.path.join(image_dir, fname)
    try:
        img = Image.open(img_path)
        # OCR with detailed output
        text = pytesseract.image_to_string(img)
        # Also get structured data
        data = pytesseract.image_to_data(img, output_type=pytesseract.Output.DICT)
        
        # Filter meaningful words
        words = []
        for i, word in enumerate(data['text']):
            if word.strip() and data['conf'][i] > 30:
                words.append({
                    'text': word.strip(),
                    'x': data['left'][i],
                    'y': data['top'][i],
                    'conf': data['conf'][i]
                })
        
        results[fname] = {
            'full_text': text.strip(),
            'words': words,
            'word_count': len(words)
        }
        
        print(f"{fname}: {len(words)} words detected")
        if text.strip():
            preview = text.strip().replace('\n', ' | ')[:150]
            print(f"  Text: {preview}")
        print()
        
    except Exception as e:
        print(f"ERROR {fname}: {e}")
        results[fname] = {'error': str(e)}

with open("/tmp/ocr_results.json", "w") as f:
    json.dump(results, f, indent=2)
print("OCR results saved to /tmp/ocr_results.json")
