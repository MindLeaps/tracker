require "rails_helper"

RSpec.describe CollectionHelper, type: :helper do
  describe "helps with collections" do
    before :each do
      @even_array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      @uneven_array = [1, 2, 3, 4, 5, 6, 7, 8, 9]

      create :group, group_name: 'A'
      create :group, group_name: 'B'
      create :group, group_name: 'C'
    end

    it "returns the middle element from an array" do
      expect(middle_from_array(@even_array)).to eq 5
      expect(middle_from_array(@uneven_array)).to eq 5
    end

    it "returns the middle element from a relation" do
      ordered_groups = Group.order(:group_name)

      expect(middle_from_rel(ordered_groups).group_name).to eq 'B'
    end
  end
end
