# frozen_string_literal: true

require_relative "lib/human_sql/version"

Gem::Specification.new do |spec|
  spec.name          = "human_sql"
  spec.version       = HumanSQL::VERSION
  spec.authors       = ["Nicolas Bertin"]
  spec.email         = ["bertin@live.cl"]

  spec.summary       = "A gem to convert natural language to ActiveRecord queries using OpenAI"
  spec.description   = "This gem allows users to convert natural language queries into ActiveRecord code leveraging OpenAI's API."
  spec.homepage      = "https://github.com/nicobertin/human_sql"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nicobertin/human_sql"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Especificar dependencias
  spec.add_runtime_dependency "rails", ">= 6.0"
  spec.add_runtime_dependency "net-http", "~> 0.1.1"
end
