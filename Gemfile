# frozen_string_literal: true

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  if place_or_version =~ /\A(git[:@][^#]*)#(.*)/
    [fake_version, { git: Regexp.last_match(1), branch: Regexp.last_match(2), require: false }].compact
  elsif place_or_version =~ %r{\Afile:\/\/(.*)}
    ['>= 0', { path: File.expand_path(Regexp.last_match(1)), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

# Dependencies used by Rake to ship the module

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "puppet-module-posix-default-r#{minor_version}", require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}",     require: false, platforms: [:ruby]
  gem 'pdk', *location_for(ENV['PDK_GEM_VERSION'])
  gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'])
  # Automatic jenkins job to push to forge requires puppet 5 which is incompatible with modern bolt
  if ENV['GEM_BOLT']
    gem 'bolt', '~> 1', require: false
  end
  # Pin puppet blacksmith to avoid failures in forge module push job
  gem 'puppet-blacksmith', '4.1.2'
end
