require 'rails_helper'

RSpec.describe GradeDescriptor, type: :model do
  describe 'relationships' do
    it { should belong_to :skill }
  end

  describe 'validations' do
    it { should validate_presence_of :skill }
    it { should validate_presence_of :mark }
  end
end
