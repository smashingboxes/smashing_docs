require 'rails/generators'
module SmashingDocumentation
  module Generators
    class BuildDocsGenerator < Rails::Generators::Base
      def build_docs
        destination = "spec/spec_helper.rb"
        if File.exist?(destination)
          uncomment_lines(destination, /config.after\(:suite\) \{ SmashingDocs.finish! \}/)
          `rspec`
          comment_lines(destination, /config.after\(:suite\) \{ SmashingDocs.finish! \}/)
        end
      end
    end
  end
end
