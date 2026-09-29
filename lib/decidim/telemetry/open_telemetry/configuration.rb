# frozen_string_literal: true

module Decidim
  module Telemetry
    module OpenTelemetry
      class Configuration
        attr_accessor :enabled, :traces_enabled, :logs_enabled, :exceptions_enabled,
                      :traces_endpoint, :logs_endpoint, :service_name,
                      :exporter_timeout, :debug

        def initialize
          @enabled = true
          @traces_enabled = true
          @logs_enabled = true
          @exceptions_enabled = true
          @traces_endpoint = default_traces_endpoint
          @logs_endpoint = default_logs_endpoint
          @service_name = ENV.fetch("OTEL_SERVICE_NAME", "rails-app").to_s
          @exporter_timeout = ENV.fetch("OTEL_EXPORTER_TIMEOUT", "5").to_i
          @debug = %w(1 true yes on).include?(ENV.fetch("OTEL_DEBUG", "false").to_s.downcase)
        end

        def enabled?
          @enabled
        end

        def traces_enabled?
          @traces_enabled
        end

        def logs_enabled?
          @logs_enabled
        end

        def exceptions_enabled?
          @exceptions_enabled
        end

        def debug?
          @debug
        end

        private

        def default_traces_endpoint
          return ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"] if ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"].present?

          base = ENV.fetch("OTEL_EXPORTER_OTLP_ENDPOINT", "")
          base.present? ? "#{base}/v1/traces" : ""
        end

        def default_logs_endpoint
          return ENV["OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"] if ENV["OTEL_EXPORTER_OTLP_LOGS_ENDPOINT"].present?

          base = ENV.fetch("OTEL_EXPORTER_OTLP_ENDPOINT", "")
          base.present? ? "#{base}/v1/logs" : ""
        end
      end
    end
  end
end
