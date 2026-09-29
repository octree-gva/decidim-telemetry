# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/telemetry/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-telemetry"
  spec.version = Decidim::Telemetry.version
  spec.authors = ["Hadrien Froger"]
  spec.email = ["hadrien@octree.ch"]

  spec.summary = "Observability for Decidim"
  spec.description = "Prometheus metrics, health probes, and OpenTelemetry (traces, logs, exceptions) for Decidim"
  spec.license = "AGPL-3.0"
  spec.homepage = "https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry"
  spec.required_ruby_version = ">= 3.2.2"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::Telemetry::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-comments", Decidim::Telemetry::COMPAT_DECIDIM_VERSION
  spec.add_dependency "opentelemetry-exporter-otlp"
  spec.add_dependency "opentelemetry-exporter-otlp-logs"
  spec.add_dependency "opentelemetry-instrumentation-all"
  spec.add_dependency "opentelemetry-logs-sdk"
  spec.add_dependency "opentelemetry-sdk"
  spec.add_dependency "yabeda", ">= 0.14.0"
  spec.add_dependency "yabeda-activejob", ">= 0.6.0"
  spec.add_dependency "yabeda-activerecord", ">= 0.1.1"
  spec.add_dependency "yabeda-prometheus", ">= 0.9.1"
  spec.add_dependency "yabeda-puma-plugin", ">= 0.8.0"
  spec.add_dependency "yabeda-rails", ">= 0.10.0"
end
