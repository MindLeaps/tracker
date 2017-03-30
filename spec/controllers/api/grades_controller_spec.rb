# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradesController, type: :controller do
  let(:grade) { json['grade'] }
  let(:grades) { json['grades'] }
  let(:admin) { create :admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :grade, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe 'show' do
    before :each do
      @grade = create :grade
      get :show, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
  end

  describe 'create' do
    before :each do
      @group = create :group
      @student = create :student, group: @group

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
    end

    context 'unsuccessful because of an already existing grade' do
      before :each do
        @existing_grade = create :grade, student: @student, lesson: @lesson, grade_descriptor: @gd1

        post :create, format: :json, params: { grade_descriptor_id: @gd2.id, lesson_id: @lesson.id, student_id: @student.id }
      end

      it { should respond_with 409 }
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
