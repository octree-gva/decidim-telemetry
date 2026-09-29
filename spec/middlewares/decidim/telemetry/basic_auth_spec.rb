# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    describe BasicAuth do
      let(:app) { double("app") }
      let(:middleware) { described_class.new(app) }
      let(:env) do
        {
          "REQUEST_METHOD" => "GET",
          "PATH_INFO" => "/metrics"
        }
      end

      before do
        allow(Decidim::Telemetry.config).to receive(:enabled?).and_return(true)
        allow(Decidim::Telemetry.config).to receive(:basic_auth_enabled?).and_return(true)
        allow(Decidim::Telemetry.config).to receive(:username).and_return("user")
        allow(Decidim::Telemetry.config).to receive(:password).and_return("pass")
      end

      describe "#call" do
        context "when telemetry is disabled" do
          before do
            allow(Decidim::Telemetry.config).to receive(:enabled?).and_return(false)
          end

          it "calls the app directly" do
            expect(app).to receive(:call).with(env)
            middleware.call(env)
          end
        end

        context "when basic auth is disabled" do
          before do
            allow(Decidim::Telemetry.config).to receive(:basic_auth_enabled?).and_return(false)
          end

          it "calls the app directly" do
            expect(app).to receive(:call).with(env)
            middleware.call(env)
          end
        end

        context "when basic auth is enabled" do
          context "with a non-metrics path" do
            let(:env) do
              {
                "REQUEST_METHOD" => "GET",
                "PATH_INFO" => "/health/live"
              }
            end

            it "calls the app without credentials" do
              expect(app).to receive(:call).with(env)
              middleware.call(env)
            end
          end

          context "with valid credentials" do
            let(:env) do
              {
                "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("user:pass").strip}",
                "REQUEST_METHOD" => "GET",
                "PATH_INFO" => "/metrics"
              }
            end

            it "calls the app" do
              expect(app).to receive(:call).with(env)
              middleware.call(env)
            end
          end

          context "with invalid credentials" do
            let(:env) do
              {
                "HTTP_AUTHORIZATION" => "Basic #{Base64.encode64("user:wrong").strip}",
                "REQUEST_METHOD" => "GET",
                "PATH_INFO" => "/metrics"
              }
            end

            it "returns unauthorized" do
              result = middleware.call(env)
              expect(result[0]).to eq(401)
              expect(result[1]["WWW-Authenticate"]).to eq('Basic realm="Telemetry"')
            end
          end

          context "without authorization header" do
            it "returns unauthorized" do
              result = middleware.call(env)
              expect(result[0]).to eq(401)
            end
          end
        end
      end
    end
  end
end
