# SmashingDocs

### Based on [SmarfDoc](https://github.com/RickCarlino/smarf_doc) by [Rick Carlino](https://github.com/RickCarlino/)

## Gem Installation in Rails

In your gemfile add the following to your test group:

`gem 'smashing_docs', '~> 0.0.3'`

Installation differs for RSpec/Minitest, so scroll to the appropriate section for guidance.

## Automatic Installation (RSpec only!)

After you bundle, run:

`rails generate smashing_documentation:install`

SmashingDocs will be configured to run on all your controller tests with the default
template.

#### To generate your docs

Run `rails g smashing_documentation:build_docs`, and your docs will be waiting for you
in the `smashing_docs` folder.

## Manual RSpec Installation

Add this to your `rails_helper.rb` It should go outside of other blocks
(Do not place it inside the `RSpec.configure` block).
```ruby
SmashingDocs.config do |c|
  c.template_file = 'smashing_docs/template.md'
  c.output_file   = 'smashing_docs/api_docs.md'
  c.run_all       = true
end
```

Add the following content to `spec_helper.rb` inside the `RSpec.configure` block

`config.after(:suite) { SmashingDocs.finish! }`

It should look like this
```ruby
RSpec.configure do |config|
  # Existing code
  config.after(:each, type: :controller) do
    SmashingDocs.run!(request, response, true)
  end
  # config.after(:suite) { SmashingDocs.finish! }
end
```

#### To run on only select tests
Set the `c.run_all` line to `false` in `rails_helper.rb`
```ruby
SmashingDocs.config do |c|
  c.template_file = 'smashing_docs/template.md'
  c.output_file   = 'smashing_docs/api_docs.md'
  c.run_all       = false
end
```

Then just add `SmashingDocs.run!(request, response)` to the tests you want to run
```ruby
it "responds with 200" do
  get :index
  expect(response).to be_success
  SmashingDocs.run!(request, response)
end
```

## Manual Minitest Installation

Add the code from below to `test_helper.rb`:
```ruby
class ActiveSupport::TestCase
  # Already existing code
  SmashingDocs.config do |c|
    c.template_file = 'smashing_docs/template.md'
    c.output_file   = 'smashing_docs/api_docs.md'
    c.run_all       = true
  end
  # More code
end

class ActionController::TestCase < ActiveSupport::TestCase
  def teardown
    SmashingDocs.run!(request, response, true)
  end
end

MiniTest::Unit.after_tests { SmashingDocs.finish! }
```

#### To run on only select tests
Set the `c.run_all` line to `false` in `test_helper.rb`
```ruby
SmashingDocs.config do |c|
  c.template_file = 'smashing_docs/template.md'
  c.output_file   = 'smashing_docs/api_docs.md'
  c.run_all       = false
end
```

Then just add `SmashingDocs.run!(request, response)` to specific tests
```ruby
def get_index
  get :index
  assert response.status == 200
  SmashingDocs.run!(request, response)
end
```

## Setting a template

If you copied the code from above, SmashingDocs will look for a template file located in
`smashing_docs/template.md`

This template may be customized to fit your needs.

```erb
<%= request.method %>
<%= request.path %>
<%= request.params %>
<%= response.body %>
<%= information[:note] %>
```

## Where to find the docs

By default, the docs are output to `api_docs.md` in the root of the Rails project.
You can change this by altering the config in `test_helper.rb` or `rails_helper.rb`.

## Additional Features

#### Skipping documentation on tests

To leave certain tests out of the documentation, just add `SmashingDocs.skip` to the test.

```ruby
it "responds with 200" do
  SmashingDocs.skip
  # test code
end
```

#### Adding information, e.g. notes
SmashingDocs will log all requests and responses by default, but you can add some
**optional** parameters as well.

```ruby
it "responds with 200" do
  SmashingDocs.information(:note, "This endpoint only responds on Tuesdays")
  # test code
end
```
You can store any information with `:note`, `:message`, or any other key you can think of.
To access information in the template, just use `<%= information[:key] %>`
