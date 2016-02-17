require_relative "test_helper"

class TestBase < SmashingDocsTest

  def test_run!
    tests = SmashingDocs.current.tests
    assert_equal 0, tests.length,
      "Expected current tests to be an empty array"
    SmashingDocs.run!(request, response)
    assert_equal 1, tests.length,
      "Expected run!() to increase number of tests"
    assert tests.first.is_a?(SmashingDocs::TestCase)
    SmashingDocs.run!(request, response)
    assert_equal 2, tests.length,
      "Expected run!() to increase number of tests"
    assert_includes tests.first.compile_template,
        "You can use ERB to format each test case",
        "Did not load correct template file"
  end

  def test_sort!
    first = Request.new("GET", {id: 12}, 'api/aaa')
    last  = Request.new("GET", {id: 12}, 'api/zzz')
    SmashingDocs.run!(first, response)
    SmashingDocs.run!(last, response)
    results = SmashingDocs.current.sort_by_url!.map{|tc| tc.request.path}
    assert_equal ["api/aaa", "api/zzz"], results,
      "Did not sort test cases by request URL"
  end

  def test_finish!
    file = SmashingDocs::Conf.output_file
    first = Request.new("GET", {id: 12}, 'api/aaa')
    last  = Request.new("GET", {id: 12}, 'api/zzz')
    SmashingDocs.run!(first, response)
    SmashingDocs.run!(last, response)
    SmashingDocs.finish!
    assert File.exists?(file),
      "Did not create an output file after finish!()ing"
    assert_includes File.read(file), "You can use ERB",
      "Did not utilize template to output docs."
  end

  def test_skip
    file = SmashingDocs::Conf.output_file
    tests= SmashingDocs.current.tests
    first = Request.new("GET", {id: 12}, 'api/skip')
    last  = Request.new("GET", {id: 12}, 'api/noskip')
    SmashingDocs.skip
    SmashingDocs.run!(first, response)
    SmashingDocs.run!(last, response)
    assert_equal 1, tests.length,
      "Tests were not skipped."
    assert_equal 'api/noskip', tests.first.request.path,
      "Tests were not skipped."
  end

  def test_multiple_skips
    file = SmashingDocs::Conf.output_file
    tests= SmashingDocs.current.tests
    first = Request.new("GET", {id: 12}, 'api/noskip1')
    second = Request.new("GET", {id: 12}, 'api/skip1')
    third  = Request.new("GET", {id: 12}, 'api/skip2')
    fourth  = Request.new("GET", {id: 12}, 'api/noskip2')
    SmashingDocs.run!(first, response)
    SmashingDocs.skip
    SmashingDocs.run!(second, response)
    SmashingDocs.skip
    SmashingDocs.run!(third, response)
    SmashingDocs.run!(fourth, response)
    assert_equal 2, tests.length,
      "Skipped incorrect number of tests."
    assert_equal 'api/noskip1', tests[0].request.path,
      "Test was supposed to be first, but was not"
    assert_equal 'api/noskip2', tests[1].request.path,
      "Test was supposed to be second, but was not."
  end

  def test_note
    file = SmashingDocs::Conf.output_file
    tests= SmashingDocs.current.tests
    first = Request.new("GET", {id: 12}, 'api/skip')
    last  = Request.new("GET", {id: 12}, 'api/noskip')
    SmashingDocs.information(:note, "Endpoint note")
    SmashingDocs.run!(first, response)
    SmashingDocs.run!(last, response)
    assert_includes tests.first.compile_template, "Endpoint note",
      "Could not find note in documentation."
  end

  def test_aside
    file = SmashingDocs::Conf.output_file
    tests= SmashingDocs.current.tests
    first = Request.new("GET", {id: 12}, 'api/skip')
    last  = Request.new("GET", {id: 12}, 'api/noskip')
    SmashingDocs.aside("This is an aside")
    SmashingDocs.run!(first, response)
    SmashingDocs.run!(last, response)
    assert_includes tests.first.compile_template, "This is an aside",
      "Could not find note in documentation."
  end
end
