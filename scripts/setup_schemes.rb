#!/usr/bin/env ruby

require 'xcodeproj'

puts 'Setting up Xcode schemes...'
project_path = 'Chat.z.ai.xcodeproj'
xcproj = Xcodeproj::Project.open(project_path)
xcproj.recreate_user_schemes
xcproj.save
puts 'Schemes recreated successfully!'

puts "\nAvailable schemes:"
system("xcodebuild -list -project #{project_path}")
