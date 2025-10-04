# frozen_string_literal: true

module Decidim
  module Telemetry
    class ApplicationController < ::ApplicationController
      def current_organization
        @current_organization ||= request.env["decidim.current_organization"]
      end
    end
  end
end
