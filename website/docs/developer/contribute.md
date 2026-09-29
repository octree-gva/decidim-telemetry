---
sidebar_position: 1
slug: /contributing
title: Contribute
description: Development setup and checks for decidim-telemetry
---

# Contribute

**decidim-telemetry** is maintained by [Voca](https://voca.city), a project from [Octree](https://octree.ch).

Issues and merge requests are welcome on GitLab:

- [Repository](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry)
- [Issues](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry/-/issues)
- [Merge requests](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry/-/merge_requests)

Read the [Code of conduct](/code-of-conduct) before participating.

Platform administrators installing the gem: [Install](../install.md).

## Local OpenTelemetry viewer

Dev Compose includes [otel-desktop-viewer](https://github.com/CtrlSpice/otel-desktop-viewer#via-docker). The `telemetry` service exports OTLP (traces, logs, exception spans) to it.

```bash
docker compose up -d
# UI — traces / logs / metrics
open http://localhost:8000
# App (host port 3029 → container 3000; 3000 often taken by other stacks)
open http://localhost:3029
```

| Port | Role |
|------|------|
| `8000` | Viewer UI |
| `3029` | Decidim host app (mapped from container `:3000`) |
| `4318` | OTLP HTTP — traces `/v1/traces`, logs `/v1/logs`, metrics `/v1/metrics` |
| `4317` | OTLP gRPC |
| `9394` | Yabeda Prometheus scrape (separate from OTLP metrics) |

Compose sets `OTEL_EXPORTER_OTLP_*_ENDPOINT` (including `…_METRICS_ENDPOINT`) and `OTEL_METRICS_EXPORTER=otlp` so the viewer can receive all three signals.

`OTEL_SERVICE_NAME` defaults to `decidim-telemetry` in Compose. Exception reports appear as spans when `Rails.error` fires (warnings/errors also show under **Logs** when `logs_enabled` is on).

## Before you push

```bash
# Local CI parity (recommended — matches GitLab ruby::rspec / rubocop)
docker compose -f docker-compose.ci.yml run --rm rspec bash -lc 'bin/ci-setup && bundle exec rubocop .'
docker compose -f docker-compose.ci.yml run --rm rspec

# Or via the development compose service
docker compose up -d
docker compose run --rm telemetry bash -lc 'cd /home/module && bundle install -j$(nproc) && ./bin/check'
cd website && yarn && yarn build
```

| Check | Command |
|-------|---------|
| Local CI RuboCop | `docker compose -f docker-compose.ci.yml run --rm rspec bash -lc 'bin/ci-setup && bundle exec rubocop .'` |
| Local CI RSpec | `docker compose -f docker-compose.ci.yml run --rm rspec` |
| Dev all | `./bin/check` (RuboCop, RSpec) |
| Docs | `cd website && yarn build` |

## See also

- [Code of conduct](/code-of-conduct)
- [Documentation website](./documentation.md)
- [Overview](../index.md)
