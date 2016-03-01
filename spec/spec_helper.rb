RSpec.configure do |config|
  config.after(:each, type: :controller) do
    SmashingDocs.run!(request, response, true)
  end
 # config.after(:suite) { SmashingDocs.finish! }
end
