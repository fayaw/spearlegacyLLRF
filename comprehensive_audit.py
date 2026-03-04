import os
import re
from pathlib import Path

def analyze_markdown_quality(file_path):
    """Analyze the quality of a markdown file"""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        analysis = {
            'file_path': file_path,
            'total_lines': len(content.split('\n')),
            'total_chars': len(content),
            'has_executive_summary': False,
            'has_technical_specs': False,
            'has_proper_title': False,
            'has_source_info': False,
            'has_comprehensive_content': False,
            'has_placeholder_text': False,
            'quality_score': 0,
            'issues': []
        }
        
        # Check for proper title
        if content.startswith('#') and len(content.split('\n')[0]) > 5:
            analysis['has_proper_title'] = True
            analysis['quality_score'] += 1
        else:
            analysis['issues'].append('Missing proper title')
        
        # Check for source information
        if '**Source:**' in content or '> **Source:**' in content:
            analysis['has_source_info'] = True
            analysis['quality_score'] += 1
        else:
            analysis['issues'].append('Missing source information')
        
        # Check for executive summary
        if any(phrase in content.lower() for phrase in ['executive summary', 'overview', 'summary']):
            analysis['has_executive_summary'] = True
            analysis['quality_score'] += 2
        else:
            analysis['issues'].append('Missing executive summary')
        
        # Check for technical specifications
        if any(phrase in content.lower() for phrase in ['technical spec', 'specification', 'voltage', 'current', 'power']):
            analysis['has_technical_specs'] = True
            analysis['quality_score'] += 2
        else:
            analysis['issues'].append('Missing technical specifications')
        
        # Check for comprehensive content (not just basic conversion)
        if analysis['total_chars'] > 1000 and not any(phrase in content for phrase in ['[This slide contains', 'see original', 'placeholder']):
            analysis['has_comprehensive_content'] = True
            analysis['quality_score'] += 3
        else:
            analysis['issues'].append('Lacks comprehensive content')
        
        # Check for placeholder text
        if any(phrase in content for phrase in ['[This slide contains', 'see original', 'placeholder', '*[This']):
            analysis['has_placeholder_text'] = True
            analysis['issues'].append('Contains placeholder text')
        
        # Determine overall quality
        if analysis['quality_score'] >= 7:
            analysis['quality'] = 'HIGH'
        elif analysis['quality_score'] >= 4:
            analysis['quality'] = 'MEDIUM'
        else:
            analysis['quality'] = 'LOW'
        
        return analysis
        
    except Exception as e:
        return {
            'file_path': file_path,
            'error': str(e),
            'quality': 'ERROR'
        }

def audit_all_markdown_files():
    """Audit all markdown files in hvps folder"""
    hvps_path = Path('hvps')
    md_files = list(hvps_path.rglob('*.md'))
    
    results = {
        'total_files': len(md_files),
        'high_quality': [],
        'medium_quality': [],
        'low_quality': [],
        'error_files': []
    }
    
    print(f"Auditing {len(md_files)} markdown files...")
    
    for md_file in md_files:
        analysis = analyze_markdown_quality(md_file)
        
        if 'error' in analysis:
            results['error_files'].append(analysis)
        elif analysis['quality'] == 'HIGH':
            results['high_quality'].append(analysis)
        elif analysis['quality'] == 'MEDIUM':
            results['medium_quality'].append(analysis)
        else:
            results['low_quality'].append(analysis)
    
    return results

# Run the audit
results = audit_all_markdown_files()

print(f"\n=== HVPS MARKDOWN FILES AUDIT RESULTS ===")
print(f"Total files analyzed: {results['total_files']}")
print(f"High quality: {len(results['high_quality'])}")
print(f"Medium quality: {len(results['medium_quality'])}")
print(f"Low quality: {len(results['low_quality'])}")
print(f"Error files: {len(results['error_files'])}")

print(f"\n=== HIGH QUALITY FILES ===")
for file_info in results['high_quality']:
    print(f"✅ {file_info['file_path']} (Score: {file_info['quality_score']}/9)")

print(f"\n=== MEDIUM QUALITY FILES (Need Improvement) ===")
for file_info in results['medium_quality'][:10]:  # Show first 10
    print(f"⚠️  {file_info['file_path']} (Score: {file_info['quality_score']}/9)")
    print(f"   Issues: {', '.join(file_info['issues'])}")

print(f"\n=== LOW QUALITY FILES (Need Major Improvement) ===")
for file_info in results['low_quality'][:15]:  # Show first 15
    print(f"❌ {file_info['file_path']} (Score: {file_info['quality_score']}/9)")
    print(f"   Issues: {', '.join(file_info['issues'])}")
    print(f"   Size: {file_info['total_chars']} chars")

if len(results['low_quality']) > 15:
    print(f"   ... and {len(results['low_quality']) - 15} more low quality files")

print(f"\n=== SUMMARY ===")
total_needing_improvement = len(results['medium_quality']) + len(results['low_quality'])
print(f"Files needing improvement: {total_needing_improvement}/{results['total_files']}")
print(f"Improvement completion: {len(results['high_quality'])}/{results['total_files']} ({len(results['high_quality'])/results['total_files']*100:.1f}%)")

