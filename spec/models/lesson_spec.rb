# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to :group }
    it { is_expected.to belong_to :subject }
    it { is_expected.to validate_presence_of :group }
    it { is_expected.to validate_presence_of :date }
    it { is_expected.to validate_presence_of :subject }

    describe 'uniqueness' do
      before :each do
        @group = create :group
        @subject = create :subject
        create :lesson, group: @group, date: Time.zone.today, subject: @subject
      end

      it 'is expected to be valid' do
        expect(create(:lesson, group: @group, date: Time.zone.yesterday)).to be_valid
        expect(create(:lesson, group: @group, date: Time.zone.today)).to be_valid
      end

      it 'is expected to be invalid' do
        lesson = build :lesson, group: @group, date: Time.zone.today, subject: @subject
        expect(lesson).to be_invalid
        expect(lesson.errors.messages[:date])
          .to include "Lesson already exists for group \"#{lesson.group.group_name}\" in \"#{lesson.subject.subject_name}\" on selected date."
      end
    end
  end
end
