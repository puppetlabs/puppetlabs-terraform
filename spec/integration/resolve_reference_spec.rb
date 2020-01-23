# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/run'
require 'open3'

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
          'config' => { 'ssh' => { 'port' => 2200 } } }
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
              'target_mapping' => target_mapping }
          ],
          'config' => {
            'transport' => 'ssh',
            'ssh' => {
              'user' => 'root',
              'password' => 'root',
              'host-key-check' => false
            }
          } }
      ]
    }
  end

  context 'with a local state file' do
    before(:all) do
      terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
      _out, _err, status = Open3.capture3('terraform init', chdir: terraform_dir)
      expect(status).to eq(0)
      _out, _err, status = Open3.capture3('terraform apply -auto-approve', chdir: terraform_dir)
      expect(status).to eq(0)
    end

    after(:all) do
      terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
      _out, _err, status = Open3.capture3('terraform destroy -auto-approve', chdir: terraform_dir)
      expect(status).to eq(0)
      _out, _err, status = Open3.capture3('rm -rf .terraform', chdir: terraform_dir)
      expect(status).to eq(0)
    end

    it 'resolves references from an applied terraform manifest' do
      result = run_task('terraform::resolve_reference', 'localhost', params)
      expect(result.first['result']).to eq(expected_result)
    end

    it 'runs a command on a discovered target' do
      result = run_command('whoami', 'terraform', inventory: inventory)
      expect(result.first['result']['stdout']).to match(/root/)
    end
  end

  context 'with a remote state file' do
    let(:backend) { 'remote' }
    let(:terraform_dir) { '.' }

    it 'errors when a remote state file is not found' do
      expect { run_command('whoami', 'terraform', inventory: inventory) }.to raise_error(
        /Could not pull Terraform remote state file/
      )
    end
  end
end
