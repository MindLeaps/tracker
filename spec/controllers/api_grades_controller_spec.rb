# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Api::GradesController, type: :controller do
  let(:json) { JSON.parse(response.body) }

  before :each do
    @grade = create :grade
  end

  describe 'show' do
    before :each do
      get :show, format: :json, params: { id: @grade.id }
    end

    it { should respond_with 200 }
    it 'responds with the requested grade' do
      expect(json['id']).to eq @grade.id
      expect(json['grade_descriptor_id']).to eq @grade.grade_descriptor_id
      expect(json['lesson_id']).to eq @grade.lesson_id
      expect(json['student_id']).to eq @grade.student_id
    end
  end
end
