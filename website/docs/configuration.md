---
sidebar_position: 3
title: Configuration
description: Environment variables and initializer overrides
---

# Configuration

Configure telemetry through environment variables (recommended for production) or a Rails initializer.

**Prerequisite:** [Install](./install.md).

## Metrics environment variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `DECIDIM_TELEMETRY_ENABLED` | no | `true` | Enable `/metrics` export and metric middleware |
| `DECIDIM_TELEMETRY_EXPORT_INTERVAL` | no | `15` | Time-bucket size in **minutes** for Decidim counters |
| `DECIDIM_TELEMETRY_MOUNT_EXPORTER` | no | `true` | Mount `/metrics` on the main Rails port |
| `DECIDIM_TELEMETRY_USER` | no | — | Basic auth username for `/metrics` only |
| `DECIDIM_TELEMETRY_PASSWORD` | no | — | Basic auth password for `/metrics` only |

Set `DECIDIM_TELEMETRY_ENABLED=false` to disable the Prometheus exporter and auth middleware. Health endpoints remain available.

### Export on Puma port only

When `DECIDIM_TELEMETRY_MOUNT_EXPORTER=false`, `/metrics` is **not** served on the Rails port. Scrape Puma's Yabeda port instead (default **9394**):

```bash
DECIDIM_TELEMETRY_MOUNT_EXPORTER=false
```

Requires the Puma plugins activation from [Install](./install.md).

## OpenTelemetry environment variables

| Name | Required | Default | Description |
|------|----------|---------|-------------|
| `OTEL_EXPORTER_OTLP_ENDPOINT` | no | — | Base OTLP URL; used to derive `/v1/traces` and `/v1/logs` |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` | no | `{base}/v1/traces` | Full traces endpoint |
| `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` | no | `{base}/v1/logs` | Full logs endpoint |
| `OTEL_SERVICE_NAME` | no | `rails-app` | Service name on spans and log records |
| `OTEL_EXPORTER_TIMEOUT` | no | `5` | Exporter timeout in seconds |
| `OTEL_DEBUG` | no | `false` | Extra stderr warnings on OTEL failures |
| `OTEL_RESOURCE_ATTRIBUTES` | no | — | Standard SDK resource attributes (e.g. `host.name=…`) |

Full OpenTelemetry setup: [OpenTelemetry](./opentelemetry.md).

## Initializer (optional)

Use an initializer when env vars are not enough:

```ruby
# config/initializers/decidim_telemetry.rb
Decidim::Telemetry.configure do |config|
  config.enabled = Rails.env.production?
  config.export_interval = 15 # minutes

  config.open_telemetry.enabled = true             # master switch
  config.open_telemetry.traces_enabled = true
  config.open_telemetry.logs_enabled = true
  config.open_telemetry.exceptions_enabled = true
  config.open_telemetry.service_name = ENV.fetch("OTEL_SERVICE_NAME", "rails-app")
end
```

When `config.open_telemetry.enabled` is `false`, the whole OpenTelemetry module is skipped (no SDK, middleware, logs, or exception subscription).

## Puma reference

Upstream docs for the Yabeda Puma plugin: [yabeda-puma-plugin](https://github.com/yabeda-rb/yabeda-puma-plugin?tab=readme-ov-file#on-different-port).

## See also

- [Install](./install.md)
- [OpenTelemetry](./opentelemetry.md)
- [Prometheus](./prometheus.md)
- [Security](./security.md)
