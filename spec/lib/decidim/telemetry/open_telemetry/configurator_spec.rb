# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Telemetry
    module OpenTelemetry
      describe Configurator do
        describe ".call" do
          it "returns ok without configuring when disabled" do
            Decidim::Telemetry.configure { |c| c.open_telemetry.enabled = false }

            allow(described_class).to receive(:new).and_wrap_original do |m, *args, **kwargs|
              instance = m.call(*args, **kwargs)
              expect(instance).not_to receive(:configure_opentelemetry!)
              instance
            end

            expect(described_class.call).to be_ok
          end

          it "returns ok when configuration succeeds" do
            Decidim::Telemetry.configure { |c| c.open_telemetry.enabled = true }

            allow(described_class).to receive(:new).and_wrap_original do |m, *args, **kwargs|
              instance = m.call(*args, **kwargs)
              allow(instance).to receive(:require_opentelemetry!)
              allow(instance).to receive(:configure_sdk!)
              allow(instance).to receive(:verify_configuration!)
              instance
            end

            expect(described_class.call).to be_ok
          end

          it "returns not ok when configuration raises" do
            Decidim::Telemetry.configure { |c| c.open_telemetry.enabled = true }

            allow(described_class).to receive(:new).and_wrap_original do |m, *args, **kwargs|
              instance = m.call(*args, **kwargs)
              allow(instance).to receive(:require_opentelemetry!)
              allow(instance).to receive(:configure_sdk!).and_raise(StandardError.new("config failed"))
              instance
            end

            result = described_class.call
            expect(result).not_to be_ok
            expect(result.error).to eq("config failed")
          end

          it "honors logs_enabled and exceptions_enabled flags" do
            Decidim::Telemetry.configure do |c|
              c.open_telemetry.enabled = true
              c.open_telemetry.logs_enabled = false
              c.open_telemetry.exceptions_enabled = false
              c.open_telemetry.traces_enabled = true
            end

            otel = Decidim::Telemetry.config.open_telemetry
            expect(otel.logs_enabled?).to be false
            expect(otel.exceptions_enabled?).to be false
            expect(otel.traces_enabled?).to be true
          end
        end
      end

      describe OtelErrorSubscriber do
        subject { described_class.new }

        it "records exception on the current span when recording" do
          span = double("span", recording?: true, context: nil)
          allow(span).to receive(:record_exception)
          allow(span).to receive(:set_attribute)
          allow(span).to receive(:status=)
          allow(::OpenTelemetry::Trace).to receive(:current_span).and_return(span)
          allow(::OpenTelemetry::Trace::Status).to receive(:error).and_return(:error_status)

          error = StandardError.new("boom")
          subject.report(error, handled: false, severity: :error, context: {}, source: "test")

          expect(span).to have_received(:record_exception).with(error)
          expect(span).to have_received(:set_attribute).with("error.handled", false)
          expect(span).to have_received(:set_attribute).with("error.severity", "error")
          expect(span).to have_received(:set_attribute).with("error.source", "test")
        end

        it "creates an error.report span when no current span is recording" do
          span = double("span", recording?: false)
          new_span = double("new_span")
          allow(new_span).to receive(:record_exception)
          allow(new_span).to receive(:set_attribute)
          allow(new_span).to receive(:status=)
          allow(new_span).to receive(:finish)
          tracer = double("tracer")
          allow(tracer).to receive(:start_span).with("error.report").and_return(new_span)
          allow(::OpenTelemetry::Trace).to receive(:current_span).and_return(span)
          tracer_provider = double("tracer_provider")
          allow(tracer_provider).to receive(:tracer).with("decidim-telemetry-error").and_return(tracer)
          allow(::OpenTelemetry).to receive(:tracer_provider).and_return(tracer_provider)
          allow(::OpenTelemetry::Trace::Status).to receive(:error).and_return(:error_status)

          subject.report(StandardError.new("boom"), handled: true, severity: :warning, context: {})

          expect(tracer).to have_received(:start_span).with("error.report")
          expect(new_span).to have_received(:finish)
        end
      end
    end
  end
end
