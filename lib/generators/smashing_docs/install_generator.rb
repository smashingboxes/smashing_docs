require 'rails/generators/base'
module SmashingDocs
  class InstallGenerator < Rails::Generators::Base
    def update_spec_helper
      append_file "spec/rails_helper.rb" do
        "SmarfDoc.config do |c|\n"\
        "c.template_file = 'spec/template.md.erb'\n"\
        "c.output_file   = 'api_docs.md'\n"\
        "end\n"
      end
    end
  end
end
