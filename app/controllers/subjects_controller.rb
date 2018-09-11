# frozen_string_literal: true

class SubjectsController < ApplicationController
  include Pagy::Backend

  def index
    authorize Subject
    @pagy, @subjects = pagy policy_scope(Subject.includes(:assignments, :skills, :organization))
  end

  def new
    authorize Subject
    @subject = Subject.new
  end

  def create
    @subject = Subject.new subject_params
    authorize @subject
    return notice_and_redirect(t(:subject_created, subject: @subject.subject_name), subjects_url) if @subject.save

    render :index
  end

  def show
    @subject = Subject.includes(assignments: [:skill]).find params.require(:id)
    authorize @subject
  end

  def edit
    @subject = Subject.includes(:assignments).find params.require(:id)
    authorize @subject
  end

  def update
    subject = Subject.includes(:organization).find params.require(:id)
    authorize subject
    notice_and_redirect(t(:subject_updated), subject) if subject.update subject_params
  end

  private

  def subject_params
    params.require(:subject).permit :subject_name, :organization_id, assignments_attributes: %i[id skill_id _destroy]
  end
end
