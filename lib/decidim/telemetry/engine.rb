# frozen_string_literal: true

require "yabeda"
module Decidim
  module Telemetry
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Telemetry
      initializer "decidim_telemetry.overrides" do
        config.to_prepare do
          Decidim::ApplicationController.include Decidim::Telemetry::Overrides::DecidimApplicationController
          Decidim::Proposals::VoteProposal.include Decidim::Telemetry::Overrides::DecidimProposalCommand
        end
      end

      initializer "decidim_telemetry.configure" do |_app|
        # Configure from environment variables
        Decidim::Telemetry.configure do |config|
          config.enabled = ::Decidim::Env.new("DECIDIM_TELEMETRY_ENABLED", "true").present?
          config.export_interval = ENV.fetch("DECIDIM_TELEMETRY_EXPORT_INTERVAL", "15").to_i
          config.username = ENV.fetch("DECIDIM_TELEMETRY_USER", nil)
          config.password = ENV.fetch("DECIDIM_TELEMETRY_PASSWORD", nil)
          config.mount_exporter = ::Decidim::Env.new("DECIDIM_TELEMETRY_MOUNT_EXPORTER", "true").present?
        end

        # Configure Yabeda
        Yabeda.configure do
          # Custom Decidim metrics
          tags = [:decidim_tenant, :type, :time_bucket]
          counter(:decidim_activity_per_minute, comment: "Activity rate", tags:)
          counter(:decidim_registrations, comment: "Participant Registrations", tags:)
          counter(:decidim_comments, comment: "Comments", tags:)
          counter(:decidim_comment_votes, comment: "Comment votes", tags:)
          counter(:decidim_proposals, comment: "Proposals", tags:)
          counter(:decidim_proposal_votes, comment: "Proposal votes", tags:)
          counter(:rack_attack_matches, comment: "Rack Attack matches", tags:)
        end

        Yabeda.configure!

        # Subscribe to ActiveJob events
        Yabeda::ActiveJob.install!
      end

      initializer "decidim_telemetry.rack_attack" do
        minutes_per_bucket = Decidim::Telemetry.config.export_interval

        # Subscribe to all rack_attack events (track, throttle, blocklist, etc.)
        ActiveSupport::Notifications.subscribe(/\.rack_attack$/) do |_name, _start, _finish, _request_id, payload|
          req = payload[:request]
          Yabeda.rack_attack_matches.increment(
            time_bucket: (Time.now.to_i / (minutes_per_bucket * 60)) * (minutes_per_bucket * 60),
            decidim_tenant: req.env["decidim.current_organization"]&.host || "unknown",
            type: req.env["rack.attack.matched"].parameterize.underscore
          )
        end
      end

      initializer "decidim_telemetry.decidim_metrics" do
        # Subscribe to all decidim.* events

        ActiveSupport::Notifications.subscribe(/^decidim\./) do |name, event|
          minutes_per_bucket = Decidim::Telemetry.config.export_interval
          metadatas = { time_bucket: (Time.now.to_i / (minutes_per_bucket * 60)) * (minutes_per_bucket * 60) }

          Yabeda.decidim_activity_per_minute.increment(type: name, decidim_tenant: "unknown", **metadatas)

          case name
          when /decidim\.events\.core\.welcome_notification/
            Yabeda.decidim_registrations.increment(
              **metadatas,
              decidim_tenant: event[:resource].organization.host,
              type: name.parameterize.underscore
            )
          when /decidim\.comments\.comment_created/
            Yabeda.decidim_comments.increment(
              **metadatas,
              decidim_tenant: Decidim::Comments::Comment.find(event[:comment_id]).organization.host,
              type: name.parameterize.underscore
            )
          when /decidim\.events\.comments\.comment_upvoted/
            Yabeda.decidim_comment_votes.increment(
              **metadatas,
              decidim_tenant: event[:resource].organization.host,
              type: "upvote"
            )
          when /decidim\.events\.comments\.comment_downvoted/
            Yabeda.decidim_comment_votes.increment(
              **metadatas,
              decidim_tenant: event[:resource].organization.host,
              type: "downvote"
            )
          when /decidim\.events\.proposals\.proposal_published/
            Yabeda.decidim_proposals.increment(
              **metadatas,
              decidim_tenant: event[:resource].organization.host,
              type: name.parameterize.underscore
            )
          end
        end
      end

      initializer "decidim_telemetry.middleware" do |app|
        app.middleware.use Decidim::Telemetry::BasicAuth if Decidim::Telemetry.config.enabled? && Decidim::Telemetry.config.basic_auth_enabled?
      end

      initializer "decidim_telemetry.routes" do
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::Telemetry::Engine => "/"
        end
      end

      routes do
        get "/health", to: "health#show"
        get "/health/ready", to: "health#ready"
        get "/health/live", to: "health#live"
        mount Yabeda::Prometheus::Exporter, at: "/metrics" if Decidim::Telemetry.config.enabled? && Decidim::Telemetry.config.mount_exporter?
      end
    end
  end
end
