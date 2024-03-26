module Mlid
  extend ActiveSupport::Concern

  included do
    validates :mlid, presence: true
    validates :mlid, format: { with: /\A[A-Z0-9]+\Z/, message: I18n.t(:mlid_cannot_contain_special_characters) }

    def mlid=(new_mlid)
      super(new_mlid&.upcase)
    end
  end
end
