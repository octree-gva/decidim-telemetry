---
sidebar_position: 4
title: OpenTelemetry
description: Traces, OTLP logs, and exception reporting
---

# OpenTelemetry

**decidim-telemetry** can export **traces**, **logs** (WARN and above), and **exception reports** via OpenTelemetry Protocol (OTLP) to your collector.

**Persona:** Decidim operators and integrators configuring observability.

**Prerequisite:** [Install](./install.md) and [Configuration](./configuration.md).

## Overview

When `config.open_telemetry.enabled` is `true` (default):

| Flag | Default | Behavior |
|------|---------|----------|
| `traces_enabled` | `true` | OTLP span export + instrumentations |
| `logs_enabled` | `true` | OTLP log export; extends `Rails.logger` (WARN+) |
| `exceptions_enabled` | `true` | Subscribes to `Rails.error` and records exceptions on spans |

Set `enabled = false` to disable the whole OpenTelemetry module.

## Infrastructure

You need an **OTLP collector** (or backend that accepts OTLP HTTP) reachable from the Rails process. Example env:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
OTEL_SERVICE_NAME=decidim-production
```

Service name resolution is **only** `OTEL_SERVICE_NAME`, falling back to `rails-app`. Extra resource attributes use the standard `OTEL_RESOURCE_ATTRIBUTES` env var.

## Decidim context on spans

Middleware and error reporting attach attributes when available:

- `enduser.id` / `enduser.nickname`
- `decidim.organization.id` / `decidim.organization.slug`
- `decidim.participatory_space.*`
- `decidim.component.*`

## Initializer example

```ruby
# config/initializers/decidim_telemetry.rb
Decidim::Telemetry.configure do |config|
  config.open_telemetry.enabled = Rails.env.production?
  config.open_telemetry.traces_enabled = true
  config.open_telemetry.logs_enabled = true
  config.open_telemetry.exceptions_enabled = true
  config.open_telemetry.traces_endpoint = ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"]
  config.open_telemetry.logs_endpoint = ENV["OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"]
  config.open_telemetry.service_name = ENV.fetch("OTEL_SERVICE_NAME", "rails-app")
  config.open_telemetry.exporter_timeout = 5
  config.open_telemetry.debug = false
end
```

OpenTelemetry boots **after** Rails config initializers, so this block can override defaults before the SDK starts.

## Debug rake tasks

```bash
bundle exec rake decidim:telemetry:opentelemetry:config
bundle exec rake decidim:telemetry:opentelemetry:test
```

## See also

- [Configuration](./configuration.md)
- [FAQ](./faq.md)
