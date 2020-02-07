# -*- encoding: utf-8 -*-
# stub: dry-transaction 0.13.0 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-transaction".freeze
  s.version = "0.13.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Riley".freeze]
  s.date = "2018-06-13"
  s.email = ["tim@icelab.com.au".freeze]
  s.homepage = "https://github.com/dry-rb/dry-transaction".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Business Transaction Flow DSL".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<dry-container>.freeze, [">= 0.2.8"])
    s.add_runtime_dependency(%q<dry-events>.freeze, [">= 0.1.0"])
    s.add_runtime_dependency(%q<dry-matcher>.freeze, [">= 0.7.0"])
    s.add_runtime_dependency(%q<dry-monads>.freeze, [">= 0.4.0"])
    s.add_development_dependency(%q<bundler>.freeze, ["~> 1.15"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 11.2", ">= 11.2.2"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.3"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_development_dependency(%q<yard>.freeze, [">= 0"])
  else
    s.add_dependency(%q<dry-container>.freeze, [">= 0.2.8"])
    s.add_dependency(%q<dry-events>.freeze, [">= 0.1.0"])
    s.add_dependency(%q<dry-matcher>.freeze, [">= 0.7.0"])
    s.add_dependency(%q<dry-monads>.freeze, [">= 0.4.0"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.15"])
    s.add_dependency(%q<rake>.freeze, ["~> 11.2", ">= 11.2.2"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.3"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<yard>.freeze, [">= 0"])
  end
end
