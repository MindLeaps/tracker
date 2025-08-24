require 'rails_helper'

RSpec.describe 'Grade API', type: :request do
  include_context 'super_admin_request'

  let(:grade) { json['grade'] }
  let(:grades) { json['grades'] }

  describe 'GET /grades/:id' do
    before :each do
      @group = create :group
      @gd = create :grade_descriptor
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @lesson = create :lesson, group: @group
      @grade = create :grade, lesson: @lesson, student: @student, grade_descriptor: @gd
    end

    it 'responds with a specific grade' do
      get_with_token api_grade_path(@grade), as: :json

      expect(grade['id']).to eq @grade.id
      expect(grade['grade_descriptor_id']).to eq @grade.grade_descriptor_id
      expect(grade['lesson_id']).to eq @grade.lesson_id
      expect(grade['student_id']).to eq @grade.student_id
    end

    it 'responds with timestamp' do
      get_with_token api_grade_path(@grade), as: :json

      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds with a specific grade including the lesson' do
      get_with_token api_grade_path(@grade), params: { include: 'lesson' }, as: :json

      expect(grade['lesson']['id']).to eq @lesson.id
      expect(grade['lesson']['subject_id']).to eq @lesson.subject_id
      expect(grade['lesson']['group_id']).to eq @lesson.group_id
    end

    it 'responds with a specific grade including the student' do
      get_with_token api_grade_path(@grade), params: { include: 'student' }, as: :json

      expect(grade['student']['id']).to eq @student.id
      expect(grade['student']['first_name']).to eq @student.first_name
      expect(grade['student']['last_name']).to eq @student.last_name
    end

    it 'responds with a specific grade including the grade descriptor' do
      get_with_token api_grade_path(@grade), params: { include: 'grade_descriptor' }, as: :json

      expect(grade['grade_descriptor']['id']).to eq @gd.id
      expect(grade['grade_descriptor']['mark']).to eq @gd.mark
      expect(grade['grade_descriptor']['grade_description']).to eq @gd.grade_description
    end
  end

  describe 'GET /grades' do
    before :each do
      @group = create :group
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      @deleted_student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], deleted_at: Time.zone.now
      @lesson1, @lesson2 = create_list :lesson, 2

      @grade1, @grade2 = create_list :grade, 2, student: @student, lesson: @lesson1, created_at: 3.months.ago, updated_at: 3.months.ago
      @grade3, @grade4 = create_list :grade, 2, lesson: @lesson2
      @grade5 = create :grade, lesson: @lesson2, deleted_at: Time.zone.now
      @grade6 = create :grade, student: @deleted_student, lesson: @lesson1
      @grade7 = create :grade, student: @deleted_student, lesson: @lesson2

      create_list :grade, 3, created_at: 5.months.ago, updated_at: 5.months.ago # we should ignore grades older than 4 months
    end

    it 'responds with a list of grades excluding the grades of deleted students' do
      get_with_token api_grades_path, as: :json

      expect(grades.length).to eq 5
      expect(grades.pluck('id')).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id, @grade5.id
    end

    it 'responds with a list of grades including the grades of deleted students' do
      get_with_token api_grades_path, as: :json, params: { include_deleted_students: true }

      expect(grades.length).to eq 7
      expect(grades.pluck('id')).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id, @grade5.id, @grade6.id, @grade7.id
    end

    it 'responds with a list of grades excluding the grades of deleted students and excluding deleted grades' do
      get_with_token api_grades_path, as: :json, params: { exclude_deleted: true }

      expect(grades.length).to eq 4
      expect(grades.pluck('id')).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id
    end

    it 'responds with timestamp' do
      get_with_token api_grades_path, as: :json
      expect(response_timestamp).to be_within(1.second).of Time.zone.now
    end

    it 'responds only with grades created or updated after a certain time' do
      create :grade, created_at: 3.months.ago, updated_at: 3.months.ago
      create :grade, created_at: 2.months.ago, updated_at: 2.months.ago
      create :grade, created_at: 4.months.ago, updated_at: 3.months.ago

      get_with_token api_grades_path, params: { after_timestamp: 1.day.ago }, as: :json

      expect(grades.length).to eq 3
    end

    it 'responds only with grades belonging to a specific student' do
      get_with_token api_grades_path, params: { student_id: @student.id }, as: :json

      expect(grades.length).to eq 2
      expect(grades.pluck('id')).to include @grade1.id, @grade2.id
    end

    it 'responds only with grades in a specific lesson' do
      get_with_token api_grades_path, params: { lesson_id: @lesson2.id }, as: :json

      expect(grades.length).to eq 3
      expect(grades.pluck('id')).to include @grade3.id, @grade4.id, @grade5.id
    end

    describe 'v2' do
      it 'responds with a list of grades excluding the grades of deleted students and with lesson_ids as UUIDs' do
        get_v2_with_token api_grades_path, as: :json

        expect(grades.length).to eq 5
        expect(response).to match_json_schema 'grades/index'
      end
    end
  end

  describe 'POST /grades' do
    before :each do
      @group = create :group
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]

      @subject = create :subject
      @skill1 = create :skill, subject: @subject
      @skill2 = create :skill, subject: @subject

      @gd1 = create :grade_descriptor, mark: 1, skill: @skill1
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill1
      @gd3 = create :grade_descriptor, mark: 1, skill: @skill2
      @gd4 = create :grade_descriptor, mark: 2, skill: @skill2

      @lesson = create :lesson, group: @group, subject: @subject
      @lesson2 = create :lesson, group: @group, subject: @subject
    end

    context 'submitting valid parameters for a new grade' do
      before :each do
        post_with_token api_grades_path, as: :json, params: { grade_descriptor_id: @gd1.id, lesson_id: @lesson.id, student_id: @student.id }
      end

      it 'creates a new grade' do
        g = Grade.last
        expect(g.grade_descriptor).to eq @gd1
        expect(g.lesson).to eq @lesson
        expect(g.student).to eq @student
      end

      it 'responds with a timestamp' do
        expect(response_timestamp).to be_within(1.second).of Time.zone.now
      end
    end

    context 'submitting parameters of an already existing grade' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1

        post_with_token api_grades_path, as: :json, params: { grade_descriptor_id: @gd2.id, lesson_id: @lesson.id, student_id: @student.id }
      end

      it 'overwrites an already existing grade' do
        expect(grade['id']).to eq @existing_grade.id
        expect(grade['grade_descriptor_id']).to eq @gd2.id
        expect(grade['student_id']).to eq @student.id
        expect(grade['lesson_id']).to eq @lesson.id
      end
    end

    context 'submitting parameters of an already existing deleted grade' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1, deleted_at: Time.zone.now

        post_with_token api_grades_path, as: :json, params: { grade_descriptor_id: @gd2.id, lesson_id: @lesson.id, student_id: @student.id }
      end

      it 'overwrites an already existing grade and undeletes it' do
        expect(grade['id']).to eq @existing_grade.id
        expect(grade['grade_descriptor_id']).to eq @gd2.id
        expect(grade['student_id']).to eq @student.id
        expect(grade['lesson_id']).to eq @lesson.id
        expect(grade['deleted_at']).to be_nil
      end
    end
  end

  describe 'PUT /grades' do
    before :each do
      @group = create :group
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]

      @subject = create :subject
      @skill1 = create :skill, subject: @subject
      @skill2 = create :skill, subject: @subject

      @gd1 = create :grade_descriptor, mark: 1, skill: @skill1
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill1
      @gd3 = create :grade_descriptor, mark: 1, skill: @skill2
      @gd4 = create :grade_descriptor, mark: 2, skill: @skill2

      @lesson = create :lesson, group: @group, subject: @subject
      @lesson2 = create :lesson, group: @group, subject: @subject
    end

    context 'submitting valid parameters for a new grade' do
      before :each do
        put_with_token api_grades_path, as: :json, params: { skill_id: @skill1.id, lesson_id: @lesson.reload.id, student_id: @student.id, mark: 1 }
      end

      it 'creates a new grade with correct lesson' do
        expect(response.status).to eq 201
        g = Grade.last
        expect(g.grade_descriptor).to eq @gd1
        expect(g.lesson).to eq @lesson
        expect(g.student).to eq @student
      end

      it 'responds with a grade' do
        expect(response).to match_json_schema 'grades/show'
      end
    end

    context 'submitting parameters of an already existing grade' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1

        put_with_token api_grades_path, as: :json, params: { lesson_id: @lesson.reload.id, student_id: @student.id, skill_id: @skill1.id, mark: 2 }
      end

      it 'overwrites an already existing grade' do
        expect(@existing_grade.reload.mark).to eq 2
        expect(@existing_grade.grade_descriptor).to eq @gd2
      end

      it 'responds with a grade' do
        expect(response).to match_json_schema 'grades/show'
      end
    end

    context 'submitting parameters of an already existing deleted grade' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1, deleted_at: Time.zone.now

        put_with_token api_grades_path, as: :json, params: { lesson_id: @lesson.reload.id, student_id: @student.id, skill_id: @skill1.id, mark: 2 }
      end

      it 'overwrites an already existing grade and undeletes it' do
        expect(@existing_grade.reload.mark).to eq 2
        expect(@existing_grade.grade_descriptor).to eq @gd2
        expect(@existing_grade.deleted_at).to be_nil
      end
    end
  end

  describe 'PATCH /grades/:id' do
    before :each do
      @subject = create :subject
      @skill = create :skill, subject: @subject
      @lesson = create :lesson, subject: @subject
      @gd1 = create :grade_descriptor, mark: 1, skill: @skill
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill

      @grade = create :grade, grade_descriptor: @gd1, lesson: @lesson
    end

    it 'updates the grade\'s grade descriptor' do
      patch_with_token api_grade_path(@grade), as: :json, params: { id: @grade.id, grade_descriptor_id: @gd2.id }

      expect(@grade.reload.grade_descriptor).to eq @gd2
    end

    it 'responds with the updated grade' do
      patch_with_token api_grade_path(@grade), as: :json, params: { id: @grade.id, grade_descriptor_id: @gd2.id }

      expect(grade['id']).to eq @grade.id
      expect(grade['grade_descriptor_id']).to eq @gd2.id
      expect(grade['student_id']).to eq @grade.student_id
      expect(grade['lesson_id']).to eq @lesson.id
    end
  end

  describe 'DELETE /grades/:id' do
    before :each do
      @grade = create :grade
    end

    it 'marks the grade as deleted' do
      delete_with_token api_grade_path(@grade), as: :json, params: { id: @grade.id }

      expect(@grade.reload.deleted_at.nil?).to be false
      expect(@grade.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end
  end

  describe 'DELETE /grades/student/:student_id/lesson/:lesson_id/skill/:skill_id' do
    before :each do
      @grade = create :grade
    end

    it 'marks the grade as deleted' do
      expect(@grade.reload.deleted_at).to be_nil
      delete_v2_with_token api_destroy_grade_v2_path(student_id: @grade.student_id, lesson_id: @grade.lesson_id, skill_id: @grade.skill_id), as: :json

      expect(@grade.reload.deleted_at.nil?).to be false
      expect(@grade.reload.deleted_at).to be_within(1.second).of Time.zone.now
    end
  end
end
