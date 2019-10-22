# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem 'puppet'
  gem 'puppetlabs_spec_helper'

  # Dependencies used by Rake to ship the module
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
end
