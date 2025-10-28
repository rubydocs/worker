# frozen_string_literal: true

require "thor"
require "json"
require "active_support/all"
require "baseline"
require "sentry-ruby"

Baseline.configuration.env = ENV["CI"] ? :production : :development

if sentry_dsn = ENV["SENTRY_DSN"]
  Sentry.init do |config|
    config.dsn                     = sentry_dsn
    config.environment             = Baseline.configuration.env
    config.include_local_variables = true
    config.send_default_pii        = true
  end
end

ApplicationService = Class.new(Baseline::BaseService)

module External
  class Base < Baseline::ExternalService
  end
end

class Manager < Thor
  def self.exit_on_failure? = true

  desc "build", "Build!"
  def build(doc_id)
    details = RubydocsApi.get_doc_details(doc_id)

    identifier, generator, git_repo, git_tag =
      details.fetch_values(
        "identifier",
        "generator",
        "git_repo",
        "git_tag"
      )

    project_dir = "__rubydocs_project"

    `git clone --depth 1 --branch #{git_tag} #{git_repo} #{project_dir}`

    doc_dir = "__rubydocs_docs"

    require_relative "generators/#{generator}"

    dir = Generators
      .const_get(generator.camelize)
      .call(project_dir, doc_dir)

    unless doc_id == "test"
      `rclone copy ./#{dir} r2:rubydocs/#{identifier}/#{git_tag}/#{generator}`

      RubydocsApi.post_doc_generation_notification \
        result
    end
  rescue => error
    Sentry.capture_exception error
    raise error
  end
end

Manager.start(ARGV)
