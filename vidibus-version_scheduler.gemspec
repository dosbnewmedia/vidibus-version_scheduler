# encoding: utf-8
lib = File.expand_path("../lib/", __FILE__)
$:.unshift lib unless $:.include?(lib)

require "vidibus/version_scheduler/version"

Gem::Specification.new do |s|
  s.name        = "vidibus-version_scheduler"
  s.version     = Vidibus::VersionScheduler::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Andre Pankratz"
  s.email       = "andre@vidibus.com"
  s.homepage    = "https://github.com/vidibus/vidibus-version_scheduler"
  s.summary     = "Provides scheduling of future versions"
  s.description = "Schedules migration to future versions created by Vidibus::Versioning."
  s.license     = 'MIT'

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "vidibus-version_scheduler"

  s.add_dependency "mongoid", ">= 5", "< 7"
  s.add_dependency "delayed_job"
  s.add_dependency "delayed_job_mongoid"
  s.add_dependency 'mongoid-observers', '~> 0.3.0'
  s.add_dependency "vidibus-versioning"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "timecop"
  s.add_development_dependency "simplecov"

  s.files = Dir.glob("{lib,app,config}/**/*") + %w[LICENSE README.md Rakefile]
  s.require_path = "lib"
end
