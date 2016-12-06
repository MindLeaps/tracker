# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  scope :after_timestamp, lambda { |timestamp|
    where("#{table_name}.created_at > :datetime OR #{table_name}.updated_at > :datetime", datetime: Time.zone.parse(timestamp))
  }

  scope :exclude_deleted, -> { where deleted_at: nil }
end
