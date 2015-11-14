require 'test_helper'

class StudentsControllerTest < ActionController::TestCase
  test "should create a student when supplied valid params" do
    post :create, student: {
      first_name: 'Trevor',
      last_name: 'Noah',
      "dob(1i)" => "2015", "dob(2i)" => "11", "dob(3i)" => 17}
    assert_redirected_to :new_student

    student = Student.last
    assert_equal student.first_name, 'Trevor'
    assert_equal student.last_name, 'Noah'
  end

  test "new should have a list of students" do
    get :new
    assert_response :success

    assert_includes assigns(:students), students(:tomislav)
  end
end
