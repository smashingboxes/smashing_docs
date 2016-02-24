require 'rails/generators'
module SmashingDocumentation
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates/", __FILE__)

      def install
        if Dir.exists?('spec')
          update_rails_helper
          update_spec_helper
          generate_docs_template
        else
          puts "It does not appear that you have RSpec installed in your app"
          puts "Please set up RSpec before running this installer"
        end
      end

      private

      def update_rails_helper
        destination = "spec/rails_helper.rb"
        create_file(destination) unless File.exist?(destination)
        append_file(destination,
          "SmashingDocs.config do |c|\n"\
          "  c.template_file = 'smashing_docs/template.md'\n"\
          "  c.output_file   = 'smashing_docs/api_docs.md'\n"\
          "  c.run_all       = true\n"\
          "end"
          ) unless File.readlines(destination).grep(/SmashingDocs.config/).any?
      end

      def update_spec_helper
        destination = "spec/spec_helper.rb"
        if File.exist?(destination)
          insert_into_file(
            destination,
            "\n  config.after(:each, type: :controller) do\n"\
            "    SmashingDocs.run!(request, response, true)\n"\
            "  end\n"\
            "#  config.after(:suite) { SmashingDocs.finish! }",
            after: "RSpec.configure do |config|"
          ) unless File.readlines(destination).grep(/SmashingDocs.finish/).any?
        end
      end

      def generate_docs_template
        source = "real_template.md"
        destination = "smashing_docs/template.md"
        copy_file(source, destination) unless File.exist?(destination)
      end
    end
  end
end
