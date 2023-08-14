# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/output.rb'
require 'json'

describe TerraformOutput do
  describe "#output" do
    let(:output) { { 'foo' => 'bar' } }
    let(:terraform_out) { JSON.dump(output) }
    let(:terraform_err) { "" }
    let(:terraform_code) { 0 }
    let(:terraform_response) { [terraform_out, terraform_err, terraform_code] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { output }
    let(:base_cli) { %w[terraform output -no-color -json] }
    let(:additional_cli) { [] }
    let(:cli) { base_cli.concat(additional_cli).join(' ') }

    context "with no options specified" do
      it 'Invokes terraform output with default args' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with dir option" do
      let(:dir) { "foo/bar" }
      let(:opts) { super().merge(dir: dir) }
      it 'invokes terraform output with default args from dir relative to cwd' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with state option" do
      let(:state) { "foo.tfstate" }
      let(:dir) { "foo/bar" }
      let(:opts) { super().merge(state: state, dir: dir) }
      let(:additional_cli) { ["-state=#{File.expand_path(File.join(dir, state))}"] }
      it 'provides abosulute path for state relative to dir' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end
  end
end
