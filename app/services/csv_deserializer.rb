class CsvDeserializer
  require 'csv'

  def initialize(file)
    @file = file
  end

  def deserialize_students
    csv = CSV.parse(File.read(@file), headers: true, col_sep: ',').delete_if { |row| row.to_hash.values.all?(&:blank?) }
    csv.map do |row|
      {
        mlid: row['MLID'],
        first_name: row['First Name'],
        last_name: row['Last Name'],
        gender: row['Gender'],
        dob: safe_parse_date(row['Date of Birth'])
      }
    end
  end

  def safe_parse_date(date_text)
    Date.parse(date_text)
  rescue Date::Error
    if date_text.include?('/')
      date_parts = date_text.split('/')
      Date.new(date_parts.last.to_i, date_parts.first.to_i, date_parts.second.to_i)
    elsif date_text.include?('-')
      date_parts = date_text.split('-')
      Date.new(date_parts.last.to_i, date_parts.second.to_i, date_parts.first.to_i)
    else
      Time.zone.today
    end
  end
end
