require 'rails_helper'

RSpec.describe Analytics::StudentsController, type: :controller do
  let(:admin) { create :global_admin }

  before :each do
    sign_in admin
  end

  describe '#index' do
    before :each do
      @org = create :organization
      @chapter = create :chapter, organization: @org
      @group = create :group, chapter: @chapter
      @students = create_list :enrolled_student, 3, organization: @org, groups: [@group]

      get :index
    end

    it { should respond_with 200 }
    it { is_expected.to render_template('analytics/students/select') }

    it 'gets an empty list of student summaries when no groups are passed' do
      response = get :index, params: { group_ids: [] }
      expect(response).to be_successful

      expect(assigns(:students)).to be_empty
      expect(assigns(:disabled)).to be_truthy
    end

    it 'gets a list of student summaries when a group is passed' do
      response = get :index, params: { group_ids: [@group.id] }
      expect(response).to be_successful

      student_summaries = assigns(:students)

      expect(student_summaries).to all(be_a(StudentAnalyticsSummary))
      expect(student_summaries.map(&:id)).to contain_exactly(@students[0].id, @students[1].id, @students[2].id)
      expect(assigns(:disabled)).to be_falsey
    end

    it 'keeps selected student ids that are available for the selected groups' do
      foreign_student = create(:enrolled_student)

      response = get :index, params: { group_ids: [@group.id], student_ids: [@students[0].id, @students[1].id, foreign_student.id], multiple: true }
      expect(response).to be_successful

      expect(assigns(:selected_student_ids)).to contain_exactly(@students[0].id.to_s, @students[1].id.to_s)
      expect(assigns(:multiple)).to be true
    end
  end
end
