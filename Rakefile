require 'rake'
require 'rake/file_utils'

include Rake::FileUtilsExt

desc 'Install dependencies'
task :setup do
  sh 'bundle install'
end

desc 'Rebuild project schemes'
task :schemes do
  ruby 'scripts/setup_schemes.rb'
end

desc 'Apply unsigned signing settings'
task :sign do
  ruby 'scripts/sign_app.rb'
end

desc 'Build unsigned IPA'
task build: %i[schemes sign] do
  sh 'scripts/build_and_deploy.sh'
end

desc 'Install first IPA on connected device'
task :install do
  ipa_path = Dir.glob('build/ipa/*.ipa').first || Dir.glob('**/*.ipa').first
  abort('No IPA found. Run rake build first.') unless ipa_path

  sh "ios-deploy --debug --bundle #{ipa_path}"
end

desc 'Remove build artifacts'
task :clean do
  rm_rf 'build/'
end

task default: :build
