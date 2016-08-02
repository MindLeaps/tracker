require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  fixtures :students

  include_context 'controller_login'

  before(:each) do
    allow(controller).to receive(:current_user)
      .and_return(instance_double('User', name: 'User For Testing', uid: '000000000000'))
  end

  describe '#new' do
    it 'create a student when supplied valid params' do
      post :create, params: { student: {
        first_name: 'Trevor',
        last_name: 'Noah',
        'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
        estimated_dob: true
      } }
      expect(response).to redirect_to controller: :students, action: :index

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
