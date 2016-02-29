require 'spec_helper'
require 'generator_spec'
require 'generators/smashing_documentation/install_generator'
RSpec.describe SmashingDocumentation::Generators::InstallGenerator, type: :generator do
  let(:rails_helper) { "spec/rails_helper.rb" }
  let(:spec_helper) { "spec/spec_helper.rb" }
  let(:docs_template) { "smashing_docs/template.md" }
  context "when rspec is installed" do
    describe "#configure_smashing_docs" do
      let(:rails_helper) { "spec/rails_helper.rb" }
      it "appends the SmashingDocs config to rails_helper.rb" do
        run_generator
        expect(File).to exist(rails_helper)
        expect(File.read(rails_helper)).to include("SmashingDocs.config do")
        `rm -r smashing_docs`
      end
    end
    describe "#add_rspec_hooks" do
      let(:spec_helper) { "spec/spec_helper.rb" }
      it "appends test suite hooks inside RSpec.configure block in spec_helper.rb" do
        run_generator
        expect(File).to exist(spec_helper)
        expect(File.read(spec_helper)).to include("config.after(:each,")
        expect(File.read(spec_helper)).to include("config.after(:suite)")
        `rm -r smashing_docs`
      end
    end

    describe "#generate_docs_template" do
      it "generates the default docs template" do
        run_generator
        expect(File).to exist(docs_template)
        expect(File.read(docs_template)).to include("request.method")
        expect(File.read(docs_template)).to include("response.body")
        `rm -r smashing_docs`
      end
    end
  end

  context "when minitest is installed" do
    describe "#configure_smashing_docs" do
      let(:test_helper) { "test/test_helper.rb" }
      it "appends the SmashingDocs config to test_helper.rb" do
        `mv spec s`
        run_generator
        expect(File).to exist(test_helper)
        expect(File.read(test_helper)).to include("SmashingDocs.config do")
        `rm #{test_helper}`
        `mv s spec`
        `rm -r smashing_docs`
      end
    end

    describe "#add_minitest_hooks" do
      let(:test_helper) { "test/test_helper.rb" }
      it "appends test suite hooks inside to the test_helper.rb" do
        `mv spec s`
        run_generator
        expect(File).to exist(test_helper)
        expect(File.read(test_helper)).to include("teardown")
        expect(File.read(test_helper)).to include("after_tests")
        expect(File.read(test_helper)).to include("SmashingDocs")
        `mv s spec`
        `rm #{test_helper}`
        `rm -r smashing_docs`
      end
    end
  end
  context "when no test suite is installed" do
    it "does not install smashing_docs" do
      `rm "#{rails_helper}"`
      File.rename('spec', 's') if Dir.exists?('spec')
      File.rename('test', 't') if Dir.exists?('test')
      run_generator
      File.rename('s', 'spec') if Dir.exists?('s')
      File.rename('t', 'test') if Dir.exists?('t')
      expect(File).to_not exist(rails_helper)
      # STDOUT is not tested here because it is suppressed in generator tests
    end
  end
end
