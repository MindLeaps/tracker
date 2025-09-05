class CsvService
  class << self
    require 'csv'

    def deserialize_students(file)
      content = File.open(file, encoding: 'UTF-8', &:read)
      content.sub!("\xEF\xBB\xBF", '')
      csv = CSV.parse(content, headers: true, col_sep: ',').delete_if { |row| row.to_hash.values.all?(&:blank?) }
      csv.map do |row|
        {
          first_name: row['First Name'],
          last_name: row['Last Name'],
          gender: row['Gender'],
          dob: safe_parse_date(row['Date of Birth'])
        }
      end
    end

    def safe_parse_date(date_text)
      date_text.present? ? Date.parse(date_text) : Time.zone.today
    rescue Date::Error
      Time.zone.today
    end
  end
end
