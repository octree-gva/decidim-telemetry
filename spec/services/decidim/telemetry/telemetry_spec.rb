# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    describe Telemetry do
      it "has a config method" do
        expect(described_class).to respond_to(:config)
      end

      it "has a configure method" do
        expect(described_class).to respond_to(:configure)
      end

      it "returns a Configuration instance" do
        expect(described_class.config).to be_a(Configuration)
      end

      it "yields configuration block" do
        expect { |b| described_class.configure(&b) }.to yield_with_args(described_class.config)
      end
    end
  end
end
