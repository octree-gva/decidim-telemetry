# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    describe HealthController do
      routes { Decidim::Telemetry::Engine.routes }

      describe "GET #show" do
        it "returns ok status" do
          get :show
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to include("status" => "ok")
        end
      end

      describe "GET #ready" do
        before do
          allow(controller).to receive(:database_ready?).and_return(true)
          allow(controller).to receive(:redis_ready?).and_return(true)
          allow(controller).to receive(:yabeda_ready?).and_return(true)
          allow(controller).to receive(:puma_ready?).and_return(true)
        end

        it "returns ready status when all checks pass" do
          get :ready
          expect(response).to have_http_status(:ok)
          body = response.parsed_body
          expect(body["status"]).to eq("ready")
          expect(body["checks"]).to include("database" => true, "redis" => true, "yabeda" => true, "puma" => true)
        end

        it "returns not_ready status when database check fails" do
          allow(controller).to receive(:database_ready?).and_return(false)
          get :ready
          expect(response).to have_http_status(:service_unavailable)
          body = response.parsed_body
          expect(body["status"]).to eq("not_ready")
        end

        it "returns not_ready status when puma is not ready" do
          allow(controller).to receive(:puma_ready?).and_return(false)
          get :ready
          expect(response).to have_http_status(:service_unavailable)
          body = response.parsed_body
          expect(body["status"]).to eq("not_ready")
        end
      end

      describe "GET #live" do
        it "returns alive status" do
          get :live
          expect(response).to have_http_status(:ok)
          expect(response.parsed_body).to include("status" => "alive")
        end
      end
    end
  end
end
