# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    describe Configuration do
      subject { described_class.new }

      describe "#enabled?" do
        it "returns true by default" do
          expect(subject.enabled?).to be true
        end

        it "returns true when enabled" do
          subject.enabled = true
          expect(subject.enabled?).to be true
        end

        it "returns false when disabled" do
          subject.enabled = false
          expect(subject.enabled?).to be false
        end
      end

      describe "#export_interval" do
        it "defaults to 15 minutes" do
          expect(subject.export_interval).to eq(15)
        end
      end

      describe "#basic_auth_enabled?" do
        it "returns false by default" do
          expect(subject.basic_auth_enabled?).to be false
        end

        it "returns true when username and password are set" do
          subject.username = "user"
          subject.password = "pass"
          expect(subject.basic_auth_enabled?).to be true
        end

        it "returns false when only username is set" do
          subject.username = "user"
          expect(subject.basic_auth_enabled?).to be false
        end
      end

      describe "#open_telemetry" do
        it "exposes nested OpenTelemetry configuration" do
          expect(subject.open_telemetry).to be_a(OpenTelemetry::Configuration)
          expect(subject.open_telemetry.enabled?).to be true
          expect(subject.open_telemetry.traces_enabled?).to be true
          expect(subject.open_telemetry.logs_enabled?).to be true
          expect(subject.open_telemetry.exceptions_enabled?).to be true
        end
      end
    end
  end
end
