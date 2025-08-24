# == Schema Information
#
# Table name: tags
#
#  id              :uuid             not null, primary key
#  shared          :boolean          not null
#  tag_name        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
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
