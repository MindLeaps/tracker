# == Schema Information
#
# Table name: tags
#
#  id              :uuid             not null, primary key
#  shared          :boolean          not null
#  tag_name        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_tags_on_organization_id  (organization_id)
#
require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'relationships' do
    it { should have_many :student_tags }
    it { should have_many :students }
    it { should belong_to :organization }
  end

  describe 'validations' do
    it { should validate_presence_of :tag_name }
    it 'when the same tag is created for an organization' do
      @org = create :organization
      create :tag, tag_name: 'Existing Tag', organization: @org
      new_tag = Tag.new tag_name: 'Existing Tag', organization_id: @org

      expect(new_tag).to_not be_valid
    end
  end
end
