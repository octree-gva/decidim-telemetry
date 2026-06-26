# Decidim Telemetry

<p align="center">
  <img src="website/static/img/logo.svg" alt="Decidim Telemetry" width="120" />
</p>

Prometheus metrics and health probes for Decidim (≥ 0.29.4).

**Documentation:** [octree.ch/decidim-telemetry](https://octree.ch/decidim-telemetry/) — install, scrape config, metrics reference.

## Quick install

1. Add `gem "decidim-telemetry", "~> 0.0"` → `bundle install` (no migrations)
2. Add Yabeda Puma plugins to `config/puma.rb` — see [Install](https://octree.ch/decidim-telemetry/install)
3. Set env vars (optional) — see [Configuration](https://octree.ch/decidim-telemetry/configuration)
4. Point Prometheus at `/metrics` — see [Prometheus](https://octree.ch/decidim-telemetry/prometheus)
5. Restart Puma

## Host app

```ruby
gem "decidim-telemetry", "~> 0.0"
```

```bash
bundle install
```

## Development (this gem)

Docker + `./bin/check` (RuboCop, RSpec) — see [CONTRIBUTING.md](CONTRIBUTING.md) and [Contribute](https://octree.ch/decidim-telemetry/contributing).

## License

AGPL-3.0.
