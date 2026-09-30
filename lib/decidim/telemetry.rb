# frozen_string_literal: true

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

if Rails.env.development?
  require "decidim/dev"
  Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))
end
require "decidim/telemetry/configuration"
require "decidim/telemetry/engine"
require "decidim/telemetry/middleware/basic_auth"
require "decidim/telemetry/overrides/decidim_application_controller"
require "decidim/telemetry/overrides/decidim_proposal_command"
require "decidim/telemetry/open_telemetry"

# Load Yabeda gems
require "yabeda"
require "yabeda/rails"
require "yabeda/puma/plugin"
require "yabeda/activejob"
require "yabeda/prometheus"

module Decidim
  module Telemetry
    class << self
      attr_accessor :opentelemetry_logger_provider
    end

    def self.config
      @config ||= Configuration.new
    end

    def self.configure
      yield config
    end

    def self.opentelemetry_flush_logs(timeout: 5)
      return false unless opentelemetry_logger_provider

      begin
        processors = opentelemetry_logger_provider.instance_variable_get(:@log_record_processors) || []
        processors.each do |processor|
          processor.force_flush(timeout:) if processor.respond_to?(:force_flush)
        end
        true
      rescue StandardError => e
        Rails.logger.warn("[OpenTelemetry] Failed to flush logs: #{e.message}") if defined?(Rails)
        false
      end
    end
  end
end
