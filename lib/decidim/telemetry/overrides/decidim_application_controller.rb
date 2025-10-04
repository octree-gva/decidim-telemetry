# frozen_string_literal: true

module Decidim
  module Telemetry
    module Overrides
      module DecidimApplicationController
        extend ActiveSupport::Concern

        included do
          def append_info_to_payload(payload)
            super
            return unless current_organization

            payload[:decidim_tenant] = current_organization.host
          end
        end
      end
    end
  end
end
