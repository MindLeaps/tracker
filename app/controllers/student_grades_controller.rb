class StudentGradesController < ApplicationController
  def show
    @student = Student.find params[:id]
    @skills = Lesson.find(params[:lesson_id]).subject.skills
  end
end
