# frozen_string_literal: true
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
    it { is_expected.to validate_presence_of :organization }
  end
end
