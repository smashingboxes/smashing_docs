class SmashingDocs::Conf
  class << self
    attr_accessor :template_file, :output_file, :auto_push

    @output_file = 'documentation.md'

    def template
      raise 'You must set a template file.' unless template_file
      @template ||= File.read(template_file)
    end
  end
end
