# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StudentImage, type: :model do
  describe 'validations' do
    it { should validate_presence_of :filename }
  end

  describe 'relations' do
    it { should belong_to :student }
  end
end
