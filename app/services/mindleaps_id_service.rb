# frozen_string_literal: true

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

    def generate_mlid(mlid_length)
      SecureRandom.alphanumeric(mlid_length).upcase
    end
  end
end
