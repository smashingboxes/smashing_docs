class SmashingDocs::Conf
  class << self
    attr_accessor :template_file, :output_file, :auto_push, :run_all, :wiki_folder
    @output_file = 'documentation.md'

    def template
      raise 'You must set a template file.' unless template_file
      File.read(template_file)
    end

    def run_all_tests
      run_all
    end
  end
end
