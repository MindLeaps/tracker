require 'rails_helper'
RSpec.describe GradePolicy do
  describe 'scope' do
    before :each do
      @org1, @org2 = create_list :organization, 2
      @group1 = create(:group, chapter: create(:chapter, organization: @org1))
      @group2 = create(:group, chapter: create(:chapter, organization: @org2))
      @student1 = create :graded_student, organization: @org1, groups: [@group1], grades: {
        'Memorization' => [1, 2, 3],
        'Grit' => [2, 1, 2],
        'Teamwork' => [3, 4, 4],
        'Discipline' => [2, 2, 2],
        'Self-Esteem' => [6, 5, 6],
        'Creativity & Self-Expression' => [5, 4],
        'Language' => [1, 1, 2]
      }
      @student2 = create :graded_student, organization: @org1, groups: [@group1], grades: {
        'Memorization' => [3, 3, 3],
        'Grit' => [3, 5, 6],
        'Teamwork' => [3, 4],
        'Discipline' => [2, 1, 2],
        'Self-Esteem' => [6, 7, 7],
        'Creativity & Self-Expression' => [2, 4],
        'Language' => [1, 2]
      }

      @student3 = create :graded_student, organization: @org2, groups: [@group2], grades: {
        'Memorization' => [1, 2, 3],
        'Grit' => [2, 1],
        'Teamwork' => [1, 2, 5],
        'Discipline' => [2, 3, 4],
        'Self-Esteem' => [1, 2, 1],
        'Creativity & Self-Expression' => [2, 3, 2],
        'Language' => [4, 5, 4]
      }
      @student4 = create :graded_student, organization: @org2, groups: [@group2], grades: {
        'Memorization' => [7, 7],
        'Grit' => [5, 4],
        'Teamwork' => [7],
        'Discipline' => [4, 5],
        'Self-Esteem' => [7, 7, 7],
        'Creativity & Self-Expression' => [5, 4, 5],
        'Language' => [4, 7, 6]
      }
    end

    RSpec.shared_examples :global_user_grade_scope do
      subject(:result) { GradePolicy::Scope.new(current_user, Grade).resolve }
      it 'returns all grades' do
        expect(result.length).to eq 38 + 36

        expect(result).to include(*@student1.grades)
        expect(result).to include(*@student2.grades)
        expect(result).to include(*@student3.grades)
        expect(result).to include(*@student4.grades)
      end
    end

    RSpec.shared_examples :local_user_in_first_org_grade_scope do
      subject(:result) { GradePolicy::Scope.new(current_user, Grade).resolve }
      it 'returns all grades' do
        expect(result.length).to eq 38

        expect(result).to include(*@student1.grades)
        expect(result).to include(*@student2.grades)
      end
    end

    RSpec.shared_examples :local_user_in_second_org_grade_scope do
      subject(:result) { GradePolicy::Scope.new(current_user, Grade).resolve }
      it 'returns all grades' do
        expect(result.length).to eq 36

        expect(result).to include(*@student3.grades)
        expect(result).to include(*@student4.grades)
      end
    end

    context 'As a Global role' do
      let(:current_user) { create :super_admin }
      it_behaves_like :global_user_grade_scope
    end

    context 'As a Local Role in first org' do
      let(:current_user) { create :admin_of, organization: @org1 }
      it_behaves_like :local_user_in_first_org_grade_scope
    end

    context 'As a Local Role in second org' do
      let(:current_user) { create :admin_of, organization: @org2 }
      it_behaves_like :local_user_in_second_org_grade_scope
    end

    context 'As a User with roles in multiple organizations' do
      let(:current_user) do
        u = create :admin_of, organization: @org1
        u.add_role :teacher, @org2
        u
      end

      it_behaves_like :global_user_grade_scope
    end
  end
end
