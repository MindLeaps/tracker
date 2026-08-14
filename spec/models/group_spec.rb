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
  describe 'relationships' do
    it { should have_many :group_tags }
    it { should have_many :tags }
  end

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
      @first_chapter = create :chapter
      @second_chapter = create :chapter

      @first_group = create :group, chapter: @first_chapter
      @second_group = create :group, chapter: @second_chapter
      @deleted_group = create :group, deleted_at: Time.zone.now, chapter: @first_chapter
    end

    describe 'exclude_deleted' do
      it 'returns only non-deleted groups' do
        expect(Group.exclude_deleted.length).to eq Group.where(deleted_at: nil).length
        expect(Group.exclude_deleted).to include @first_group, @second_group
        expect(Group.exclude_deleted).not_to include @deleted_group
      end

      it 'returns only groups belonging to a specific chapter' do
        expect(Group.by_chapter(@first_chapter.id).length).to eq 2
        expect(Group.by_chapter(@first_chapter.id)).to include @first_group, @deleted_group
        expect(Group.by_chapter(@first_chapter.id)).not_to include @second_group
      end
    end
  end

  describe 'methods' do
    describe 'delete_group_and_dependents' do
      before :each do
        @group_to_delete = create :group

        @lessons_to_delete = create_list :lesson, 2, group: @group_to_delete
        @grades_to_delete = create_list :grade, 2, lesson: @lessons_to_delete.first
        @deleted_lesson = create :lesson, group: @group_to_delete, deleted_at: Time.zone.now

        @group_to_delete.delete_group_and_dependents
        @group_to_delete.reload
      end

      it 'marks the group as deleted' do
        expect(@group_to_delete.deleted_at).to be_within(1.second).of Time.zone.now
      end

      it 'marks the group\'s dependents as deleted' do
        @lessons_to_delete.each { |lesson| expect(lesson.reload.deleted_at).to eq(@group_to_delete.deleted_at) }
        @grades_to_delete.each { |grade| expect(grade.reload.deleted_at).to eq(@group_to_delete.deleted_at) }
      end

      it 'does not mark previously deleted dependents of the group as deleted' do
        expect(@deleted_lesson.reload.deleted_at).to_not eq(@group_to_delete.deleted_at)
      end
    end

    describe 'restore_group_and_dependents' do
      before :each do
        @group_to_restore = create :group, deleted_at: Time.zone.now

        @lessons_to_restore = create_list :lesson, 2, group: @group_to_restore, deleted_at: @group_to_restore.deleted_at
        @grades_to_restore = create_list :grade, 2, lesson: @lessons_to_restore.first, deleted_at: @group_to_restore.deleted_at
        @deleted_lesson = create :lesson, group: @group_to_restore, deleted_at: Time.zone.now

        @group_to_restore.restore_group_and_dependents
        @group_to_restore.reload
      end

      it 'removes the group\'s deleted timestamp' do
        expect(@group_to_restore.deleted_at).to be_nil
      end

      it 'removes the group\'s dependents deleted timestamps' do
        @lessons_to_restore.each { |lesson| expect(lesson.reload.deleted_at).to be_nil }
        @grades_to_restore.each { |grade| expect(grade.reload.deleted_at).to be_nil }
      end

      it 'does not remove the previously deleted dependents of the group\'s deleted timestamp' do
        expect(@deleted_lesson.reload.deleted_at).to_not be_nil
      end
    end

    describe '#active_students' do
      before :each do
        @group = create :group
        @active_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
        @formerly_enrolled_student = create :student, organization: @group.chapter.organization
        create :enrollment, group: @group, student: @formerly_enrolled_student, active_since: 1.year.ago, inactive_since: 1.month.ago
        @not_yet_active_student = create :student, organization: @group.chapter.organization
        create :enrollment, group: @group, student: @not_yet_active_student, active_since: 1.month.from_now.to_date
        @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now
      end

      it 'returns only non-deleted students with an open enrollment that has already started' do
        expect(@group.active_students).to contain_exactly @active_student
      end
    end

    describe '#sync_tags_to_active_students' do
      before :each do
        @group = create :group
        @kept_tag = create :tag, organization: @group.chapter.organization
        @removed_tag = create :tag, organization: @group.chapter.organization
        @added_tag = create :tag, organization: @group.chapter.organization

        @active_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], tags: []
        @inactive_student = create :student, organization: @group.chapter.organization, tags: []
        create :enrollment, group: @group, student: @inactive_student, active_since: 1.year.ago, inactive_since: 1.month.ago

        create :student_tag, student: @active_student, tag: @kept_tag
        create :student_tag, student: @active_student, tag: @removed_tag
        create :student_tag, student: @inactive_student, tag: @removed_tag

        previous_tag_ids = [@kept_tag.id, @removed_tag.id]
        @group.tag_ids = [@kept_tag.id, @added_tag.id]
        @group.save!

        @group.sync_tags_to_active_students(previous_tag_ids)
      end

      it 'adds newly added group tags to active students' do
        expect(@active_student.reload.tags).to include @added_tag
      end

      it 'removes tags no longer on the group from active students' do
        expect(@active_student.reload.tags).not_to include @removed_tag
      end

      it 'leaves tags that remain on the group untouched' do
        expect(@active_student.reload.tags).to include @kept_tag
      end

      it 'does not affect students who are not currently active in the group' do
        expect(@inactive_student.reload.tags).to include @removed_tag
      end
    end

    describe '#students_with_grades_outside_enrollment' do
      before :each do
        @group = create :group
        @students = create_list :student, 5, organization: @group.chapter.organization
        create :enrollment, group: @group, student: @students[0], active_since: Time.zone.now
        create :enrollment, group: @group, student: @students[1], active_since: Time.zone.now
        create :enrollment, group: @group, student: @students[2], active_since: 1.week.ago, inactive_since: 2.days.ago
        create :enrollment, group: @group, student: @students[3], active_since: 1.week.ago, inactive_since: 2.days.ago
        create :enrollment, group: @group, student: @students[4], active_since: 1.day.ago

        @lesson = create :lesson, group: @group, date: 1.day.ago
        @students.each { |s| create :grade, student: s, lesson: @lesson }
      end

      it 'returns students who have grades outside their enrollment in the group' do
        result = @group.students_with_grades_outside_enrollment

        expect(result).to include @students[0], @students[1], @students[2], @students[3]
        expect(result).not_to include @students[4]
      end
    end
  end
end
