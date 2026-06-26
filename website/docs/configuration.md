---
sidebar_position: 3
title: Configuration
description: Environment variables and initializer overrides
---

# Configuration

Configure telemetry through environment variables (recommended for production) or a Rails initializer.

**Prerequisite:** [Install](./install.md).

## Environment variables

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

## Initializer (optional)

Use an initializer when env vars are not enough (for example, enable only in production):

```ruby
# config/initializers/decidim_telemetry.rb
Decidim::Telemetry.configure do |config|
  config.enabled = Rails.env.production?
  config.export_interval = 15 # minutes
end
```

Initializer values override defaults set at boot. Environment variables are applied first; set `config.*` after boot only through this block.

## Puma reference

Upstream docs for the Yabeda Puma plugin: [yabeda-puma-plugin](https://github.com/yabeda-rb/yabeda-puma-plugin?tab=readme-ov-file#on-different-port).

## See also

- [Install](./install.md)
- [Prometheus](./prometheus.md)
- [Security](./security.md)
