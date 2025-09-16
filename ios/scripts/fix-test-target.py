#!/usr/bin/env python3

"""
Script to fix the DungeonKitTests target by adding missing test files
"""

import os
import uuid
import re

PROJECT_FILE = "HealerKit.xcodeproj/project.pbxproj"

def read_project_file():
    """Read the Xcode project file"""
    with open(PROJECT_FILE, 'r') as f:
        return f.read()

def write_project_file(content):
    """Write the Xcode project file"""
    with open(PROJECT_FILE, 'w') as f:
        f.write(content)

def generate_uuid():
    """Generate a UUID for Xcode identifiers"""
    return str(uuid.uuid4()).upper().replace('-', '')[:24]

def add_file_to_project(content, file_path, file_name):
    """Add a test file to the project"""

    # Generate UUIDs for the file reference and build file
    file_ref_id = generate_uuid()
    build_file_id = generate_uuid()

    print(f"Adding {file_path} with IDs: {file_ref_id}, {build_file_id}")

    # Add PBXBuildFile entry
    build_file_entry = f"\t\t{build_file_id} /* {file_name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ref_id} /* {file_name} */; }};"

    # Find the end of PBXBuildFile section
    build_file_section = re.search(r'\/\* Begin PBXBuildFile section \*\/(.*?)\/\* End PBXBuildFile section \*\/', content, re.DOTALL)
    if build_file_section:
        # Insert before the end comment
        end_pos = content.find('/* End PBXBuildFile section */')
        content = content[:end_pos] + build_file_entry + '\n' + content[end_pos:]

    # Add PBXFileReference entry
    file_ref_entry = f"\t\t{file_ref_id} /* {file_name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {file_name}; sourceTree = \"<group>\"; }};"

    # Find the end of PBXFileReference section
    file_ref_section = re.search(r'\/\* Begin PBXFileReference section \*\/(.*?)\/\* End PBXFileReference section \*\/', content, re.DOTALL)
    if file_ref_section:
        end_pos = content.find('/* End PBXFileReference section */')
        content = content[:end_pos] + file_ref_entry + '\n' + content[end_pos:]

    # Add to Sources Build Phase for DungeonKitTests target
    # Find the sources build phase for DungeonKitTests
    sources_phase_pattern = r'(A194BCD52E7873C400DC3B4F \/\* Sources \*\/ = {[^}]+files = \([^)]+)'
    sources_match = re.search(sources_phase_pattern, content, re.DOTALL)

    if sources_match:
        # Add the build file reference
        build_file_ref = f"\t\t\t\t{build_file_id} /* {file_name} in Sources */,"
        insert_pos = sources_match.end()
        content = content[:insert_pos] + '\n' + build_file_ref + content[insert_pos:]

    return content

def main():
    """Main function to add test files to project"""

    if not os.path.exists(PROJECT_FILE):
        print(f"Error: {PROJECT_FILE} not found")
        return

    # Read current project file
    content = read_project_file()

    # Test files to add - check what actually exists
    test_files = [
        ("DungeonKitTests/ModelTests/DungeonTests.swift", "DungeonTests.swift"),
        ("DungeonKitTests/ModelTests/BossEncounterTests.swift", "BossEncounterTests.swift"),
        ("DungeonKitTests/ModelTests/SeasonTests.swift", "SeasonTests.swift"),
    ]

    # Add each test file
    for file_path, file_name in test_files:
        if os.path.exists(file_path):
            # Check if file is already in project
            if file_name not in content:
                print(f"Adding {file_name} to project...")
                content = add_file_to_project(content, file_path, file_name)
            else:
                print(f"File {file_name} already in project")
        else:
            print(f"Warning: {file_path} does not exist")

    # Write updated project file
    write_project_file(content)
    print("✅ Project file updated successfully!")
    print("💡 Run 'xcodebuild clean' to ensure changes take effect")

if __name__ == "__main__":
    main()