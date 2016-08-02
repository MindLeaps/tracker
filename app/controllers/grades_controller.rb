class GradesController < ApplicationController
  def index
    @students = Student.order(:group_id).all
  end
end
