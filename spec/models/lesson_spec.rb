require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to :group }
    it { is_expected.to validate_presence_of :group }
    it { is_expected.to validate_presence_of :date }

    describe 'uniqueness' do
      before :each do
        @group = create :group
        create :lesson, group: @group, date: Time.zone.today
      end

      it 'is expected to be valid' do
        expect(create(:lesson, group: @group, date: Time.zone.yesterday)).to be_valid
      end

      it 'is expected to be invalid' do
        lesson = build :lesson, group: @group, date: Time.zone.today
        expect(lesson).to be_invalid
        expect(lesson.errors.messages[:date])
          .to include "Lesson already exists in group \"#{lesson.group.group_name}\" on selected date."
      end
    end
  end
end
