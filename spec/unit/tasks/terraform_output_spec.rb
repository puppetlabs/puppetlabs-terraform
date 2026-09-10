# frozen_string_literal: true

require 'spec_helper'
require_relative '../../fixtures/modules/ruby_task_helper/files/task_helper'
require_relative '../../../tasks/output'
require 'json'

describe TerraformOutput do
  describe '#output' do
    let(:output) { { 'foo' => 'bar' } }
    let(:terraform_out) { JSON.dump(output) }
    let(:terraform_err) { '' }
    # A real Open3.capture3 call returns a Process::Status here, not an
    # Integer -- Process::Status has no #zero? method, only #success?/
    # #exitstatus. Use a verifying double so the mock's shape matches the
    # real API (see tasks/output.rb's `status.success?` check).
    let(:terraform_status) { instance_double(Process::Status, success?: true) }
    let(:terraform_response) { [terraform_out, terraform_err, terraform_status] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { output }
    let(:base_cli) { ['terraform', 'output', '-no-color', '-json'] }
    let(:additional_cli) { [] }
    let(:cli) { base_cli.concat(additional_cli).join(' ') }

    context 'with no options specified' do
      it 'Invokes terraform output with default args' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context 'with dir option' do
      let(:dir) { 'foo/bar' }
      let(:opts) { super().merge(dir: dir) }

      it 'invokes terraform output with default args from dir relative to cwd' do
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

    context 'when terraform output exits non-zero' do
      let(:terraform_out) { '' }
      let(:terraform_err) { 'Error: something went wrong' }
      let(:terraform_status) { instance_double(Process::Status, success?: false) }

      it 'raises a TaskHelper::Error instead of parsing stdout as JSON' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        expect { subject.output(opts) }.to raise_error(TaskHelper::Error, terraform_err)
      end
    end
  end
end
