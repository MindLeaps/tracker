require 'rails_helper'

RSpec.describe Api::GradeDescriptorsController, type: :controller do
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :grade_descriptor, 3

      get :index, format: :json
    end

    it { should respond_with 200 }

    it 'should return grade descriptors ordered by their marks' do
      marks = response.parsed_body[:grade_descriptors].pluck(:mark)

      expect(marks).to eq(marks.sort)
    end
  end

  describe '#show' do
    before :each do
      @gd = create :grade_descriptor

      get :show, format: :json, params: { id: @gd.id }
    end

    it { should respond_with 200 }
  end
end
