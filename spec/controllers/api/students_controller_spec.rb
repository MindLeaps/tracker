require 'rails_helper'

RSpec.describe Api::StudentsController, type: :controller do
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      @group = create :group
      create_list :enrolled_student, 3, organization: @group.chapter.organization, groups: [@group]
      get :index, format: :json
    end

    it { should respond_with 200 }
  end

  describe '#show' do
    before :each do
      @group = create :group
      @student = create :enrolled_student, organization: @group.chapter.organization, groups: [@group]
      get :show, format: :json, params: { id: @student.id }
    end

    it { should respond_with 200 }
  end
end
