# frozen_string_literal: true

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
require 'rails_helper'

RSpec.describe StudentImage, type: :model do
  describe 'validations' do
    it { should validate_presence_of :image }
  end

  describe 'relations' do
    it { should belong_to :student }
  end
end
