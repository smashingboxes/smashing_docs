require 'erb'

class SmashingDocs::TestCase
  attr_reader :request, :response, :created_at, :information, :aside
  attr_accessor :template

  def initialize(request, response, information = {}, aside = '')
    @request, @response, @information, @aside = request, response, information, aside
    @created_at = Time.now
  end

  def compile_template
    ERB.new(template).result binding
  end
end
