# frozen_string_literal: true

require 'spec_helper'
require_relative '../../fixtures/modules/ruby_task_helper/files/task_helper'
require_relative '../../../tasks/initialize'

describe TerraformInitialize do
  describe '#initialize' do
    let(:terraform_out) { 'Terraform message' }
    let(:terraform_err) { '' }
    # A real Open3.capture3 call returns a Process::Status here, not an
    # Integer -- Process::Status has no #zero? method, only #success?/
    # #exitstatus. Use a verifying double so the mock's shape matches the
    # real API (see tasks/initialize.rb's `status.success?` check).
    let(:terraform_status) { instance_double(Process::Status, success?: true) }
    let(:terraform_response) { [terraform_out, terraform_err, terraform_status] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { { stdout: terraform_out } }
    let(:terraform_cli) { 'terraform init -no-color' }

    context 'with no options specified' do
      it 'Invokes terraform init with default args' do
        expect(Open3).to receive(:capture3).with(terraform_cli).and_return(terraform_response)
        result = subject.init(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with dir option' do
      let(:dir) { 'foo/bar' }
      let(:opts) { { dir: dir } }

      it 'invokes terraform init with default args from dir relative to cwd' do
        expected_dir = File.expand_path(dir)
        expect(Open3).to receive(:capture3).with(terraform_cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.init(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'when terraform init exits non-zero' do
      let(:terraform_err) { 'Error: something went wrong' }
      let(:terraform_status) { instance_double(Process::Status, success?: false) }

      it 'raises a TaskHelper::Error instead of returning stdout' do
        expect(Open3).to receive(:capture3).with(terraform_cli).and_return(terraform_response)
        expect { subject.init(opts) }.to raise_error(TaskHelper::Error, terraform_err)
      end
    end
  end
end
