# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    module OpenTelemetry
      describe Configuration do
        subject { described_class.new }

        describe "#enabled?" do
          it "defaults to true" do
            expect(subject.enabled?).to be true
          end
        end

        describe "#traces_enabled? / #logs_enabled? / #exceptions_enabled?" do
          it "defaults to true" do
            expect(subject.traces_enabled?).to be true
            expect(subject.logs_enabled?).to be true
            expect(subject.exceptions_enabled?).to be true
          end
        end

        describe "#service_name" do
          around do |example|
            original = ENV.fetch("OTEL_SERVICE_NAME", nil)
            example.run
          ensure
            if original.nil?
              ENV.delete("OTEL_SERVICE_NAME")
            else
              ENV["OTEL_SERVICE_NAME"] = original
            end
          end

          it "uses OTEL_SERVICE_NAME when set" do
            ENV["OTEL_SERVICE_NAME"] = "my-service"
            expect(described_class.new.service_name).to eq("my-service")
          end

          it "falls back to rails-app" do
            ENV.delete("OTEL_SERVICE_NAME")
            expect(described_class.new.service_name).to eq("rails-app")
          end
        end

        describe "endpoints" do
          around do |example|
            keys = %w(OTEL_EXPORTER_OTLP_ENDPOINT OTEL_EXPORTER_OTLP_TRACES_ENDPOINT OTEL_EXPORTER_OTLP_LOGS_ENDPOINT)
            originals = keys.index_with { |k| ENV.fetch(k, nil) }
            example.run
          ensure
            keys.each do |k|
              if originals[k].nil?
                ENV.delete(k)
              else
                ENV[k] = originals[k]
              end
            end
          end

          it "derives traces and logs endpoints from OTEL_EXPORTER_OTLP_ENDPOINT" do
            ENV.delete("OTEL_EXPORTER_OTLP_TRACES_ENDPOINT")
            ENV.delete("OTEL_EXPORTER_OTLP_LOGS_ENDPOINT")
            ENV["OTEL_EXPORTER_OTLP_ENDPOINT"] = "http://collector:4318"

            cfg = described_class.new
            expect(cfg.traces_endpoint).to eq("http://collector:4318/v1/traces")
            expect(cfg.logs_endpoint).to eq("http://collector:4318/v1/logs")
          end
        end
      end
    end
  end
end
