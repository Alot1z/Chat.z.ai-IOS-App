#!/usr/bin/env ruby

# Repairs or creates a minimal Xcode project and regenerates shared schemes.

require 'fileutils'
require 'xcodeproj'

PROJECT_PATH = 'Chat.z.ai.xcodeproj'.freeze
PBXPROJ_PATH = File.join(PROJECT_PATH, 'project.pbxproj').freeze
TARGET_NAME = 'Chat.z.ai'.freeze
SOURCE_ROOT = 'Chat.z.ai'.freeze
ENTITLEMENTS_PATH = "#{SOURCE_ROOT}/Chat.z.ai.entitlements".freeze

SOURCE_FILES = %w[
  AppDelegate.swift
  SceneDelegate.swift
  ContentView.swift
  ChatView.swift
  ChatViewModel.swift
  APIClient.swift
].freeze

RESOURCE_FILES = %w[
  Base.lproj/LaunchScreen.storyboard
  Assets.xcassets
].freeze

MANAGED_FILES = (SOURCE_FILES + RESOURCE_FILES + %w[Info.plist Chat.z.ai.entitlements]).freeze

def apply_base_settings!(target)
  target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.chatai.app'
    config.build_settings['INFOPLIST_FILE'] = "#{SOURCE_ROOT}/Info.plist"
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
    config.build_settings['CODE_SIGN_ENTITLEMENTS'] = ENTITLEMENTS_PATH
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = ''
    config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = '$(inherited) @executable_path/Frameworks'
  end
end

def ensure_file_reference!(project, main_group, relative_path)
  existing = main_group.files.find { |f| f.path == relative_path }
  return existing if existing

  main_group.new_file(relative_path)
end

def ensure_build_file!(phase, file_ref)
  return if phase.files_references.include?(file_ref)

  phase.add_file_reference(file_ref)
end

def remove_stale_build_files!(phase, managed_paths)
  managed_names = managed_paths.map { |path| File.basename(path) }

  phase.files.each do |build_file|
    file_ref = build_file.file_ref
    next unless file_ref

    ref_path = file_ref.path.to_s
    should_remove = managed_paths.include?(ref_path) || managed_names.include?(File.basename(ref_path))
    build_file.remove_from_project if should_remove
  end
end

def attach_files_to_target!(project, target, main_group)
  remove_stale_build_files!(target.source_build_phase, SOURCE_FILES)
  remove_stale_build_files!(target.resources_build_phase, RESOURCE_FILES)

  SOURCE_FILES.each do |path|
    file_ref = ensure_file_reference!(project, main_group, path)
    ensure_build_file!(target.source_build_phase, file_ref)
  end

  RESOURCE_FILES.each do |path|
    file_ref = ensure_file_reference!(project, main_group, path)
    ensure_build_file!(target.resources_build_phase, file_ref)
  end

  ensure_file_reference!(project, main_group, 'Info.plist')
  ensure_file_reference!(project, main_group, 'Chat.z.ai.entitlements')
end

def create_or_repair_project!
  project = Xcodeproj::Project.new(PROJECT_PATH)

  main_group = project.main_group.find_subpath(SOURCE_ROOT, true)
  main_group.set_source_tree('SOURCE_ROOT')

  target = project.new_target(:application, TARGET_NAME, :ios, '14.0')
  target.product_name = TARGET_NAME

  apply_base_settings!(target)
  attach_files_to_target!(project, target, main_group)

  project.save
  project
end

def load_project
  return create_or_repair_project! unless File.exist?(PBXPROJ_PATH)

  project = Xcodeproj::Project.open(PROJECT_PATH)

  # Recover from skeletal project files that technically parse but contain no objects.
  if project.root_object.nil? || project.main_group.nil?
    warn 'Project file is missing core objects. Rebuilding a minimal project...'
    FileUtils.rm_rf(PROJECT_PATH)
    return create_or_repair_project!
  end

  project
rescue StandardError => e
  warn "Project file is invalid (#{e.message}). Rebuilding a minimal project..."
  FileUtils.rm_rf(PROJECT_PATH)
  create_or_repair_project!
end

def ensure_target!(project)
  target = project.targets.find { |t| t.name == TARGET_NAME }

  unless target
    warn "Missing target #{TARGET_NAME}; creating it..."
    target = project.new_target(:application, TARGET_NAME, :ios, '14.0')
  end

  main_group = project.main_group.find_subpath(SOURCE_ROOT, true)
  main_group.set_source_tree('SOURCE_ROOT')

  apply_base_settings!(target)
  attach_files_to_target!(project, target, main_group)

  # Remove duplicate or root-level references for files managed under SOURCE_ROOT.
  project.files.each do |file_ref|
    next unless MANAGED_FILES.include?(file_ref.path.to_s)
    next if file_ref.parent == main_group

    file_ref.remove_from_project
  end

  project.save
end

project = load_project
ensure_target!(project)

puts 'Regenerating user/shared schemes...'
project.recreate_user_schemes
project.save

puts 'Schemes regenerated successfully.'
system("xcodebuild -list -project #{PROJECT_PATH}")
