#!/usr/bin/env ruby

# Repairs or creates a minimal Xcode project and regenerates shared schemes.

require 'fileutils'
require 'xcodeproj'

PROJECT_PATH = 'Chat.z.ai.xcodeproj'.freeze
PBXPROJ_PATH = File.join(PROJECT_PATH, 'project.pbxproj').freeze
TARGET_NAME = 'Chat.z.ai'.freeze
SOURCE_ROOT = 'Chat.z.ai'.freeze

def create_or_repair_project!
  project = Xcodeproj::Project.new(PROJECT_PATH)

  main_group = project.main_group.find_subpath(SOURCE_ROOT, true)
  main_group.set_source_tree('SOURCE_ROOT')

  target = project.new_target(:application, TARGET_NAME, :ios, '14.0')
  target.product_name = TARGET_NAME

  target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.chatai.app'
    config.build_settings['INFOPLIST_FILE'] = "#{SOURCE_ROOT}/Info.plist"
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  end

  project.save
  project
end

def load_project
  return create_or_repair_project! unless File.exist?(PBXPROJ_PATH)

  Xcodeproj::Project.open(PROJECT_PATH)
rescue StandardError => e
  warn "Project file is invalid (#{e.message}). Rebuilding a minimal project..."
  FileUtils.rm_rf(PROJECT_PATH)
  create_or_repair_project!
end

def ensure_target!(project)
  return if project.targets.any? { |t| t.name == TARGET_NAME }

  warn "Missing target #{TARGET_NAME}; creating it..."
  project.new_target(:application, TARGET_NAME, :ios, '14.0')
  project.save
end

project = load_project
ensure_target!(project)

puts 'Regenerating user/shared schemes...'
project.recreate_user_schemes
project.save

puts 'Schemes regenerated successfully.'
system("xcodebuild -list -project #{PROJECT_PATH}")
