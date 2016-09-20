require 'rails_helper'

RSpec.describe StudentGradesController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#show' do
    before :each do
      group = create :group, group_name: 'Student Grades Spec Group'
      student = create :student, first_name: 'Graden', last_name: 'Gradanovic', group: group
      sub = create :subject, subject_name: 'Student Grades Testing'
      create :skill_in_subject, skill_name: 'Controller Test I', subject: sub
      create :skill_in_subject, skill_name: 'Controller Test II', subject: sub
      lesson = create :lesson, subject: sub, group: group

      get :show, params: { lesson_id: lesson.id, id: student.id }
    end

    it { should respond_with 200 }
    it { should render_template 'show' }
  end
end
