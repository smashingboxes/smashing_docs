# SmashingDocs

Based on [SmarfDoc](https://github.com/RickCarlino/smarf_doc)

![Smarf](http://i.imgur.com/f5mzeRU.png)

Too many docs spoil the broth.

SmashingDocs lets you turn your controller tests into API docs _without making changes to your test suite or how you write tests_.

Pop it into your test suite and watch it amaze.

Time for this project was provided by my employer, [SmashingBoxes](http://smashingboxes.com/). What a great place to work!

## Setup

In your gemfile:
`gem 'smashing_docs', group: :test, github: 'smashingboxes/smashing_docs'`

In  `test_helper.rb`:
```ruby
SmashingDocs.config do |c|
  c.template_file = 'test/template.md.erb'
  c.output_file   = 'api_docs.md'
end
```

[See test/fake_template.md for template examples.](https://github.com/smashingboxes/smashing_docs/blob/master/test/fake_template.md)

To run doc generation after every controller spec, put this into your `teardown` method. Or whatever method your test framework of choice will run after *every test*.

## Minitest Usage

Running it for every test case:

```ruby
class ActionController::TestCase < ActiveSupport::TestCase
  def teardown
    SmashingDocs.run!(request, response)
  end
end
```

..or if you only want to run it on certain tests, try this:

```ruby
def test_some_api
  get :index, :users
  assert response.status == 200
  SmashingDocs.run!(request, response)
end
```

Then put this at the bottom of your `test_helper.rb`:

```ruby
MiniTest::Unit.after_tests { SmashingDocs.finish! }
```

## Rspec Usage

Put this in your `spec_helper` and smoke it.

```ruby
RSpec.configure do |config|
  config.after(:each, type: :controller) do
    SmashingDocs.run!(request, response)
  end

  config.after(:suite) { SmashingDocs.finish! }
end
```


## Usage

It will log all requests and responses by default, but you can add some **optional** parameters as well.

### Skipping documentation

```ruby
def test_stuff
  SmashingDocs.skip
  # Blahhh
end
```

## Adding notes

```ruby
def test_stuff
  SmashingDocs.note "안녕하세요. This is a note."
  # Blahhh
end
```
