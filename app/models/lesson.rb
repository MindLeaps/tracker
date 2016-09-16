class Lesson < ApplicationRecord
  validates :group, :date, presence: true
  validates :date, uniqueness: {
    scope: :group_id,
    message: ->(object, _data) { "Lesson already exists in group \"#{object.group.group_name}\" on selected date." }
  }

  belongs_to :group
end
