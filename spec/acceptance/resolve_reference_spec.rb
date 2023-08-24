# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/run'

describe 'terraform::resolve_reference' do
  include BoltSpec::Run

  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }
  let(:terraform_dir) { File.join(RSpec.configuration.module_path, '../docker_provision') }
  let(:resource_type) { 'docker_container' }
  let(:backend) { 'local' }

  let(:expected_result) do
    {
      'value' => [
        { 'uri' => '0.0.0.0',
          'config' => { 'ssh' => { 'port' => 2200 } } },
      ]
    }
  end

  let(:target_mapping) do
    {
      'uri' => 'ports.0.ip',
      'config' => {
        'ssh' => {
          'port' => 'ports.0.external'
        }
      }
    }
  end

  let(:params) do
    {
      'dir' => terraform_dir,
      'resource_type' => resource_type,
      'target_mapping' => target_mapping
    }
  end

  let(:inventory) do
    {
      'version' => 2,
      'groups' => [
        { 'name' => 'terraform',
          'targets' => [
            { '_plugin' => 'terraform',
              'dir' => terraform_dir,
              'resource_type' => resource_type,
              'backend' => backend,
              'target_mapping' => target_mapping },
          ],
          'config' => {
            'transport' => 'ssh',
            'ssh' => {
              'user' => 'root',
              'password' => 'root',
              'host-key-check' => false,
              'load-config' => false,
              'private-key' => '/dev/null',
            }
          } },
      ]
    }
  end

  context 'with a local state file' do
    before(:all) do
      terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
      bolt_config = { 'modulepath' => RSpec.configuration.module_path }
      result = run_task('terraform::initialize', 'localhost', { 'dir' => terraform_dir }, config: bolt_config)
      expect(result[0]['status']).to eq('success')
      result = run_task('terraform::apply', 'localhost', { 'dir' => terraform_dir }, config: bolt_config)
      expect(result[0]['status']).to eq('success')
    end

    after(:all) do
      terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
      bolt_config = { 'modulepath' => RSpec.configuration.module_path }
      result = run_task('terraform::destroy', 'localhost', { 'dir' => terraform_dir }, config: bolt_config)
      expect(result[0]['status']).to eq('success')
    end

    it 'resolves references from an applied terraform manifest' do
      result = run_task('terraform::resolve_reference', 'localhost', params)
      expect(result[0]['value']).to eq(expected_result)
    end

    it 'runs a command on a discovered target' do
      result = run_command('whoami', 'terraform', inventory: inventory)
      expect(result[0]['value']['stdout']).to match(%r{root})
    end
  end

  context 'with a remote state file' do
    let(:backend) { 'remote' }
    let(:terraform_dir) { '.' }

    it 'errors when a remote state file is not found' do
      expect { run_command('whoami', 'terraform', inventory: inventory) }.to raise_error(
        %r{Could not pull Terraform remote state file},
      )
    end
  end
end
