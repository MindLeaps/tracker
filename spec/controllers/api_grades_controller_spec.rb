# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradesController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:grade) { json['grade'] }
  let(:grades) { json['grades'] }
  let(:admin) { create :admin }

  before :each do
    sign_in admin
    @group = create :group
    @student = create :student, group: @group

    @subject = create :subject
    @skill1 = create :skill, subject: @subject
    @skill2 = create :skill, subject: @subject

    @gd1 = create :grade_descriptor, mark: 1, skill: @skill1
    @gd2 = create :grade_descriptor, mark: 2, skill: @skill1
    @gd3 = create :grade_descriptor, mark: 1, skill: @skill2
    @gd4 = create :grade_descriptor, mark: 2, skill: @skill2

    @lesson = create :lesson, group: @group, subject: @subject
  end

  describe '#index' do
    before :each do
      @lesson1 = create :lesson
      @lesson2 = create :lesson

      @deleted_student = create :student, group: @group, deleted_at: Time.zone.now

      @grade1 = create :grade, student: @student, lesson: @lesson1, created_at: 3.months.ago, updated_at: 3.months.ago
      @grade2 = create :grade, student: @student, lesson: @lesson1, created_at: 3.months.ago, updated_at: 3.months.ago
      @grade3 = create :grade, lesson: @lesson2
      @grade4 = create :grade, lesson: @lesson2
      @grade5 = create :grade, lesson: @lesson2, deleted_at: Time.zone.now
      @grade6 = create :grade, student: @deleted_student, lesson: @lesson1
      @grade7 = create :grade, student: @deleted_student, lesson: @lesson2

      get :index, format: :json
    end

    it 'lists all grades excluding the grades of deleted students' do
      expect(grades.length).to eq 5
      expect(grades.map { |g| g['id'] }).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id, @grade5.id
    end

    it 'lists all grades including the grades of deleted students' do
      get :index, format: :json, params: { include_deleted_students: true }

      expect(grades.length).to eq 7
      expect(grades.map { |g| g['id'] }).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id, @grade5.id, @grade6.id, @grade7.id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    it 'lists only grades scoped by student' do
      get :index, format: :json, params: { student_id: @student.id }

      expect(grades.length).to eq 2
      expect(grades.map { |g| g['id'] }).to include @grade1.id, @grade2.id
    end

    it 'lists only grades scoped by lesson' do
      get :index, format: :json, params: { lesson_id: @lesson2.id }

      expect(grades.length).to eq 3
      expect(grades.map { |g| g['id'] }).to include @grade3.id, @grade4.id, @grade5.id
    end

    it 'lists only grades created or updated after a certain time' do
      create :grade, created_at: 3.months.ago, updated_at: 3.months.ago
      create :grade, created_at: 2.months.ago, updated_at: 2.months.ago
      create :grade, created_at: 4.months.ago, updated_at: 3.months.ago

      get :index, format: :json, params: { after_timestamp: 1.day.ago }

      expect(grades.length).to eq 3
    end

    it 'excludes deleted grades' do
      get :index, format: :json, params: { exclude_deleted: true }

      expect(grades.length).to eq 4
      expect(grades.map { |g| g['id'] }).to include @grade1.id, @grade2.id, @grade3.id, @grade4.id
    end
  end

  describe 'show' do
    before :each do
      @gd = create :grade_descriptor
      @student = create :student
      @lesson = create :lesson
      @grade = create :grade, lesson: @lesson, student: @student, grade_descriptor: @gd
      get :show, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'responds with the requested grade' do
      expect(grade['id']).to eq @grade.id
      expect(grade['grade_descriptor_id']).to eq @grade.grade_descriptor_id
      expect(grade['lesson_id']).to eq @grade.lesson_id
      expect(grade['student_id']).to eq @grade.student_id
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
    end

    describe 'include' do
      it 'includes a lesson in the response' do
        get :show, format: :json, params: { id: @grade.id, include: 'lesson' }

        expect(grade['lesson']['id']).to eq @lesson.id
        expect(grade['lesson']['subject_id']).to eq @lesson.subject_id
        expect(grade['lesson']['group_id']).to eq @lesson.group_id
      end

      it 'includes a student in the response' do
        get :show, format: :json, params: { id: @grade.id, include: 'student' }

        expect(grade['student']['id']).to eq @student.id
        expect(grade['student']['first_name']).to eq @student.first_name
        expect(grade['student']['last_name']).to eq @student.last_name
      end

      it 'includes a grade descriptor in the response' do
        get :show, format: :json, params: { id: @grade.id, include: 'grade_descriptor' }

        expect(grade['grade_descriptor']['id']).to eq @gd.id
        expect(grade['grade_descriptor']['mark']).to eq @gd.mark
      end
    end
  end

  describe 'create' do
    before :each do
      post :create, format: :json, params: { grade_descriptor_id: @gd1.id, lesson_id: @lesson.id, student_id: @student.id }
    end
    it { should respond_with 201 }

    it 'creates a new grade' do
      g = Grade.last
      expect(g.grade_descriptor).to eq @gd1
      expect(g.lesson).to eq @lesson
      expect(g.student).to eq @student
    end

    it 'responds with timestamp' do
      expect(Time.zone.parse(json['meta']['timestamp'])).to be_within(1.second).of Time.zone.now
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
    end

    it 'updates the grade\'s grade descriptor' do
      patch :update, format: :json, params: { id: @grade.id, grade_descriptor_id: @gd2.id }

      expect(@grade.reload.grade_descriptor).to eq @gd2
    end
  end

  describe '#destroy' do
    before :each do
      @grade = create :grade
      delete :destroy, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'marks the grade as deleted' do
      expect(@grade.reload.deleted_at.nil?).to be false
    end
  end
end
