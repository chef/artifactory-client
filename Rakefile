require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = "--tag integration"
end
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = "--tag ~integration"
end

namespace :travis do
  desc 'Run tests on Travis'
  task :ci => [:unit,:integration]
end
