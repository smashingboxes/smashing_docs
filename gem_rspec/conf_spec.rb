require 'spec_helper'

RSpec.describe SmashingDocs::Conf do
  let!(:config) {
    SmashingDocs.config do |c|
      c.template_file = "gem_spec/fake_template.md.erb"
      c.output_file   = "api_docs.md"
    end
  }
  it "sets the output file" do
    expect(SmashingDocs::Conf.output_file).to eq("api_docs.md")
  end

  it "sets the template file" do
    expect(SmashingDocs::Conf.template_file).to eq("gem_spec/fake_template.md.erb")
  end
end
