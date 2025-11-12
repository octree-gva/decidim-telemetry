# frozen_string_literal: true

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

if Rails.env.development?
  require "decidim/dev"
  Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))
end
require "decidim/telemetry/configuration"
require "decidim/telemetry/engine"
require "decidim/telemetry/middleware/basic_auth"
require "decidim/telemetry/overrides/decidim_application_controller"
require "decidim/telemetry/overrides/decidim_proposal_command"

# Load Yabeda gems
require "yabeda"
require "yabeda/rails"
require "yabeda/puma/plugin"
require "yabeda/activejob"
require "yabeda/prometheus"

module Decidim
  module Telemetry
    def self.config
      @config ||= Configuration.new
    end

    def self.configure
      yield config
    end
  end
end
