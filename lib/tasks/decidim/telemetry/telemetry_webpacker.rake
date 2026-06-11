# frozen_string_literal: true

require "decidim/gem_manager"

namespace :decidim_telemetry do
  namespace :webpacker do
    desc "Installs Telemetry webpacker files in Rails instance application"
    task install: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_telemetry_npm
    end

    desc "Adds Telemetry dependencies in package.json"
    task upgrade: :environment do
      raise "Decidim gem is not installed" if decidim_path.nil?

      install_telemetry_npm
    end

    def install_telemetry_npm
      return if telemetry_npm_dependencies.empty?

      puts "install NPM packages. You can also do this manually with this command:"
      puts "npm i #{telemetry_npm_dependencies.join(" ")}"
      telemetry_system! "npm i #{telemetry_npm_dependencies.join(" ")}"
    end

    def telemetry_npm_dependencies
      @telemetry_npm_dependencies ||= if telemetry_path.nil? || !File.exist?(telemetry_path.join("package.json"))
                                        []
                                      else
                                        package_json = JSON.parse(File.read(telemetry_path.join("package.json")))
                                        (package_json["dependencies"] || {}).map { |package, version| "#{package}@#{version}" }
                                      end
    end

    def telemetry_path
      @telemetry_path ||= Pathname.new(telemetry_gemspec.full_gem_path) if Gem.loaded_specs.has_key?(telemetry_gem_name)
    end

    def rails_app_path
      @rails_app_path ||= Rails.root
    end

    def telemetry_system!(command)
      system("cd #{rails_app_path} && #{command}") || abort("\n== Command #{command} failed ==")
    end

    def telemetry_gemspec
      @telemetry_gemspec ||= Gem.loaded_specs[telemetry_gem_name]
    end

    def telemetry_gem_name
      "decidim-telemetry"
    end
  end
end
