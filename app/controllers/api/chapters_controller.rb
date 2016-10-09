# frozen_string_literal: true
module Api
  class ChaptersController < ApiController
    def index
      @chapters = Chapter.all
      respond_with @chapters, include: :groups
    end

    def show
      @chapter = Chapter.find params[:id]
      respond_with @chapter, include: :groups
    end
  end
end
