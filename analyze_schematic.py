import pytesseract
from PIL import Image, ImageEnhance, ImageFilter, ImageOps
import numpy as np

# Load and preprocess image
img = Image.open('/tmp/sd7307900101_extracted.png')
print(f'Original size: {img.size}')

# Convert to grayscale if needed
if img.mode != 'L':
    img = img.convert('L')

# Try different preprocessing approaches
preprocessed_images = []

# Original
preprocessed_images.append(('original', img))

# Enhanced contrast
enhancer = ImageEnhance.Contrast(img)
img_contrast = enhancer.enhance(2.0)
preprocessed_images.append(('contrast', img_contrast))

# Sharpened
img_sharp = img_contrast.filter(ImageFilter.SHARPEN)
preprocessed_images.append(('sharp', img_sharp))

# Inverted (white text on black background)
img_inverted = ImageOps.invert(img)
preprocessed_images.append(('inverted', img_inverted))

# Threshold (binary)
threshold = 128
img_thresh = img.point(lambda x: 255 if x > threshold else 0, mode='1')
preprocessed_images.append(('threshold', img_thresh))

# OCR with different configurations
configs = [
    '--psm 6',  # Uniform block of text
    '--psm 4',  # Single column of text
    '--psm 3',  # Fully automatic page segmentation
    '--psm 11', # Sparse text
    '--psm 12', # Sparse text with OSD
]

best_text = ''
best_length = 0
best_combo = ''

for img_name, processed_img in preprocessed_images:
    for config in configs:
        try:
            text = pytesseract.image_to_string(processed_img, config=config)
            if len(text) > best_length:
                best_text = text
                best_length = len(text)
                best_combo = f'{img_name} + {config}'
            print(f'{img_name} + {config}: {len(text)} chars')
        except Exception as e:
            print(f'{img_name} + {config} failed: {e}')
            continue

print(f'\nBest OCR result ({best_length} chars) with {best_combo}:')
if best_text:
    print(best_text[:2000])
    if len(best_text) > 2000:
        print('\n... [truncated] ...')
else:
    print('No text extracted')

# Also try to get structured data
try:
    data = pytesseract.image_to_data(img_sharp, output_type=pytesseract.Output.DICT)
    words = []
    for i, word in enumerate(data['text']):
        if word.strip() and data['conf'][i] > 30:
            words.append({
                'text': word.strip(),
                'x': data['left'][i],
                'y': data['top'][i],
                'conf': data['conf'][i]
            })
    print(f'\nStructured data: {len(words)} words with confidence > 30')
    # Show high-confidence words
    high_conf_words = [w for w in words if w['conf'] > 60]
    print(f'High confidence words ({len(high_conf_words)}):')
    for w in high_conf_words[:20]:
        print(f"  {w['text']} (conf: {w['conf']})")
except Exception as e:
    print(f'Structured data extraction failed: {e}')
