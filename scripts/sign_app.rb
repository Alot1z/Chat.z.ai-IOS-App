#!/usr/bin/env ruby

# Applies unsigned-signing settings to project and all targets.

require 'xcodeproj'

PROJECT_PATH = 'Chat.z.ai.xcodeproj'.freeze
UNSIGNED_SETTINGS = {
  'CODE_SIGN_STYLE' => 'Manual',
  'CODE_SIGN_IDENTITY' => '',
  'PROVISIONING_PROFILE_SPECIFIER' => '',
  'DEVELOPMENT_TEAM' => '',
  'CODE_SIGNING_REQUIRED' => 'NO',
  'CODE_SIGNING_ALLOWED' => 'NO'
}.freeze

project = Xcodeproj::Project.open(PROJECT_PATH)

(project.build_configurations + project.targets.flat_map(&:build_configurations)).each do |config|
  UNSIGNED_SETTINGS.each do |key, value|
    config.build_settings[key] = value
  end
end

project.save
puts 'Unsigned signing settings were applied across project and targets.'
