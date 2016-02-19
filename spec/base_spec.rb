require 'spec_helper'

RSpec.describe SmashingDocs do
  let(:file) { SmashingDocs::Conf.output_file }
  let(:first) { Request.new("GET", {id: 12}, 'api/aaa') }
  let(:middle) { Request.new("GET", { id: 12 }, 'api/ooo') }
  let(:last) { Request.new("GET", {id: 12}, 'api/zzz') }
  let(:tests) { SmashingDocs.current.tests }

  describe ".run!(request, response)" do
    context "when run_all config is set to true" do
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

    context "when run_all config is set to false" do
      context "tests triggered by RSpec after hook" do
        it "does not add the tests" do
          SmashingDocs::Conf.run_all = false
          SmashingDocs.run!(request, response, true)
          expect(tests.length).to eq(0)
        end
      end
      context "tests added by the user" do
        it "adds the tests" do
          SmashingDocs::Conf.run_all = false
          SmashingDocs.run!(request, response)
          expect(tests.length).to eq(1)
        end
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
    context "when there are tests" do
      it "creates the docs file with output from the template" do
        SmashingDocs.run!(first, response)
        SmashingDocs.run!(last, response)
        SmashingDocs.finish!
        expect(File).to exist(file)
        expect(File.read(file)).to include("You can use ERB")
      end
    end

    context "when there are no tests" do
      it "does not overwrite the docs with an empty file" do
        # Generate docs
        SmashingDocs.run!(first, response)
        SmashingDocs.run!(last, response)
        SmashingDocs.finish!
        expect(File).to exist(file)
        expect(File.read(file)).to include("You can use ERB")

        SmashingDocs.current.tests = []
        SmashingDocs.finish!
        expect(File).to exist(file)
        expect(File.read(file)).to include("You can use ERB")
      end
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
    # The template file must have <%= information[:note] %>
    it "sends information to be displayed about the endpoint" do
      SmashingDocs.aside("I am an aside")
      SmashingDocs.run!(first, response)
      expect(tests.first.compile_template).to include("<aside class='notice'>")
      expect(tests.first.compile_template).to include("I am an aside")
    end
  end
end
