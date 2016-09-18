require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'relationships' do
    it { should belong_to :organization }
    it { should have_many(:assignments).dependent :destroy }
    it { should have_many(:subjects).through :assignments }
  end

  describe 'validations' do
    it { should validate_presence_of :skill_name }
    it { should validate_presence_of :organization }
  end
end
