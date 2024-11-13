source "https://rubygems.org"

# Specify your gem's dependencies in scorpion.gemspec
gemspec
gem "activesupport"

group :development do
  gem "combustion"
end

group :test do
  gem "rails-controller-testing"
  gem "rspec"
  gem "rspec-rails"

  gem "awesome_print"
  gem "debug"
  gem "fuubar"
  gem "nokogiri"
  gem "spring"
end

gem "bundler", "~> 2"

group :development, :test do
  gem "rails", "~> 7"
  gem "rake"
  gem "sqlite3"
end
