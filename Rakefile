require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Test the develop version'
task :test_dev do
  ENV['CANTALOUPE_VERSION'] = 'dev'
  if !RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero? then abort 'Dev spec failed' end
end

desc 'Test the stable version'
task :test_stable do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  if !RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero? then abort 'Stable spec failed' end
end

# Run our docker-cantaloupe tests with different ENVs
task default: %i[rubocop test]

desc 'Run tests'
task(:test) do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  if !RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero? then abort 'Stable spec failed' end
  RSpec.clear_examples
  ENV['CANTALOUPE_VERSION'] = 'dev'
  if !RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero? then abort 'Dev spec failed' end
end

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

# Let's throw in a few aliases
task spec: :default
task rspec: :default
