require 'spec_helper'
require 'generator_spec'
require 'generators/smashing_documentation/install_generator'
RSpec.describe SmashingDocumentation::Generators::InstallGenerator, type: :generator do
  describe "#update_spec_helper" do
    let(:rails_helper) { "spec/rails_helper.rb" }
    it "appends the SmashingDocs config to rails_helper.rb" do
      run_generator
      expect(File).to exist(rails_helper)
      expect(File.read(rails_helper)).to include("SmashingDocs.config do")
    end
  end

  describe "#update_spec_helper" do
    let(:spec_helper) { "spec/spec_helper.rb" }
    it "appends test suite hooks inside RSpec.configure block in spec_helper.rb" do
      run_generator
      expect(File).to exist(spec_helper)
      expect(File.read(spec_helper)).to include("config.after(:each)")
      expect(File.read(spec_helper)).to include("config.after(:suite)")
    end
  end

  describe "#generate_docs_template" do
    let(:docs_template) { "smashing_docs/template.md" }
    it "generates the default docs template" do
      run_generator
      expect(File).to exist(docs_template)
      expect(File.read(docs_template)).to include("request.method")
      expect(File.read(docs_template)).to include("response.body")
    end
  end
end
