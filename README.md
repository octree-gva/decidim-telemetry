# Decidim Telemetry

A monitoring module for Decidim applications that provides OpenTelemetry and Prometheus-compatible endpoints.

## Installation

Add to your Gemfile:

```ruby
gem 'decidim-telemetry'
```

Run:

```bash
bundle install
```

## Configuration

### Environment Variables

```bash
# Basic Authentication (optional)
DECIDIM_TELEMETRY_USER=your_username
DECIDIM_TELEMETRY_PASSWORD=your_password

# Telemetry settings
DECIDIM_TELEMETRY_ENABLED=true
DECIDIM_TELEMETRY_EXPORT_INTERVAL=30  # minutes
DECIDIM_TELEMETRY_MOUNT_EXPORTER=true # Mount in rails server (default)
```

### Initializer
If you prefer to configure telemetry through configuration files,
setup an initializer:
```ruby
# config/initializers/decidim_telemetry.rb
Decidim::Telemetry.configure do |config|
  config.enabled = Rails.env.production?
  config.export_interval = 30 # minutes
end
```

[To configure your puma.rb](https://github.com/yabeda-rb/yabeda-puma-plugin?tab=readme-ov-file#on-different-port): 
```ruby
# config/puma.rb
activate_control_app
plugin :yabeda
plugin :yabeda_prometheus
``` 
Set the `DECIDIM_TELEMETRY_MOUNT_EXPORTER=false` to export only from the puma port (default `:9394`)

## Endpoints

- `GET /health` - Health check (application/json)
- `GET /health/ready` - Readiness probe
- `GET /health/live` - Liveness probe

If `DECIDIM_TELEMETRY_MOUNT_EXPORTER=true`, you will also have:
- `GET /metrics` - Prometheus metrics (text/plain)

## Supported Processes

- Puma (master + workers)
- GoodJob

## Metrics

### Application Metrics
- Request count, duration, status codes
- Registrations, Proposals, Comments and votes.

### Process Metrics
- Memory usage, CPU usage
- Worker queue sizes
- Background job processing rates

## Development

```bash
bundle install
bundle exec rspec
```

## License

APGL-V3