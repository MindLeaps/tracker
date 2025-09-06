require 'rails_helper'

RSpec.describe CsvService do
  describe '#deserialize_students' do
    it 'deserializes a .csv file' do
      deserialized_students = CsvService.deserialize_students(File.open(file_fixture('students_to_import.csv')))

      expect(deserialized_students.size).to eq 2
      expect(deserialized_students[0][:first_name]).to eq 'Marko'
      expect(deserialized_students[0][:last_name]).to eq 'Markovikj'
      expect(deserialized_students[0][:gender]).to eq 'M'
      expect(deserialized_students[1][:first_name]).to eq 'Rick'
      expect(deserialized_students[1][:last_name]).to eq 'Sanchez'
      expect(deserialized_students[1][:gender]).to eq 'M'
    end
  end

  describe '#safe_parse_date' do
    it 'correctly parses dates' do
      first_date = CsvService.safe_parse_date('30/04/1999')
      second_date = CsvService.safe_parse_date('23.01.1943')
      incorrect_date = CsvService.safe_parse_date('100/100/100')

      expect(first_date).to eq(Date.new(1999, 4, 30))
      expect(second_date).to eq(Date.new(1943, 1, 23))
      expect(incorrect_date).to eq Time.zone.today
    end
  end
end
