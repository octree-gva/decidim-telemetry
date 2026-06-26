---
sidebar_position: 4
title: Endpoints
description: Health probes and metrics URL
---

# Endpoints

All paths are mounted at the **host application root** (same port as Decidim unless noted).

**Prerequisite:** [Install](./install.md).

## Health (always available)

| Path | Purpose | Auth |
|------|---------|------|
| `GET /health` | Simple OK check | none |
| `GET /health/live` | Liveness probe | none |
| `GET /health/ready` | Readiness probe | none |

### Readiness checks

`/health/ready` returns `200` when all checks pass, `503` otherwise.

| Check | What it verifies |
|-------|------------------|
| `database` | PostgreSQL connection active |
| `yabeda` | Yabeda configured |
| `cache` | Rails cache read/write |
| `public_files_accessibles` | `public/decidim-packs/manifest.json` exists |
| `redis` | Redis answer to PING. Included only when `REDIS_URL` is set |

Example ready response:

```json
{
  "status": "ready",
  "checks": {
    "database": true,
    "yabeda": true,
    "cache": true,
    "public_files_accessibles": true
  },
  "timestamp": "2026-06-26T12:00:00Z"
}
```

## Metrics (when enabled)

| Path | Content-Type | Condition |
|------|--------------|-----------|
| `GET /metrics` | `text/plain` | `DECIDIM_TELEMETRY_ENABLED=true` and `DECIDIM_TELEMETRY_MOUNT_EXPORTER=true` |

When `DECIDIM_TELEMETRY_MOUNT_EXPORTER=false`, scrape `/metrics` on the **Puma Yabeda port** (default `9394`) instead.

Basic auth applies to `/metrics` only when both `DECIDIM_TELEMETRY_USER` and `DECIDIM_TELEMETRY_PASSWORD` are set. See [Security](./security.md).

## See also

- [Prometheus](./prometheus.md)
- [Metrics reference](./metrics.md)
- [FAQ](./faq.md)
