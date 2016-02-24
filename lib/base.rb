class SmashingDocs
  attr_accessor :tests
  def initialize
    @tests = []
    @skip = false
    @information = {}
  end

  def sort_by_url!
    @tests.sort! do |x, y|
      x.request.path <=> y.request.path
    end
  end

  def clean_up!
    @tests = []
  end

  def information(key, value)
    @information[key] = value
  end

  def run!(request, response, called_by_test_hook)
    run_all = self.class::Conf.run_all
    if @skip
      @skip = false
      return
    end
    if run_all
      add_test_case(request, response)
    else
      add_test_case(request, response) unless called_by_test_hook
    end
    @information = {}
    self
  end

  def add_test_case(request, response)
    test = self.class::TestCase.new(request, response, @information)
    test.template = self.class::Conf.template
    self.tests << test
  end

  def skip
    @skip = true
  end

  def output_testcases_to_file
    docs = self.class::Conf.output_file
    raise 'No output file specific for SmashingDocs' unless docs
    File.delete docs if File.exists? docs
    write_to_file
  end

  def write_to_file
    File.open(self.class::Conf.output_file, 'a') do |file|
      @tests.each do |test|
        file.write(test.compile_template)
      end
    end
  end

# = = = =
# These class methods are used to persist test data across tests
# RSpec and Minitest do not support hooks that would allow
# for an instance variable to be declared and used

  def self.finish!
    unless current.tests.empty?
      current.sort_by_url!
      current.output_testcases_to_file
      current.clean_up!
    end
  end

  def self.run!(request, response, called_by_test_hook = false)
    current.run!(request, response, called_by_test_hook)
  end

  def self.skip
    current.skip
  end

  def self.information(key, value)
    current.information(key, value)
  end

  def self.current
    # Behaves like an instance of SmashingDocs class
    Thread.current[:instance] ||= self.new
  end

  def self.config(&block)
    yield(self::Conf)
  end
end
