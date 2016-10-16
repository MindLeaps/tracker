# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :after_timestamp, ->(timestamp) { where('created_at > ? OR updated_at > ?', timestamp, timestamp) }
end
