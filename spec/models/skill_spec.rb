require 'rails_helper'

RSpec.describe Skill, type: :model do
  describe 'validations' do
    it { should belong_to :organization }
    it { should validate_presence_of :skill_name }
    it { should validate_presence_of :organization }
  end
end
