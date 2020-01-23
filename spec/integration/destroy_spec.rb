# frozen_string_literal: true

require 'spec_helper'
require 'bolt_spec/run'
require 'open3'

describe 'terraform::destroy' do
  include BoltSpec::Run
  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }
  let(:terraform_dir) { File.join(RSpec.configuration.module_path, '../docker_provision') }

  before(:all) do
    bolt_config = { 'modulepath' => RSpec.configuration.module_path }
    terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
    result = run_task('terraform::initialize', 'localhost', { 'dir' => terraform_dir }, config: bolt_config)[0]
    expect(result['status']).to eq('success')
  end

  before(:each) do
    terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
    _out, _err, status = Open3.capture3('terraform apply -auto-approve -no-color', chdir: terraform_dir)
    expect(status).to eq(0)
  end

  after(:all) do
    terraform_dir = File.join(RSpec.configuration.module_path, '../docker_provision')
    _out, _err, status = Open3.capture3('rm -rf .terraform', chdir: terraform_dir)
    expect(status).to eq(0)
  end

  it "destroys Terraform resources" do
    result = run_plan('terraform::destroy', 'dir' => terraform_dir)
    expect(result['status']).to eq('success')
    expect(result['value'][0]['result']['stdout'])
      .to match(/Destroy complete! Resources: 2 destroyed./)
  end
end
