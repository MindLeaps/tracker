# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :after_timestamp, ->(timestamp) { where('created_at > :datetime OR updated_at > :datetime', datetime: Time.zone.parse(timestamp)) }
end
