require 'rails_helper'

RSpec.describe StudentGroupsController, type: :controller do
  let(:group_a) { create :group, group_name: 'Group A' }

  context 'logged in as a global administrator' do
    let(:organization) { create :organization }
    let(:signed_in_user) { create :global_admin }
    before :each do
      sign_in signed_in_user
    end

    describe '#new' do
      it 'returns a student form to populate' do
        response = get :new, params: { group_id: group_a.id }

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
        post :create, params: { group_id: group_a.id, student: {
          mlid: '6I',
          first_name: 'Stoic',
          last_name: 'Henderson',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
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
        post :create, params: { group_id: group_a.id, student: {
          mlid: '12345',
          first_name: 'Stoic',
          last_name: 'Henderson',
          'dob(1i)' => '2015', 'dob(2i)' => '11', 'dob(3i)' => 17,
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
        post :update, params: { group_id: group_a.id, id: student.id, student: {
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
        post :create, params: { group_id: group_a.id, student: {
          first_name: ''
        } }

        student.reload
        expect(response).to_not be_successful
        expect(student.first_name).to eq 'Student'
      end
    end

    describe '#destroy' do
      it 'marks the student as deleted' do
        student = create :student, group: group_a
        response = post :destroy, params: { group_id: group_a.id, id: student.id }

        expect(response).to be_successful
        expect(student.reload.deleted_at).not_to be_nil
      end
    end

    describe '#cancel' do
      it 'returns a student successfully without updating' do
        student = create :student, group: group_a, first_name: 'Student'
        get :edit, params: { id: student.id, group_id: group_a.id }
        response = get :cancel, params: { id: student.id, group_id: group_a.id }

        expect(response).to be_successful
        expect(student.reload.first_name).to eq('Student')
      end
    end
  end
end
