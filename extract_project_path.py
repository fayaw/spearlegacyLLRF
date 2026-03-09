#!/usr/bin/env python3
import re

def extract_project_path():
    with open('Designs/ProjectPath.md', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find the mermaid diagram
    lines = content.split('\n')
    mermaid_start = None
    mermaid_end = None
    
    for i, line in enumerate(lines):
        if '```mermaid' in line:
            mermaid_start = i + 1
        elif mermaid_start is not None and '```' in line and 'mermaid' not in line:
            mermaid_end = i
            break
    
    if mermaid_start and mermaid_end:
        mermaid_content = '\n'.join(lines[mermaid_start:mermaid_end])
        print("=== MERMAID DIAGRAM FOUND ===")
        print(f"Lines {mermaid_start} to {mermaid_end}")
        print("=== CONTENT ===")
        print(mermaid_content[:2000])
        print("\n=== ANALYSIS ===")
        
        # Count subgraphs
        subgraphs = re.findall(r'subgraph\s+(\w+)\[([^\]]+)\]', mermaid_content)
        print(f"Found {len(subgraphs)} subsystems:")
        for name, title in subgraphs:
            print(f"  - {name}: {title}")
    
    # Extract timeline information
    print("\n=== HARDWARE READINESS ===")
    table_start = content.find('| Subsystem | Hardware | Status |')
    if table_start != -1:
        table_section = content[table_start:table_start+2000]
        table_lines = table_section.split('\n')[2:]  # Skip header and separator
        for line in table_lines:
            if line.strip() and '|' in line:
                parts = [p.strip() for p in line.split('|')[1:-1]]  # Remove empty first/last
                if len(parts) >= 3:
                    print(f"  {parts[0]}: {parts[2]}")
                if not line.strip().startswith('|'):
                    break

if __name__ == "__main__":
    extract_project_path()

