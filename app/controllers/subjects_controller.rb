# frozen_string_literal: true

class SubjectsController < HtmlController
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
    if params[:add_skill]
      @subject.assignments.build
    elsif @subject.save
      success(title: t(:subject_added), text: t(:subject_added_text, subject: @subject.subject_name))
      return redirect_to @subject
    else
      failure title: t(:subject_invalid), text: t(:fix_form_errors)
    end

    render :new, status: :unprocessable_entity
  end

  def show
    @subject = Subject.includes(assignments: [:skill]).find params.require(:id)
    @pagy, @skills = pagy @subject.skills
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
