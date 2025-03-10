# frozen_string_literal: true

class CSVDeserializer < ActiveModel::Serializer
  require 'csv'

  def deserialize_students_from_file(file)
    file = File.read(file)
    csv = CSV.parse(file, headers: true, col_sep: ',')

    csv.map do |row|
      {
        mlid: row['MLID'],
        first_name: row['First Name'],
        last_name: row['Last Name'],
        gender: row['Gender'],
        dob: Date.parse(row['Date of Birth'])
      }
    end
  end
end
