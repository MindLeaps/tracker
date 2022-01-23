# frozen_string_literal: true

# == Schema Information
#
# Table name: subjects
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  subject_name    :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer          not null
#
# Indexes
#
#  index_subjects_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  subjects_organization_id_fk  (organization_id => organizations.id)
#
require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to :organization }
    it { is_expected.to have_many :lessons }
    it { is_expected.to have_many(:assignments).dependent :destroy }
    it { is_expected.to have_many(:skills).through :assignments }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :subject_name }
  end

  describe 'scopes' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @subject1 = create :subject, organization: @org1
      @subject2 = create :subject, organization: @org1
      @subject3 = create :subject, organization: @org2
    end

    describe 'by_organization' do
      it 'returns subjects scoped by organization' do
        expect(Subject.by_organization(@org1.id).length).to eq 2
        expect(Subject.by_organization(@org1.id)).to include @subject1, @subject2
      end
    end
  end
end
