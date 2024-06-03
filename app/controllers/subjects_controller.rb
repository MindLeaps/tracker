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
    elsif can_update_subject
      redirect_to @subject
    else
      failure(title: t(:subject_invalid), text: t(:fix_form_errors))
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def can_update_subject
    if !check_for_removed_skills || (check_for_removed_skills && no_grades_using_skill)
      if @subject.save
        success(title: t(:subject_updated), text: t(:subject_updated_text, subject: @subject.subject_name))
      else
        return false
      end
    end

    true
  end

  def no_grades_using_skill
    destroyed_assignments = formatted_assignment_attributes.select { |v| v if v[:_destroy] == '1' }
    lessons_using_subject = Lesson.where(subject_id: @subject.id).pluck(:id)

    destroyed_assignments.each do |assignment|
      if Grade.exists?(lesson_id: lessons_using_subject, skill_id: assignment[:skill_id])
        failure(title: t(:unable_to_remove_skill_from_subject, skill_name: Skill.find(assignment[:skill_id]).skill_name), text: t(:skill_not_removed_because_grades))
        return false
      end
    end

    true
  end

  def check_for_removed_skills
    formatted_assignment_attributes.any? { |v| v[:_destroy] == '1' }
  end

  def formatted_assignment_attributes
    subject_params[:assignments_attributes].to_unsafe_h.values
  end

  def subject_params
    params.require(:subject).permit :subject_name, :organization_id, assignments_attributes: %i[id skill_id _destroy]
  end
end
