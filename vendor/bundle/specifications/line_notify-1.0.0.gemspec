# -*- encoding: utf-8 -*-
# stub: line_notify 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "line_notify".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["YuzuruS".freeze]
  s.bindir = "exe".freeze
  s.date = "2018-02-18"
  s.description = "Client for the LINE notify API".freeze
  s.email = ["navitima@gmail.com".freeze]
  s.homepage = "https://github.com/YuzuruS/line_notify".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.0.2".freeze
  s.summary = "Client for the LINE notify API".freeze

  s.installed_by_version = "3.0.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<pry>.freeze, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0"])
      s.add_development_dependency(%q<guard>.freeze, [">= 0"])
      s.add_development_dependency(%q<terminal-notifier>.freeze, [">= 0"])
      s.add_development_dependency(%q<terminal-notifier-guard>.freeze, [">= 0"])
      s.add_development_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_development_dependency(%q<ffi>.freeze, ["= 1.9.18"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<pry>.freeze, [">= 0"])
      s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
      s.add_dependency(%q<guard>.freeze, [">= 0"])
      s.add_dependency(%q<terminal-notifier>.freeze, [">= 0"])
      s.add_dependency(%q<terminal-notifier-guard>.freeze, [">= 0"])
      s.add_dependency(%q<coveralls>.freeze, [">= 0"])
      s.add_dependency(%q<ffi>.freeze, ["= 1.9.18"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.16"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<guard-rspec>.freeze, [">= 0"])
    s.add_dependency(%q<guard>.freeze, [">= 0"])
    s.add_dependency(%q<terminal-notifier>.freeze, [">= 0"])
    s.add_dependency(%q<terminal-notifier-guard>.freeze, [">= 0"])
    s.add_dependency(%q<coveralls>.freeze, [">= 0"])
    s.add_dependency(%q<ffi>.freeze, ["= 1.9.18"])
  end
end
