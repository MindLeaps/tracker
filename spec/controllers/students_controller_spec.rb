require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  fixtures :students
  include_context 'controller_login'

  describe '#create' do
    it 'creates a student when supplied valid params' do
      post :create, params: { student: {
        first_name: 'Trevor',
        last_name: 'Noah',
        'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
        gender: 'M',
        quartier: 'He lives somewhere...',
        estimated_dob: true
      } }
      expect(response).to redirect_to student_path(assigns[:student])

      student = Student.last
      expect(student.first_name).to eql 'Trevor'
      expect(student.last_name).to eql 'Noah'
      expect(student.gender).to eql 'M'
      expect(student.quartier).to eql 'He lives somewhere...'
    end

    it 'creates a female student when supplied valid params' do
      post :create, params: { student: {
        first_name: 'Ami',
        last_name: 'Ayola',
        'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
        gender: 'F',
        estimated_dob: true
      } }
      student = Student.last
      expect(student.first_name).to eql 'Ami'
      expect(student.last_name).to eql 'Ayola'
      expect(student.gender).to eql 'F'
    end

    it 'creates a student with health information' do
      post :create, params: { student: {
        first_name: 'Healthy',
        last_name: 'Health',
        'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
        gender: 'F',
        estimated_dob: true,
        health_insurance: 'HEALTH123',
        health_issues: 'In perfect health',
        hiv_tested: true
      } }
      student = Student.last
      expect(student.first_name).to eql 'Healthy'
      expect(student.last_name).to eql 'Health'
      expect(student.health_insurance).to eql 'HEALTH123'
      expect(student.health_issues).to eql 'In perfect health'
      expect(student.hiv_tested).to eql true
    end

    it 'creates a student with school information' do
      post :create, params: { student: {
        first_name: 'Educated',
        last_name: 'Dropout',
        'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
        gender: 'F',
        name_of_school: 'Super School',
        school_level_completed: 'B2-1',
        year_of_dropout: 1995,
        reason_for_leaving: 'Financial situation'
      } }
      student = Student.last
      expect(student.first_name).to eql 'Educated'
      expect(student.last_name).to eql 'Dropout'
      expect(student.name_of_school).to eql 'Super School'
      expect(student.school_level_completed).to eql 'B2-1'
      expect(student.year_of_dropout).to eql 1995
      expect(student.reason_for_leaving).to eql 'Financial situation'
    end
  end

  describe '#index' do
    it 'gets a list of students' do
      get :index
      expect(response).to be_success

      expect(assigns(:students)).to include students(:tomislav)
    end
  end
end
