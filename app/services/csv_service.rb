class CsvService
  class << self
    require 'csv'

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def deserialize_students(file)
      content = File.open(file, encoding: 'UTF-8', &:read)
      content.sub!("\xEF\xBB\xBF", '')
      csv = CSV.parse(content, headers: true, col_sep: ',').delete_if { |row| row.to_hash.values.all?(&:blank?) }
      csv.map do |row|
        {
          first_name: row['First Name'],
          last_name: row['Last Name'],
          gender: safe_parse_gender(row['Gender']),
          dob: safe_parse_date(row['Date of Birth']),
          country_of_nationality: row['Country of Nationality'],
          family_members: row['Family Members'],
          guardian_contact: row['Guardian Contact'],
          guardian_name: row['Guardian Name'],
          guardian_occupation: row['Guardian Occupation'],
          health_insurance: row['Health Insurance'],
          health_issues: row['Health Issues'],
          hiv_tested: safe_parse_bool?(row['Hiv Tested']),
          name_of_school: row['Name ofSchool'],
          notes: row['Notes'],
          reason_for_leaving: row['Reason for Leaving'],
          school_level_completed: row['School Level Completed'],
          year_of_dropout: safe_parse_integer(row['Year of Dropout'])
        }
      end
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def safe_parse_integer(value)
      Integer(value) if value
    rescue ArgumentError
      nil
    end

    def safe_parse_bool?(value)
      case value.to_s.downcase
      when 'true', 't', 'yes', 'y', '1', 'True'
        true
      else
        false
      end
    end

    def safe_parse_date(date_text)
      date_text.present? ? Date.parse(date_text) : Time.zone.today
    rescue Date::Error
      Time.zone.today
    end

    def safe_parse_gender(gender)
      return gender if %w[M F NB].include? gender

      case gender[0]
      when 'M'
        :M
      when 'F'
        :F
      else
        :NB
      end
    end
  end
end
