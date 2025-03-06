# frozen_string_literal: true

class CsvImportService
  require 'csv'

  def import_students_from_file(file, group)
    file = File.read(file)
    csv = CSV.parse(file, headers: true, col_sep: ';')

    csv.map do |row|
      Student.new(
        {
          mlid: row['MLID'],
          first_name: row['First Name'],
          last_name: row['Last Name'],
          gender: row['Gender'],
          dob: row['Date of Birth'],
          group: group,
          estimated_dob: false
        }
      )
    end
  end
end
