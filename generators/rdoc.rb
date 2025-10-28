# frozen_string_literal: true

module Generators
  class Rdoc < External::Base
    def call(project_dir, doc_dir)
      options = {
        format:,
        template:,
        output: doc_dir
      }.compact

      if readme = Dir.glob("*", base: project_dir).grep(/\Areadme/i).first
        options[:main] = readme
      end

      system <<~CMD
        bundle exec rdoc \
          #{options.map { "--#{_1.to_s.tr("_", "-")} #{_2}" }.join(" ")}
      CMD
    end

    private

      def format   = nil
      def template = nil
  end
end
