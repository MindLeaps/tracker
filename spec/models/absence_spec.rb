# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Absence, type: :model do
  describe 'relationships' do
    it { should belong_to :student }
    it { should belong_to :lesson }
  end

  describe 'validations' do
    subject { build :absence }

    it { should validate_uniqueness_of(:student).scoped_to :lesson_id }
  end
end
