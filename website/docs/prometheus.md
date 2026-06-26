---
sidebar_position: 5
title: Prometheus
description: Scrape configuration for Decidim metrics
---

# Prometheus

Configure Prometheus (or any OpenMetrics-compatible scraper) to pull `/metrics` from your Decidim host.

**Prerequisite:** [Install](./install.md) and [Configuration](./configuration.md).

## Scrape Rails port (default)

When `DECIDIM_TELEMETRY_MOUNT_EXPORTER=true` (default):

```yaml
# prometheus.yml
scrape_configs:
  - job_name: decidim
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['decidim-web:3000']
```

Replace `decidim-web:3000` with your service hostname and port.

## Scrape Puma port

When `DECIDIM_TELEMETRY_MOUNT_EXPORTER=false`:

```yaml
scrape_configs:
  - job_name: decidim-puma
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets: ['decidim-web:9394']
```

Expose port `9394` in your container or process supervisor if Prometheus runs outside the host network.

## Basic auth

When credentials are set, add them to the scrape job:

```yaml
scrape_configs:
  - job_name: decidim
    metrics_path: /metrics
    basic_auth:
      username: metrics
      password_file: /etc/prometheus/secrets/decidim_metrics
    static_configs:
      - targets: ['decidim-web:3000']
```

Auth applies to `/metrics` only. Health probes stay open.

## What you will see

Besides custom Decidim counters (see [Metrics](./metrics.md)), Yabeda exports standard Rails, Puma, and ActiveJob metrics (`ruby_*`, `puma_*`, `activejob_*`, etc.).

## See also

- [Endpoints](./endpoints.md)
- [Metrics reference](./metrics.md)
- [Security](./security.md)
