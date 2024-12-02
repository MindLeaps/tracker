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
#  mlid                   :string           not null
#  name_of_school         :string
#  notes                  :text
#  quartier               :string
#  reason_for_leaving     :string
#  school_level_completed :string
#  year_of_dropout        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  old_group_id           :integer
#  organization_id        :bigint
#  profile_image_id       :integer
#
# Indexes
#
#  index_students_on_old_group_id      (old_group_id)
#  index_students_on_organization_id   (organization_id)
#  index_students_on_profile_image_id  (profile_image_id)
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
        @org2 = create :organization
        @existing_student = create :student, organization: @org, mlid: 'AA1'
      end

      describe 'is valid' do
        it 'when a student is the only student in their organization' do
          new_student = create :student, organization: @org2, mlid: 'AA1'
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

      @group1 = create :group, group_name: 'A Group'
      @group2 = create :group, group_name: 'B Group'

      @student1 = create :enrolled_student, first_name: 'Emberto', groups: [@group1]
      @student2 = create :enrolled_student, first_name: 'Amberto', groups: [@group1]
      @student3 = create :enrolled_student, first_name: 'Omberto', groups: [@group1]


      @student4 = create :enrolled_student, first_name: 'Ambuba', groups: [@group2]
      @student5 = create :enrolled_student, first_name: 'Ombuba', groups: [@group2]
    end

    describe 'table_order' do
      it 'returns students sorted by first name' do
        expect(Student.table_order(key: :first_name, order: 'ASC').map(&:first_name)).to eq %w[Amberto Ambuba Emberto Omberto Ombuba]
      end
    end

    describe 'search' do
      before :each do
        @zombarato = create :student, first_name: 'Zombarato', last_name: 'Agustato', mlid: 'Z31'
        @zombaruto = create :student, first_name: 'Zombaruto', last_name: 'Agurat'
        @zomzovato = create :student, first_name: 'Zomzovato', last_name: 'Domovat'
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
        result = Student.search('Z3')
        expect(result.length).to eq 1
        expect(result).to include @zombarato
      end

      it 'finds students by a partial first name match' do
        result = Student.search('Zomb')
        expect(result.length).to eq 2
        expect(result).to include @zombarato, @zombaruto
      end

      it 'finds students by a partial last name match' do
        result = Student.search('Dom')
        expect(result.length).to eq 1
        expect(result).to include @zomzovato
      end
    end
  end
end
