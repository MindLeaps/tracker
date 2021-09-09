# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  describe 'relationships' do
    it { should belong_to :group }
    it { should belong_to :student }
  end
end
