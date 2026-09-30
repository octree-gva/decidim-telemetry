# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    module OpenTelemetry
      describe OtelLogger do
        let(:test_class) do
          Class.new do
            include OtelLogger
            public :message_to_string, :severity_to_number, :severity_to_text, :low_severity?,
                   :otel_severity_pair, :extract_attributes
          end
        end

        subject { test_class.new }

        describe "#message_to_string" do
          it "returns the string when msg is a String" do
            expect(subject.message_to_string("hello")).to eq("hello")
          end

          it "returns nil when msg is nil" do
            expect(subject.message_to_string(nil)).to be_nil
          end

          it "returns msg.to_s when msg responds to :to_s" do
            obj = double("obj", to_s: "stringified")
            expect(subject.message_to_string(obj)).to eq("stringified")
          end
        end

        describe "#low_severity?" do
          it "returns true for DEBUG and INFO" do
            expect(subject.low_severity?(0)).to be true
            expect(subject.low_severity?("INFO")).to be true
          end

          it "returns false for WARN and ERROR" do
            expect(subject.low_severity?("WARN")).to be false
            expect(subject.low_severity?("ERROR")).to be false
          end
        end

        describe "#severity_to_number" do
          it "returns OTel severity number for known severities" do
            expect(subject.severity_to_number("DEBUG")).to eq(5)
            expect(subject.severity_to_number("WARN")).to eq(13)
            expect(subject.severity_to_number("ERROR")).to eq(17)
          end

          it "returns 9 (INFO) for unknown severity" do
            expect(subject.severity_to_number("UNKNOWN")).to eq(9)
          end
        end

        describe "#extract_attributes" do
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

          it "exports OTEL_SERVICE_NAME as service.name and serviceName" do
            ENV["OTEL_SERVICE_NAME"] = "my-decidim-instance"
            Decidim::Telemetry.instance_variable_set(:@config, nil)

            attrs = subject.extract_attributes("MyLogger")

            expect(attrs["service.name"]).to eq("my-decidim-instance")
            expect(attrs["serviceName"]).to eq("my-decidim-instance")
          end

          it "falls back to rails-app when OTEL_SERVICE_NAME is unset" do
            ENV.delete("OTEL_SERVICE_NAME")
            Decidim::Telemetry.instance_variable_set(:@config, nil)

            attrs = subject.extract_attributes(nil)

            expect(attrs["service.name"]).to eq("rails-app")
            expect(attrs["serviceName"]).to eq("rails-app")
          end
        end
      end
    end
  end
end
