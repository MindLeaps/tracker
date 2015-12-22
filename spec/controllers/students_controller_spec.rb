require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  fixtures :students

  describe '#new' do
    it 'create a student when supplied valid params' do
      post :create, student: {
        first_name: 'Trevor',
        last_name: 'Noah',
        'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
        estimated_dob: true }
      expect(response).to be_success

      student = Student.last
      expect(student.first_name).to eql 'Trevor'
      expect(student.last_name).to eql 'Noah'
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
