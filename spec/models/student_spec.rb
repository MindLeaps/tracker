# == Schema Information
#
# Table name: students
#
#  id                     :integer          not null, primary key
#  country_of_nationality :text
#  deleted_at             :datetime
#  dob                    :date             not null
#  estimated_dob          :boolean          default(TRUE), not null
#  family_members         :text
#  first_name             :string           not null
#  gender                 :enum             not null
#  guardian_contact       :string
#  guardian_name          :string
#  guardian_occupation    :string
#  health_insurance       :text
#  health_issues          :text
#  hiv_tested             :boolean
#  last_name              :string           not null
#  mlid                   :string(8)        not null
#  name_of_school         :string
#  notes                  :text
#  old_mlid               :string
#  quartier               :string
#  reason_for_leaving     :string
#  school_level_completed :string
#  year_of_dropout        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  old_group_id           :integer
#  organization_id        :integer          not null
#  profile_image_id       :integer
#
# Indexes
#
#  index_students_on_mlid_and_organization_id  (mlid,organization_id) UNIQUE
#  index_students_on_old_group_id              (old_group_id)
#  index_students_on_organization_id           (organization_id)
#  index_students_on_profile_image_id          (profile_image_id)
#
# Foreign Keys
#
#  fk_rails_...          (organization_id => organizations.id)
#  fk_rails_...          (profile_image_id => student_images.id)
#  students_group_id_fk  (old_group_id => groups.id)
#
require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:gro) { create :group }

  describe 'relationships' do
    it { should belong_to :organization }
    it { should have_many :grades }
    it { should have_many :enrollments }
    it { should have_many :student_images }
    it { should accept_nested_attributes_for :student_images }
    it { should have_many :student_tags }
    it { should have_many :tags }
  end

  describe 'validate' do
    before :each do
      # Bullet gives false positives for these tests
      Bullet.enable = false
    end

    subject { create :student, mlid: 'TS1' }

    describe 'student is valid' do
      let(:org) { create :organization }

      it 'with first and last name, dob, and gender' do
        male_student = Student.new mlid: '1S', first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 'male', organization: org
        expect(male_student).to be_valid
        expect(male_student.save).to eq true

        female_student = Student.new mlid: '2S', first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 'female', organization: org
        expect(female_student).to be_valid
        expect(female_student.save).to eq true
      end
    end

    describe 'MLID' do
      before :each do
        @org = create :organization
        @another_org = create :organization
        @existing_student = create :student, organization: @org, mlid: 'AA1'
      end

      describe 'is valid' do
        it 'when a student is the only student in their organization' do
          new_student = create :student, organization: @another_org, mlid: 'AA1'
          expect(new_student).to be_valid
        end

        it 'when it is unique in an organization' do
          new_student = create :student, organization: @org, mlid: 'BB1'
          expect(new_student).to be_valid
        end
      end

      describe 'is invalid' do
        it 'when it is duplicated in the same organization' do
          new_student = build :student, organization: @org, mlid: 'AA1'
          expect(new_student).to be_invalid
        end

        it 'when it is longer than 8 characters' do
          new_student = build :student, organization: @org, mlid: '123456789'
          expect(new_student).to be_invalid
        end
      end
    end

    describe 'profile_image' do
      before :each do
        @student = create :student
        @image = create :student_image, student: @student
        @other_image = create :student_image
      end

      it 'student is valid if profile image belongs to student' do
        @student.profile_image = @image
        expect(@student).to be_valid
      end
    end

    it { should validate_presence_of :mlid }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :dob }

    after :all do
      Bullet.enable = true
    end
  end

  describe 'when creating or updating' do
    before :each do
      @org = create :organization
      @chapter = create :chapter, organization: @org
      @first_group = create :group, chapter: @chapter
      @second_group = create :group, chapter: @chapter
      @student = create :student, organization: @org
      @second_student = create :enrolled_student, organization: @org, groups: [@first_group, @second_group]
    end

    it 'has no enrollments when created' do
      expect(@student.enrollments.count).to eq 0
    end

    it 'has updated enrollments when they are modified' do
      expect(@second_student.enrollments.count).to eq 2
      Enrollment.find(@second_student.enrollments.last.id).destroy
      expect(@second_student.reload.enrollments.count).to eq 1
    end
  end

  describe '#proper_name' do
    it 'returns last and first name concatenated' do
      student = Student.new first_name: 'Ignazio', last_name: 'Sorbos'
      expect(student.proper_name).to eq 'Sorbos, Ignazio'
    end
  end

  describe 'scopes' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization
      @chapter1 = create :chapter, organization: @org1
      @chapter2 = create :chapter, organization: @org2
      @group1 = create :group, chapter: @chapter1, group_name: 'A Group'
      @group2 = create :group, chapter: @chapter2, group_name: 'B Group'

      @student1 = create :student, first_name: 'Emberto', organization: @org1
      @student2 = create :student, first_name: 'Amberto', organization: @org1
      @student3 = create :student, first_name: 'Omberto', organization: @org1

      create :student, first_name: 'Ambuba', organization: @org2
      create :student, first_name: 'Ombuba', organization: @org2
    end

    describe 'table_order' do
      it 'returns students sorted by first name' do
        expect(Student.table_order(key: :first_name, order: 'ASC').map(&:first_name)).to eq %w[Amberto Ambuba Emberto Omberto Ombuba]
      end
    end

    describe 'search' do
      before :each do
        @zombarato = create :student, first_name: 'Zombarato', last_name: 'Agustato', mlid: 'Z31'
        @zombanavo = create :student, first_name: 'Zombanavo', last_name: 'Domboklat', mlid: 'Z32'
        @zombaruto = create :student, first_name: 'Zombaruto', last_name: 'Agurat', mlid: 'Z33'
        @zomzovato = create :student, first_name: 'Zomzovato', last_name: 'Domovat', mlid: 'Z34'
      end

      it 'finds the student by the first name match' do
        result = Student.search('Zombarato')
        expect(result.length).to eq 1
        expect(result).to include @zombarato
      end

      it 'finds the student by the last name match' do
        result = Student.search('Agustato')
        expect(result.length).to eq 1
        expect(result).to include @zombarato
      end

      it 'finds the student by the MLID match' do
        result = Student.search('Z31')
        expect(result.length).to eq 1
        expect(result).to include @zombarato
      end

      it 'finds students by a partial first name match' do
        result = Student.search('Zomb')
        expect(result.length).to eq 3
        expect(result).to include @zombarato, @zombaruto, @zombanavo
      end

      it 'finds students by a partial last name match' do
        result = Student.search('Dom')
        expect(result.length).to eq 2
        expect(result).to include @zomzovato, @zombanavo
      end
    end
  end


  describe 'methods' do

    describe '#deleted_enrollment_with_grades?' do
      before :each do
        @group = create :group
        @first_student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: {
          'Memorization' => [1, 3, 6], 'Grit' => [2, 4, 7]
        }
        @second_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      end

      it 'returns false if no enrollments which contain grades have been deleted' do
        expect(@first_student.deleted_enrollment_with_grades?).to eq false
        expect(@second_student.deleted_enrollment_with_grades?).to eq false
      end

      it 'returns any enrollment which contains grades that has been deleted' do
        @first_student.enrollments.each(&:mark_for_destruction)
        @second_student.enrollments.each(&:mark_for_destruction)

        expect(@first_student.deleted_enrollment_with_grades?).to eq @first_student.enrollments.first
        expect(@second_student.deleted_enrollment_with_grades?).to eq false
      end
    end

    describe '#updated_group_for_existing_enrollment??' do
      before :each do
        @first_group = create :group
        @second_group = create :group, chapter: @first_group.chapter
        @student = create :enrolled_student, organization: @first_group.chapter.organization, groups: [@first_group, @second_group]
      end

      it 'returns false if no group has been modified for existing enrollments' do
        expect(@student.updated_group_for_existing_enrollment?).to eq false
      end

      it 'returns the enrollment whose group has been modified' do
        first_enrollment = @student.enrollments.first
        first_enrollment.group_id = @second_group.id

        expect(@student.updated_group_for_existing_enrollment?).to eq first_enrollment
      end
    end

    describe '#updated_enrollment_with_grades?' do
      before :each do
        @group = create :group
        @student = create :graded_student, organization: @group.chapter.organization, groups: [@group], grades: {
          'Memorization' => [1, 3, 6], 'Grit' => [2, 4, 7]
        }
      end

      it 'returns false if enrollment update does not lose grades' do
        existing_enrollment = @student.enrollments.first
        existing_enrollment.active_since = 2.years.ago

        expect(@student.updated_enrollment_with_grades?).to eq false
      end

      it 'returns any enrollment whose update will lose grades' do
        existing_enrollment = @student.enrollments.first
        existing_enrollment.active_since = 1.day.from_now

        expect(@student.updated_enrollment_with_grades?).to eq existing_enrollment
      end
    end
  end
end
