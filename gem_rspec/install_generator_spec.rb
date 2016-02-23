require 'spec_helper'
require 'generator_spec'
require 'generators/smashing_documentation/install_generator'
RSpec.describe SmashingDocumentation::Generators::InstallGenerator, type: :generator do
  let(:rails_helper) { "spec/rails_helper.rb" }
  let(:spec_helper) { "spec/spec_helper.rb" }
  let(:docs_template) { "smashing_docs/template.md" }
  context "when rspec is installed" do
    describe "#update_spec_helper" do
      it "appends the SmashingDocs config to rails_helper.rb" do
        run_generator
        expect(File).to exist(rails_helper)
        expect(File.read(rails_helper)).to include("SmashingDocs.config do")
      end

      it "appends test suite hooks inside RSpec.configure block in spec_helper.rb" do
        run_generator
        expect(File).to exist(spec_helper)
        expect(File.read(spec_helper)).to include("config.after(:each,")
        expect(File.read(spec_helper)).to include("config.after(:suite)")
      end
    end

    describe "#generate_docs_template" do
      it "generates the default docs template" do
        run_generator
        expect(File).to exist(docs_template)
        expect(File.read(docs_template)).to include("request.method")
        expect(File.read(docs_template)).to include("response.body")
      end
    end
  end
  
  context "when rspec is not installed" do
    it "does not install smashing_docs" do
      File.rename('spec', 's') if Dir.exists?('spec')
      run_generator
      expect(File).to_not exist(rails_helper)
      File.rename('s', 'spec') if Dir.exists?('s')

      # STDOUT is not tested here because it is suppressed in generator tests
    end
  end
end
