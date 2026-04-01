#!/usr/bin/env ruby

require 'xcodeproj'

project = Xcodeproj::Project.open('Chat.z.ai.xcodeproj')

def apply_unsigned_settings(config)
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  config.build_settings['CODE_SIGN_IDENTITY'] = ''
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
end

project.build_configurations.each { |config| apply_unsigned_settings(config) }
project.targets.each do |target|
  target.build_configurations.each { |config| apply_unsigned_settings(config) }
end

project.save
puts 'Applied unsigned code-sign settings.'
