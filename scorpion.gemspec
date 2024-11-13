lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "scorpion/version"

Gem::Specification.new do |spec|
  spec.name = "scorpion-ioc"
  spec.version = "#{Scorpion::VERSION}"
  spec.authors = ["Paul Alexander"]
  spec.email = ["me@phallguy.com"]
  spec.summary = "Add IoC to rails with minimal fuss and ceremony"
  spec.description = "Embrace convention over configuration while still benefitting from dependency injection design principles."
  spec.homepage = "https://github.com/phallguy/scorpion"
  spec.license = "MIT"

  spec.files = Dir["lib/**/*.rb"] + Dir["bin/*"]
  spec.files += Dir["[A-Z]*"] + Dir["spec/**/*"]
  spec.files << "scorpion.gemspec"
  spec.files.reject! { |fn| fn.include?(".git") }

  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
