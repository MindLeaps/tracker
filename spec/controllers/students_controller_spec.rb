require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  fixtures :students
  
  describe '#new' do
    it 'create a student when supplied valid params' do
      post :create, student: {
        first_name: 'Trevor',
        last_name: 'Noah',
        "dob(1i)" => "2015", "dob(2i)" => "11", "dob(3i)" => 17}
      assert_response :success

      student = Student.last
      assert_equal student.first_name, 'Trevor'
      assert_equal student.last_name, 'Noah'
    end
  end

  describe '#index' do
    it 'gets a list of students' do
      get :index
      assert_response :success

      assert_includes assigns(:students), students(:tomislav)
    end
  end
end
