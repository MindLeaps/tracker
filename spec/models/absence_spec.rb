# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Absence, type: :model do
  describe 'relationships' do
    it { should belong_to :student }
    it { should belong_to :lesson }
  end
end
