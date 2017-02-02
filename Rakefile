require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = "--tag integration"
end
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = "--tag ~integration"
end

require "chefstyle"
require "rubocop/rake_task"
desc "Run ChefStyle"
RuboCop::RakeTask.new(:chefstyle) do |task|
  task.options << "--display-cop-names"
end

desc "Generate coverage report"
RSpec::Core::RakeTask.new(:coverage) do |t|
  ENV["COVERAGE"] = "true"
end

namespace :travis do
  desc "Run tests on Travis"
  task ci: %w{chefstyle unit integration}
end

task default: %w{travis:ci}
