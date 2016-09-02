class Group < ActiveRecord::Base
  validates :group_name, presence: true
  belongs_to :chapter
  has_many :students

  delegate :chapter_name, to: :chapter, allow_nil: true
end
