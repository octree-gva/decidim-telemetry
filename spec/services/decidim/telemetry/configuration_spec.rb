# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    describe Configuration do
      subject { described_class.new }

      describe "#enabled?" do
        it "returns false by default" do
          expect(subject.enabled?).to be false
        end

        it "returns true when enabled" do
          subject.enabled = true
          expect(subject.enabled?).to be true
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
    end
  end
end
