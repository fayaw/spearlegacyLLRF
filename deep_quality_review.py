import os
import re
from pathlib import Path
from datetime import datetime

class DeepQualityReviewer:
    def __init__(self):
        self.all_files = []
        self.quality_issues = {}
        self.high_quality_files = []
        self.needs_improvement = []
    
    def comprehensive_quality_check(self, file_path):
        """Perform comprehensive quality check on a markdown file"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            quality_score = 0
            issues = []
            
            # Check 1: Proper title structure (2 points)
            if content.startswith('#') and len(content.split('\n')[0]) > 10:
                quality_score += 2
            else:
                issues.append("Missing or inadequate title")
            
            # Check 2: Source information (2 points)
            if '**Source:**' in content and '> **Source:**' in content:
                quality_score += 2
            else:
                issues.append("Missing proper source information")
            
            # Check 3: Executive summary (3 points)
            if 'Executive Summary' in content and len(re.findall(r'## Executive Summary.*?\n\n(.*?)\n\n', content, re.DOTALL)) > 0:
                summary_content = re.findall(r'## Executive Summary.*?\n\n(.*?)\n\n', content, re.DOTALL)
                if summary_content and len(summary_content[0]) > 200:
                    quality_score += 3
                else:
                    quality_score += 1
                    issues.append("Executive summary too brief")
            else:
                issues.append("Missing executive summary")
            
            # Check 4: Technical specifications (3 points)
            if 'Technical Specifications' in content:
                tech_specs = re.findall(r'## Technical Specifications.*?\n\n(.*?)\n\n', content, re.DOTALL)
                if tech_specs and len(tech_specs[0]) > 100:
                    quality_score += 3
                else:
                    quality_score += 1
                    issues.append("Technical specifications too brief")
            else:
                issues.append("Missing technical specifications")
            
            # Check 5: Proper ASCII diagrams (3 points)
            ascii_blocks = re.findall(r'```\n(.*?)\n```', content, re.DOTALL)
            has_good_ascii = False
            for block in ascii_blocks:
                if (len(block) > 100 and 
                    ('---->' in block or '|||' in block or '++' in block or 'HVPS' in block) and
                    not re.search(r"^[a-zA-Z]{1,3}\s*$", block.strip(), re.MULTILINE)):
                    has_good_ascii = True
                    break
            
            if has_good_ascii:
                quality_score += 3
            elif ascii_blocks:
                quality_score += 1
                issues.append("ASCII diagrams need improvement")
            else:
                issues.append("Missing ASCII diagrams")
            
            # Check 6: Comprehensive content (4 points)
            if len(content) > 2000:
                quality_score += 4
            elif len(content) > 1000:
                quality_score += 2
                issues.append("Content could be more comprehensive")
            else:
                issues.append("Content too brief")
            
            # Check 7: No meaningless ASCII (2 points)
            meaningless_patterns = [
                r"'XS\s+besssasal",
                r"fe\]\s+seen\s+Toor",
                r"[a-z]{2,3}\s+[a-z]{4,}\s+[a-z]{4,}\s+[a-z]{2,3}",
            ]
            
            has_meaningless = False
            for pattern in meaningless_patterns:
                if re.search(pattern, content, re.MULTILINE):
                    has_meaningless = True
                    break
            
            if not has_meaningless:
                quality_score += 2
            else:
                issues.append("Contains meaningless ASCII patterns")
            
            # Check 8: System integration context (2 points)
            if 'System Integration' in content or 'integration' in content.lower():
                quality_score += 2
            else:
                issues.append("Missing system integration context")
            
            # Check 9: Safety considerations (2 points)
            if 'Safety' in content and ('90kV' in content or 'high voltage' in content.lower()):
                quality_score += 2
            else:
                issues.append("Missing safety considerations")
            
            # Check 10: Proper document structure (1 point)
            section_count = len(re.findall(r'^##\s+', content, re.MULTILINE))
            if section_count >= 5:
                quality_score += 1
            else:
                issues.append("Insufficient document structure")
            
            return {
                'file_path': file_path,
                'quality_score': quality_score,
                'max_score': 24,
                'issues': issues,
                'content_length': len(content),
                'section_count': section_count
            }
            
        except Exception as e:
            return {
                'file_path': file_path,
                'quality_score': 0,
                'max_score': 24,
                'issues': [f"Error reading file: {e}"],
                'content_length': 0,
                'section_count': 0
            }
    
    def review_all_files(self):
        """Review all markdown files in the HVPS directory"""
        hvps_path = Path('hvps')
        md_files = list(hvps_path.rglob('*.md'))
        
        print(f"Conducting deep quality review of {len(md_files)} markdown files...")
        
        for md_file in md_files:
            analysis = self.comprehensive_quality_check(md_file)
            self.all_files.append(analysis)
            
            # Categorize by quality
            quality_percentage = (analysis['quality_score'] / analysis['max_score']) * 100
            
            if quality_percentage >= 80:  # 80% or higher
                self.high_quality_files.append(analysis)
            else:
                self.needs_improvement.append(analysis)
                self.quality_issues[str(md_file)] = analysis
        
        return self.generate_quality_report()
    
    def generate_quality_report(self):
        """Generate comprehensive quality report"""
        total_files = len(self.all_files)
        high_quality_count = len(self.high_quality_files)
        needs_improvement_count = len(self.needs_improvement)
        
        print(f"\n=== DEEP QUALITY REVIEW RESULTS ===")
        print(f"Total files reviewed: {total_files}")
        print(f"High quality files (≥80%): {high_quality_count} ({high_quality_count/total_files*100:.1f}%)")
        print(f"Files needing improvement (<80%): {needs_improvement_count} ({needs_improvement_count/total_files*100:.1f}%)")
        
        # Calculate average quality score
        avg_score = sum(f['quality_score'] for f in self.all_files) / total_files
        avg_percentage = (avg_score / 24) * 100
        print(f"Average quality score: {avg_score:.1f}/24 ({avg_percentage:.1f}%)")
        
        # Show top quality files
        print(f"\n=== TOP QUALITY FILES ===")
        sorted_high_quality = sorted(self.high_quality_files, key=lambda x: x['quality_score'], reverse=True)
        for file_info in sorted_high_quality[:10]:
            percentage = (file_info['quality_score'] / file_info['max_score']) * 100
            print(f"✅ {file_info['file_path']} - {file_info['quality_score']}/24 ({percentage:.1f}%)")
        
        # Show files needing improvement
        if self.needs_improvement:
            print(f"\n=== FILES NEEDING IMPROVEMENT ===")
            sorted_needs_improvement = sorted(self.needs_improvement, key=lambda x: x['quality_score'])
            for file_info in sorted_needs_improvement[:15]:
                percentage = (file_info['quality_score'] / file_info['max_score']) * 100
                print(f"⚠️  {file_info['file_path']} - {file_info['quality_score']}/24 ({percentage:.1f}%)")
                print(f"   Issues: {', '.join(file_info['issues'][:3])}")
                if len(file_info['issues']) > 3:
                    print(f"   ... and {len(file_info['issues']) - 3} more issues")
        
        # Issue frequency analysis
        print(f"\n=== COMMON ISSUES ANALYSIS ===")
        issue_counts = {}
        for file_info in self.needs_improvement:
            for issue in file_info['issues']:
                issue_counts[issue] = issue_counts.get(issue, 0) + 1
        
        for issue, count in sorted(issue_counts.items(), key=lambda x: x[1], reverse=True):
            print(f"{issue}: {count} files")
        
        return {
            'total_files': total_files,
            'high_quality_count': high_quality_count,
            'needs_improvement_count': needs_improvement_count,
            'average_quality_percentage': avg_percentage,
            'needs_improvement_files': self.needs_improvement
        }

# Run the deep quality review
reviewer = DeepQualityReviewer()
results = reviewer.review_all_files()

