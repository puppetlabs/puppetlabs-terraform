# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/initialize.rb'

describe TerraformInitialize do
  describe "#initialize" do
    let(:terraform_out) { "Terraform message" }
    let(:check_err) { "" }
    let(:check_code) { 1 }
    let(:check_response) { [terraform_out, check_err, check_code] }
    let(:init_err) { "" }
    let(:init_code) { 0 }
    let(:init_response) { [terraform_out, init_err, init_code] }
    let(:expected_dir) { File.join(Dir.pwd, dir) }
    let(:opts) { {} }
    let(:success_result) { { stdout: terraform_out } }
    let(:check_cli) { "terraform providers" }
    let(:init_cli) { "terraform init -no-color" }

    context "with no options specified" do
      it 'Invokes terraform init with default args' do
        expect(Open3).to receive(:capture3).with(check_cli).and_return(check_response)
        expect(Open3).to receive(:capture3).with(init_cli).and_return(init_response)
        result = subject.init(opts)
        expect(result).to eq(success_result)
      end
    end

    context "with dir option" do
      let(:dir) { "foo/bar" }
      let(:opts) { { dir: dir } }
      it 'invokes terraform init with default args from dir relative to cwd' do
        expected_dir = File.expand_path(dir)
        expect(Open3).to receive(:capture3).with(check_cli, chdir: expected_dir).and_return(check_response)
        expect(Open3).to receive(:capture3).with(init_cli, chdir: expected_dir).and_return(init_response)
        result = subject.init(opts)
        expect(result).to eq(success_result)
      end
    end
  end
end
