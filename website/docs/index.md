---
sidebar_position: 1
slug: /
title: Overview
description: Prometheus metrics and health probes for Decidim
---

# Decidim Telemetry

**decidim-telemetry** adds **Prometheus metrics** and **health probes** to a running Decidim host application. It does not replace your monitoring stack — it exposes `/metrics` and `/health/*` so Prometheus, Kubernetes, or your load balancer can observe the app.

**Prerequisite:** a Decidim host app (≥ 0.29.4), Puma, and a Prometheus-compatible scraper.

## What you get

- **Health endpoints** — liveness and readiness checks for orchestrators
- **Prometheus `/metrics`** — Decidim activity counters, Rack::Attack matches, Yabeda Rails/Puma/ActiveJob metrics
- **No database migrations** — drop-in gem

## Documentation

| You are… | Read |
|----------|------|
| Platform / system administrator | [Install](./install.md) → [Prometheus](./prometheus.md) |
| Security review | [Security](./security.md) |
| On-call / troubleshooting | [FAQ](./faq.md) |
| Gem contributor | [Contribute](./contributing) |

## Compatibility

| Decidim | Supported |
|---------|-----------|
| ≥ 0.29.4 | yes |
| 0.28 and older | no |

## Quick install

```ruby
# Gemfile
gem "decidim-telemetry", "~> 0.0"
```

```bash
bundle install
```

Then follow [Install](./install.md) for Puma plugins, environment variables, and Prometheus scrape config.

## See also

- [Install](./install.md)
- [Configuration](./configuration.md)
- [Endpoints](./endpoints.md)
- [Metrics reference](./metrics.md)
