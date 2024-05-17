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
#  index_lessons_on_id                                (id) UNIQUE
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
    it { should have_many :absences }
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

  describe '#mark_student_as_absent' do
    before :each do
      @group = create :group
      @student = create :student, group: @group
      @lesson = create :lesson, group: @group

      @absent_student = create :student, group: @group
      @lesson2 = create :lesson, group: @group
      @absence = create :absence, student: @absent_student, lesson: @lesson2
    end

    it 'marks the student as absent from lesson' do
      expect(@lesson.reload.absences.length).to eq 0
      @lesson.mark_student_as_absent @student

      expect(@lesson.reload.absences.length).to eq 1
      expect(@lesson.absences.map(&:student_id)).to include @student.id
      expect(@student.absences.map(&:lesson_id)).to include @lesson.id
    end

    it 'leaves the student as already absent' do
      @lesson2.mark_student_as_absent @absent_student

      expect(@lesson2.reload.absences.length).to eq 1
      expect(@lesson2.absences.map(&:student_id)).to include @absent_student.id
      expect(@absent_student.absences.map(&:lesson_id)).to include @lesson2.id
    end
  end

  describe '#mark_student_as_present' do
    before :each do
      @group = create :group

      @student = create :student, group: @group
      @lesson = create :lesson, group: @group
      @absence = create :absence, student: @student, lesson: @lesson

      @present_student = create :student, group: @group
      @lesson2 = create :lesson, group: @group
    end

    it 'marks student as present' do
      expect(@lesson.reload.absences.length).to eq 1
      @lesson.mark_student_as_present @student

      expect(@lesson.reload.absences.length).to eq 0
    end

    it 'leaves the student as already present' do
      @lesson2.mark_student_as_present @present_student

      expect(@lesson2.reload.absences.length).to eq 0
    end
  end

  describe '#student_absent?' do
    before :each do
      @group = create :group
      @student = create :student, group: @group
      @lesson = create :lesson, group: @group
    end

    it 'returns true if a student is absent' do
      create :absence, lesson: @lesson, student: @student

      expect(@lesson.student_absent?(@student)).to be true
    end

    it 'returns false if student is not absent' do
      expect(@lesson.student_absent?(@student)).to be false
    end
  end
end
