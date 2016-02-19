$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.authors = ['Tyler Rockwell', 'Annie Baer', 'Rick Carlino']
  s.description = "Write API documentation using existing controller tests."
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/smashingboxes/smashing_docs'
  s.license = 'MIT'
  s.name = 'smashing_docs'
  s.require_paths = ['lib']
  s.summary = "Uses your test cases to write example documentation for your API."
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = '0.0.3'

  s.add_development_dependency "bundler", "~> 1.11"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "generator_spec"
end
