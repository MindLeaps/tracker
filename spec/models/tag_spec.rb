# == Schema Information
#
# Table name: tags
#
#  id                      :uuid             not null, primary key
#  shared                  :boolean          not null
#  shared_organization_ids :bigint           default([]), is an Array
#  tag_name                :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :bigint           not null
#
# Indexes
#
#  index_tags_on_organization_id  (organization_id)
#
require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'relationships' do
    it { should have_many :student_tags }
    it { should have_many :students }
    it { should belong_to :organization }
  end

  describe 'validations' do
    it { should validate_presence_of :tag_name }

    it 'when the same tag is created for an organization' do
      @org = create :organization
      create :tag, tag_name: 'Existing Tag', organization: @org
      new_tag = Tag.new tag_name: 'Existing Tag', organization_id: @org

      expect(new_tag).to_not be_valid
    end

    it 'when tag has duplicate shared organization ids' do
      @organizations = create_list :organization, 3
      new_tag = Tag.new tag_name: 'New Tag', organization_id: @organizations[0].id, shared_organization_ids: [@organizations[1].id, @organizations[2].id, @organizations[2].id]

      expect(new_tag).to_not be_valid
      expect(new_tag.errors[:shared_organization_ids]).to include I18n.t(:'errors.messages.must_contain_unique')
    end

    it 'when tag has duplicate shared organization ids' do
      @org = create :organization
      new_tag = Tag.new tag_name: 'New Tag', organization_id: @org.id, shared_organization_ids: [5]

      expect(new_tag).to_not be_valid
      expect(new_tag.errors[:shared_organization_ids]).to include I18n.t(:selected_organizations_must_exist)
    end
  end

  describe 'methods' do
    before(:each) do
      @org = create :organization
      @chapter = create :chapter, organization: @org
      @group = create :group, chapter: @chapter
      @student = create :enrolled_student, organization: @org, groups: [@group]
      @unused_tag = create :tag, tag_name: 'Empty tag', organization: @org
      @used_tag = create :tag, tag_name: 'First tag', organization: @org
      create :student_tag, tag: @used_tag, student: @student
    end

    describe '#can_delete' do
      it 'should return true when the tag has no students associated with it' do
        expect(@unused_tag.can_delete?).to be true
      end

      it 'should return false when the tag has students associated with it' do
        expect(@used_tag.can_delete?).to be false
      end
    end
  end
end
