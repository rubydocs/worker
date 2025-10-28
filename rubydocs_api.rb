# frozen_string_literal: true

class RubydocsApi < External::Base
  BASE_URL = "https://api.rubydocs.org".freeze

  add_action :get_doc_details do |result|
    request :get, "docs/#{doc_id}"
  end

  add_action :post_doc_generation_notification do |result|
    request :post,
      "docs/generation_notification",
      json: {
        result:
      }
  end

  private

    def request_auth = "Bearer #{ENV.fetch "RUBYDOCS_API_TOKEN"}"
end
