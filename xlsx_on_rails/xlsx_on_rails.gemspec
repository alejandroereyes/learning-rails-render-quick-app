$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "xlsx_on_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "xlsx_on_rails"
  s.version     = XlsxOnRails::VERSION
  s.authors     = ["Alex Reyes"]
  s.email       = ["alex.reyes@peopleadmin.com"]
  s.homepage    = "TODO"
  s.summary     = "An XLSX renderer and template handler"
  s.description = "A complete XLSX solution for Rails, offering a template handler, custom renderer, and respond_with support."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.22"
  s.add_dependency "axlsx", ">= 2.0.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "roo"
  s.add_development_dependency 'test-unit'
end
