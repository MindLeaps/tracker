# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  group_name :string           default(""), not null
#  mlid       :string(2)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chapter_id :integer
#
# Indexes
#
#  index_groups_on_chapter_id  (chapter_id)
#  unique_mlid_per_chapter_id  (mlid,chapter_id) UNIQUE
#
# Foreign Keys
#
#  groups_chapter_id_fk  (chapter_id => chapters.id)
#
require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    it { should validate_presence_of :group_name }
    it { should validate_presence_of :mlid }

    describe 'mlid' do
      before :each do
        @chapter = create :chapter
      end

      it 'validates the max length of mlid' do
        valid_group = Group.new group_name: 'Valid Group', mlid: '1A', chapter_id: @chapter.id
        invalid_group = Group.new group_name: 'Invalid Group', mlid: '1A2', chapter_id: @chapter.id
        expect(valid_group).to be_valid
        expect(invalid_group).to be_invalid
      end
    end
  end

  describe 'scopes' do
    before :each do
      @chapter1 = create :chapter
      @chapter2 = create :chapter

      @group1 = create :group, chapter: @chapter1
      @group2 = create :group, chapter: @chapter2
      @group3 = create :group, deleted_at: Time.zone.now, chapter: @chapter1
    end

    describe 'exclude_deleted' do
      it 'returns only non-deleted groups' do
        expect(Group.exclude_deleted.length).to eq 2
        expect(Group.exclude_deleted).to include @group1, @group2
      end

      it 'returns only groups belonging to a specific chapter' do
        expect(Group.by_chapter(@chapter1.id).length).to eq 2
        expect(Group.by_chapter(@chapter1.id)).to include @group1, @group3
      end
    end
  end
end
