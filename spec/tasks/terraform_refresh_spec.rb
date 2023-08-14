# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/refresh.rb'
require 'json'

describe TerraformRefresh do
  describe "#refresh" do
    let(:terraform_out) { "Terraform message" }
    let(:terraform_err) { "" }
    let(:terraform_code) { 0 }
    let(:terraform_response) { [terraform_out, terraform_err, terraform_code] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { { stdout: terraform_out } }
    let(:base_cli) { %w[terraform refresh -no-color] }
    let(:additional_cli) { [] }
    let(:cli) { base_cli.concat(additional_cli).join(' ') }

    context "with no options specified" do
      it 'Invokes terraform refresh with default args' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with dir option" do
      let(:dir) { "foo/bar" }
      let(:opts) { super().merge(dir: dir) }
      it 'invokes terraform refresh with default args from dir relative to cwd' do
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

    context "with single target resource option" do
      let(:target) { "aws.t1micro" }
      let(:opts) { { target: target } }
      let(:additional_cli) { ["-target=#{target}"] }
      it 'specifieds single target' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with multiple target resource options" do
      let(:target) { %w[aws.t1micro aws.t2macro] }
      let(:opts) { super().merge(target: target) }
      let(:additional_cli) { target.map { |r| "-target=#{r}" } }
      it 'specifies multiple targets' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with single var option" do
      let(:var) { { 'foo' => 'bar' } }
      let(:opts) { super().merge(var: var) }
      let(:additional_cli) { ["-var 'foo=bar'"] }
      it 'specifieds single var' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with multiple var options" do
      let(:var) { { 'foo' => 'bar', 'baz' => 'foo' } }
      let(:opts) { super().merge(var: var) }
      let(:additional_cli) { var.map { |k, v| "-var '#{k}=#{v}'" } }
      it 'specifies multiple vars' do
        expect(Open3).to receive(:capture3).with(cli).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with var_file option" do
      let(:var_file) { "foo.tfvars" }
      let(:dir) { "foo/bar" }
      let(:opts) { super().merge(var_file: var_file, dir: dir) }
      let(:additional_cli) { ["-var-file=#{File.expand_path(File.join(dir, var_file))}"] }
      it 'provides abosulute path for var-file relative to dir' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end
  end
end
