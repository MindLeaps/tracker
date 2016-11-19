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
      it { should render_template 'student_images/index'}

      it 'assigns all of students images' do
        expect(assigns(:images)).to include @image1, @image2
      end

      it 'does not assign images of other students' do
        expect(assigns(:images)).not_to include @image3
      end
    end
  end
end
