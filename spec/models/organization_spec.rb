# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  country           :string
#  country_code      :string
#  deleted_at        :datetime
#  image             :string           default("https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200")
#  mlid              :string(3)        not null
#  organization_name :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  organizations_mlid_key  (mlid) UNIQUE
#
require 'rails_helper'

RSpec.describe Organization, type: :model do
  let(:existing_org) { create :organization, organization_name: 'Already Existing Organization' }

  it { should have_many :chapters }

  describe 'is valid' do
    it 'with a valid, unique name and a unique MLID' do
      org = Organization.new organization_name: 'Totally valid org', mlid: 'UNI'
      expect(org).to be_valid
      expect(org.organization_name).to eql 'Totally valid org'
      expect(org.mlid).to eql 'UNI'
    end
  end

  describe 'is not valid' do
    it 'without organization name' do
      org = Organization.new organization_name: nil, mlid: 'ABC'
      expect(org).to_not be_valid
    end

    it 'without an MLID' do
      org = Organization.new organization_name: 'Some org', mlid: nil
      expect(org).to_not be_valid
    end

    it 'with a duplicated name' do
      org = Organization.new organization_name: existing_org.organization_name, mlid: '1J4'
      expect(org).to_not be_valid
    end

    it 'with a duplicated MLID' do
      org = Organization.new organization_name: 'Some other org', mlid: existing_org.mlid
      expect(org).to_not be_valid
    end

    it 'with an MLID containing special characters' do
      org = Organization.new organization_name: 'Another org', mlid: 'AV?'
      expect(org).to_not be_valid
    end

    it 'with an MLID that is longer than 3 characters' do
      org = Organization.new organization_name: 'Another org', mlid: 'AVBV'
      expect(org).to_not be_valid
    end
  end

  describe '#add_user_with_role' do
    let(:org) { create :organization }

    it 'Adds a new user with a specified role in the organization' do
      expect(org.add_user_with_role('someone@example.com', :admin)).to be_truthy

      user = User.find_by email: 'someone@example.com'
      expect(user.has_role?(:admin)).to be false
      expect(user.has_role?(:admin, org)).to be true
    end

    it 'Does not add a new user if a passed role is invalid' do
      expect(org.add_user_with_role('someone@example.com', :nonexistant)).to be false

      expect(User.find_by(email: 'someone@example.com')).to be_nil
    end
  end

  describe '#members' do
    let(:org) { create :organization }
    let(:other_org) { create :organization }

    before :each do
      @members = create_list :teacher_in, 2, organization: org
      @non_members = create_list :teacher_in, 3, organization: other_org
      @members << create(:admin_of, organization: org)
    end

    it 'returns users who have a role in the organization' do
      expect(org.members.length).to eq 3
      expect(org.members).to include(OrganizationMember.find(@members[0].id))
      expect(org.members).to include(OrganizationMember.find(@members[1].id))
      expect(org.members).to include(OrganizationMember.find(@members[2].id))
    end
  end

  describe 'scopes' do
    before :each do
      @first_organization = create :organization
      @second_organization = create :organization
      @deleted_organization = create :organization, deleted_at: Time.zone.now
    end

    describe 'exclude_deleted' do
      it 'returns only non-deleted organizations' do
        expect(Organization.exclude_deleted.length).to eq Organization.where(deleted_at: nil).length
        expect(Organization.exclude_deleted).to include @first_organization, @second_organization
        expect(Organization.exclude_deleted).not_to include @deleted_organization
      end
    end
  end

  describe 'methods' do
    describe 'delete_organization_and_dependents' do
      before :each do
        @organization_to_delete = create :organization

        @chapters = create_list :chapter, 2, organization: @organization_to_delete
        @groups = create_list :group, 2, chapter: @chapters.first
        @students = create_list :enrolled_student, 2, groups: [@groups.first], organization: @organization_to_delete
        @lessons = create_list :lesson, 2, group: @groups.first
        @grades = create_list :grade, 2, lesson: @lessons.first
        @deleted_chapter = create :chapter, organization: @organization_to_delete, deleted_at: Time.zone.now

        @organization_to_delete.delete_organization_and_dependents
        @organization_to_delete.reload
      end

      it 'marks the organization as deleted' do
        expect(@organization_to_delete.deleted_at).to be_within(1.second).of Time.zone.now
      end

      it 'marks the organization\'s dependents as deleted' do
        @chapters.each { |chapter| expect(chapter.reload.deleted_at).to eq(@organization_to_delete.deleted_at) }
        @groups.each { |group| expect(group.reload.deleted_at).to eq(@organization_to_delete.deleted_at) }
        @students.each { |student| expect(student.reload.deleted_at).to eq(@organization_to_delete.deleted_at) }
        @lessons.each { |lesson| expect(lesson.reload.deleted_at).to eq(@organization_to_delete.deleted_at) }
        @grades.each { |grade| expect(grade.reload.deleted_at).to eq(@organization_to_delete.deleted_at) }
      end

      it 'does not mark previously deleted dependents of the organization as deleted' do
        expect(@deleted_chapter.reload.deleted_at).to_not eq(@organization_to_delete.deleted_at)
      end
    end

    describe 'restore_organization_and_dependents' do
      before :each do
        @organization_to_restore = create :organization, deleted_at: Time.zone.now

        @chapters = create_list :chapter, 2, organization: @organization_to_restore, deleted_at: @organization_to_restore.deleted_at
        @groups = create_list :group, 2, chapter: @chapters.first, deleted_at: @organization_to_restore.deleted_at
        @students = create_list :enrolled_student, 2, groups: [@groups.first], organization: @organization_to_restore, deleted_at: @organization_to_restore.deleted_at
        @lessons = create_list :lesson, 2, group: @groups.first, deleted_at: @organization_to_restore.deleted_at
        @grades = create_list :grade, 2, lesson: @lessons.first, deleted_at: @organization_to_restore.deleted_at
        @deleted_chapter = create :chapter, organization: @organization_to_restore, deleted_at: Time.zone.now

        @organization_to_restore.restore_organization_and_dependents
        @organization_to_restore.reload
      end

      it 'removes the organization\'s deleted timestamp' do
        expect(@organization_to_restore.deleted_at).to be_nil
      end

      it 'remove the organization\'s dependents deleted timestamps' do
        @chapters.each { |chapter| expect(chapter.reload.deleted_at).to be_nil }
        @groups.each { |group| expect(group.reload.deleted_at).to be_nil }
        @students.each { |student| expect(student.reload.deleted_at).to be_nil }
        @lessons.each { |lesson| expect(lesson.reload.deleted_at).to be_nil }
        @grades.each { |grade| expect(grade.reload.deleted_at).to be_nil }
      end

      it 'does not remove the previously deleted dependents of the chapter\'s deleted timestamp' do
        expect(@deleted_chapter.reload.deleted_at).to_not be_nil
      end
    end
  end
end
