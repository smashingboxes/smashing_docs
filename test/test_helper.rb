require_relative '../lib/smashing_docs'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

class SmashingDocsTest < Minitest::Test
  def setup
    SmashingDocs.config do |c|
      c.template_file = 'test/fake_template.md.erb'
      c.output_file   = 'test/fake_output.md'
    end
  end

  def teardown
    SmashingDocs.finish!
  end

  # Include some fake structs that act like response/request objects.
  Request  = Struct.new :method, :params, :path
  Response = Struct.new :body, :success?

  def request
    Request.new("GET", {id: 12}, 'api/users')
  end

  def response
    Response.new('{"id": 12, "name": "rick"}', true)
  end
end
