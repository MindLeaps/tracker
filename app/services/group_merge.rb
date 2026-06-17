class GroupMerge
  attr_reader :source_group, :destination_group

  def initialize(source_group:, destination_group:)
    @source_group = source_group
    @destination_group = destination_group
  end

  def preview
    @preview ||= GroupMergePreview.new(source_group:, destination_group:)
  end

  def merge!
    raise ActiveRecord::RecordInvalid, source_group unless preview.mergeable?

    ActiveRecord::Base.transaction do
      merge_lessons
      merge_enrollments
      source_group.update!(deleted_at: Time.zone.now)
    end
  end

  private

  def merge_lessons
    preview.lessons_to_merge.each { |source_lesson| merge_lesson(source_lesson) }
    preview.lessons_to_move.each { |source_lesson| source_lesson.update!(group: destination_group) }
  end

  def merge_lesson(source_lesson)
    destination_lesson = destination_lesson_for(source_lesson)

    source_lesson.grades.exclude_deleted.find_each do |source_grade|
      merge_grade(source_grade, destination_lesson)
    end

    hard_delete_lesson(source_lesson)
  end

  def merge_grade(source_grade, destination_lesson)
    destination_grade = destination_lesson.grades.exclude_deleted.find_by(student_id: source_grade.student_id, skill_id: source_grade.skill_id)

    if destination_grade.nil?
      source_grade.update!(lesson: destination_lesson)
    elsif source_grade.mark > destination_grade.mark
      destination_grade.update!(grade_descriptor: source_grade.grade_descriptor)
    end
  end

  def hard_delete_lesson(lesson)
    DeletedLesson.find_or_create_by!(id: lesson.id) do |deleted_lesson|
      deleted_lesson.group = lesson.group
    end

    Grade.where(lesson_id: lesson.id).delete_all
    lesson.destroy!
  end

  def merge_enrollments
    source_group.enrollments.select(:student_id).distinct.pluck(:student_id).each do |student_id|
      merge_student_enrollments(student_id)
    end
  end

  def merge_student_enrollments(student_id)
    enrollments = Enrollment.where(student_id:, group: [source_group, destination_group]).to_a
    normalized_ranges = normalize_ranges(enrollments)

    Enrollment.where(student_id:, group: [source_group, destination_group]).delete_all
    normalized_ranges.each do |range|
      Enrollment.create!(
        student_id:,
        group: destination_group,
        active_since: range[:active_since],
        inactive_since: range[:inactive_since]
      )
    end
  end

  def normalize_ranges(enrollments)
    sorted = enrollments.sort_by(&:active_since)
    sorted.each_with_object([]) do |enrollment, ranges|
      current = range_from(enrollment)
      previous = ranges.last

      if previous && overlapping_or_continuous?(previous, current)
        previous[:inactive_since] = latest_end(previous, current)
        previous[:destination_open] ||= current[:destination_open]
      else
        ranges << current
      end
    end
  end

  def range_from(enrollment)
    {
      active_since: enrollment.active_since,
      inactive_since: enrollment.inactive_since,
      destination_open: enrollment.group_id == destination_group.id && enrollment.inactive_since.nil?
    }
  end

  def overlapping_or_continuous?(previous, current)
    return true if previous[:inactive_since].nil?

    current[:active_since] <= previous[:inactive_since] + 1.day
  end

  def latest_end(previous, current)
    return nil if previous[:destination_open] || current[:destination_open]
    return current[:inactive_since] if previous[:inactive_since].nil?
    return previous[:inactive_since] if current[:inactive_since].nil?

    [previous[:inactive_since], current[:inactive_since]].max
  end

  def destination_lesson_for(source_lesson)
    destination_lessons[[source_lesson.subject_id, source_lesson.date]]
  end

  def destination_lessons
    @destination_lessons ||= destination_group.lessons.exclude_deleted.index_by { |lesson| [lesson.subject_id, lesson.date] }
  end
end
