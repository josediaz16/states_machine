# -*- encoding: utf-8 -*-
# stub: dry-monads 1.3.5 ruby lib

Gem::Specification.new do |s|
  s.name = "dry-monads".freeze
  s.version = "1.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Nikita Shilnikov".freeze]
  s.bindir = "exe".freeze
  s.date = "2020-01-06"
  s.description = "Common monads for Ruby.".freeze
  s.email = ["fg@flashgordon.ru".freeze]
  s.homepage = "https://github.com/dry-rb/dry-monads".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4.0".freeze)
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Common monads for Ruby.".freeze

  s.installed_by_version = "3.1.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<dry-core>.freeze, ["~> 0.4", ">= 0.4.4"])
    s.add_runtime_dependency(%q<dry-equalizer>.freeze, [">= 0"])
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<dry-types>.freeze, [">= 0.12"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  else
    s.add_dependency(%q<concurrent-ruby>.freeze, ["~> 1.0"])
    s.add_dependency(%q<dry-core>.freeze, ["~> 0.4", ">= 0.4.4"])
    s.add_dependency(%q<dry-equalizer>.freeze, [">= 0"])
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<dry-types>.freeze, [">= 0.12"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
  end
end
