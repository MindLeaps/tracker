require 'rails_helper'

RSpec.describe Subject, type: :model do
  describe 'validations' do
    it { is_expected.to belong_to :organization }
    it { is_expected.to validate_presence_of :subject_name }
    it { is_expected.to validate_presence_of :organization }
  end
end
