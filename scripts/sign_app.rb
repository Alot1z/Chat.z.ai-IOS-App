#!/usr/bin/env ruby

require 'xcodeproj'

puts 'Setting up code signing...'
project_path = 'Chat.z.ai.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.first
raise 'No targets found in project.' unless target

project.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  config.build_settings['CODE_SIGN_IDENTITY'] = 'iPhone Developer'
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
end

target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_STYLE'] = 'Manual'
  config.build_settings['CODE_SIGN_IDENTITY'] = 'iPhone Developer'
  config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = ''
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
  config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
end

project.save
puts 'Code signing settings updated for unsigned builds!'
