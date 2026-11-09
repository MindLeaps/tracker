class ChapterDashboard
  attr_reader :chapter, :today

  def initialize(chapter:, group_id: nil, subject_id: nil, today: Date.current)
    @chapter = chapter
    @today = today
    @requested_group_id = group_id
    @requested_subject_id = subject_id
  end

  def week
    (today - 6)..today
  end

  def previous_week
    (today - 13)..(today - 7)
  end

  def history_period
    (today - 27)..today
  end

  def groups
    @groups ||= chapter.groups.where(deleted_at: nil).order(:group_name, :id).to_a
  end

  def subjects
    @subjects ||= Subject.where(organization_id: chapter.organization_id, deleted_at: nil).order(:subject_name, :id).to_a
  end

  def activity
    @activity ||= { lessons: [lessons.where(date: week).count, lessons.where(date: previous_week).count],
                    students: [assessed_students(week), assessed_students(previous_week)],
                    groups: [lessons.where(date: week).distinct.count(:group_id), lessons.where(date: previous_week).distinct.count(:group_id)] }
  end

  def daily_lessons
    counts = lessons.where(date: week).group(:date).count
    week.map { |date| { date: date, count: counts.fetch(date, 0) } }
  end

  def declines
    learning.patterns(:decline, 5)
  end

  def improvements
    learning.patterns(:improvement, 3)
  end

  def selected_group
    @selected_group ||= groups.find { |group| group.id.to_s == @requested_group_id.to_s } ||
                        groups.find { |group| group.id == most_recent_row&.dig(:group_id) } || groups.first
  end

  def selected_subject
    @selected_subject ||= subjects.find { |subject| subject.id.to_s == @requested_subject_id.to_s } || recent_subject || subjects.first
  end

  def snapshot
    return [] unless selected_group && selected_subject

    learning.snapshot(snapshot_skills, selected_group.id, selected_subject.id)
  end

  def group_overview
    weekly_lessons = lessons.where(date: week).group(:group_id).count
    weekly_students = eligible_grades.where(lessons: { date: week }).group('lessons.group_id').distinct.count(:student_id)
    latest_dates = lessons.where(date: ..today).group(:group_id).maximum(:date)
    groups.map do |group|
      { group: group, lessons: weekly_lessons.fetch(group.id, 0), students: weekly_students.fetch(group.id, 0), latest: latest_dates[group.id] }
    end
  end

  private

  def learning
    @learning ||= DashboardLearning.new(rows: history_rows, week: week)
  end

  def recent_subject
    subject_id = most_recent_row(selected_group&.id)&.dig(:subject_id)
    subjects.find { |subject| subject.id == subject_id }
  end

  def lessons
    Lesson.joins(:subject).where(group_id: groups.map(&:id), deleted_at: nil, subjects: { deleted_at: nil, organization_id: chapter.organization_id })
  end

  def assessed_students(period)
    eligible_grades.where(lessons: { date: period }).distinct.count(:student_id)
  end

  def eligible_grades
    Grade.joins(:student, :skill, :grade_descriptor, lesson: :subject)
         .where(deleted_at: nil, lesson_id: lessons.select(:id), students: { deleted_at: nil, organization_id: chapter.organization_id },
                skills: { deleted_at: nil }, grade_descriptors: { deleted_at: nil })
         .where(<<~SQL.squish)
           EXISTS (SELECT 1 FROM enrollments e
             WHERE e.student_id = grades.student_id AND e.group_id = lessons.group_id
               AND e.active_since <= lessons.date AND (e.inactive_since IS NULL OR e.inactive_since >= lessons.date))
         SQL
  end

  def history_rows
    @history_rows ||= Grade.connection.select_all(<<~SQL.squish).to_a.map(&:symbolize_keys)
      SELECT * FROM (#{ranked_history.to_sql}) ranked WHERE position <= 3
    SQL
  end

  def ranked_history
    eligible_grades.joins(lesson: :group).where(lessons: { date: history_period })
                   .where(<<~SQL.squish, today: today).select(history_columns)
                     EXISTS (SELECT 1 FROM enrollments current_enrollment
                       WHERE current_enrollment.student_id = grades.student_id AND current_enrollment.group_id = lessons.group_id
                         AND current_enrollment.active_since <= :today
                         AND (current_enrollment.inactive_since IS NULL OR current_enrollment.inactive_since > :today))
                   SQL
  end

  def history_columns
    <<~SQL.squish
      grades.student_id, students.first_name, students.last_name, grades.skill_id, skills.skill_name, grades.mark,
      lessons.group_id, groups.group_name, lessons.subject_id, subjects.subject_name, lessons.date AS lesson_date,
      ROW_NUMBER() OVER (PARTITION BY grades.student_id, lessons.group_id, lessons.subject_id, grades.skill_id
        ORDER BY lessons.date DESC, lessons.id DESC, grades.id DESC) AS position
    SQL
  end

  def most_recent_row(group_id = nil)
    history_rows.select { |row| group_id.nil? || row[:group_id] == group_id }.max_by { |row| [row[:lesson_date], -row[:group_id], -row[:subject_id]] }
  end

  def snapshot_skills
    selected_subject.skills.where(deleted_at: nil).includes(:grade_descriptors).order(:skill_name, :id).distinct
  end
end
