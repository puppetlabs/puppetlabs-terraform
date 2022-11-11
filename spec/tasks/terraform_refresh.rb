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
    let(:boltdir) { '/boltdir' }
    let(:expected_dir) { File.join(boltdir, dir) }
    let(:base_opts) { { _boltdir: boltdir } }
    let(:additional_opts) { {} }
    let(:opts) { base_opts.merge(additional_opts) }
    let(:success_result) { { stdout: terraform_out } }
    let(:base_cli) { %w[terraform refresh -no-color -json] }
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
      let(:additional_opts) { { dir: dir } }
      it 'invokes terraform refresh with default args from dir relative to boltdir' do
        expected_dir = File.expand_path(dir, boltdir)
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with state option" do
      let(:state) { "foo.tfstate" }
      let(:dir) { "foo/bar" }
      let(:additional_opts) { { state: state, dir: dir } }
      let(:additional_cli) { ["-state=#{File.join(boltdir, dir, state)}"] }
      it 'provides abosulute path for state relative to dir' do
        expect(Open3).to receive(:capture3).with(cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.output(opts)
        expect(result).to eq(success_result)
      end
    end
  end
end
