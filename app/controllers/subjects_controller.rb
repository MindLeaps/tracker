class SubjectsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }, only: :index
  has_scope :table_order_skills, type: :hash, only: :show
  def index
    authorize Subject
    @pagy, @subjects = pagy apply_scopes(policy_scope(Subject.includes(:assignments, :skills, :organization)))
  end

  def show
    @subject = Subject.find params.require(:id)
    @pagy, @skills = pagy apply_scopes(@subject.skills.includes(:organization), { table_order_skills: params['table_order_skills'] || { key: :skill_name, order: :asc } })
    authorize @subject
  end

  def new
    authorize Subject
    @subject = Subject.new
  end

  def edit
    @subject = Subject.includes(:assignments).find params.require(:id)
    authorize @subject
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

  def update
    @subject = Subject.includes(:organization, :skills).find params.require(:id)
    @subject.assign_attributes subject_params
    authorize @subject
    if params[:add_skill]
      @subject.assignments.build
      render :new, status: :ok
    elsif save_with_assignment_validation
      redirect_to @subject
    else
      failure(title: t(:subject_invalid), text: t(:fix_form_errors))
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def save_with_assignment_validation
    removed_skill_ids = @subject.assignments.filter(&:marked_for_destruction?).map(&:skill_id)

    removed_skill_ids.each do |id|
      return failure(title: t(:unable_to_remove_skill_from_subject, skill_name: Skill.find(id).skill_name), text: t(:skill_not_removed_because_grades)) if @subject.grades_in_skill?(id)
    end

    return success(title: t(:subject_updated), text: t(:subject_updated_text, subject: @subject.subject_name)) if @subject.save

    false
  end

  def subject_params
    params.require(:subject).permit :subject_name, :organization_id, assignments_attributes: %i[id skill_id _destroy]
  end
end
