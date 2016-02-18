require 'spec_helper'
require 'generator_spec'
require 'generators/smashing_docs/install_generator'
RSpec.describe SmashingDocumentation::Generators::InstallGenerator, type: :generator do
  describe "update_spec_helper" do
    let(:rails_helper) { "spec/rails_helper.rb" }
    it "appends the SmashingDocs config to rails_helper.rb" do
      run_generator
      expect(File).to exist(rails_helper)
      expect(File.read(rails_helper)).to include("SmashingDocs.config do")
    end
  end

  describe "update_spec_helper" do
    let(:spec_helper) { "spec/spec_helper.rb" }
    it "appends the SmashingDocs config to rails_helper.rb" do
      run_generator
      expect(File).to exist(spec_helper)
      expect(File.read(spec_helper)).to include("config.after(:each)")
      expect(File.read(spec_helper)).to include("config.after(:suite)")
    end
  end
end
