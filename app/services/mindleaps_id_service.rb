class MindleapsIdService
  class << self
    def generate_organization_mlid
      generated_mlid = nil
      loop do
        generated_mlid = generate_mlid(3)
        mlid_exists = Organization.exists?(mlid: generated_mlid)
        break unless mlid_exists
      end
      generated_mlid
    end

    def generate_chapter_mlid(organization_id)
      generated_mlid = nil
      loop do
        generated_mlid = generate_mlid(2)
        mlid_exists = Chapter.exists?(organization_id:, mlid: generated_mlid)
        break unless mlid_exists
      end
      generated_mlid
    end

    def generate_mlid(mlid_length)
      SecureRandom.alphanumeric(mlid_length).upcase
    end

    def generate_student_mlid(organization_id)
      conn = ActiveRecord::Base.connection.raw_connection
      sql = <<~SQL.squish
        select mlid from random_student_mlids(#{organization_id}, 8, 1);
      SQL
      conn.exec(sql).values[0][0]
    end
  end
end
