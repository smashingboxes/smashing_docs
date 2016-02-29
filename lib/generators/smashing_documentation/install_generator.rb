require 'rails/generators'
module SmashingDocumentation
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates/", __FILE__)

      def install
        if Dir.exists?('spec')
          configure_smashing_docs("spec/rails_helper.rb")
          add_rspec_hooks
          generate_docs_template
        elsif Dir.exists?('test')
          configure_smashing_docs("test/test_helper.rb")
          add_minitest_hooks
          generate_docs_template
        else
          puts "It does not appear that you have a test suite installed in your app"
          puts "Please...please use tests"
        end
      end

      private

      def configure_smashing_docs(config_file)
        create_config_file(config_file)
        add_configuration(config_file)
      end

      def add_rspec_hooks
        destination = "spec/spec_helper.rb"
        if File.exist?(destination)
          insert_into_file(
            destination,
            "\n  config.after(:each, type: :controller) do\n"\
            "    SmashingDocs.run!(request, response)\n"\
            "  end\n"\
            "#  config.after(:suite) { SmashingDocs.finish! }",
            after: "RSpec.configure do |config|"
          ) unless File.readlines(destination).grep(/config.after\(:suite\) { Smashing/).any?
        end
      end

      def add_minitest_hooks
        helper = "test/test_helper.rb"
        append_file(
          helper,
          "\nclass ActionController::TestCase < ActiveSupport::TestCase\n"\
          "  def teardown\n"\
          "    SmashingDocs.run!(request, response, true)\n"\
          "  end\n"\
          "end\n"\
          "MiniTest::Unit.after_tests { SmashingDocs.finish! }\n"
        ) unless test_hooks_already_setup?(helper)
      end

      def generate_docs_template
        source = "real_template.md"
        destination = "smashing_docs/template.md"
        copy_file(source, destination) unless File.exist?(destination)
      end

      def create_config_file(config_file)
        unless File.exist?(config_file)
          create_file(config_file)
          append_file(config_file, "class ActiveSupport::TestCase\n end\n") if using_minitest?(config_file)
        end
      end

      def add_configuration(config_file)
        if config_already_setup?(config_file)
          return
        else
          config = "SmashingDocs.config do |c|\n"\
                   "  c.template_file = 'smashing_docs/template.md'\n"\
                   "  c.output_file   = 'smashing_docs/api_docs.md'\n"\
                   "  c.auto_push     = false\n"\
                   "end\n"
          if using_minitest?(config_file)
            insert_into_file(config_file, config, after: "class ActiveSupport::TestCase\n")
          else
            append_file(config_file, config)
          end
        end
      end

      def config_already_setup?(config_file)
        File.readlines(config_file).grep(/SmashingDocs.config/).any?
      end

      def test_hooks_already_setup?(helper)
        File.readlines(helper).grep(/SmashingDocs\.run!/).any?
      end

      def using_minitest?(config_file)
        config_file.include?("test")
      end
    end
  end
end
