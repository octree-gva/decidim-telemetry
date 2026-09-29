# frozen_string_literal: true

namespace :decidim do
  namespace :telemetry do
    namespace :opentelemetry do
      desc "Test OpenTelemetry configuration and send a test span"
      task test: :environment do
        otel = Decidim::Telemetry.config.open_telemetry
        puts "=== OpenTelemetry Debugging ==="
        puts
        puts "✓ Enabled: #{otel.enabled?}"
        unless otel.enabled?
          puts "  Reason: config.open_telemetry.enabled is false"
          exit 1
        end

        puts "✓ Traces enabled: #{otel.traces_enabled?}"
        puts "✓ Logs enabled: #{otel.logs_enabled?}"
        puts "✓ Exceptions enabled: #{otel.exceptions_enabled?}"
        puts "✓ Traces endpoint: #{otel.traces_endpoint.presence || "(blank)"}"
        puts "✓ Logs endpoint: #{otel.logs_endpoint.presence || "(blank)"}"
        puts "✓ Service name: #{otel.service_name}"

        if defined?(OpenTelemetry)
          puts "✓ OpenTelemetry gem loaded"
        else
          puts "✗ OpenTelemetry gem not loaded"
          exit 1
        end

        begin
          tracer_provider = OpenTelemetry.tracer_provider
          puts "✓ Tracer provider available: #{tracer_provider.class}"
        rescue StandardError => e
          puts "✗ Tracer provider error: #{e.message}"
          exit 1
        end

        if otel.traces_enabled?
          puts
          puts "Creating test span..."
          begin
            tracer = OpenTelemetry.tracer_provider.tracer("decidim-telemetry-test")
            tracer.start_span("test.span") do |s|
              s.set_attribute("test.attribute", "test_value")
              s.set_attribute("test.timestamp", Time.now.to_i)
              puts "✓ Test span created and finished"
            end
          rescue StandardError => e
            puts "✗ Failed to create span: #{e.class} - #{e.message}"
            exit 1
          end
        end

        if otel.exceptions_enabled? && defined?(Rails.error)
          subscribers = Rails.error.instance_variable_get(:@subscribers) || []
          otel_subscriber = subscribers.find { |s| s.is_a?(Decidim::Telemetry::OpenTelemetry::OtelErrorSubscriber) }
          puts otel_subscriber ? "✓ Error subscriber registered" : "⚠ Error subscriber not found"
        end

        if otel.logs_enabled?
          logger_provider = Decidim::Telemetry.opentelemetry_logger_provider
          puts logger_provider ? "✓ Logger provider: #{logger_provider.class}" : "⚠ Logger provider not configured"
        end

        puts
        puts "=== Summary ==="
        puts "Configuration looks correct. Check application logs for [OpenTelemetry] messages."
      end

      desc "Show OpenTelemetry configuration"
      task config: :environment do
        otel = Decidim::Telemetry.config.open_telemetry
        puts "=== OpenTelemetry Configuration ==="
        puts
        puts "Enabled: #{otel.enabled?}"
        puts "Traces enabled: #{otel.traces_enabled?}"
        puts "Logs enabled: #{otel.logs_enabled?}"
        puts "Exceptions enabled: #{otel.exceptions_enabled?}"
        puts "Traces endpoint: #{otel.traces_endpoint.presence || "(not set)"}"
        puts "Logs endpoint: #{otel.logs_endpoint.presence || "(not set)"}"
        puts "Service name: #{otel.service_name}"
        puts "Exporter timeout: #{otel.exporter_timeout}"
        puts "Debug: #{otel.debug?}"
        puts
        puts "Environment variables:"
        puts "  OTEL_EXPORTER_OTLP_ENDPOINT: #{ENV["OTEL_EXPORTER_OTLP_ENDPOINT"] || "(not set)"}"
        puts "  OTEL_EXPORTER_OTLP_TRACES_ENDPOINT: #{ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"] || "(not set)"}"
        puts "  OTEL_EXPORTER_OTLP_LOGS_ENDPOINT: #{ENV["OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"] || "(not set)"}"
        puts "  OTEL_SERVICE_NAME: #{ENV["OTEL_SERVICE_NAME"] || "(not set)"}"
        puts "  OTEL_EXPORTER_TIMEOUT: #{ENV["OTEL_EXPORTER_TIMEOUT"] || "(not set)"}"
        puts "  OTEL_DEBUG: #{ENV["OTEL_DEBUG"] || "(not set)"}"
      end
    end
  end
end
