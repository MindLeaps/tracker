# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  let(:group_a) { create :group, group_name: 'Group A' }

  context 'logged in as a global administrator' do
    let(:organization) { create :organization }
    let(:signed_in_user) { create :global_admin }
    before :each do
      sign_in signed_in_user
    end

    describe '#create' do
      it 'creates a student when supplied valid params' do
        post :create, params: { student: {
          mlid: '1M',
          first_name: 'Trevor',
          last_name: 'Noah',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          group_id: group_a.id,
          gender: 'M',
          quartier: 'He lives somewhere...',
          estimated_dob: true
        } }
        expect(response).to redirect_to details_student_path(assigns[:student])

        student = Student.last
        expect(student.first_name).to eql 'Trevor'
        expect(student.last_name).to eql 'Noah'
        expect(student.group.group_name).to eql 'Group A'
        expect(student.gender).to eql 'M'
        expect(student.quartier).to eql 'He lives somewhere...'
      end

      it 'creates a female student when supplied valid params' do
        post :create, params: { student: {
          mlid: '1F',
          first_name: 'Ami',
          last_name: 'Ayola',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          group_id: group_a.id,
          estimated_dob: true
        } }
        student = Student.last
        expect(student.first_name).to eql 'Ami'
        expect(student.last_name).to eql 'Ayola'
        expect(student.gender).to eql 'F'
      end

      it 'creates a student with guardian information' do
        post :create, params: { student: {
          mlid: '1G',
          first_name: 'Guardianed',
          last_name: 'Guard',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          group_id: group_a.id,
          guardian_name: 'Guardian Omonzu',
          guardian_occupation: 'Moto driver',
          guardian_contact: '123-123-123 or email@example.com',
          family_members: 'Brothers: Omonu and Umunzu'
        } }
        student = Student.last
        expect(student.first_name).to eql 'Guardianed'
        expect(student.last_name).to eql 'Guard'
        expect(student.guardian_name).to eql 'Guardian Omonzu'
        expect(student.guardian_occupation).to eql 'Moto driver'
        expect(student.guardian_contact).to eql '123-123-123 or email@example.com'
        expect(student.family_members).to eql 'Brothers: Omonu and Umunzu'
      end

      it 'creates a student with health information' do
        post :create, params: { student: {
          mlid: '1H',
          first_name: 'Healthy',
          last_name: 'Health',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          group_id: group_a.id,
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
          mlid: '1E',
          first_name: 'Educated',
          last_name: 'Dropout',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          group_id: group_a.id,
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

      it 'creates a student with notes' do
        post :create, params: { student: {
          mlid: '1P',
          first_name: 'Prime',
          last_name: 'Noted',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          gender: 'F',
          group_id: group_a.id,
          notes: 'Prime is showing great promise despite the initial learning difficulties.'
        } }
        student = Student.last
        expect(student.first_name).to eql 'Prime'
        expect(student.last_name).to eql 'Noted'
        expect(student.notes).to eql 'Prime is showing great promise despite the initial learning difficulties.'
      end
    end

    describe '#index' do
      before :each do
        @student1 = create :student
        @student2 = create :student
        @deleted_student = create :student, deleted_at: Time.zone.now
      end

      context 'regular visit' do
        before :each do
          get :index
        end

        it { should respond_with 200 }

        it 'gets a list of students' do
          expect(assigns(:component).students.map(&:id)).to include @student1.id, @student2.id
        end

        it 'does not display deleted students' do
          expect(assigns(:component).students.map(&:id)).not_to include @deleted_student.id
        end
      end

      context 'search' do
        before :each do
          get :index, params: { search: @student1.first_name }
        end

        it { should respond_with 200 }

        it 'responds with a listed of searched students' do
          expect(assigns(:component).students.length).to eq 1
          expect(assigns(:component).students[0].first_name).to eq @student1.first_name
        end
      end
    end

    describe '#new' do
      before :each do
        @group = create :group
        get :new, params: { group_id: @group.id }
      end

      it 'prepopulates the student with the correct group' do
        expect(assigns(:student).group.id).to eq @group.id
        expect(assigns(:student).group.group_name).to eq @group.group_name
      end
    end

    describe '#performance' do
      before :each do
        @student = create :graded_student, grades: {
          'Memorization' => [1, 2, 3],
          'Grit' => [3, 5, 6]
        }
        get :performance, params: { id: @student.id }
      end

      it { should respond_with 200 }

      it 'assigns the correct marks in skills by lesson' do
        lessons = assigns[:student_lessons_details_by_subject].values.first
        expect(lessons[0].skill_marks.values.map { |l| l.slice('skill_name', 'mark') }).to eq [
          { 'skill_name' => 'Memorization', 'mark' => 1 }, { 'skill_name' => 'Grit', 'mark' => 3 }
        ]
        expect(lessons[1].skill_marks.values.map { |l| l.slice('skill_name', 'mark') }).to eq [
          { 'skill_name' => 'Memorization', 'mark' => 2 }, { 'skill_name' => 'Grit', 'mark' => 5 }
        ]
        expect(lessons[2].skill_marks.values.map { |l| l.slice('skill_name', 'mark') }).to eq [
          { 'skill_name' => 'Memorization', 'mark' => 3 }, { 'skill_name' => 'Grit', 'mark' => 6 }
        ]
      end

      it 'calculates the correct average mark for each lesson' do
        lessons = assigns[:student_lessons_details_by_subject].values.first
        expect(lessons.map(&:average_mark)).to eq [2.0, 3.5, 4.5]
      end

      it 'assigns the subjects with the skills' do
        expect(assigns[:subjects].first.skills.map(&:skill_name)).to include 'Memorization', 'Grit'
        expect(assigns[:subjects].first.skills.length).to eq 2
      end

      context 'student has no grades' do
        before :each do
          @student = create :student

          get :performance, params: { id: @student.id }
        end

        it { should redirect_to action: :details }
      end
    end

    describe '#details' do
      before :each do
        @student = create :student, first_name: 'Studento', last_name: 'Detailso', mlid: 'Det-123'
        get :details, params: { id: @student.id }
      end

      it { should respond_with 200 }
    end

    describe '#update' do
      before :each do
        @student = create :student
        @image = create :student_image, student: @student
      end

      it 'updates the student\'s profile image' do
        post :update, params: { id: @student.id, student: { profile_image_id: @image.id } }

        expect(@student.reload.profile_image).to eq @image
      end

      it 'updates the student\'s tags' do
        tag1 = create :tag
        tag2 = create :tag

        post :update, params: { id: @student.id, student: { tag_ids: [tag1.id, tag2.id, @student.tags[0].id] } }

        expect(@student.reload.tags.map(&:tag_name)).to include(tag1.tag_name, tag2.tag_name, @student.tags[0].tag_name)
        expect(@student.reload.tags.length).to eq 3
      end
    end

    describe '#destroy' do
      before :each do
        @student = create :student

        post :destroy, params: { id: @student.id }
      end

      it { should redirect_to students_path }
      it { should set_flash[:undo_notice] }

      it 'Marks the student as deleted' do
        expect(@student.reload.deleted_at).not_to be_nil
      end
    end

    describe '#undelete' do
      before :each do
        @student = create :student, deleted_at: Time.zone.now
        request.env['HTTP_REFERER'] = 'http://example.com/students?param=1'

        post :undelete, params: { id: @student.id }
      end

      it { should redirect_to 'http://example.com/students?param=1' }

      it { should set_flash[:notice].to "Student \"#{@student.proper_name}\" restored." }

      it 'Marks the student as not deleted' do
        expect(@student.reload.deleted_at).to be_nil
      end
    end
  end
end
