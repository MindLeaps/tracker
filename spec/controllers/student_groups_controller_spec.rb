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
    end
  end
end
