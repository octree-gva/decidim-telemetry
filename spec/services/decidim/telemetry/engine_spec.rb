# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    describe Engine do
      describe "routes" do
        it "has health route" do
          expect(described_class.routes.recognize_path("/health", method: :get)).to eq(
            controller: "decidim/telemetry/health", action: "show"
          )
        end

        it "has ready route" do
          expect(described_class.routes.recognize_path("/health/ready", method: :get)).to eq(
            controller: "decidim/telemetry/health", action: "ready"
          )
        end

        it "has live route" do
          expect(described_class.routes.recognize_path("/health/live", method: :get)).to eq(
            controller: "decidim/telemetry/health", action: "live"
          )
        end
      end
    end
  end
end
