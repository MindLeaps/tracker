# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_validation :log_errors, if: ->(m) { m.errors.present? }

  scope :after_timestamp, lambda { |timestamp|
    where("#{table_name}.created_at > :datetime OR #{table_name}.updated_at > :datetime", datetime: Time.zone.parse(timestamp))
  }

  scope :exclude_deleted, -> { where deleted_at: nil }

  def log_errors
    Rails.logger.warn "#{self.class.name} #{id || '(new)'} is invalid: #{errors.full_messages.inspect}"
  end
end
