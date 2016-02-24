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

  def push_docs
    directory = `pwd`
    app_name = directory.match(/\w+\n/).to_s.gsub(/\n/, "")
    `cp "#{SmashingDocs::Conf.output_file}" ../"#{app_name}.wiki"`
    output_file_name = SmashingDocs::Conf.output_file.match(/\w+\.md/)
    Dir.chdir("../#{app_name}.wiki") do
      `git add "#{output_file_name}"`
      `git commit -m "Update Docs -- Auto post by SmashingDocs"`
      `git push`
    end
  end

  def aside(msg)
    @aside = ''
    @aside = "<aside class='notice'>\n #{msg}\n</aside>"
  end

  def information(key, value)
    @information[key] = value
  end

  def run!(request, response)
    if @skip
      @skip = false
      return
    end
    add_test_case(request, response)
    @information = {}
    @skip = false
    self
  end

  def add_test_case(request, response)
    test = self.class::TestCase.new(request, response, @information, @aside)
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
    current.sort_by_url!
    current.output_testcases_to_file
    current.push_docs
    current.clean_up!
  end

  def self.run!(request, response)
    current.run!(request, response)
  end

  def self.skip
    current.skip
  end

  def self.information(key, value)
    current.information(key, value)
  end

  def self.aside(message)
    current.aside(message)
  end

  def self.current
    # Behaves like an instance of SmashingDocs class
    Thread.current[:instance] ||= self.new
  end

  def self.config(&block)
    yield(self::Conf)
  end
end
