require 'rails_helper'

RSpec.describe GroupStudentsController, type: :controller do
  let(:group_a) { create :group, group_name: 'Group A' }

  context 'logged in as a global administrator' do
    let(:organization) { create :organization }
    let(:signed_in_user) { create :global_admin }
    before :each do
      sign_in signed_in_user
    end

    describe '#new' do
      it 'returns a student form to populate' do
        response = get :new, as: :turbo_stream, params: { group_id: group_a.id }

        expect(response).to be_successful
        expect(response).to render_template('new')
      end
    end

    describe '#edit' do
      it 'returns a student form to edit' do
        student = create :student, group: group_a
        response = get :edit, params: { id: student.id, group_id: group_a.id }

        expect(response).to be_successful
        expect(response).to render_template('edit')
      end
    end

    describe '#create' do
      it 'creates a student when passed valid params' do
        post :create, as: :turbo_stream, params: { group_id: group_a.id, student: {
          mlid: '6I',
          first_name: 'Stoic',
          last_name: 'Henderson',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => '17',
          gender: 'M',
          estimated_dob: true
        } }

        student = Student.last

        expect(response).to be_successful
        expect(student.first_name).to eql 'Stoic'
        expect(student.last_name).to eql 'Henderson'
        expect(student.gender).to eql 'M'
      end

      it 'does not create a student when passed invalid params' do
        post :create, as: :turbo_stream, params: { group_id: group_a.id, student: {
          mlid: '1234567890',
          first_name: 'Stoic',
          last_name: 'Henderson',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => '17',
          gender: 'M',
          estimated_dob: true
        } }

        student = Student.last

        expect(response).to_not be_successful
        expect(student).to be_nil
      end
    end

    describe '#update' do
      it 'updates a student when passed valid params' do
        student = create :student, group: group_a, first_name: 'Student', gender: 'M'
        post :update, as: :turbo_stream, params: { group_id: group_a.id, id: student.id, student: {
          first_name: 'Updated Student',
          gender: 'NB'
        } }

        student.reload
        expect(response).to be_successful
        expect(student.first_name).to eql 'Updated Student'
        expect(student.gender).to eql 'NB'
      end

      it 'does not update a student when passed invalid params' do
        student = create :student, group: group_a, first_name: 'Student', gender: 'M'
        post :create, as: :turbo_stream, params: { group_id: group_a.id, student: {
          first_name: ''
        } }

        student.reload
        expect(response).to_not be_successful
        expect(student.first_name).to eq 'Student'
      end
    end

    describe '#cancel' do
      it 'returns a student successfully without updating' do
        student = create :student, group: group_a, first_name: 'Student'
        get :edit, params: { id: student.id, group_id: group_a.id }
        response = get :cancel_edit, as: :turbo_stream, params: { id: student.id, group_id: group_a.id }

        expect(response).to be_successful
        expect(student.reload.first_name).to eq('Student')
      end
    end

    describe '#import' do
      it 'returns an import form' do
        response = get :import, as: :turbo_stream, params: { group_id: group_a.id }

        expect(response).to be_successful
        expect(response).to render_template('import')
      end
    end

    describe '#import_students' do
      it 'does not import students if file is not csv' do
        @file = fixture_file_upload('text_file.txt', 'text/plain')
        post :import_students, params: { group_id: group_a.id, file: @file }

        expect(group_a.students.count).to eq 0
      end

      it 'returns unsuccessfully if file contains invalid data' do
        @file = fixture_file_upload('invalid_import.csv', 'text/csv')
        response = post :import_students, as: :turbo_stream, params: { group_id: group_a.id, file: @file }

        expect(response).to_not be_successful
        expect(response).to render_template('import')
        expect(group_a.students.count).to eq 0
      end

      it 'imports students successfully if file is valid' do
        @file = fixture_file_upload('valid_import.csv', 'text/csv')
        response = post :import_students, params: { group_id: group_a.id, file: @file }

        expect(response).to redirect_to(group_path(group_a))
        expect(group_a.students.count).to eq 2
        expect(group_a.students.map(&:first_name)).to include 'Marko', 'Rick'
      end
    end
  end
end
