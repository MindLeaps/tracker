# frozen_string_literal: true

class CsvImportService
  require 'csv'

  def import_students_from_file(file)
    file = File.open(file)
    csv = CSV.parse(file, headers: true, col_sep: ',')

    csv.each do |row|
      student_hash = {}
      student_hash[:mlid] = row['MLID']
      student_hash[:first_name] = row['Last Name']
      student_hash[:last_name] = row['Email Address']
      student_hash[:gender] = row['Gender']
      student_hash[:dob] = row['Date of Birth']

      Student.find_or_create_by!(user_hash)
    end
  end
end
