# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/age_and_district_action_authorization/version"

Gem::Specification.new do |s|
  s.name = "decidim-module-age_and_district_action_authorization"
  s.version = Decidim::AgeAndDistrictActionAuthorization::VERSION
  s.authors = ["Oliver Valls"]
  s.email = ["oliver.vh@coditramuntana.com"]
  s.summary = "Age and district based Action authorizer for the Decidim project"
  s.description = ""
  s.homepage = "https://github.com/CodiTramuntana/decidim-module-age_and_district_action_authorization"
  s.license = "AGPLv3"

  s.required_ruby_version = ">= 2.7.5"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  DECIDIM_VERSION = ">= #{Decidim::AgeAndDistrictActionAuthorization::MIN_DECIDIM_VERSION}"

  s.add_dependency "decidim", DECIDIM_VERSION

  s.add_development_dependency "decidim-dev", DECIDIM_VERSION
end
