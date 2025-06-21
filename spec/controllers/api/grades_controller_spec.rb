require 'rails_helper'

RSpec.describe Api::GradesController, type: :controller do
  let(:grade) { json['grade'] }
  let(:grades) { json['grades'] }
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :grade, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
    it 'should match grades json schema' do
      expect(response).to match_json_schema('grades/index')
    end
  end

  describe 'show' do
    before :each do
      @grade = create :grade
      get :show, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'should match grade json schema' do
      expect(response).to match_json_schema('grades/show')
    end
  end

  describe 'create' do
    before :each do
      @org = create :organization
      @group = create :group, chapter: create(:chapter, organization: @org)
      @student = create :student, organization: @org

      @subject = create :subject
      @skill = create :skill, subject: @subject

      @gd1 = create :grade_descriptor, mark: 1, skill: @skill
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill
      @lesson = create :lesson, group: @group, subject: @subject
    end

    context 'successfully creates a new grade' do
      before :each do
        post :create, format: :json, params: { grade_descriptor_id: @gd1.id, lesson_id: @lesson.id, student_id: @student.id }
      end

      it { should respond_with 201 }
      it 'saves the grade' do
        g = Grade.last
        expect(g.grade_descriptor_id).to eq @gd1.id
        expect(g.lesson_id).to eq @lesson.id
        expect(g.student_id).to eq @student.id
      end
    end

    context 'rejects invalid parameters' do
      before :each do
        post :create, format: :json, params: { lesson_id: @lesson.id, student_id: @student.id }
      end

      it { should respond_with 400 }
    end

    context 'successfully overwrites an already existing grade' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1

        post :create, format: :json, params: { grade_descriptor_id: @gd2.id, lesson_id: @lesson.id, student_id: @student.id }
      end

      it { should respond_with 200 }
      it 'updates the existing grade' do
        expect(@existing_grade.reload.grade_descriptor_id).to eq @gd2.id
      end
    end

    context 'does not update the existing grade if new grade params are not valid' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1

        post :create, format: :json, params: { lesson_id: @lesson.id, student_id: @student.id }
      end

      it { should respond_with 400 }
    end
  end

  describe 'put_v2' do
    before :each do
      @org = create :organization
      @group = create :group, chapter: create(:chapter, organization: @org)
      @student = create :student, organization: @org

      @subject = create :subject
      @skill = create :skill, subject: @subject

      @gd1 = create :grade_descriptor, mark: 1, skill: @skill
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill
      @lesson = create :lesson, group: @group, subject: @subject
    end

    context 'successfully creates a new grade' do
      before :each do
        put :put_v2, format: :json, params: { lesson_id: @lesson.reload.id, student_id: @student.id, mark: 1, skill_id: @skill.id }
      end

      it { should respond_with 201 }
    end
  end

  describe '#update' do
    before :each do
      @subject = create :subject
      @skill = create :skill, subject: @subject
      @lesson = create :lesson, subject: @subject
      @gd1 = create :grade_descriptor, mark: 1, skill: @skill
      @gd2 = create :grade_descriptor, mark: 2, skill: @skill

      @grade = create :grade, grade_descriptor: @gd1, lesson: @lesson
      patch :update, format: :json, params: { id: @grade.id, grade_descriptor_id: @gd2.id }
    end

    it { should respond_with 200 }
  end

  describe '#destroy' do
    before :each do
      @grade = create :grade
      delete :destroy, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
  end
end
