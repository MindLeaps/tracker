# == Schema Information
#
# Table name: subjects
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  subject_name    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#
# Indexes
#
#  index_subjects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  subjects_organization_id_fk  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to :organization }
    it { is_expected.to have_many :lessons }
    it { is_expected.to have_many(:assignments).dependent :destroy }
    it { is_expected.to have_many(:skills).through :assignments }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :subject_name }
  end

  describe 'scopes' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @subject1 = create :subject, organization: @org1
      @subject2 = create :subject, organization: @org1
      @subject3 = create :subject, organization: @org2
    end

    describe 'by_organization' do
      it 'returns subjects scoped by organization' do
        expect(Subject.by_organization(@org1.id).length).to eq 2
        expect(Subject.by_organization(@org1.id)).to include @subject1, @subject2
      end
    end
  end

  describe 'methods' do
    describe 'grades_in_skill?' do
      before :each do
        @subject = create :subject
        @graded_skill = create :skill, subject: @subject
        @ungraded_skill = create :skill, subject: @subject
        @lesson = create :lesson, subject: @subject
        @grade_using_skill = create :grade, lesson: @lesson, skill: @graded_skill
      end

      it 'returns true for a graded skill' do
        expect(@subject.grades_in_skill?(@graded_skill.id)).to be true
      end

      it 'returns false for an ungraded skill' do
        expect(@subject.grades_in_skill?(@ungraded_skill.id)).to be false
      end
    end

    describe 'assignment_validation' do
      before :each do
        @subject = create :subject
        @some_other_subject = create :subject
        @graded_skill = create :skill
        @assignment = create :assignment, subject: @subject, skill: @graded_skill
        @lesson = create :lesson, subject: @subject
        @grade_using_skill = create :grade, lesson: @lesson, skill: @graded_skill
      end

      it 'returns the graded skill name' do
        @subject.assignments.each(&:mark_for_destruction)
        expect(@subject.assignment_validation).to eq @graded_skill.skill_name
      end

      it 'returns false if no graded skill is found' do
        expect(@some_other_subject.assignment_validation).to be false
      end
    end
  end
end
