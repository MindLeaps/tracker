class GroupMergePreview
  attr_reader :source_group, :destination_group

  def initialize(source_group:, destination_group:)
    @source_group = source_group
    @destination_group = destination_group
  end

  def blockers
    [
      ('Choose two different groups.' if source_group == destination_group),
      ('Both groups must be active.' if source_group.deleted_at.present? || destination_group.deleted_at.present?),
      ('Groups must belong to the same chapter.' if source_group.chapter_id != destination_group.chapter_id)
    ].compact
  end

  def mergeable?
    blockers.empty?
  end

  def lessons_to_move
    return [] unless mergeable?

    source_lessons.reject { |lesson| destination_lesson_for(lesson) }
  end

  def lessons_to_merge
    return [] unless mergeable?

    source_lessons.filter { |lesson| destination_lesson_for(lesson) }
  end

  def grade_summary
    return empty_grade_summary unless mergeable?

    lessons_to_merge.each_with_object(empty_grade_summary) do |source_lesson, summary|
      destination_lesson = destination_lesson_for(source_lesson)
      source_lesson.grades.exclude_deleted.find_each do |source_grade|
        summarize_source_grade(summary, source_grade, destination_lesson)
      end
    end
  end

  def enrollment_summary
    return empty_enrollment_summary unless mergeable?

    source_enrollments.group_by(&:student_id).each_with_object(empty_enrollment_summary) do |(student_id, enrollments), summary|
      summarize_student_enrollments(summary, student_id, enrollments)
    end
  end

  def source_lessons_count
    source_lessons.size
  end

  private

  def empty_grade_summary
    { grades_to_move: 0, source_higher: 0, destination_kept: 0 }
  end

  def empty_enrollment_summary
    {
      source_enrollments: 0,
      students_affected: 0,
      ranges_before: 0,
      ranges_after: 0,
      students_with_merged_ranges: 0,
      students_with_preserved_gaps: 0
    }
  end

  def summarize_source_grade(summary, source_grade, destination_lesson)
    destination_grade = destination_lesson.grades.exclude_deleted.find_by(student_id: source_grade.student_id, skill_id: source_grade.skill_id)
    if destination_grade.nil?
      summary[:grades_to_move] += 1
    elsif source_grade.mark > destination_grade.mark
      summary[:source_higher] += 1
    else
      summary[:destination_kept] += 1
    end
  end

  def summarize_student_enrollments(summary, student_id, enrollments)
    ranges = destination_group.enrollments.where(student_id:).to_a + enrollments
    normalized_ranges = normalize_ranges(ranges)
    summary[:students_affected] += 1
    summary[:source_enrollments] += enrollments.size
    summary[:ranges_before] += ranges.size
    summary[:ranges_after] += normalized_ranges.size
    summary[:students_with_merged_ranges] += 1 if normalized_ranges.size < ranges.size
    summary[:students_with_preserved_gaps] += 1 if normalized_ranges.size > 1
  end

  def source_lessons
    @source_lessons ||= source_group.lessons.exclude_deleted.to_a
  end

  def source_enrollments
    @source_enrollments ||= source_group.enrollments.to_a
  end

  def destination_lessons
    @destination_lessons ||= destination_group.lessons.exclude_deleted.index_by { |lesson| [lesson.subject_id, lesson.date] }
  end

  def destination_lesson_for(source_lesson)
    destination_lessons[[source_lesson.subject_id, source_lesson.date]]
  end

  def normalize_ranges(enrollments)
    GroupMergeEnrollmentNormalizer.new(enrollments:, destination_group:).normalize
  end
end
