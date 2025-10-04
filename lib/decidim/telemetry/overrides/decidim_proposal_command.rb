module Decidim
  module Telemetry
    module Overrides
      module DecidimProposalCommand
        extend ActiveSupport::Concern

        included do
          alias_method :telemetry_decidim_origin_call, :call

          def call
            minutes_per_bucket = Decidim::Telemetry.config.minutes_per_bucket
            Yabeda.decidim_proposal_votes.increment(
              time_bucket: (Time.now.to_i / (minutes_per_bucket * 60)) * (minutes_per_bucket * 60),
              decidim_tenant: @current_user.organization.host,
              type: "upvote"
            )
            telemetry_decidim_origin_call
          end
        end
        
      end
    end
  end
end