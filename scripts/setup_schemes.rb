#!/usr/bin/env ruby

require 'xcodeproj'

PROJECT_PATH = 'Chat.z.ai.xcodeproj'
TARGET_NAME = 'Chat.z.ai'

def build_project
  project = Xcodeproj::Project.new(PROJECT_PATH)
  target = project.new_target(:application, TARGET_NAME, :ios, '14.0')

  target.build_configurations.each do |config|
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.chatai.app'
    config.build_settings['INFOPLIST_FILE'] = 'Chat.z.ai/Info.plist'
    config.build_settings['SWIFT_VERSION'] = '5.0'
    config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
    config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
    config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    config.build_settings['CODE_SIGN_IDENTITY'] = ''
  end

  group = project.main_group.find_subpath('Chat.z.ai', true)
  group.set_source_tree('<group>')

  Dir.glob('Chat.z.ai/**/*').sort.each do |path|
    next unless File.file?(path)

    file_ref = group.new_file(path)
    ext = File.extname(path)

    if ext == '.swift'
      target.source_build_phase.add_file_reference(file_ref)
    elsif ['.storyboard', '.xcassets'].include?(ext)
      target.resources_build_phase.add_file_reference(file_ref)
    end
  end

  project.recreate_user_schemes
  project.save
end

puts 'Ensuring Xcode project and scheme exist...'
begin
  project = Xcodeproj::Project.open(PROJECT_PATH)
  project.recreate_user_schemes
  project.save
rescue StandardError => e
  warn "Rebuilding project because existing project is invalid: #{e.message}"
  build_project
end

puts 'Done.'
system("xcodebuild -list -project #{PROJECT_PATH}")
