require 'rails_helper'

RSpec.describe 'Authorizations', js: true do
  describe 'Interacting with various resource creation' do
    context 'As a global super administrator' do
      include_context 'login_with_super_admin'

      it 'create buttons are visible' do
        visit '/students'
        expect(page).to have_link nil, href: '/students/new'

        visit '/groups'
        expect(page).to have_link nil, href: '/groups/new'

        visit '/chapters'
        expect(page).to have_link nil, href: '/chapters/new'

        visit '/organizations'
        expect(page).to have_link nil, href: '/organizations/new'

        visit '/lessons'
        expect(page).to have_link nil, href: '/lessons/new'

        visit '/subjects'
        expect(page).to have_link nil, href: '/subjects/new'

        visit '/skills'
        expect(page).to have_link nil, href: '/skills/new'

        visit '/users'
        expect(page).to have_link nil, href: '/users/new'
      end
    end

    context 'As a global guest' do
      include_context 'login_with_global_guest'

      it 'create buttons are not visible' do
        visit '/students'
        expect(page).not_to have_link nil, href: '/students/new'

        visit '/groups'
        expect(page).not_to have_link nil, href: '/groups/new'

        visit '/chapters'
        expect(page).not_to have_link nil, href: '/chapters/new'

        visit '/organizations'
        expect(page).not_to have_link nil, href: '/organizations/new'

        visit '/lessons'
        expect(page).not_to have_link nil, href: '/lessons/new'

        visit '/subjects'
        expect(page).not_to have_link nil, href: '/subjects/new'

        visit '/skills'
        expect(page).not_to have_link nil, href: '/skills/new'

        visit '/users'
        expect(page).not_to have_link nil, href: '/users/new'
      end
    end
  end
end
