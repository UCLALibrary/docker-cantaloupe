require 'rake'
require 'rspec'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Test the develop version'
task :test_dev do
  ENV['CANTALOUPE_VERSION'] = 'dev'
  abort 'Dev spec failed' unless RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero?
end

desc 'Test the stable version'
task :test_stable do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  abort 'Stable spec failed' unless RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero?
end

desc 'Test the stable version with a DELEGATE_URL'
task :test_stable_with_delegate do
  ENV['DELEGATE_URL'] = 'https://raw.githubusercontent.com/UCLALibrary/cantaloupe-delegate/master/lib/delegates.rb'
  ENV['CANTALOUPE_VERSION'] = 'stable'
  abort 'Stable spec failed' unless RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero?
end

desc 'Test the develop version with a DELEGATE_URL'
task :test_dev_with_delegate do
  ENV['DELEGATE_URL'] = 'https://raw.githubusercontent.com/UCLALibrary/cantaloupe-delegate/master/lib/delegates.rb'
  ENV['CANTALOUPE_VERSION'] = 'dev'
  abort 'Dev spec failed' unless RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero?
end

# Run our docker-cantaloupe tests with different ENVs
task default: %i[rubocop test]

desc 'Run tests'
task(:test) do
  ENV['CANTALOUPE_VERSION'] = 'stable'
  abort 'Stable spec failed' unless RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero?
  RSpec.clear_examples
  ENV['CANTALOUPE_VERSION'] = 'dev'
  abort 'Dev spec failed' unless RSpec::Core::Runner.run(['spec/cantaloupe_spec.rb']).zero?
end

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new
end

# Let's throw in a few aliases
task spec: :default
task rspec: :default
