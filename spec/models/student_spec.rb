# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:gro) { create :group }

  describe 'relationships' do
    it { should belong_to :group }
    it { should have_many :grades }
    it { should have_many :absences }
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

    subject { create :student, mlid: 'TEST1' }

    describe 'student is valid' do
      it 'with first and last name, dob, and gender' do
        male_student = Student.new mlid: '1S', first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 'male', group: gro
        expect(male_student).to be_valid
        expect(male_student.save).to eq true

        female_student = Student.new mlid: '2S', first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 'female', group: gro
        expect(female_student).to be_valid
        expect(female_student.save).to eq true
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

      it 'student is invalid if profile image belongs to other student' do
        @student.profile_image = @other_image
        expect(@student).to be_invalid
        expect(@student.errors.messages[:profile_image])
          .to include "Image of #{@other_image.student.proper_name} cannot be a profile image for #{@student.proper_name}"
      end
    end

    it { should validate_presence_of :mlid }
    it { should validate_presence_of :group }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :dob }
    it { should validate_uniqueness_of(:mlid) }

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

      @student1 = create :student, first_name: 'Emberto', group: @group1
      @student2 = create :student, first_name: 'Amberto', group: @group1
      @student3 = create :student, first_name: 'Omberto', group: @group1

      create :student, first_name: 'Ambuba', group: @group2
      create :student, first_name: 'Ombuba', group: @group2
    end

    describe 'by_group' do
      it 'returns students scoped by group' do
        expect(Student.by_group(@group1.id).length).to eq 3
        expect(Student.by_group(@group1.id)).to include @student1, @student2, @student3
      end
    end

    describe 'order_by_group_name' do
      it 'returns students sorted by Group Name' do
        expect(Student.order_by_group_name('asc').map(&:first_name)[0..2]).to include 'Emberto', 'Amberto', 'Omberto'
        expect(Student.order_by_group_name('asc').map(&:first_name)[3..4]).to include 'Ambuba', 'Ombuba'
        expect(Student.order_by_group_name('desc').map(&:first_name)[0..1]).to include 'Ambuba', 'Ombuba'
        expect(Student.order_by_group_name('desc').map(&:first_name)[2..4]).to include 'Emberto', 'Amberto', 'Omberto'
      end
    end

    describe 'table_order' do
      it 'returns students sorted by first name' do
        expect(Student.table_order(key: :first_name, order: 'ASC').map(&:first_name)).to eq %w[Amberto Ambuba Emberto Omberto Ombuba]
      end

      it 'returns students sorted by group name' do
        expect(Student.table_order(key: :order_by_group_name, order: 'ASC', custom_scope_order: 'true')).to eq Student.order_by_group_name('asc')
      end
    end

    describe 'search' do
      before :each do
        @zombarato = create :student, first_name: 'Zombarato', last_name: 'Agustato', mlid: 'ot32to'
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
        result = Student.search('ot3')
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

  describe '#organization' do
    let(:org) { create :organization }
    let(:student) { create :student, group: create(:group, chapter: create(:chapter, organization: org)) }

    it 'returns the organization that the student ultimately belongs to' do
      expect(student.organization).to eq(org)
    end
  end
end
