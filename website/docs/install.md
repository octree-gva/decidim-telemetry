---
sidebar_position: 2
slug: /install
title: Installation
description: Five steps to add observability to a Decidim host app
---

# Installation

Install the gem on your **host application**. No migrations are required.

**Prerequisite:** [Overview](./index.md).

**Next:** [Configure environment variables](./configuration.md), then [Prometheus scrape](./prometheus.md).

## 1. Add the gem

```ruby
# Gemfile
gem "decidim-telemetry", "~> 0.0"
```

## 2. Bundle

```bash
bundle install
```

## 3. Enable Puma metrics

Add to `config/puma.rb`:

```ruby
activate_control_app
plugin :yabeda
plugin :yabeda_prometheus
```

Puma exposes an additional metrics port (default **9394**) when `DECIDIM_TELEMETRY_MOUNT_EXPORTER=false`. See [Configuration](./configuration.md).

## 4. Set environment variables

Minimum for production (metrics on the main Rails port):

```bash
DECIDIM_TELEMETRY_ENABLED=true
```

Optional tuning — full list in [Configuration](./configuration.md).

## 5. Configure Prometheus and restart

Point your scraper at `/metrics` on port **3000** (or **9394** when the exporter is not mounted on Rails). Example in [Prometheus](./prometheus.md).

Restart Puma after changing env vars or `puma.rb`.

## Kubernetes probes

```yaml
livenessProbe:
  httpGet:
    path: /health/live
    port: 3000
  initialDelaySeconds: 30
readinessProbe:
  httpGet:
    path: /health/ready
    port: 3000
  periodSeconds: 10
```

Probes do not require authentication. See [Endpoints](./endpoints.md).

## See also

- [Configuration](./configuration.md)
- [Prometheus](./prometheus.md)
- [Security](./security.md)
- [FAQ](./faq.md)
