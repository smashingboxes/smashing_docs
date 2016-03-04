# SmashingDocs

### Based on [SmarfDoc](https://github.com/RickCarlino/smarf_doc) by [Rick Carlino](https://github.com/RickCarlino/)

## Gem Installation in Rails

In your gemfile add the following to your test group:

`gem 'smashing_docs', '~> 1.3.1'`

Installation differs for RSpec/Minitest, so scroll to the appropriate section for guidance.

## Automatic Installation (RSpec or Minitest!)

After you bundle, run:

`rails g docs:install`

SmashingDocs will be configured to run on all your controller tests with the default
template.

If you're using RSpec and you haven't required `rails_helper` in your tests, do that now.

`require 'rails_helper'`

#### To generate your docs

Run `rails g docs:build_docs`, and your docs will be waiting for you in the `smashing_docs` folder.

## Manual RSpec Installation

Add this to your `rails_helper.rb` It should go outside of other blocks
(Do not place it inside the `RSpec.configure` block).
```ruby
SmashingDocs.config do |c|
  c.template_file = 'smashing_docs/template.md'
  c.output_file   = 'smashing_docs/api_docs.md'
  c.run_all       = true
  c.auto_push     = false
  c.wiki_folder   = nil
end
```

Add the following content to `spec_helper.rb` inside the `RSpec.configure` block

`# config.after(:suite) { SmashingDocs.finish! }`

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
  # configs
  c.run_all       = false
  # configs
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
    c.auto_push     = false
    c.wiki_folder   = nil
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
  # configs
  c.run_all       = false
  # configs
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

If you used the auto-installer or copied the code from above, SmashingDocs will
look for a template file located in `smashing_docs/template.md`

This template may be customized to fit your needs.

```erb
<%= request.method %>
<%= request.path %>
<%= request.params %>
<%= response.body %>
<%= information[:note] %>
```

## Where to find the docs

By default, the docs are output to `smashing_docs/api_docs.md` in the Rails project.
You can change this by altering the config in `test_helper.rb` (MiniTest) or
`rails_helper.rb`(RSpec).

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

#### Auto-Push Docs to Your Project Wiki

SmashingDocs can automatically push your generated docs to your project wiki.

**To enable this feature**
  1. Clone your wiki repo from Github into the same parent folder as your app

  Your folder structure should be

    ../projects/rails_app

    ../projects/my_rails_app.wiki

  2. Set the name of your wiki folder (do **not** include '.wiki')

    ``` ruby
      SmashingDocs.config do |c|
        # configs
        c.wiki_folder = "my_rails_app"
      end
    ```

  3. Set auto_push to true in `rails_helper.rb` or `test_helper.rb`

    ``` ruby
      SmashingDocs.config do |c|
        # configs
        c.auto_push = true
        # configs
      end
    ```

  4. Build your docs with `rails g docs:build_docs`

#### Generate Docs on Every Test Suite Run

If you prefer to have your docs built every time you run the test suite, and do
not want to run the build command, then uncomment the `SmashingDocs.finish` line
in your `rails_helper` or `test_helper`
