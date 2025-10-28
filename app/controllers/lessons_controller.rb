class LessonsController < HtmlController
  include Pagy::Backend

  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :table_order, type: :hash, only: :index, default: { key: :date, order: :desc }
  has_scope :table_order_lesson_students, type: :hash, only: :show
  has_scope :table_order_lesson_skills, type: :hash, only: :show

  def index
    authorize Lesson
    @pagy, @lesson_rows = pagy apply_scopes(policy_scope(LessonTableRow, policy_scope_class: LessonPolicy::Scope))
  end

  def show
    @lesson = Lesson.includes(:group, :subject).find(params[:id])
    authorize @lesson
    @pagy, @student_lesson_summaries = pagy apply_scopes(StudentLessonSummary.where(lesson_id: @lesson.id), student_lesson_order_scope)
    @lesson_skill_summary = apply_scopes(LessonSkillSummary.where(lesson_id: @lesson.id), lesson_skill_order_scope)
    @group_lessons_data = process_group_lesson_data(GroupLessonSummary.around(@lesson, 31) || [], @lesson)
  end

  def new
    authorize Lesson
    @lesson = Lesson.new
  end

  def edit
    @lesson = Lesson.find params.require :id
    authorize @lesson
  end

  def create
    @lesson = Lesson.new params.require(:lesson).permit :group_id, :date, :subject_id
    if @lesson.valid? && @lesson.save
      authorize @lesson
      success(title: t(:lesson_added), text: t(:lesson_added_text, date: @lesson.date, group: @lesson.group.group_name, subject: @lesson.subject.subject_name))
      return redirect_to @lesson
    end

    skip_authorization
    failure(title: t(:lesson_invalid), text: t(:fix_form_errors))
    render :new, status: :unprocessable_entity
  end

  def update
    @lesson = Lesson.find params.require :id
    if @lesson.valid? && @lesson.update(lesson_params)
      authorize @lesson
      success title: t(:lesson_updated), text: t(:lesson_updated_text, group: @lesson.group.group_name, subject: @lesson.subject.subject_name)
      return redirect_to(flash[:redirect] || lesson_path(@lesson))
    end

    skip_authorization
    failure(title: t(:lesson_invalid), text: t(:fix_form_errors))
    render :edit, status: :unprocessable_entity
  end

  private

  def lesson_params
    params.require(:lesson).permit :group_id, :date, :subject_id
  end

  def student_lesson_order_scope
    {
      table_order_lesson_students: params['table_order_lesson_students'] || { key: :last_name, order: :asc },
      exclude_deleted: params['exclude_deleted'] || true
    }
  end

  def lesson_skill_order_scope
    {
      table_order_lesson_skills: params['table_order_lesson_skills'] || { key: :skill_name, order: :asc },
      exclude_deleted: nil
    }
  end

  def process_group_lesson_data(data, current_lesson)
    {
      prev_lesson_url: get_prev_lesson_url(current_lesson, data),
      next_lesson_url: get_next_lesson_url(current_lesson, data),
      group_lessons: data.map do |l|
        h = l.as_json
        h[:lesson_url] = lesson_url l.lesson_id
        h
      end
    }
  end

  def get_prev_lesson_url(lesson, data)
    i = data.find_index { |e| e.lesson_id == lesson.id }
    i.present? && i.positive? ? lesson_url(data[i - 1].lesson_id, request.query_parameters) : nil
  end

  def get_next_lesson_url(lesson, data)
    i = data.find_index { |e| e.lesson_id == lesson.id }
    i.present? && i + 1 < data.size ? lesson_url(data[i + 1].lesson_id, request.query_parameters) : nil
  end
end
