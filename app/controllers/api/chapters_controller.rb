# frozen_string_literal: true
module Api
  class ChaptersController < ApiController
    def index
      @chapters = Chapter.all
      respond_with @chapters, meta: { timestamp: Time.zone.now }
    end

    def show
      @chapter = Chapter.find params[:id]
      respond_with @chapter, meta: { timestamp: Time.zone.now }
    end
  end
end
