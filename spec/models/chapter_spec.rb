# == Schema Information
#
# Table name: chapters
#
#  id              :integer          not null, primary key
#  chapter_name    :string           not null
#  deleted_at      :datetime
#  mlid            :string(2)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#
# Indexes
#
#  index_chapters_on_organization_id  (organization_id)
#  unique_mlid_per_scope              (mlid,organization_id) UNIQUE
#
# Foreign Keys
#
#  chapters_organization_id_fk  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe 'validations' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization
    end

    describe 'is valid' do
      it 'with a valid, unique name in an organization and a valid MLID' do
        chapter = Chapter.new chapter_name: 'Totally valid chapter', organization: @org1, mlid: 'C1'
        expect(chapter).to be_valid
        expect(chapter.chapter_name).to eql 'Totally valid chapter'
        expect(chapter.mlid).to eql 'C1'
      end

      it 'with a duplicated name and MLID in a different organization' do
        create :chapter, chapter_name: 'Existing Chapter Spec Chapter', organization: @org1, mlid: 'A1'
        chapter = Chapter.new chapter_name: 'Existing Chapter Spec Chapter', mlid: 'A1', organization_id: @org2.id
        expect(chapter).to be_valid
      end
    end

    describe 'is not valid' do
      it 'without chapter name' do
        chapter = Chapter.new chapter_name: nil, mlid: 'AB', organization: @org1
        expect(chapter).to_not be_valid
      end

      it 'with a nonexisting organization id' do
        chapter = Chapter.new chapter_name: 'Valid Name', organization_id: '1092837465', mlid: 'AB'
        expect(chapter).to_not be_valid
      end

      it 'with a duplicated name in the same organization' do
        create :chapter, chapter_name: 'Existing Chapter Spec Chapter', organization: @org1, mlid: 'A1'
        chapter = Chapter.new chapter_name: 'Existing Chapter Spec Chapter', organization_id: @org1.id, mlid: 'AB'
        expect(chapter).to_not be_valid
      end

      it 'without an MLID' do
        chapter = Chapter.new chapter_name: 'Valid Name', organization: @org1
        expect(chapter).to_not be_valid
      end

      it 'with a duplicated MLID in an organization' do
        existing_chapter = create :chapter, mlid: 'ML'
        chapter = Chapter.new chapter_name: 'Chapter', organization: existing_chapter.organization, mlid: 'ML'
        expect(chapter).to_not be_valid
      end
    end
  end

  describe 'scopes' do
    before :each do
      @first_organization = create :organization
      @second_organization = create :organization

      @first_chapter = create :chapter, organization: @first_organization
      @second_chapter = create :chapter, organization: @second_organization
      @deleted_chapter = create :chapter, deleted_at: Time.zone.now, organization: @second_organization
    end

    describe 'exclude_deleted' do
      it 'returns only non-deleted chapters' do
        expect(Chapter.exclude_deleted.length).to eq Chapter.where(deleted_at: nil).length
        expect(Chapter.exclude_deleted).to include @first_chapter, @second_chapter
        expect(Chapter.exclude_deleted).not_to include @deleted_chapter
      end
    end

    describe 'by_organization' do
      it 'should return only chapters belonging to a certain organization' do
        expect(Chapter.by_organization(@first_organization.id).length).to eq 1
        expect(Chapter.by_organization(@first_organization.id)).to include @first_chapter
        expect(Chapter.by_organization(@first_organization.id)).not_to include @second_chapter
      end
    end
  end

  describe 'methods' do
    describe 'delete_chapter_and_dependents' do
      before :each do
        @chapter_to_delete = create :chapter

        @groups_to_delete = create_list :group, 2, chapter: @chapter_to_delete
        @lessons_to_delete = create_list :lesson, 2, group: @groups_to_delete.first
        @grades_to_delete = create_list :grade, 2, lesson: @lessons_to_delete.first
        @deleted_group = create :group, chapter: @chapter_to_delete, deleted_at: Time.zone.now

        @chapter_to_delete.delete_chapter_and_dependents
        @chapter_to_delete.reload
      end

      it 'marks the chapter as deleted' do
        expect(@chapter_to_delete.deleted_at).to be_within(1.second).of Time.zone.now
      end

      it 'marks the chapter\'s dependents as deleted' do
        @groups_to_delete.each { |group| expect(group.reload.deleted_at).to eq(@chapter_to_delete.deleted_at) }
        @lessons_to_delete.each { |lesson| expect(lesson.reload.deleted_at).to eq(@chapter_to_delete.deleted_at) }
        @grades_to_delete.each { |grade| expect(grade.reload.deleted_at).to eq(@chapter_to_delete.deleted_at) }
      end

      it 'does not mark previously deleted dependents of the chapter as deleted' do
        expect(@deleted_group.reload.deleted_at).to_not eq(@chapter_to_delete.deleted_at)
      end
    end

    describe 'restore_chapter_and_dependents' do
      before :each do
        @chapter_to_restore = create :chapter, deleted_at: Time.zone.now

        @groups_to_restore = create_list :group, 2, chapter: @chapter_to_restore, deleted_at: @chapter_to_restore.deleted_at
        @lessons_to_restore = create_list :lesson, 2, group: @groups_to_restore.first, deleted_at: @chapter_to_restore.deleted_at
        @grades_to_restore = create_list :grade, 2, lesson: @lessons_to_restore.first, deleted_at: @chapter_to_restore.deleted_at
        @deleted_group = create :group, chapter: @chapter_to_restore, deleted_at: Time.zone.now

        @chapter_to_restore.restore_chapter_and_dependents
        @chapter_to_restore.reload
      end

      it 'removes the chapter\'s deleted timestamp' do
        expect(@chapter_to_restore.deleted_at).to be_nil
      end

      it 'removes the chapter\'s dependents deleted timestamps' do
        @groups_to_restore.each { |group| expect(group.reload.deleted_at).to be_nil }
        @lessons_to_restore.each { |lesson| expect(lesson.reload.deleted_at).to be_nil }
        @grades_to_restore.each { |grade| expect(grade.reload.deleted_at).to be_nil }
      end

      it 'does not remove the previously deleted dependents of the chapter\'s deleted timestamp' do
        expect(@deleted_group.reload.deleted_at).to_not be_nil
      end
    end
  end
end
