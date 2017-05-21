# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentPolicy do
  describe 'scope' do
    subject(:result) { StudentPolicy::Scope.new(current_user, Student).resolve }

    context 'logged in as a super administrator' do
      let(:current_user) { create :super_admin }

      it 'includes all students' do
        org1 = create :organization
        org2 = create :organization
        student1 = create :student, organization: org1
        student2 = create :student, organization: org1
        student3 = create :student, organization: org2

        expect(result).to include student1, student2, student3
      end
    end

    context 'logged in as an admin of a specific organization' do
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:current_user) { create :admin_of, organization: org1 }

      before :each do
        @student1 = create :student, organization: org1
        @student2 = create :student, organization: org1
        @student3 = create :student, organization: org2
      end

      it 'includes students from the user\'s organization' do
        expect(result).to include @student1, @student2
      end

      it 'excludes students in other organizations' do
        expect(result).to_not include @student3
      end

      it 'excludes students in other organizations that have admin users' do
        create :admin_of, organization: org2

        expect(result).to_not include @student3
      end
    end
  end
end
