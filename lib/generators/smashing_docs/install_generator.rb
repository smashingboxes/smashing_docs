require 'rails/generators/base'
module SmashingDocs
  class InstallGenerator < Rails::Generators::Base
    def code_that_runs
      puts "Hi"
    end
  end
end
