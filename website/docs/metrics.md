---
sidebar_position: 6
title: Metrics reference
description: Decidim-specific Prometheus counters
---

# Metrics reference

Custom counters exported by decidim-telemetry. All use tags: `decidim_tenant`, `type`, `time_bucket`.

**Prerequisite:** [Endpoints](./endpoints.md).

## Decidim counters

| Metric | Description |
|--------|-------------|
| `decidim_activity_per_minute` | Incremented on every `decidim.*` notification event |
| `decidim_registrations` | New participant welcome notifications |
| `decidim_comments` | Comments created |
| `decidim_comment_votes` | Comment upvotes and downvotes |
| `decidim_proposals` | Proposals published |
| `decidim_proposal_votes` | Proposal votes |
| `rack_attack_matches` | Rack::Attack throttle, blocklist, and track events |

### Tags

| Tag | Example | Meaning |
|-----|---------|---------|
| `decidim_tenant` | `participate.example.org` | Organization host |
| `type` | `upvote`, `post_comments_allow2ban` | Event or rule name |
| `time_bucket` | Unix timestamp | Bucket start (see `DECIDIM_TELEMETRY_EXPORT_INTERVAL`) |

### Example PromQL

```promql
# Comments per tenant in the last hour
sum by (decidim_tenant) (increase(decidim_comments_total[1h]))

# Rack::Attack blocks
sum by (type) (increase(rack_attack_matches_total[5m]))
```

Exact metric names in Prometheus include the `_total` suffix for counters.

## Supported processes

| Process | Metrics source |
|---------|----------------|
| Puma (master + workers) | `yabeda-puma-plugin` on port 9394 |
| ActiveJob | `yabeda-activejob` |
| GoodJob | ActiveJob adapter (same job metrics) |

## See also

- [Prometheus](./prometheus.md)
- [Configuration](./configuration.md)
- [FAQ](./faq.md)
