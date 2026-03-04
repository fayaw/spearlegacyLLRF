import os
import re
from pathlib import Path
from datetime import datetime

class SystematicQualityReviewer:
    def __init__(self):
        self.problematic_files = []
        self.quality_issues = {}
    
    def scan_all_markdown_files(self):
        """Scan all markdown files for quality issues"""
        hvps_path = Path('hvps')
        md_files = list(hvps_path.rglob('*.md'))
        
        print(f"Scanning {len(md_files)} markdown files for quality issues...")
        
        for md_file in md_files:
            issues = self.identify_quality_issues(md_file)
            if issues:
                self.problematic_files.append(md_file)
                self.quality_issues[str(md_file)] = issues
        
        return self.problematic_files
    
    def identify_quality_issues(self, file_path):
        """Identify specific quality issues in a markdown file"""
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            issues = []
            
            # Check for meaningless ASCII patterns
            if self.has_meaningless_ascii(content):
                issues.append("meaningless_ascii")
            
            # Check for empty or minimal content
            if len(content.strip()) < 500:
                issues.append("minimal_content")
            
            # Check for repetitive empty sections
            if self.has_repetitive_empty_sections(content):
                issues.append("repetitive_empty_sections")
            
            # Check for missing technical content
            if not self.has_technical_content(content):
                issues.append("missing_technical_content")
            
            # Check for poor ASCII diagrams
            if self.has_poor_ascii_diagrams(content):
                issues.append("poor_ascii_diagrams")
            
            return issues
            
        except Exception as e:
            return ["file_read_error"]
    
    def has_meaningless_ascii(self, content):
        """Check for meaningless ASCII patterns"""
        # Look for patterns like 'XS besssasal, random characters
        meaningless_patterns = [
            r"'XS\s+besssasal",
            r"[a-zA-Z]{1,3}\s+[a-zA-Z]{8,}sal",
            r"fe\]\s+seen\s+Toor",
            r"[a-z]{2,3}\s+[a-z]{4,}\s+[a-z]{4,}\s+[a-z]{2,3}",
            r"^\s*[a-zA-Z]{1,3}\s*$",  # Single random letters on lines
        ]
        
        for pattern in meaningless_patterns:
            if re.search(pattern, content, re.MULTILINE):
                return True
        return False
    
    def has_repetitive_empty_sections(self, content):
        """Check for repetitive empty sections"""
        # Look for patterns like multiple "### Slide X:" with no content
        empty_slide_pattern = r"###\s+Slide\s+\d+:.*?\n\n.*?\n\n.*?\n\n"
        matches = re.findall(empty_slide_pattern, content, re.DOTALL)
        
        # If more than 5 empty slides, it's problematic
        if len(matches) > 5:
            return True
        
        # Check for repetitive identical content
        lines = content.split('\n')
        identical_lines = 0
        prev_line = ""
        for line in lines:
            if line.strip() == prev_line.strip() and len(line.strip()) > 10:
                identical_lines += 1
            prev_line = line
        
        return identical_lines > 10
    
    def has_technical_content(self, content):
        """Check if file has meaningful technical content"""
        technical_indicators = [
            r'\d+\s*[kKmM]?[VvAaWw]',  # Voltage, current, power values
            r'\d+\s*[Oo]hm',  # Resistance values
            r'\d+\s*[Hh]z',   # Frequency values
            r'circuit|schematic|diagram',
            r'transformer|rectifier|filter',
            r'voltage|current|power|resistance',
            r'specification|requirement|parameter'
        ]
        
        for pattern in technical_indicators:
            if re.search(pattern, content, re.IGNORECASE):
                return True
        return False
    
    def has_poor_ascii_diagrams(self, content):
        """Check for poor quality ASCII diagrams"""
        # Look for ASCII blocks that are just random characters
        ascii_blocks = re.findall(r'```\n(.*?)\n```', content, re.DOTALL)
        
        for block in ascii_blocks:
            # If ASCII block is very short or just random characters
            if len(block.strip()) < 20:
                return True
            
            # Check for meaningless patterns in ASCII blocks
            if re.search(r"^[a-zA-Z]{1,3}\s*$", block.strip(), re.MULTILINE):
                return True
        
        return False
    
    def generate_quality_report(self):
        """Generate comprehensive quality report"""
        print(f"\n=== SYSTEMATIC QUALITY REVIEW REPORT ===")
        print(f"Total files scanned: {len(list(Path('hvps').rglob('*.md')))}")
        print(f"Problematic files found: {len(self.problematic_files)}")
        
        # Group by issue type
        issue_counts = {}
        for file_path, issues in self.quality_issues.items():
            for issue in issues:
                issue_counts[issue] = issue_counts.get(issue, 0) + 1
        
        print(f"\n=== ISSUE BREAKDOWN ===")
        for issue, count in sorted(issue_counts.items()):
            print(f"{issue}: {count} files")
        
        print(f"\n=== MOST PROBLEMATIC FILES ===")
        # Sort by number of issues
        sorted_files = sorted(self.quality_issues.items(), 
                            key=lambda x: len(x[1]), reverse=True)
        
        for file_path, issues in sorted_files[:15]:
            print(f"❌ {file_path}")
            print(f"   Issues: {', '.join(issues)}")
            
            # Show file size
            try:
                size = os.path.getsize(file_path)
                print(f"   Size: {size} bytes")
            except:
                pass
        
        return sorted_files
    
    def create_improvement_plan(self, sorted_files):
        """Create systematic improvement plan"""
        print(f"\n=== IMPROVEMENT PLAN ===")
        
        # Categorize files by priority
        critical_files = []
        high_priority = []
        medium_priority = []
        
        for file_path, issues in sorted_files:
            if len(issues) >= 3 or "meaningless_ascii" in issues:
                critical_files.append(file_path)
            elif len(issues) >= 2:
                high_priority.append(file_path)
            else:
                medium_priority.append(file_path)
        
        print(f"Critical (immediate fix needed): {len(critical_files)} files")
        print(f"High Priority: {len(high_priority)} files")
        print(f"Medium Priority: {len(medium_priority)} files")
        
        print(f"\n=== CRITICAL FILES FOR IMMEDIATE IMPROVEMENT ===")
        for file_path in critical_files[:10]:
            print(f"🔥 {file_path}")
        
        return critical_files, high_priority, medium_priority

# Run the systematic review
reviewer = SystematicQualityReviewer()
problematic_files = reviewer.scan_all_markdown_files()
sorted_files = reviewer.generate_quality_report()
critical, high, medium = reviewer.create_improvement_plan(sorted_files)

