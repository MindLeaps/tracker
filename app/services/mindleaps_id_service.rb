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
  end
end
