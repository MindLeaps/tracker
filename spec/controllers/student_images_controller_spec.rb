# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StudentImagesController, type: :controller do
  context 'as a global administrator' do
    let(:user) { create :admin }

    before :each do
      sign_in user
    end

    describe '#index' do
      before :each do
        @student = create :student
        @image1 = create :student_image, student: @student
        @image2 = create :student_image, student: @student

        @student2 = create :student
        @image3 = create :student_image, student: @student2

        get :index, params: { student_id: @student.id }
      end

      it { should route(:get, "/students/#{@student.id}/student_images").to action: :index, student_id: @student.id }
      it { should respond_with 200 }
      it { should render_template 'student_images/index' }

      it 'assigns the current student' do
        expect(assigns(:student)).to eq @student
      end

      it 'student contains its own images' do
        expect(assigns(:student).student_images).to include @image1, @image2
      end

      it 'student does not contain images of other students' do
        expect(assigns(:student).student_images).not_to include @image3
      end

      it 'assigns a new empty image' do
        expect(assigns(:new_image)).to be_instance_of StudentImage
      end
    end

    describe '#create' do
      context 'submits a single image successfully' do
        before :each do
          @student = create :student

          post :create, params: { student_id: @student.id, student_image: { filename: [test_image] } }
        end

        it { should route(:post, "students/#{@student.id}/student_images").to action: :create, student_id: @student.id }
        it { should redirect_to student_student_images_url }
        it { should set_flash[:notice].to 'Images successfully uploaded.' }
        it 'saves a new image' do
          expect(StudentImage.where(student_id: @student.id).length).to eq 1
        end
      end

      context 'submits no image' do
        before :each do
          @student = create :student

          post :create, params: { student_id: @student.id }
        end

        it { should respond_with :bad_request }
        it { should render_template 'student_images/index' }
        it { should set_flash[:alert].to 'No image submitted.' }
      end
    end
  end
end
