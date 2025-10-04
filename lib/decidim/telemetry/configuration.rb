# frozen_string_literal: true

module Decidim
  module Telemetry
    class Configuration
      attr_accessor :enabled, :sample_rate, :export_interval, :username, :password, :minutes_per_bucket

      def initialize
        @enabled = true
        @sample_rate = 1.0
        @export_interval = 30
        @username = nil
        @password = nil
        # 1 decidim stat every 15 minutes
        @minutes_per_bucket = 15
      end

      def enabled?
        @enabled
      end

      def basic_auth_enabled?
        username.present? && password.present?
      end
    end
  end
end
