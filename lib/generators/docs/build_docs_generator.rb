require 'rails/generators'
module Docs
  module Generators
    class BuildDocsGenerator < Rails::Generators::Base
      ENV['RAILS_ENV'] = 'test'
      source_root File.expand_path("../../../templates/", __FILE__)
      def build_docs
        destination = "spec/spec_helper.rb"
        if File.exist?(destination)
          uncomment_lines(destination, /config.after\(:suite\) \{ SmashingDocs.finish! \}/)
          system('rspec spec > /dev/null')
          comment_lines(destination, /config.after\(:suite\) \{ SmashingDocs.finish! \}/)
        else
          puts "Could not find spec/spec_helper.rb"
        end
      end
    end
  end
end
