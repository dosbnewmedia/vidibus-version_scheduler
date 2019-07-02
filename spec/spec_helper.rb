require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

$:.unshift File.expand_path('../../', __FILE__)

# require "rubygems"
require "rspec"
require "timecop"
require "vidibus-version_scheduler"

require "support/book"
require "support/stubs"

Mongo::Logger.logger.level = Logger::FATAL

Mongoid.configure do |config|
  config.connect_to('vidibus-version_scheduler_test')
end

RSpec.configure do |config|
  # config.mock_with :rr
  config.before(:each) do
    Mongoid::Clients.default.collections.
      select {|c| c.name !~ /system/}.each(&:drop)
  end

  config.after(:each) do
    Timecop.return
  end
end