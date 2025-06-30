require 'rails_helper'

RSpec.describe StudentsController, type: :controller do
  let(:organization) { create :organization }
  let(:chapter) { create :chapter, organization: organization }
  let(:group_a) { create :group, group_name: 'Group A', chapter: chapter }

  context 'logged in as a global administrator' do
    let(:signed_in_user) { create :global_admin }

    before :each do
      sign_in signed_in_user
    end

    describe '#create' do
      it 'creates a student when supplied valid params ensuring mlid is uppercase' do
        post :create, params: { student: {
          mlid: 'abcdefgh',
          first_name: 'Trevor',
          last_name: 'Noah',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
          organization_id: organization.id,
          enrollments_attributes: [{ group_id: group_a.id, 'active_since(1i)': '2024', 'active_since(2i)': '01', 'active_since(3i)': '01' }],
          gender: 'M',
          quartier: 'He lives somewhere...',
          estimated_dob: true
        } }

        student = Student.last
        expect(student.mlid).to eql 'ABCDEFGH'
        expect(student.first_name).to eql 'Trevor'
        expect(student.last_name).to eql 'Noah'
        expect(student.organization.id).to eql organization.id
        expect(student.groups[0].group_name).to eql 'Group A'
        expect(student.gender).to eql 'M'
        expect(student.quartier).to eql 'He lives somewhere...'
      end

      it 'creates a female student when supplied valid params' do
        post :create, params: { student: {
          mlid: '1F',
          first_name: 'Ami',
          last_name: 'Ayola',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => '17',
          organization_id: organization.id,
          gender: 'F',
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
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => '17',
          gender: 'F',
          organization_id: organization.id,
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
          organization_id: organization.id,
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
          organization_id: organization.id,
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
          organization_id: organization.id,
          notes: 'Prime is showing great promise despite the initial learning difficulties.'
        } }
        student = Student.last
        expect(student.first_name).to eql 'Prime'
        expect(student.last_name).to eql 'Noted'
        expect(student.notes).to eql 'Prime is showing great promise despite the initial learning difficulties.'
      end

      context 'redirects' do
        it 'redirects to student page if there is no redirect flash' do
          allow_any_instance_of(StudentsController).to receive(:flash).and_return(redirect: nil)
          post :create, params: { student: build(:student).as_json }
          expect(response).to redirect_to(student_path(Student.last.id))
        end

        it 'redirects to redirect flash if exists' do
          allow_any_instance_of(StudentsController).to receive(:flash).and_return(redirect: students_path)
          post :create, params: { student: build(:student).as_json }
          expect(response).to redirect_to(students_path)
          allow_any_instance_of(StudentsController).to receive(:flash).and_return(redirect: group_path(group_a))
          post :create, params: { student: build(:student).as_json }
          expect(response).to redirect_to(group_path(group_a))
        end
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
      end

      context 'search' do
        before :each do
          get :index, params: { search: @student1.first_name }
        end

        it { should respond_with 200 }
      end
    end

    describe '#new' do
      before :each do
        @group = create :group
        get :new, params: { group_id: @group.id }
      end

      it { should respond_with :ok }
      it { should render_template :new }
      it { should set_flash[:redirect] }

      it 'prepopulates the student with the correct group' do
        expect(assigns(:student).enrollments[0].group_id).to eq @group.id
        expect(assigns(:student).organization_id).to eq @group.chapter.organization.id
      end
    end

    describe '#edit' do
      let(:student) { create :student }
      before :each do
        get :edit, params: { id: student.id }
      end

      it { should respond_with :ok }
      it { should render_template :edit }
    end

    describe '#show' do
      before :each do
        @student = create :graded_student, grades: {
          'Memorization' => [1, 2, 3],
          'Grit' => [3, 5, 6]
        }
        get :show, params: { id: @student.id }
      end

      it { should respond_with 200 }

      it 'assigns the correct averages for each skill' do
        averages = assigns[:skill_averages].values[0]
        averages.sort_by { |a| a['skill'] }

        expect(averages[0][:skill]).to eq('Grit')
        expect(averages[0][:average]).to be_within(0.01).of 4.66
        expect(averages[1][:skill]).to eq('Memorization')
        expect(averages[1][:average]).to be_within(0.01).of 2.0
      end
    end

    describe '#performance' do
      before :each do
        @student = create :graded_student, grades: {
          'Memorization' => [1, 2, 3],
          'Grit' => [3, 5, 6]
        }
        get :show, params: { id: @student.id }
      end

      it { should respond_with 200 }

      it 'assigns the correct marks in skills by lesson' do
        lessons = assigns[:student_lessons_details_by_subject].values.first.sort_by(&:date)
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
        lessons = assigns[:student_lessons_details_by_subject].values.first.sort_by(&:date)
        expect(lessons.map { |l| l.average_mark.to_s }).to eq %w[2.0 3.5 4.5]
      end

      it 'assigns the subjects with the skills' do
        expect(assigns[:subjects].first.skills.map(&:skill_name)).to include 'Memorization', 'Grit'
        expect(assigns[:subjects].first.skills.length).to eq 2
      end
    end

    describe '#update' do
      before :each do
        @group = create :group
        @other_group = create :group, chapter: @group.chapter
        @student = create :student, organization: @group.chapter.organization
        @image = create :student_image, student: @student
        @existing_enrollment = create :enrollment, student: @student, group: @other_group
      end

      context 'redirects after successful update' do
        it 'redirects to student path if there is no redirect flash' do
          allow_any_instance_of(StudentsController).to receive(:flash).and_return(redirect: nil)
          post :update, params: { id: @student.id, student: { first_name: 'updated' } }
          expect(response).to redirect_to(student_path(@student))
        end

        it 'redirects to the path in flash[:redirect]' do
          allow_any_instance_of(StudentsController).to receive(:flash).and_return(redirect: students_path)
          post :update, params: { id: @student.id, student: { first_name: 'updated' } }
          expect(response).to redirect_to(students_path)
        end
      end

      it 'updates the student\'s profile image' do
        post :update, params: { id: @student.id, student: { profile_image_id: @image.id } }

        expect(@student.reload.profile_image).to eq @image
      end

      it 'updates the student\'s tags' do
        tag1 = create :tag, organization: @student.organization
        tag2 = create :tag, organization: @student.organization

        post :update, params: { id: @student.id, student: { tag_ids: [tag1.id, tag2.id, @student.tags[0].id] } }

        expect(@student.reload.tags.map(&:tag_name)).to include(tag1.tag_name, tag2.tag_name, @student.tags[0].tag_name)
        expect(@student.reload.tags).to include tag1, tag2
      end

      it 'updates the student\'s enrollments' do
        post :update, params: { id: @student.id, student: { enrollments_attributes:
          { '0' => { id: @existing_enrollment.id, _destroy: '1' },
            '1' => { group_id: @group.id, active_since: 1.day.ago.to_date, _destroy: '0' } } } }

        expect(@student.reload.enrollments).not_to include @existing_enrollment
        expect(@student.reload.enrollments.first.group_id).to eq @group.id
        expect(@student.reload.enrollments.first.active_since).to eq 1.day.ago.to_date
      end

      it 'returns the new student template when a group is added' do
        new_student = create :student

        post :update, params: { id: new_student.id, student: { first_name: 'Added Group' }, add_group: 'Add+Group' }

        expect(response).to be_successful
        expect(response).to render_template('new')
      end
    end

    describe '#destroy' do
      before :each do
        @student = create :student

        post :destroy, params: { id: @student.id }
      end

      it { should redirect_to student_path(@student) }
      it { should set_flash[:success_notice] }

      it 'Marks the student as deleted' do
        expect(@student.reload.deleted_at).not_to be_nil
      end
    end

    describe '#undelete' do
      before :each do
        @student = create :student, deleted_at: Time.zone.now
        post :undelete, params: { id: @student.id }
      end

      it { should set_flash[:success_notice] }

      it 'Marks the student as not deleted' do
        expect(@student.reload.deleted_at).to be_nil
      end
    end
  end
end
