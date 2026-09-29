---
sidebar_position: 8
title: FAQ
description: Common installation and operations questions
---

# FAQ

**Prerequisite:** [Install](./install.md).

## `/health/ready` returns 503

Check the `checks` object in the JSON response:

| Failed check | Likely cause |
|--------------|--------------|
| `database` | PostgreSQL down or wrong `DATABASE_URL` |
| `cache` | Cache store misconfigured |
| `public_files_accessibles` | Assets not compiled — run `rails assets:precompile` |
| `yabeda` | Gem not loaded — verify `bundle install` and restart |
| `redis` | `REDIS_URL` set but Redis unreachable |

## `/metrics` returns 404

- Confirm `DECIDIM_TELEMETRY_ENABLED=true`
- If `DECIDIM_TELEMETRY_MOUNT_EXPORTER=false`, scrape port **9394** instead of the Rails port
- Restart Puma after env changes

## `/metrics` returns 401

Basic auth is enabled. Pass credentials in your scraper or unset `DECIDIM_TELEMETRY_USER` and `DECIDIM_TELEMETRY_PASSWORD`.

## Metrics are empty or zero

- Counters increment on Decidim activity — generate a test comment or registration
- `rack_attack_matches` requires Rack::Attack rules to fire
- Check `DECIDIM_TELEMETRY_EXPORT_INTERVAL` — buckets are coarse by design

## Do I need migrations?

No. `bundle install` is enough.

## Does this send data to a third party?

No. Metrics stay on your infrastructure. Prometheus pulls from your app; nothing is pushed outbound by default.

OpenTelemetry only exports when you set `OTEL_*` endpoints and leave `config.open_telemetry.enabled` on — data goes to **your** OTLP collector.

## Traces or logs do not appear

- Confirm `config.open_telemetry.enabled` is true and the feature flags you need (`traces_enabled`, `logs_enabled`) are true
- Set `OTEL_EXPORTER_OTLP_ENDPOINT` (or specific traces/logs endpoints)
- Run `bundle exec rake decidim:telemetry:opentelemetry:config` and `:test`
- Check app logs for `[OpenTelemetry]` messages; set `OTEL_DEBUG=true` for extra warnings

## See also

- [Endpoints](./endpoints.md)
- [Configuration](./configuration.md)
- [OpenTelemetry](./opentelemetry.md)
- [Prometheus](./prometheus.md)
