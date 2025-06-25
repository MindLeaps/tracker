class SkillsController < HtmlController
  include Pagy::Backend
  has_scope :exclude_deleted, only: :index, type: :boolean, default: true
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }, only: :index
  has_scope :table_order_grades, type: :hash, only: :show
  has_scope :table_order_subjects, type: :hash, only: :show
  has_scope :search, only: :index

  def index
    authorize Skill
    @pagy, @skills = pagy apply_scopes(policy_scope(Skill.includes(:organization)))
  end

  def show
    @skill = Skill.includes(:organization).find params[:id]
    @average = scoped_grades(Grade.where(skill_id: @skill.id)).average(:mark)
    @pagy, @subjects = pagy SubjectPolicy::Scope.new(current_user, skill_subjects).resolve
    @pagy_grades, @grade_descriptors = pagy apply_scopes(@skill.grade_descriptors, table_order_grades: params['table_order_grades'] || { key: :mark, order: :asc })
    @skill_mark_counts = []
    populate_skill_mark_counts
    authorize @skill
  end

  def new
    @skill = Skill.new
    authorize @skill
  end

  def create
    @skill = Skill.new skill_parameters
    authorize @skill
    if params[:add_grade]
      @skill.grade_descriptors.build
      render :new, status: :ok
    elsif @skill.save
      success(title: t(:skill_added), text: t(:skill_added_text, skill: @skill.skill_name))
      redirect_to @skill
    else
      failure(title: t(:skill_invalid), text: t(:fix_form_errors))
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @skill = Skill.find params.require(:id)
    authorize @skill

    if @skill.can_delete?
      @skill.deleted_at = Time.zone.now
      return unless @skill.save

      success title: t(:skill_deleted), text: t(:skill_deleted_text, skill_name: @skill.skill_name), button_text: t(:undo), button_path: undelete_skill_path, button_method: :post
      redirect_to skills_path
    else
      render_deletion_error
    end
  end

  def undelete
    @skill = Skill.find params.require :id
    authorize @skill
    @skill.deleted_at = nil
    if @skill.save
      success title: t(:skill_restored), text: t(:skill_restored_text, skill_name: @skill.skill_name)
      redirect_to request.referer || @skill
    end
  end

  private

  def scoped_grades(grades)
    GradePolicy::Scope.new(current_user, grades).resolve
  end

  def populate_skill_mark_counts
    grades_using_skill_count = scoped_grades(Grade.where(skill_id: @skill.id)).count
    @skill.grade_descriptors.each do |desc|
      @skill_mark_counts << {
        mark: desc.mark,
        average: scoped_grades(Grade.where(skill_id: @skill.id).where(grade_descriptor_id: desc.id)).count / grades_using_skill_count.to_f
      }
    end
  end

  def skill_subjects
    subjects = @skill.subjects.includes(:assignments, :skills, :organization).where(assignments: { deleted_at: nil })
    apply_scopes(subjects, table_order_subjects: params['table_order_subjects'] || { key: :created_at, order: :desc })
  end

  def skill_parameters
    params.require(:skill).permit(:skill_name, :organization_id, :skill_description, grade_descriptors_attributes: %i[mark grade_description _destroy])
  end

  def render_deletion_error
    if Grade.where(skill: @skill).any?
      failure title: t(:unable_to_delete_skill), text: t(:skill_not_deleted_because_grades)
    elsif @skill.subjects.any?
      failure title: t(:unable_to_delete_skill), text: t(:skill_not_deleted_because_subject)
    end
    redirect_to request.referer || skill_path(@skill)
  end
end
