require 'rails/generators'
module SmashingDocumentation
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def update_rails_helper
        destination = "spec/rails_helper.rb"
        create_file(destination) unless File.exist?(destination)
        append_file(destination,
          "SmashingDocs.config do |c|\n"\
          "  c.template_file = 'spec/template.md.erb'\n"\
          "  c.output_file   = 'api_docs.md'\n"\
          "end"
          )
      end

      def update_spec_helper
        destination = "spec/spec_helper.rb"
        if File.exist?(destination)
          insert_into_file(
            destination,
            "\n  config.after(:each, type: :controller) do\n"\
            "    SmashingDocs.run!(request, response)\n"\
            "  end\n"\
            "  config.after(:suite) { SmashingDocs.finish! }",
            after: "RSpec.configure do |config|"
          )
        end
      end
    end
  end
end
