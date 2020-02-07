# -*- encoding: utf-8 -*-
# stub: dry-matcher 0.8.3 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-matcher".freeze
  s.version = "0.8.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Riley".freeze, "Nikita Shilnikov".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-01-07"
  s.description = "Flexible, expressive pattern matching for Ruby".freeze
  s.email = ["tim@icelab.com.au".freeze, "fg@flashgordon.ru".freeze]
  s.homepage = "http://dry-rb.org/gems/dry-matcher".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Flexible, expressive pattern matching for Ruby".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<dry-core>.freeze, [">= 0.4.8"])
    s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  else
    s.add_dependency(%q<dry-core>.freeze, [">= 0.4.8"])
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
  end
end
