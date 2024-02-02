# frozen_string_literal: true

class SubjectsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }, only: :index
  has_scope :table_order_skills, type: :hash, only: :show
  def index
    authorize Subject
    @pagy, @subjects = pagy apply_scopes(policy_scope(Subject.includes(:assignments, :skills, :organization)))
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
      render :new, status: :ok
    elsif @subject.save
      success(title: t(:subject_added), text: t(:subject_added_text, subject: @subject.subject_name))
      redirect_to @subject
    else
      failure title: t(:subject_invalid), text: t(:fix_form_errors)
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @subject = Subject.find params.require(:id)
    @pagy, @skills = pagy apply_scopes(@subject.skills.includes(:organization), { table_order_skills: params['table_order_skills'] || { key: :skill_name, order: :asc } })
    authorize @subject
  end

  def edit
    @subject = Subject.includes(:assignments).find params.require(:id)
    authorize @subject
  end

  def update
    @subject = Subject.includes(:organization, :skills).find params.require(:id)
    @subject.assign_attributes subject_params
    authorize @subject
    if params[:add_skill]
      @subject.assignments.build
      render :new, status: :ok
    elsif @subject.save
      success(title: t(:subject_updated), text: t(:subject_updated_text, subject: @subject.subject_name))
      redirect_to @subject
    else
      failure(title: t(:subject_invalid), text: t(:fix_form_errors))
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def subject_params
    params.require(:subject).permit :subject_name, :organization_id, assignments_attributes: %i[id skill_id _destroy]
  end
end
