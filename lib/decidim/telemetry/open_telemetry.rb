# frozen_string_literal: true

module Decidim
  module Telemetry
    module OpenTelemetry
    end
  end
end

require "decidim/telemetry/open_telemetry/configuration"
require "decidim/telemetry/open_telemetry/decidim_context_attributes"
require "decidim/telemetry/open_telemetry/request_env"
require "decidim/telemetry/open_telemetry/logger_provider_resolver"
require "decidim/telemetry/open_telemetry/otel_logger"
require "decidim/telemetry/open_telemetry/otel_error_subscriber"
require "decidim/telemetry/open_telemetry/otel_decidim_context"
require "decidim/telemetry/open_telemetry/logs_setup"
require "decidim/telemetry/open_telemetry/configurator"
