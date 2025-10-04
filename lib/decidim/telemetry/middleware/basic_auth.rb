# frozen_string_literal: true

module Decidim
  module Telemetry
    class BasicAuth
      def initialize(app)
        @app = app
      end

      def call(env)
        return @app.call(env) unless Decidim::Telemetry.config.basic_auth_enabled?

        request = ActionDispatch::Request.new(env)

        return unauthorized_response unless request.authorization

        creds = ActionController::HttpAuthentication::Basic.decode_credentials(request)
        username, password = creds.split(":")

        if valid_credentials?(username, password)
          @app.call(env)
        else
          unauthorized_response
        end
      end

      private

      def valid_credentials?(username, password)
        username == Decidim::Telemetry.config.username &&
          password == Decidim::Telemetry.config.password
      end

      def unauthorized_response
        [401, { "WWW-Authenticate" => 'Basic realm="Telemetry"' }, ["Unauthorized"]]
      end
    end
  end
end
