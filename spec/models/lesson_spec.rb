require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to :group }
    it { is_expected.to validate_presence_of :group }
    it { is_expected.to validate_presence_of :date }

    describe 'uniqueness' do
      subject { create :lesson }

      it do
        is_expected.to validate_uniqueness_of(:date).scoped_to(:group_id)
          .with_message "Lesson already exists in group \"#{subject.group.group_name}\" on selected date."
      end
    end
  end
end
