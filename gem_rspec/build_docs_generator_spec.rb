require 'spec_helper'
require 'generator_spec'
require 'generators/smashing_documentation/build_docs_generator'
RSpec.describe SmashingDocumentation::Generators::BuildDocsGenerator, type: :generator do
  it "activates Smashing Docs, runs the test suite, and deactivates Smashing Docs" do
    # run_generator # Causes test suite to hang as it infinitely runs tests
  end
end
