# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/initialize.rb'

describe TerraformInitialize do
  describe "#initialize" do
    let(:terraform_out) { "Terraform message" }
    let(:terraform_err) { "" }
    let(:terraform_code) { 0 }
    let(:terraform_response) { [terraform_out, terraform_err, terraform_code] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { { stdout: terraform_out } }
    let(:terraform_cli) { "terraform init -no-color" }

    context "with no options specified" do
      it 'Invokes terraform init with default args' do
        expect(Open3).to receive(:capture3).with(terraform_cli).and_return(terraform_response)
        result = subject.init(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with dir option" do
      let(:dir) { "foo/bar" }
      let(:opts) { { dir: dir } }
      it 'invokes terraform init with default args from dir relative to cwd' do
        expected_dir = File.expand_path(dir)
        expect(Open3).to receive(:capture3).with(terraform_cli, chdir: expected_dir).and_return(terraform_response)
        result = subject.init(opts)
        expect(result).to eq(success_result)
      end
    end
  end
end
