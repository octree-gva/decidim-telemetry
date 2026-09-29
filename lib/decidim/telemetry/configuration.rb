# frozen_string_literal: true

require "decidim/telemetry/open_telemetry/configuration"

module Decidim
  module Telemetry
    class Configuration
      attr_accessor :enabled, :export_interval, :username, :password, :mount_exporter
      attr_reader :open_telemetry

      def initialize
        @enabled = true
        @export_interval = 15
        @username = nil
        @password = nil
        @mount_exporter = true
        @open_telemetry = OpenTelemetry::Configuration.new
      end

      def enabled?
        @enabled
      end

      def mount_exporter?
        @mount_exporter
      end

      def basic_auth_enabled?
        username.present? && password.present?
      end
    end
  end
end
