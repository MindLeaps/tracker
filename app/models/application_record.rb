class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_validation :log_errors, if: ->(m) { m.errors.present? }

  scope :after_timestamp, lambda { |timestamp|
    where("#{table_name}.created_at > :datetime OR #{table_name}.updated_at > :datetime", datetime: Time.zone.parse(timestamp))
  }

  scope :exclude_deleted, -> { where deleted_at: nil }

  scope :table_order, lambda { |order_hash|
    order(Arel.sql(order_hash[:key].to_s) => Arel.sql(order_hash[:order].to_s))
  }

  def log_errors
    Rails.logger.warn "#{self.class.name} #{id || '(new)'} is invalid: #{errors.full_messages.inspect}"
  end

  def self.alias_table_order_scope(*scope_names)
    scope_names.each do |scope_name|
      singleton_class.alias_method(scope_name, :table_order)
    end
  end
end
