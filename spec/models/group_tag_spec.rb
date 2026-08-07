require 'rails_helper'

RSpec.describe GroupTag, type: :model do
  describe 'relationships' do
    it { should belong_to :group }
    it { should belong_to :tag }
  end
end
