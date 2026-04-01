require 'rake'
require 'rake/file_utils'

include Rake::FileUtilsExt

desc 'Setup project dependencies'
task :setup do
  sh 'bundle install'
  sh 'gem install shenzhen ios-deploy xcodeproj'
end

desc 'Recreate Xcode schemes'
task :schemes do
  ruby 'scripts/setup_schemes.rb'
end

desc 'Build unsigned IPA'
task :build do
  sh 'scripts/build_and_deploy.sh'
end

desc 'Install to device'
task :install do
  ipa_path = Dir.glob('**/*.ipa').first || 'build/ipa/Chat.z.ai-unsigned.ipa'
  sh "ios-deploy --debug --bundle #{ipa_path}"
end

desc 'Full build and install'
task deploy: %i[build install]

desc 'Clean build artifacts'
task :clean do
  rm_rf 'build/'
  rm_rf 'Chat.z.ai/build/'
end

task default: :build
