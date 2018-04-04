
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scorpion/version"

Gem::Specification.new do |spec|
  spec.name          = "scorpion-ioc"
  spec.version       = "#{ Scorpion::VERSION }"
  spec.authors       = ["Paul Alexander"]
  spec.email         = ["me@phallguy.com"]
  spec.summary       = "Add IoC to rails with minimal fuss and ceremony"
  spec.description   = "Embrace convention over configuration while still benefitting from dependency injection design principles." # rubocop:disable Metrics/LineLength
  spec.homepage      = "https://github.com/phallguy/scorpion"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z 2>/dev/null`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 4.0"
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 3.00"
  spec.add_development_dependency "rspec-rails", "~> 3.00"
  spec.add_development_dependency "combustion", "~> 0.5.3"
  spec.add_development_dependency "sqlite3"
end
