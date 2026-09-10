# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'net/http'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require 'uri'

# Ensures the `terraform` CLI is present on PATH before acceptance specs run.
#
# Background (bolt_193 debug session `acceptance-terraform-missing`):
# spec/acceptance/{apply,destroy,resolve_reference}_spec.rb shell out to
# `terraform` directly (Open3.capture3) and run the `terraform::initialize`
# Bolt task against target 'localhost' -- i.e. against the CI runner host
# itself, not the Litmus-provisioned acceptance target. The self-hosted
# runner image used by puppetlabs/cat-github-actions's
# `module_acceptance.yml@main` reusable workflow does not ship `terraform`,
# and that workflow exposes no hook for injecting an install step, so this
# module has to guarantee it itself.
#
# Installs into a repo-local, gitignored directory (`tmp/terraform-bin`)
# and prepends it to ENV['PATH'] for the current process -- no root/sudo
# required, and safe to call multiple times (no-ops once terraform is
# reachable).
module TerraformBootstrap
  # Bump periodically; override per-run with TERRAFORM_VERSION=x.y.z.
  DEFAULT_VERSION = '1.9.8'
  RELEASES_BASE_URL = 'https://releases.hashicorp.com/terraform'

  def self.ensure_installed!
    return true if on_path?

    puts "[terraform_bootstrap] 'terraform' not found on PATH -- installing a local copy for acceptance specs."
    install!

    return true if on_path?

    raise "[terraform_bootstrap] terraform install completed but 'terraform version' still fails; PATH=#{ENV.fetch('PATH', '')}"
  end

  def self.on_path?
    _stdout, _stderr, status = Open3.capture3('terraform version')
    status.success?
  rescue Errno::ENOENT
    false
  end

  def self.install!
    version = resolve_version
    os = platform_os
    arch = platform_arch
    filename = "terraform_#{version}_#{os}_#{arch}.zip"
    base_url = "#{RELEASES_BASE_URL}/#{version}"

    Dir.mktmpdir('terraform-bootstrap') do |tmp_dir|
      zip_path = File.join(tmp_dir, filename)
      File.binwrite(zip_path, http_get("#{base_url}/#{filename}"))
      verify_checksum!(zip_path, filename, version, base_url)
      unzip!(zip_path, tmp_dir)

      FileUtils.mkdir_p(install_dir)
      FileUtils.install(File.join(tmp_dir, 'terraform'), File.join(install_dir, 'terraform'), mode: 0o755)
    end

    ENV['PATH'] = "#{install_dir}#{File::PATH_SEPARATOR}#{ENV.fetch('PATH', '')}"
    puts "[terraform_bootstrap] Installed terraform #{version} (#{os}/#{arch}) to #{install_dir}"
  end

  def self.install_dir
    File.expand_path(File.join(__dir__, '..', '..', 'tmp', 'terraform-bin'))
  end

  def self.resolve_version
    env_version = ENV.fetch('TERRAFORM_VERSION', nil)
    return env_version unless env_version.nil? || env_version.empty?

    DEFAULT_VERSION
  end

  def self.platform_os
    case RbConfig::CONFIG['host_os']
    when %r{linux} then 'linux'
    when %r{darwin} then 'darwin'
    else raise "[terraform_bootstrap] Unsupported OS for terraform auto-install: #{RbConfig::CONFIG['host_os']} (set up terraform manually, or extend TerraformBootstrap)"
    end
  end

  def self.platform_arch
    case RbConfig::CONFIG['host_cpu']
    when 'x86_64', 'amd64' then 'amd64'
    when %r{\A(arm64|aarch64)\z} then 'arm64'
    else raise "[terraform_bootstrap] Unsupported CPU architecture for terraform auto-install: #{RbConfig::CONFIG['host_cpu']}"
    end
  end

  def self.verify_checksum!(zip_path, filename, version, base_url)
    sums_text = http_get("#{base_url}/terraform_#{version}_SHA256SUMS")
    expected_line = sums_text.lines.find { |line| line.split(%r{\s+}).last == filename }
    raise "[terraform_bootstrap] No checksum entry for #{filename} in terraform_#{version}_SHA256SUMS" unless expected_line

    expected_sha = expected_line.split(%r{\s+}).first
    actual_sha = Digest::SHA256.file(zip_path).hexdigest
    return if actual_sha == expected_sha

    raise "[terraform_bootstrap] Checksum mismatch for #{filename}: expected #{expected_sha}, got #{actual_sha}"
  end

  def self.unzip!(zip_path, dest_dir)
    _stdout, stderr, status = Open3.capture3('unzip', '-o', '-q', zip_path, '-d', dest_dir)
    raise "[terraform_bootstrap] Failed to unzip #{zip_path}: #{stderr}" unless status.success?
  rescue Errno::ENOENT
    raise "[terraform_bootstrap] 'unzip' is required to install terraform automatically but was not found on PATH"
  end

  def self.http_get(uri_str, redirect_limit = 5)
    raise "[terraform_bootstrap] Too many HTTP redirects fetching #{uri_str}" if redirect_limit.zero?

    uri = URI.parse(uri_str)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(Net::HTTP::Get.new(uri))
    end

    case response
    when Net::HTTPSuccess
      response.body
    when Net::HTTPRedirection
      http_get(response['location'], redirect_limit - 1)
    else
      raise "[terraform_bootstrap] HTTP #{response.code} fetching #{uri_str}"
    end
  end
end
