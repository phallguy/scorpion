require "bundler/gem_tasks"

desc "Run the specs"
task :specs do
  system "rspec"
end

desc "Run linters on the codebase"
task :lint do
  system "rubocop"
end

task :default => [ :lint, :specs ]
task :release => [ :default ]
