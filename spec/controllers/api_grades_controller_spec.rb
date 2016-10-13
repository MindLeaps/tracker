# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradesController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  before :each do
    @group = create :group
    @student = create :student, group: @group

    @subject = create :subject
    @skill1 = create :skill, subject: @subject
    @skill2 = create :skill, subject: @subject

    @gd1_1 = create :grade_descriptor, mark: 1, skill: @skill1
    @gd1_2 = create :grade_descriptor, mark: 2, skill: @skill1
    @gd2_1 = create :grade_descriptor, mark: 1, skill: @skill2
    @gd2_2 = create :grade_descriptor, mark: 2, skill: @skill2

    @lesson = create :lesson, group: @group, subject: @subject
  end

  describe 'show' do
    before :each do
      @grade = create :grade
      get :show, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'responds with the requested grade' do
      expect(json['id']).to eq @grade.id
      expect(json['grade_descriptor_id']).to eq @grade.grade_descriptor_id
      expect(json['lesson_id']).to eq @grade.lesson_id
      expect(json['student_id']).to eq @grade.student_id
    end
  end

  describe 'create' do
    before :each do
      post :create, format: :json, params: { grade_descriptor_id: @gd1_1.id, lesson_id: @lesson.id, student_id: @student.id }
    end
    it 'creates a new grade' do
      g = Grade.last
      expect(g.grade_descriptor).to eq @gd1_1
      expect(g.lesson).to eq @lesson
      expect(g.student).to eq @student
    end

    it { should respond_with 201 }
  end
end
