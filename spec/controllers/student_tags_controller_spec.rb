# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentTagsController, type: :controller do
  context 'logged in as a global administrator' do
    let(:organization) { create :organization }
    let(:signed_in_user) { create :global_admin }
    before :each do
      sign_in signed_in_user
    end

    describe '#index' do
      before :each do
        @tag1 = create :tag, organization: organization
        @tag2 = create :tag, organization: organization
      end

      context 'regular visit' do
        before :each do
          get :index
        end

        it { should respond_with 200 }

        it 'gets a list of student tags' do
          expect(assigns(:tags).length).to eq 2
          expect(assigns(:tags).map(&:id)).to include @tag1.id, @tag2.id
        end
      end
    end

    describe '#show' do
      before :each do
        @tag = create :tag
        @students_with_tag = create_list :student, 4, tags: [@tag]
        @students_without_tag = create_list :student, 2

        get :show, params: { id: @tag.id }
      end

      it { should respond_with 200 }

      it 'displays the requested tag' do
        expect(assigns(:tag)).to eq @tag
      end

      it 'assigns the associated students' do
        expect(assigns(:student_table_component).students.length).to eq @students_with_tag.length
        expect(assigns(:student_table_component).students.map(&:id)).to include(*@students_with_tag.map(&:id))
        expect(assigns(:student_table_component).students.map(&:id)).not_to include(*@students_without_tag.map(&:id))
      end

      it 'searches students with this tag' do
        get :show, params: { id: @tag.id, search: @students_with_tag[0].first_name }

        expect(assigns(:student_table_component).students.length).to eq 1
        expect(assigns(:student_table_component).students[0].id).to eq @students_with_tag[0].id
      end
    end

    describe '#new' do
      before :each do
        get :new
      end

      it { should respond_with 200 }
    end

    describe '#edit' do
      before :each do
        @tag = create :tag
        get :edit, params: { id: @tag.id }
      end

      it { should respond_with 200 }
    end

    describe '#update' do
      before :each do
        @tag = create :tag, tag_name: 'My Old Tag'
      end

      it 'updates the student\'s profile image' do
        post :update, params: { id: @tag.id, tag: {
          tag_name: 'My New Tag'
        } }

        expect(@tag.reload.tag_name).to eq 'My New Tag'
      end
    end

    describe '#create' do
      before :each do
        @org = create :organization
        post :create, params: { tag: {
          tag_name: 'My Test Tag',
          organization_id: @org.id,
          shared: true
        } }
      end

      it { should redirect_to student_tag_path Tag.last }

      it 'creates a new tag' do
        tag = Tag.last
        expect(tag.tag_name).to eq 'My Test Tag'
        expect(tag.organization_id).to eq @org.id
        expect(tag.shared).to eq true
      end
    end
  end
end
