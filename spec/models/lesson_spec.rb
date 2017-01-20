# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Lesson, type: :model do
  describe 'relationships' do
    it { should belong_to :group }
    it { should belong_to :subject }
    it { should have_many :absences }
  end

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
