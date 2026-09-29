---
sidebar_position: 1
slug: /
title: Overview
description: Prometheus metrics, health probes, and OpenTelemetry for Decidim
---

# Decidim Telemetry

**decidim-telemetry** adds **Prometheus metrics**, **health probes**, and optional **OpenTelemetry** (traces, OTLP logs, exception reporting) to a running Decidim host application. It does not replace your monitoring stack — it exposes `/metrics` and `/health/*`, and can export OTLP data to your collector.

**Prerequisite:** a Decidim host app (≥ 0.29.4), Puma, and a Prometheus-compatible scraper. OpenTelemetry needs an OTLP collector when enabled.

## What you get

- **Health endpoints** — liveness and readiness checks for orchestrators
- **Prometheus `/metrics`** — Decidim activity counters, Rack::Attack matches, Yabeda Rails/Puma/ActiveJob metrics
- **OpenTelemetry** — traces, WARN+ logs, and `Rails.error` exception spans (configurable)
- **No database migrations** — drop-in gem

## Compatibility

| Decidim | Supported |
|---------|-----------|
| ≥ 0.29.4 | yes |
| 0.28 and older | no |

## Quick install

```ruby
# Gemfile
gem "decidim-telemetry", "~> 0.1"
```

```bash
bundle install
```

Then follow [Install](./install.md) for Puma plugins, environment variables, and Prometheus scrape config. For traces and logs, see [OpenTelemetry](./opentelemetry.md).

## See also

- [Install](./install.md)
- [Configuration](./configuration.md)
- [OpenTelemetry](./opentelemetry.md)
- [Endpoints](./endpoints.md)
- [Metrics reference](./metrics.md)
