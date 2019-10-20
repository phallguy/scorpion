require "simplecov"
SimpleCov.start

require "pry"
require "bundler/setup"
require "combustion"

Combustion.initialize! :all do
  config.active_record.sqlite3.represent_boolean_as_integer = true
end

require "rspec/rails"
require "scorpion"
require "scorpion/rspec"

root_path = File.expand_path( "../..", __FILE__ )

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[ File.join( root_path, "spec/support/**/*.rb" ) ].each { |f| require f }

RSpec.configure do |config|

  config.order = "random"

  config.filter_run focus: true
  config.filter_run_excluding :broken => true
  config.run_all_when_everything_filtered = true

  config.before(:each)  { GC.disable }
  config.after(:each)   { GC.enable }

  config.before( :each, type: :model ) do
    [ Todo, Author ].each(&:destroy_all)
  end
end