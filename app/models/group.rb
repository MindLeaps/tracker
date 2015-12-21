class Group < ActiveRecord::Base
  validates :group_name, presence: true
end
