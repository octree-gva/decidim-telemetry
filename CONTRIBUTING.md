# Contributing to decidim-telemetry

Contributor documentation: [octree.ch/decidim-telemetry/contributing](https://octree.ch/decidim-telemetry/contributing).

## Quick links

- **Doc site (local):** `cd website && yarn && yarn start`
- **Doc site (build):** `cd website && yarn build`
- **Local CI (parity with GitLab):**  
  `docker compose -f docker-compose.ci.yml run --rm rspec bash -lc 'bin/ci-setup && bundle exec rubocop .'`  
  `docker compose -f docker-compose.ci.yml run --rm rspec`
- **Dev container check:** `./bin/check` — RuboCop, RSpec (inside `docker compose` service `telemetry`)
- **Local OTEL UI:** `docker compose up -d` → [http://localhost:8000](http://localhost:8000) (viewer) · Decidim on [http://localhost:3029](http://localhost:3029)
- **GitLab:** [issues](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry/-/issues) · [merge requests](https://git.octree.ch/decidim/vocacity/decidim-modules/decidim-telemetry/-/merge_requests)
- **Code of conduct:** [octree.ch/decidim-telemetry/code-of-conduct](https://octree.ch/decidim-telemetry/code-of-conduct)

## Platform administrators

Install guide: [octree.ch/decidim-telemetry/install](https://octree.ch/decidim-telemetry/install).

Host install summary: [README.md](README.md).
