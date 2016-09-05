require 'rails_helper'

RSpec.describe Chapter, type: :model do
  fixtures :organizations, :chapters

  let(:good_test_organization) { organizations(:good_test_organization) }
  let(:good_test_chapter) { chapters(:good_test_chapter) }

  describe 'is valid' do
    it 'with a valid, unique name' do
      chapter = Chapter.new chapter_name: 'Totally valid chapter'
      expect(chapter).to be_valid
      expect(chapter.chapter_name).to eql 'Totally valid chapter'
    end

    it 'with a duplicated name in different organization' do
      chapter = Chapter.new(
        chapter_name: good_test_chapter.chapter_name,
        organization_id: organizations(:mindleaps_organization).id
      )
      expect(chapter).to be_valid
      expect(chapter.chapter_name).to eql good_test_chapter.chapter_name
    end

    it 'with a valid, unique name, and an existing organization id' do
      chapter = Chapter.new chapter_name: 'Totally valid chapter', organization_id: good_test_organization.id
      expect(chapter).to be_valid
      expect(chapter.chapter_name).to eql 'Totally valid chapter'
      expect(chapter.organization.organization_name).to eql good_test_organization.organization_name
    end
  end

  describe 'is not valid' do
    it 'without chapter name' do
      chapter = Chapter.new chapter_name: nil
      expect(chapter).to_not be_valid
    end

    it 'with a nonexisting organization id' do
      chapter = Chapter.new chapter_name: 'Valid Name', organization_id: '1092837465'
      expect(chapter).to_not be_valid
    end

    it 'with a duplicated name in the same organization' do
      chapter = Chapter.new chapter_name: good_test_chapter.chapter_name, organization_id: good_test_organization.id
      expect(chapter).to_not be_valid
    end
  end
end
