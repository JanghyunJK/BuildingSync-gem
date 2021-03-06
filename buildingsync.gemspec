lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'buildingsync/version'

Gem::Specification.new do |spec|
  spec.name          = 'buildingsync'
  spec.version       = BuildingSync::VERSION
  spec.authors       = ['Nicholas Long', 'Dan Macumber', 'Katherine Fleming']
  spec.email         = ['nicholas.long@nrel.gov', 'daniel.macumber@nrel.gov', 'katherine.fleming@nrel.gov']

  spec.summary       = 'BuildingSync library for reading, writing, and exporting BuildingSync to OpenStudio'
  spec.description   = 'BuildingSync library for reading, writing, and exporting BuildingSync to OpenStudio'
  spec.homepage      = 'https://buildingsync.net'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'rake', '12.3.1'
  spec.add_development_dependency 'rspec', '3.8.0'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'
  spec.add_development_dependency 'rubocop-checkstyle_formatter', '~> 0.4.0'

  spec.add_dependency 'multipart-post', '2.1.1'
  spec.add_dependency 'openstudio-model-articulation', '~> 0.1.0'
end
