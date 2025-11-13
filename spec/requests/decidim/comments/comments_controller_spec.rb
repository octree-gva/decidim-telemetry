# frozen_string_literal: true

require "spec_helper"
require "rack/test"

module Decidim
  module Comments
    describe "CommentsController with Rack::Attack" do
      include ::Devise::Test::IntegrationHelpers

      let(:organization) { create(:organization) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { create(:component, participatory_space: participatory_process) }
      let(:commentable) { create(:dummy_resource, component:) }
      let(:user) { create(:user, :confirmed, locale: "en", organization:) }

      before do
        host! organization.host
        sign_in user, scope: :user
        allow(Decidim::Telemetry.config).to receive(:enabled?).and_return(true)
        allow(Decidim::Telemetry.config).to receive(:mount_exporter?).and_return(true)
        allow(Decidim::Telemetry.config).to receive(:export_interval).and_return(10)
        Rack::Attack.enabled = true
        Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
        Rails.cache = ActiveSupport::Cache::MemoryStore.new
        Rack::Attack.blocklist("test post comments allow2ban") do |request|
          Rack::Attack::Allow2Ban.filter(request.ip, maxretry: 3, findtime: 1.minute, bantime: 1.second) do |_req|
            request.ip if (request.post? || request.put?) && request.path.start_with?("/comments")
          end
        end
      end

      after do
        Rack::Attack.cache.store.clear
        Rails.cache.clear
        Rack::Attack.clear_configuration
      end

      describe "POST create with rack attack" do
        let(:comment_params) do
          {
            commentable_gid: commentable.to_signed_global_id.to_s,
            body: "This is a comment",
            alignment: 0
          }
        end

        it "blocks user after rate limit and increments rack_attack_matches metric" do
          initial_metrics = rack_attack_metric_value

          blocked_count = 0
          10.times do |i|
            post "/comments", xhr: true, params: { comment: comment_params.merge(body: "Comment #{i + 1}") }
            blocked_count += 1 if response.status == 429 || response.status == 403
          end

          sleep 2.seconds
          expect(blocked_count).to be >= 1

          metrics_response = metrics_via_rack
          expect(metrics_response.status).to eq(200)

          metrics_body = metrics_response.body
          final_rack_attack_value = extract_rack_attack_metric(metrics_body)

          expect(final_rack_attack_value).to be > initial_metrics
        end

        private

        def rack_attack_metric_value
          metrics_response = metrics_via_rack
          return 0 unless metrics_response.status == 200

          extract_rack_attack_metric(metrics_response.body)
        end

        def metrics_via_rack
          rack_test_session = Rack::Test::Session.new(Rack::MockSession.new(Rails.application))
          rack_test_session.get("/metrics")
        end

        def extract_rack_attack_metric(metrics_body)
          lines = metrics_body.split("\n")
          rack_attack_lines = lines.select { |line| line.start_with?("rack_attack_matches") && !line.start_with?("#") }
          return 0 if rack_attack_lines.empty?

          rack_attack_lines.sum do |line|
            value = line.split.last.to_f
            value.nan? ? 0 : value
          end
        end
      end
    end
  end
end
