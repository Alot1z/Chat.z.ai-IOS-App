require 'rake'

desc 'Install Ruby dependencies'
task :setup do
  sh 'bundle install'
end

desc 'Repair/prepare the Xcode project and shared schemes'
task :schemes do
  sh 'bundle exec ruby scripts/setup_schemes.rb'
end

desc 'Apply unsigned signing configuration'
task :sign do
  sh 'bundle exec ruby scripts/sign_app.rb'
end

desc 'Build unsigned IPA'
task build: %i[schemes sign] do
  sh './scripts/build_and_deploy.sh'
end

desc 'Clean artifacts'
task :clean do
  sh 'rm -rf build'
end

task default: :build
