# frozen_string_literal: true

require 'spec_helper'
require_relative '../../fixtures/modules/ruby_task_helper/files/task_helper'
require_relative '../../../tasks/refresh'
require 'json'

describe TerraformRefresh do
  describe '#refresh' do
    let(:terraform_out) { 'Terraform message' }
    let(:terraform_err) { '' }
    # A real Open3.capture3 call returns a Process::Status here, not an
    # Integer -- Process::Status has no #zero? method, only #success?/
    # #exitstatus. Use a verifying double so the mock's shape matches the
    # real API (see tasks/refresh.rb's `status.success?` check).
    let(:terraform_status) { instance_double(Process::Status, success?: true) }
    let(:terraform_response) { [terraform_out, terraform_err, terraform_status] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { { stdout: terraform_out } }
    let(:base_cli) { ['terraform', 'refresh', '-no-color'] }
    let(:additional_cli) { [] }
    let(:cli) { base_cli.concat(additional_cli).join(' ') }

    context 'with no options specified' do
      it 'Invokes terraform refresh with default args' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with dir option' do
      let(:dir) { 'foo/bar' }
      let(:opts) { super().merge(dir: dir) }

      it 'invokes terraform refresh with default args from dir relative to cwd' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with state option' do
      let(:state) { 'foo.tfstate' }
      let(:dir) { 'foo/bar' }
      let(:opts) { super().merge(state: state, dir: dir) }
      let(:additional_cli) { ["-state=#{File.expand_path(File.join(dir, state))}"] }

      it 'provides abosulute path for state relative to dir' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with single target resource option' do
      let(:target) { 'aws.t1micro' }
      let(:opts) { { target: target } }
      let(:additional_cli) { ["-target=#{target}"] }

      it 'specifieds single target' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with multiple target resource options' do
      let(:target) { ['aws.t1micro', 'aws.t2macro'] }
      let(:opts) { super().merge(target: target) }
      let(:additional_cli) { target.map { |r| "-target=#{r}" } }

      it 'specifies multiple targets' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with single var option' do
      let(:var) { { 'foo' => 'bar' } }
      let(:opts) { super().merge(var: var) }
      let(:additional_cli) { ["-var 'foo=bar'"] }

      it 'specifieds single var' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with multiple var options' do
      let(:var) { { 'foo' => 'bar', 'baz' => 'foo' } }
      let(:opts) { super().merge(var: var) }
      let(:additional_cli) { var.map { |k, v| "-var '#{k}=#{v}'" } }

      it 'specifies multiple vars' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with var_file option' do
      let(:var_file) { 'foo.tfvars' }
      let(:dir) { 'foo/bar' }
      let(:opts) { super().merge(var_file: var_file, dir: dir) }
      let(:additional_cli) { ["-var-file=#{File.expand_path(File.join(dir, var_file))}"] }

      it 'provides abosulute path for var-file relative to dir' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'when terraform refresh exits non-zero' do
      let(:terraform_err) { 'Error: something went wrong' }
      let(:terraform_status) { instance_double(Process::Status, success?: false) }

      it 'raises a TaskHelper::Error instead of returning stdout' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        expect { subject.output(opts) }.to raise_error(TaskHelper::Error, terraform_err)
      end
    end
  end
end
