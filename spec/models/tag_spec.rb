# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'relationships' do
    it { should have_many :student_tags }
    it { should have_many :students }
    it { should belong_to :organization }
  end

  describe 'validations' do
    it { should validate_presence_of :tag_name }
    it { should validate_presence_of :organization }
  end
end
