require 'rails_helper'

RSpec.describe 'User updates profile preferences', type: :feature do
  it 'saves, changes and clears the working chapter through the profile dropdown' do
    organization = create :organization
    user = create(:teacher_in, organization:)
    chapter = create :chapter, organization:, chapter_name: 'Kampala Studio'
    other_chapter = create :chapter, organization:, chapter_name: 'Victory Church Gangu'

    login(user)
    click_link 'My profile'
    select chapter.chapter_name, from: 'Chapter'
    click_button 'Save preferences'

    expect(page).to have_content('Preferences saved')
    expect(page).to have_select('Chapter', selected: chapter.chapter_name)
    expect(user.reload.preferred_chapter).to eq chapter

    select other_chapter.chapter_name, from: 'Chapter'
    click_button 'Save preferences'

    expect(page).to have_select('Chapter', selected: other_chapter.chapter_name)
    expect(user.reload.preferred_chapter).to eq other_chapter

    select 'No chapter preference', from: 'Chapter'
    click_button 'Save preferences'

    expect(page).to have_select('Chapter', selected: 'No chapter preference')
    expect(user.reload.preferred_chapter).to be_nil
  end
end
