require 'spec_helper'

RSpec.describe SmashingDocs do
  let(:file) { SmashingDocs::Conf.output_file }
  let(:first) { Request.new("GET", {id: 12}, 'api/aaa') }
  let(:middle) { Request.new("GET", { id: 12 }, 'api/ooo') }
  let(:last) { Request.new("GET", {id: 12}, 'api/zzz') }
  let(:tests) { SmashingDocs.current.tests }

  describe ".run!(request, response)" do
    context "when no tests have been run" do
      it "has done nothing" do
        expect(tests.length).to eq(0)
      end
    end
    context "running 1 test" do
      it "adds the test to the list of tests" do
        SmashingDocs.run!(request, response)
        expect(tests.length).to eq(1)
        expect(tests.first).to be_a(SmashingDocs::TestCase)
      end
    end
    context "running 2 tests" do
      it "adds both tests to the list of tests" do
        2.times { SmashingDocs.run!(request, response) }
        expect(tests.length).to eq(2)
      end
    end
  end

  describe ".sort!" do
    let(:results) { SmashingDocs.current.sort_by_url!.map{|tc| tc.request.path} }
    it "sorts tests alphabetically by endpoint" do
      SmashingDocs.run!(first, response)
      SmashingDocs.run!(last, response)
      SmashingDocs.run!(middle, response)
      expect(results).to eq(["api/aaa", "api/ooo", "api/zzz"])
    end
  end

  describe ".finish!" do
    it "creates the docs file with output from the template" do
      SmashingDocs.run!(first, response)
      SmashingDocs.run!(last, response)
      SmashingDocs.finish!
      expect(File).to exist(file)
      expect(File.read(file)).to include("You can use ERB")
    end
  end

  describe ".skip" do
    context "one skip" do
      it "skips a single test" do
        SmashingDocs.skip
        SmashingDocs.run!(first, response)
        SmashingDocs.run!(last, response)
        expect(tests.length).to eq(1)
        expect(tests.first.request.path).to eq("api/zzz")
      end
    end
    context "multiple skips" do
      it "skips multiple tests" do
        SmashingDocs.skip
        SmashingDocs.run!(first, response)
        SmashingDocs.skip
        SmashingDocs.run!(middle, response)
        SmashingDocs.run!(last, response)
        expect(tests.length).to eq(1)
        expect(tests.first.request.path).to eq("api/zzz")
      end
    end
  end

  describe ".information(key, value)" do
    # The template file must have <%= information[:note] %>
    it "sends information to be displayed about the endpoint" do
      SmashingDocs.information(:note, "Endpoint note")
      SmashingDocs.run!(first, response)
      expect(tests.first.compile_template).to include("Endpoint note")
    end
  end

  describe ".aside(message)" do
    # The template file must have <%= aside %>
    it "sends information to be displayed about the endpoint" do
      SmashingDocs.aside("I am an aside")
      SmashingDocs.run!(first, response)
      expect(tests.first.compile_template).to include("<aside class='notice'>")
      expect(tests.first.compile_template).to include("I am an aside")
    end
  end

  describe "#app_name" do
    it "returns the name of the app it is installed in" do
      expect(SmashingDocs.current.send(:app_name)).to eq("smashing_docs")
    end
  end

  describe "#output_file" do
    it "returns only the file name of the configured output file" do
      expect(SmashingDocs.current.send(:output_file)).to eq("fake_output.md")
    end
  end

  describe "#wiki_repo_exists(wiki_repo)" do
    context "when the repo exists" do
      let(:wiki_repo) { "../#{SmashingDocs.current.send(:app_name)}.wiki" }
      it "returns true" do
        expect(SmashingDocs.current.send(:wiki_repo_exists?, wiki_repo)).to eq(true)
      end
    end

    context "when the repo does not exist" do
      let(:wiki_repo) { "../ifyoumakethisdirectorythetestwillfail.wiki" }
      it "returns false" do
        expect(SmashingDocs.current.send(:wiki_repo_exists?, wiki_repo)).to eq(false)
      end
    end
  end

  describe "#copy_docs_to_wiki_repo(wiki_repo)" do
    let(:wiki_repo) { "../#{SmashingDocs.current.send(:app_name)}.wiki" }
    let(:output_file) { SmashingDocs.current.send(:output_file) }
    it "makes a copy of the docs in the wiki folder" do
      `rm -f ../smashing_docs.wiki/"#{output_file}"` # -f just in case the file's stubborn
      expect(!File.exist?("../smashing_docs.wiki/#{output_file}"))
      SmashingDocs.current.send(:copy_docs_to_wiki_repo, wiki_repo)
      expect(File.exist?("../smashing_docs.wiki/#{output_file}"))
    end
  end

  describe "#auto_push?" do
    context "when auto_push configuration is false" do
      let!(:config) { SmashingDocs.config { |c| c.auto_push = false } }
      it "returns false" do
        expect(!SmashingDocs.current.send(:auto_push?))
      end
    end
    context "when auto_push configuration is true" do
      let!(:config) { SmashingDocs.config { |c| c.auto_push = true } }
      it "returns true" do
        expect(SmashingDocs.current.send(:auto_push?))
        SmashingDocs.config { |c| c.auto_push = false } # Config stays changed without this line
      end
    end
  end
end
