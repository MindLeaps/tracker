require 'rails_helper'

RSpec.describe Api::EnrollmentsController, type: :controller do
  let(:enrollment) { json['enrollment'] }
  let(:enrollments) { json['enrollments'] }
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      create_list :enrollment, 3
      get :index, format: :json
    end

    it { should respond_with 200 }
    it 'should match enrollments json schema' do
      expect(response).to match_json_schema('enrollments/index')
    end
  end

  describe '#show' do
    before :each do
      @enrollment = create :enrollment
      get :show, format: :json, params: { id: @enrollment.id }
    end

    it { should respond_with 200 }
    it 'should match enrollment json schema' do
      expect(response).to match_json_schema('enrollments/enrollment')
    end
  end
end
