# frozen_string_literal: true
module Helpers
  def json
    JSON.parse(response.body)
  end

  def response_timestamp
    Time.zone.parse(json['meta']['timestamp'])
  end
end
