require 'rails_helper'

RSpec.describe GroupsController, type: :controller do

  describe '#new' do
    it 'create a group when supplied valid params' do
      post :create, group: {
        group_name: 'Group A'}
      expect(response).to be_success

      group = Group.last
      expect(group.group_name).to eql 'Group A'
    end
  end
end
