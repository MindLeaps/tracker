# == Schema Information
#
# Table name: lessons
#
#  id         :uuid             not null, primary key
#  date       :date             not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer          not null
#  subject_id :integer          not null
#
# Indexes
#
#  index_lessons_on_group_id                          (group_id)
#  index_lessons_on_group_id_and_subject_id_and_date  (group_id,subject_id,date) UNIQUE WHERE (deleted_at IS NULL)
#  index_lessons_on_subject_id                        (subject_id)
#  lesson_uuid_unique                                 (id) UNIQUE
#
# Foreign Keys
#
#  lessons_group_id_fk    (group_id => groups.id)
#  lessons_subject_id_fk  (subject_id => subjects.id)
#
require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe 'relationships' do
    it { should belong_to :group }
    it { should belong_to :subject }
    it { should have_many :grades }
  end

  describe 'validations' do
    it { is_expected.to belong_to :group }
    it { is_expected.to belong_to :subject }
    it { is_expected.to validate_presence_of :date }

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

  describe 'scopes' do
    before :each do
      @subject1 = create :subject
      @subject2 = create :subject

      @group1 = create :group
      @group2 = create :group

      @lesson1 = create :lesson, group: @group1, subject: @subject1
      @lesson2 = create :lesson, group: @group1, subject: @subject2
      @lesson3 = create :lesson, group: @group2, subject: @subject1
      @lesson4 = create :lesson, group: @group2, subject: @subject2
    end

    describe 'by_group' do
      it 'returns lessons belonging to a particular group' do
        expect(Lesson.by_group(@group1.id).length).to eq 2
        expect(Lesson.by_group(@group1.id)).to include @lesson1, @lesson2
      end
    end

    describe 'by_subject' do
      it 'returns lessons belonging to a particular subject' do
        expect(Lesson.by_subject(@subject1.id).length).to eq 2
        expect(Lesson.by_subject(@subject1.id)).to include @lesson1, @lesson3
      end
    end
  end
end
