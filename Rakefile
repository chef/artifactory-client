require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:integration)
RSpec::Core::RakeTask.new(:unit)

namespace :travis do
  desc 'Run tests on Travis'
  task :ci => [:unit,:integration]
end
