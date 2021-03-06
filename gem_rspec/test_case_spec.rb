require 'spec_helper'

RSpec.describe SmashingDocs::TestCase do
  let(:test_case) { SmashingDocs::TestCase.new(request, response) }

  describe "#compile_template" do
    context "with text" do
      let(:template) { "<%= 2 + 2 %>" }
      it "evaluates erb and returns a value" do
        test_case.template = template
        expect(test_case.compile_template).to eq("4")
      end
    end

    context "with a template file" do
      let!(:template) { SmashingDocs.config { |c| c.template_file = 'gem_rspec/fake_template.md.erb' } }
      it "sets the template file and returns docs matching the template" do
        test_case.template = SmashingDocs::Conf.template
        expect(test_case.compile_template).to include("use ERB")
      end
    end
  end

  describe "#created_at" do
    it "returns the time the TestCase was created" do
      expect(test_case.created_at).to be_a(Time)
    end
  end
end
