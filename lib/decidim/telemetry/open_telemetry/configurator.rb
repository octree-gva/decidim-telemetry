# frozen_string_literal: true

module Decidim
  module Telemetry
    module OpenTelemetry
      class Configurator
        Result = Struct.new(:ok, :error, keyword_init: true) do
          def ok?
            ok
          end
        end

        def self.call
          new.call
        end

        def call
          otel = Decidim::Telemetry.config.open_telemetry
          unless otel.enabled?
            Rails.logger.debug("[OpenTelemetry] Disabled - config.open_telemetry.enabled is false")
            return Result.new(ok: true)
          end

          Rails.logger.info("[OpenTelemetry] Initializing...")
          Rails.logger.info("[OpenTelemetry] Traces endpoint: #{otel.traces_endpoint}")
          Rails.logger.info("[OpenTelemetry] Logs endpoint: #{otel.logs_endpoint}")
          Rails.logger.info("[OpenTelemetry] Service name: #{otel.service_name}")

          configure_opentelemetry!
          verify_configuration! if otel.traces_enabled?
          Result.new(ok: true)
        rescue StandardError => e
          Rails.logger.error("[OpenTelemetry] Configuration failed: #{e.class} - #{e.message}")
          Rails.logger.error("[OpenTelemetry] Backtrace: #{e.backtrace.first(5).join("\n")}")
          Result.new(ok: false, error: e.message)
        end

        private

        def otel
          Decidim::Telemetry.config.open_telemetry
        end

        def configure_opentelemetry!
          require_opentelemetry!
          configure_sdk!
        end

        def require_opentelemetry!
          require "opentelemetry/sdk"
          require "opentelemetry/exporter/otlp"
          require "opentelemetry/instrumentation/all"
          require "opentelemetry-logs-api"
          require "opentelemetry/sdk/logs"
          require "opentelemetry/exporter/otlp_logs"
        rescue LoadError => e
          raise LoadError, "decidim-telemetry OpenTelemetry requires opentelemetry-logs-sdk and opentelemetry-exporter-otlp-logs. #{e.message}"
        end

        def configure_sdk!
          Rails.logger.debug("[OpenTelemetry] Configuring SDK...")
          set_exporter_timeouts!
          configure_opentelemetry_sdk!
          Rails.logger.info("[OpenTelemetry] SDK configured successfully")
          warn_missing_traces_endpoint!
          setup_logging! if otel.logs_enabled?
          setup_error_reporting! if otel.exceptions_enabled?
        end

        def set_exporter_timeouts!
          timeout = otel.exporter_timeout
          ENV["OTEL_EXPORTER_OTLP_TIMEOUT"] = timeout.to_s unless ENV["OTEL_EXPORTER_OTLP_TIMEOUT"]
          ENV["OTEL_EXPORTER_OTLP_TRACES_TIMEOUT"] = timeout.to_s unless ENV["OTEL_EXPORTER_OTLP_TRACES_TIMEOUT"]
          ENV["OTEL_EXPORTER_OTLP_LOGS_TIMEOUT"] = timeout.to_s unless ENV["OTEL_EXPORTER_OTLP_LOGS_TIMEOUT"]
        end

        def configure_opentelemetry_sdk!
          ::OpenTelemetry::SDK.configure do |c|
            c.service_name = otel.service_name
            c.resource = resource
            c.use_all(excluded_instrumentations: ["OpenTelemetry::Instrumentation::ActionPack"])
            c.add_span_processor(span_processor) if otel.traces_enabled? && traces_endpoint_present?
          end
        end

        def warn_missing_traces_endpoint!
          return unless otel.traces_enabled?
          return if traces_endpoint_present?

          Rails.logger.warn("[OpenTelemetry] traces_enabled is true but traces endpoint is blank - skipping span processor")
        end

        def traces_endpoint_present?
          otel.traces_endpoint.to_s.strip.present?
        end

        def resource
          ::OpenTelemetry::SDK::Resources::Resource.create(
            "deployment.environment" => Rails.env.to_s,
            "service.version" => Decidim.version.to_s
          )
        end

        def span_processor
          exporter = ::OpenTelemetry::Exporter::OTLP::Exporter.new(
            endpoint: otel.traces_endpoint,
            timeout: otel.exporter_timeout
          )
          ::OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
            exporter,
            exporter_timeout: otel.exporter_timeout * 1000,
            schedule_delay: LogsSetup::BATCH_SCHEDULE_DELAY_MS,
            max_queue_size: LogsSetup::BATCH_MAX_QUEUE_SIZE,
            max_export_batch_size: LogsSetup::BATCH_MAX_EXPORT_SIZE
          )
        end

        def setup_logging!
          Rails.logger.debug("[OpenTelemetry] Configuring logging...")
          Rails.logger.debug { "[OpenTelemetry] Logs endpoint: #{otel.logs_endpoint}" }
          LogsSetup.call(
            logs_endpoint: otel.logs_endpoint,
            exporter_timeout: otel.exporter_timeout,
            resource:
          )
        end

        def setup_error_reporting!
          Rails.error.subscribe(OtelErrorSubscriber.new) if defined?(Rails.error)
          Rails.logger.debug("[OpenTelemetry] Error reporting subscribed")
        end

        def verify_configuration!
          tracer = ::OpenTelemetry.tracer_provider.tracer("decidim-telemetry")
          span = tracer.start_span("opentelemetry.verification")
          span.set_attribute("verification.check", true)
          span.finish
          Rails.logger.info("[OpenTelemetry] Verification span created - tracer is active")
        rescue StandardError => e
          Rails.logger.warn("[OpenTelemetry] Verification failed: #{e.message}")
          Rails.logger.warn("[OpenTelemetry] Continuing without telemetry - collector may be unavailable")
        end
      end
    end
  end
end
