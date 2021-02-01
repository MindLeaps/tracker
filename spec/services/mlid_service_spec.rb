# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MindleapsIdService do
  describe '#generate_organization_mlid' do
    before :each do
      @existing_organization = create :organization, mlid: 'ASD'
    end

    it 'generates a unique MLID' do
      allow(SecureRandom).to receive(:alphanumeric).and_return('ASD', 'BSD')
      generated_new_organization_mlid = MindleapsIdService.generate_organization_mlid
      expect(generated_new_organization_mlid).to eq 'BSD'
    end
  end
end
