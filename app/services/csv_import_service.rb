# frozen_string_literal: true

class CsvImportService
  require 'csv'

  def import_students_from_file(file, group_id)
    file = File.open(file, &:read)
    csv = CSV.parse(file, headers: true, col_sep: ',')
    new_students = []

    csv.each do |row|
      student_hash = {}
      student_hash[:mlid] = row['MLID']
      student_hash[:first_name] = row['First Name']
      student_hash[:last_name] = row['Last Name']
      student_hash[:gender] = row['Gender']
      student_hash[:dob] = row['Date of Birth']
      student_hash[:group_id] = group_id
      student_hash[:estimated_dob] = false

      new_students << Student.find_or_create_by!(student_hash)
    end
    new_students
  end
end
