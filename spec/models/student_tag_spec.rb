# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StudentTag, type: :model do
  describe 'relationships' do
    it { should belong_to :student }
    it { should belong_to :tag }
  end

  describe 'validations' do
    it { should validate_presence_of :student }
    it { should validate_presence_of :tag }
  end
end
