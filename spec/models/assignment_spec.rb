# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe 'relationships' do
    it { should belong_to :skill }
    it { should belong_to :subject }
  end

  describe 'validations' do
    it { should validate_presence_of :skill }
    it { should validate_presence_of :subject }
  end
end
