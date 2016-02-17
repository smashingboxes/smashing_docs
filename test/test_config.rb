require_relative "test_helper"

class TestConfig < SmashingDocsTest

  def test_set_configs
    SmashingDocs.config do |c|
      c.template_file = 'test/template.md.erb'
      c.output_file   = 'api_docs.md'
    end
    assert_equal 'api_docs.md', SmashingDocs::Conf.output_file,
      "Unable to set output file"
    assert_equal 'test/template.md.erb', SmashingDocs::Conf.template_file,
      "Unable to set template file"
  end
end
