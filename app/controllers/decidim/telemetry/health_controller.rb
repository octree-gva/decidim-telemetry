# frozen_string_literal: true

module Decidim
  module Telemetry
    class HealthController < ApplicationController
      def show
        render json: { status: "ok", timestamp: Time.current.iso8601 }
      end

      def ready
        # Check if application is ready to serve requests
        checks = {
          database: database_ready?,
          yabeda: yabeda_ready?,
          public_files_accessibles: public_files_accessible?,
          cache: cache_ready?
        }

        checks[:redis] = redis_ready? if Decidim::Env.new("REDIS_URL").present?

        if checks.values.all?
          render json: { status: "ready", checks:, timestamp: Time.current.iso8601 }
        else
          render json: { status: "not_ready", checks:, timestamp: Time.current.iso8601 }, status: :service_unavailable
        end
      end

      def live
        # Simple liveness check
        render json: { status: "alive", timestamp: Time.current.iso8601 }
      end

      private

      def cache_ready?
        token = Time.current.iso8601
        Rails.cache.write("health_check", token)
        Rails.cache.fetch("health_check") { "" } == token
      rescue StandardError
        false
      ensure
        Rails.cache.delete("health_check")
      end

      def database_ready?
        ActiveRecord::Base.connection.active?
      rescue StandardError
        false
      end

      def redis_ready?
        return true unless defined?(Redis)

        Redis.current.ping == "PONG"
      rescue StandardError
        false
      end

      def yabeda_ready?
        defined?(Yabeda) && Yabeda.configured?
      end

      def public_files_accessible?
        Rails.public_path.join("decidim-packs/manifest.json").exist?
      end
    end
  end
end
