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
DECIDIM_TELEMETRY_SAMPLE_RATE=1.0
```

### Initializer

```ruby
# config/initializers/decidim_telemetry.rb
Decidim::Telemetry.configure do |config|
  config.enabled = Rails.env.production?
  config.sample_rate = 1.0
  config.export_interval = 30 # seconds
end
```

[Configure your puma.rb](https://github.com/yabeda-rb/yabeda-puma-plugin?tab=readme-ov-file#on-different-port): 
```ruby
# config/puma.rb
activate_control_app
plugin :yabeda
plugin :yabeda_prometheus
``` 

## Endpoints

- `GET /metrics` - Prometheus metrics (text/plain)
- `GET /health` - Health check (application/json)
- `GET /health/ready` - Readiness probe
- `GET /health/live` - Liveness probe

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