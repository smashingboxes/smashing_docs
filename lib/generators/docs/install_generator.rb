require 'rails/generators'
module Docs
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../templates/", __FILE__)

      def install
        if Dir.exists?('spec')
          @config_file = "spec/rails_helper.rb"
        elsif Dir.exists?('test')
          @config_file = "test/test_helper.rb"
        else
          puts "It does not appear that you have a test suite installed in your app"
          puts "Please...please use tests"
          return
        end
        configure_smashing_docs
        using_minitest? ? add_minitest_hooks : add_rspec_hooks
        generate_docs_template
      end

      private
      def configure_smashing_docs
        create_config_file
        add_configuration
      end

      def add_rspec_hooks
        helper = "spec/spec_helper.rb"
        if File.exist?(helper)
          insert_into_file(
            helper,
            "\n  config.after(:each, type: :controller) do\n"\
            "    SmashingDocs.run!(request, response, true)\n"\
            "  end\n"\
            " # config.after(:suite) { SmashingDocs.finish! }",
            after: "RSpec.configure do |config|"
          ) unless test_hooks_already_setup?(helper)
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

      def create_config_file
        unless File.exist?(@config_file)
          create_file(@config_file)
          append_file(@config_file, "class ActiveSupport::TestCase\n end\n") if using_minitest?
        end
      end

      def add_configuration
        setup_configuration unless config_already_setup?
      end

      def setup_configuration
        config = "SmashingDocs.config do |c|\n"\
                 "  c.template_file = 'smashing_docs/template.md'\n"\
                 "  c.output_file   = 'smashing_docs/api_docs.md'\n"\
                 "  c.run_all       = true\n"\
                 "  c.auto_push     = false\n"\
                 "  c.wiki_folder   = nil\n"\
                 "end\n"
        if using_minitest?
          insert_into_file(@config_file, config, after: "class ActiveSupport::TestCase\n")
        else
          append_file(@config_file, config)
        end
      end

      def config_already_setup?
        File.readlines(@config_file).grep(/SmashingDocs.config/).any?
      end

      def test_hooks_already_setup?(helper)
        File.readlines(helper).grep(/SmashingDocs\.run!/).any?
      end

      def using_minitest?
        @config_file.include?("test")
      end
    end
  end
end
