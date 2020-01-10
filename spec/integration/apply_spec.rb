# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/run'
require 'open3'

describe 'terraform::apply' do
  include BoltSpec::Run
  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }
  let(:terraform_dir) { File.join(RSpec.configuration.module_path, '../docker_provision') }
  let(:expected_default_output) { { 'clivar' => 'override', 'tfstatevar' => 'foo' } }
  let(:expected_modified_output) { { 'clivar' => 'foo', 'tfstatevar' => 'bar' } }
  let(:var_file) { 'tfvar_alternate.tfvars' }

  before(:all) do
    config = { 'modulepath' => RSpec.configuration.module_path }
    terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
    puts terraform_dir
    result = run_task('terraform::initialize', 'localhost', { 'dir' => terraform_dir, 'reinit' => true }, config: config)
    puts result
    expect(result[0]['status']).to eq('success')
  end

  after(:each) do
    terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
    _out, _err, status = Open3.capture3('terraform destroy -auto-approve -no-color', chdir: terraform_dir)
    expect(status).to eq(0)
  end

  after(:all) do
    terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
    _out, _err, status = Open3.capture3('rm -rf .terraform', chdir: terraform_dir)
    expect(status).to eq(0)
  end

  it "applies terraform manifest and returns logs" do
    result = run_plan('terraform::apply', 'dir' => terraform_dir)
    puts result
    expect(result['status']).to eq('success')
    expect(result['value'][0]['result']['stdout'])
      .to match(/Apply complete! Resources: 2 added, 0 changed, 0 destroyed./)
  end

  it "applies terraform manifest and returns output" do
    result = run_plan('terraform::apply', 'dir' => terraform_dir, 'return_output' => true)
    puts result
    expect(result['status']).to eq('success')
    expect(result['value']['terraform_output']['value']).to eq(expected_default_output)
  end

  it "sends along vars and var-file" do
    params = {
      'dir' => terraform_dir,
      'return_output' => true,
      'var' => { 'clivar' => 'foo' },
      'var_file' => var_file
    }
    result = run_plan('terraform::apply', params)
    puts result
    expect(result['status']).to eq('success')
    expect(result['value']['terraform_output']['value']).to eq(expected_modified_output)
  end
end
