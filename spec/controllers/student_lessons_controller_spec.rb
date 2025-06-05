require 'rails_helper'

RSpec.describe StudentLessonsController, type: :controller do
  let(:group_a) { create :group, group_name: 'Group A' }

  context 'logged in as a global administrator' do
    let(:organization) { create :organization }
    let(:signed_in_user) { create :global_admin }

    before :each do
      sign_in signed_in_user
    end

    describe 'grading' do
      before :each do
        @group = create :group, group_name: 'Student Grades Spec Group'
        @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group], first_name: 'Graden', last_name: 'Gradanovic'
        @subject = create :subject, subject_name: 'Student Grades Testing'
        @skill = create :skill_in_subject, skill_name: 'Controller Test I', subject: @subject
        @lesson = create(:lesson, subject: @subject, group: @group)
        @gd1 = create :grade_descriptor, mark: 1, grade_description: 'Mark One For Skill One', skill: @skill
        @gd2 = create :grade_descriptor, mark: 2, grade_description: 'Mark Two For Skill One', skill: @skill
      end

      describe '#show' do
        before :each do
          get :show, format: :turbo_stream, params: { id: @student.id, lesson_id: @lesson.id }
        end

        it { should respond_with 200 }
        it { should render_template :show }
      end

      describe '#grade' do
        before :each do
          post :update, params: { id: @student.id, lesson_id: @lesson.id, student_lesson: {
            grades_attributes: { '0' => { grade_descriptor_id: @gd1.id, skill_id: @gd1.skill_id } }
          } }
        end

        context 'successfully' do
          it { should redirect_to lesson_path(@lesson.id) }

          it 'Saves the new grade' do
            expect(@student.grades.length).to eq 1
            expect(@student.grades[0].grade_descriptor).to eq @gd1
          end

          it 'Updates the existing grade' do
            post :update, params: { id: @student.id, lesson_id: @lesson.id, student_lesson: {
              grades_attributes: { '0' => { grade_descriptor_id: @gd2.id, skill_id: @gd2.skill_id } }
            } }

            student = Student.find @student.id
            expect(student.grades.length).to eq 1
            expect(student.grades[0].grade_descriptor).to eq @gd2
          end

          it 'Updates the existing grade to be ungraded' do
            existing_grade_id = @student.grades[0].id

            post :update, params: { id: @student.id, lesson_id: @lesson.id, student_lesson: {
              grades_attributes: { '0' => { id: existing_grade_id, grade_descriptor_id: '' } }
            } }

            student = Student.find @student.id
            expect(student.grades.exclude_deleted.length).to eq 0
          end
        end
      end
    end
  end
end
