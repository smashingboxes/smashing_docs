require 'erb'

class SmashingDocs::TestCase
  attr_reader :request, :response, :created_at, :information
  attr_accessor :template

  def initialize(request, response, information = {})
    @request, @response, @information = request, response, information
    @created_at = Time.now
  end

  def compile_template
    ERB.new(template).result binding
  end
end
