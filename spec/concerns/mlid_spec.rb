require 'rails_helper'

class MlidIncludeTestModel < ApplicationRecord
  self.table_name = 'organizations' # we need a table for this model, using organizations since it is simple and has MLID

  include Mlid
end

RSpec.describe Mlid do
  let(:test_instance) { MlidIncludeTestModel.new }

  describe 'mlid presence validation' do
    it 'invalid without set mlid' do
      expect(test_instance.valid?).to eq false
    end

    it 'valid with set mlid' do
      test_instance.mlid = 'A1'
      expect(test_instance.valid?).to eq true
    end

    it 'invalid with an MLID containing special characters' do
      test_instance.mlid = 'A?1'
      expect(test_instance.valid?).to eq false
      expect(test_instance.errors.messages_for(:mlid)).to include I18n.t(:mlid_cannot_contain_special_characters)
    end
  end

  describe '#mlid=' do
    it 'sets the mlid value with uppercase' do
      test_instance.mlid = 'aa'
      expect(test_instance.mlid).to eq 'AA'
    end

    it 'handles nil values' do
      test_instance.mlid = nil
      expect(test_instance.mlid).to be_nil
    end
  end
end
