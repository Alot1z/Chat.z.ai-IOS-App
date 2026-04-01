#!/usr/bin/env ruby

# Validates that the expected shared Xcode scheme exists.

PROJECT_PATH = 'Chat.z.ai.xcodeproj'.freeze
TARGET_SCHEME = 'Chat.z.ai'.freeze
SHARED_SCHEME_PATH = File.join(PROJECT_PATH, 'xcshareddata', 'xcschemes', "#{TARGET_SCHEME}.xcscheme").freeze

unless File.exist?(SHARED_SCHEME_PATH)
  warn <<~MSG
    Missing shared scheme: #{SHARED_SCHEME_PATH}

    CI builds require a committed shared scheme and must not auto-repair the project.
    Please run the maintenance workflow (or repair script) explicitly, commit the updated
    #{PROJECT_PATH} contents, and re-run this build.
  MSG
  exit 1
end

puts "Shared scheme found: #{SHARED_SCHEME_PATH}"
