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
