require 'rails_helper'

RSpec.describe Student, type: :model do
  let(:organization) { create :organization }

  describe 'is valid' do
    it 'with first and last name, dob, and gender' do
      student = Student.new first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 0, organization: organization
      expect(student).to be_valid
      expect(student.save).to eq true
    end
  end

  describe 'is not valid' do
    it 'without first name' do
      student = Student.new last_name: 'Last', dob: 10.years.ago, gender: 0, organization: organization
      expect(student).to_not be_valid
    end

    it 'without last name' do
      student = Student.new first_name: 'First', dob: 10.years.ago, gender: 0, organization: organization
      expect(student).to_not be_valid
    end

    it 'without DOB' do
      student = Student.new first_name: 'First', last_name: 'Last', gender: 0, organization: organization
      expect(student).to_not be_valid
    end

    it 'without an organization' do
      student = Student.new first_name: 'First', last_name: 'Last', dob: 10.years.ago, gender: 0
      expect(student).to_not be_valid
    end
  end
end