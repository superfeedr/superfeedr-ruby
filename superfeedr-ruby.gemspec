# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{superfeedr-ruby}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["julien Genestoux"]
  s.date = %q{2009-06-11}
  s.email = %q{julien.genestoux@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/config.yaml",
    "lib/stanzas/iq_query_stanza.rb",
    "lib/stanzas/notification_stanza.rb",
    "lib/stanzas/subscribe_query_stanza.rb",
    "lib/stanzas/subscriptions_query_stanza.rb",
    "lib/stanzas/unsubscribe_query_stanza.rb",
    "lib/superfeedr.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/stanzas/iq_query_stanza_spec.rb",
    "spec/stanzas/notifications_stanza_spec.rb",
    "spec/stanzas/subscribe_stanza_spec.rb",
    "spec/stanzas/subscriptions_stanza_spec.rb",
    "spec/stanzas/unsubscribe_stanza_spec.rb",
    "spec/superfeedr_ruby_spec.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/julien51/superfeedr-ruby/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{superfeedr-ruby}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby Client for the Superfeedr}
  s.test_files = [
    "spec/spec_helper.rb",
    "spec/stanzas/iq_query_stanza_spec.rb",
    "spec/stanzas/notifications_stanza_spec.rb",
    "spec/stanzas/subscribe_stanza_spec.rb",
    "spec/stanzas/subscriptions_stanza_spec.rb",
    "spec/stanzas/unsubscribe_stanza_spec.rb",
    "spec/superfeedr_ruby_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<julien51-babylon>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<julien51-babylon>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<julien51-babylon>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
