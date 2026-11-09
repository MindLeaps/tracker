class DashboardLearning
  def initialize(rows:, week:)
    @rows = rows
    @week = week
  end

  def patterns(direction, limit)
    candidates = @rows.group_by { |row| row.values_at(:student_id, :group_id, :subject_id, :skill_id) }.values.filter_map do |rows|
      pattern(rows, direction)
    end
    candidates.sort_by { |row| [-row[:change], -row[:lesson_date].jd, row[:student_id], row[:skill_id]] }
              .uniq { |row| row[:student_id] }.first(limit)
  end

  def snapshot(skills, group_id, subject_id)
    latest = @rows.select { |row| row[:group_id] == group_id && row[:subject_id] == subject_id && row[:position] == 1 }.group_by { |row| row[:skill_id] }
    skills.map { |skill| snapshot_entry(skill, latest.fetch(skill.id, [])) }
  end

  private

  def snapshot_entry(skill, rows)
    marks = skill.grade_descriptors.reject(&:deleted_at).map(&:mark)
    average = (rows.sum { |row| row[:mark] }.to_f / rows.size).round(2) if rows.size >= 3
    { skill: skill, count: rows.size, average: average, minimum: marks.min, maximum: marks.max }
  end

  def pattern(rows, direction)
    ordered = rows.sort_by { |row| row[:position] }.reverse
    return unless ordered.size == 3 && @week.cover?(ordered.last[:lesson_date])

    marks = ordered.pluck(:mark)
    change = (marks.last - marks.first).abs
    return unless change >= 1 && monotonic?(marks, direction)

    ordered.last.merge(change: change, evidence: ordered)
  end

  def monotonic?(marks, direction)
    marks.each_cons(2).all? { |first, last| direction == :decline ? last < first : last > first }
  end
end
