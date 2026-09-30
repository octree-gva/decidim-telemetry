# frozen_string_literal: true

module Decidim
  module Telemetry
    module OpenTelemetry
      module LoggerProviderResolver
        module_function

        def current
          Decidim::Telemetry.opentelemetry_logger_provider
        end
      end
    end
  end
end
