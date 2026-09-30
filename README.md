# Decidim Telemetry

<p align="center">
  <img src="website/static/img/logo.svg" alt="Decidim Telemetry" width="120" />
</p>

Prometheus metrics, health probes, and OpenTelemetry (traces, logs, exceptions) for Decidim (≥ 0.29.4).

**Documentation:** [octree.ch/decidim-telemetry](https://octree.ch/decidim-telemetry/) — install, scrape config, metrics, OpenTelemetry.

## Quick install

1. Add `gem "decidim-telemetry", "~> 0.1"` → `bundle install` (no migrations)
2. Add Yabeda Puma plugins to `config/puma.rb` — see [Install](https://octree.ch/decidim-telemetry/install)
3. Set env vars (optional) — see [Configuration](https://octree.ch/decidim-telemetry/configuration)
4. Point Prometheus at `/metrics` — see [Prometheus](https://octree.ch/decidim-telemetry/prometheus)
5. (Optional) Set `OTEL_*` for traces/logs — see [OpenTelemetry](https://octree.ch/decidim-telemetry/opentelemetry)
6. Restart Puma

## Host app

```ruby
gem "decidim-telemetry", "~> 0.1"
```

```bash
bundle install
```

## Development (this gem)

Docker + checks — see [CONTRIBUTING.md](CONTRIBUTING.md).

### Local workflow

```bash
docker compose up -d
```

| URL | What |
|-----|------|
| http://localhost:8000 | OTEL desktop viewer (traces / logs / metrics) |
| http://localhost:3029 | Decidim host app |

Sign in on Decidim with the seeded org admin: `admin@example.org` / `decidim123456789` (developer login).

Local CI parity (RuboCop + RSpec, Decidim 0.29 / Ruby 3.2.2):

```bash
docker compose -f docker-compose.ci.yml run --rm rspec bash -lc 'bin/ci-setup && bundle exec rubocop .'
docker compose -f docker-compose.ci.yml run --rm rspec
```

Dev container: `./bin/check` via `docker compose run --rm telemetry`.

## License

AGPL-3.0.
