# frozen_string_literal: true
require 'rails_helper'

RSpec.describe StudentImage, type: :model do
  describe 'relations' do
    it { should belong_to :student }
  end
end
