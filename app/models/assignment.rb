# frozen_string_literal: true
class Assignment < ApplicationRecord
  belongs_to :skill
  belongs_to :subject

  validates :skill, presence: true
  validates :subject, presence: true

  def destroy
    update_attribute :deleted_at, Time.zone.now
  end
end
