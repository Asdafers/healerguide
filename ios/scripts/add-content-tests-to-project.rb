#!/usr/bin/env ruby

# Script to add ContentValidationTests to Xcode project
# This script modifies the project.pbxproj file to include the new test files

require 'xcodeproj'

# Project path
project_path = 'HealerKit.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the DungeonKitTests target
test_target = project.targets.find { |target| target.name == 'DungeonKitTests' }

if test_target.nil?
  puts "❌ DungeonKitTests target not found"
  exit 1
end

# Find the DungeonKitTests group
test_group = project.main_group.groups.find { |group| group.name == 'DungeonKitTests' }

if test_group.nil?
  puts "❌ DungeonKitTests group not found"
  exit 1
end

# Create ContentValidationTests group if it doesn't exist
content_validation_group = test_group.groups.find { |group| group.name == 'ContentValidationTests' }
if content_validation_group.nil?
  content_validation_group = test_group.new_group('ContentValidationTests')
  puts "✅ Created ContentValidationTests group"
end

# Test files to add
test_files = [
  'ContentValidationTests/DungeonContentValidationTests.swift',
  'ContentValidationTests/BossEncounterContentValidationTests.swift',
  'ContentValidationTests/DataIntegrityValidationTests.swift'
]

added_files = 0

test_files.each do |file_path|
  # Check if file exists on disk
  full_path = "DungeonKitTests/#{file_path}"
  unless File.exist?(full_path)
    puts "⚠️  File not found: #{full_path}"
    next
  end

  # Check if file is already in project
  existing_file = content_validation_group.files.find { |f| f.path&.end_with?(File.basename(file_path)) }
  if existing_file
    puts "⚠️  File already in project: #{file_path}"
    next
  end

  # Add file to group
  file_ref = content_validation_group.new_file(full_path)

  # Add file to test target
  test_target.add_file_references([file_ref])

  puts "✅ Added #{file_path} to project and test target"
  added_files += 1
end

if added_files > 0
  # Save the project
  project.save
  puts "🎉 Successfully added #{added_files} test files to Xcode project"
  puts "💡 You may need to clean and rebuild the project for changes to take effect"
else
  puts "ℹ️  No new files to add"
end