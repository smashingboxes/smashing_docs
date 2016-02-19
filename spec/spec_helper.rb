$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'smashing_docs'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.before(:each) do
    SmashingDocs.config do |c|
      c.template_file = 'spec/fake_template.md.erb'
      c.output_file   = 'spec/fake_output.md'
      c.run_all       = true
    end
  end
  config.after(:each) do
    SmashingDocs.finish!
  end
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
