# == Schema Information
#
# Table name: student_images
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  student_id :integer          not null
#
# Indexes
#
#  index_student_images_on_student_id  (student_id)
#
# Foreign Keys
#
#  student_images_student_id_fk  (student_id => students.id)
#
class StudentImage < ApplicationRecord
  belongs_to :student
  mount_uploader :image, StudentImageUploader

  validates :image, presence: true
end
