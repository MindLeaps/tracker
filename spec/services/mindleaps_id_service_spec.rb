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

  describe '#generate_chapter_mlid' do
    before :each do
      @org1 = create :organization
      @org2 = create :organization

      @existing_chapter_in_org1 = create :chapter, organization: @org1, mlid: 'A1'
    end

    it 'generates an MLID' do
      allow(SecureRandom).to receive(:alphanumeric).and_return('A1', 'B2')
      generated_new_chapter_mlid = MindleapsIdService.generate_chapter_mlid(@org2.id)
      expect(generated_new_chapter_mlid).to eq 'A1'
    end

    it 'generates a unique MLID within organization' do
      allow(SecureRandom).to receive(:alphanumeric).and_return('A1', 'B2')
      generated_new_chapter_mlid = MindleapsIdService.generate_chapter_mlid(@org1.id)
      expect(generated_new_chapter_mlid).to eq 'B2'
    end
  end

  describe '#generate_student_mlid' do
    before :each do
      @org1 = create :organization
    end
    it 'generates a unique 8 character MLID' do
      mlid = MindleapsIdService.generate_student_mlid(@org1.id)
      expect(mlid.length).to eq 8
    end
  end
end
