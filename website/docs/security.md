---
sidebar_position: 7
title: Security
description: Basic auth and network exposure for metrics
---

# Security

How authentication and exposure work for observability endpoints.

**Prerequisite:** [Configuration](./configuration.md).

## Basic authentication

Set both variables to protect `/metrics`:

```bash
DECIDIM_TELEMETRY_USER=metrics
DECIDIM_TELEMETRY_PASSWORD=<secret>
```

- Auth applies **only** to `GET /metrics`
- `/health`, `/health/live`, and `/health/ready` stay **unauthenticated** so load balancers and Kubernetes can probe without credentials
- Participant and admin traffic is **not** affected

Configure Prometheus with `basic_auth` — see [Prometheus](./prometheus.md).

## Disable metrics export

```bash
DECIDIM_TELEMETRY_ENABLED=false
```

Stops `/metrics` on the Rails port and disables the auth middleware. Health endpoints remain available.

## Network exposure

| Endpoint | Typical exposure |
|----------|------------------|
| `/health/*` | Load balancer, orchestrator (internal) |
| `/metrics` | Prometheus scraper (internal network or VPN) |
| Puma `:9394` | Internal only when using separate exporter port |

Restrict scrape targets with firewall rules or Kubernetes `NetworkPolicy` so `/metrics` is not reachable from the public internet.

## See also

- [Endpoints](./endpoints.md)
- [Prometheus](./prometheus.md)
- [FAQ](./faq.md)
