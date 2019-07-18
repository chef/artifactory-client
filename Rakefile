require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:integration) do |t|
  t.rspec_opts = "--tag integration"
end
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = "--tag ~integration"
end

begin
  require "chefstyle"
  require "rubocop/rake_task"
  desc "Run Chefstyle tests"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle gem is not installed. bundle install first to make sure all dependencies are installed."
end

begin
  require "yard"
  YARD::Rake::YardocTask.new(:docs)
rescue LoadError
  puts "yard is not available. bundle install first to make sure all dependencies are installed."
end

desc "Generate coverage report"
RSpec::Core::RakeTask.new(:coverage) do |t|
  ENV["COVERAGE"] = "true"
end

task default: %w{style unit integration}
