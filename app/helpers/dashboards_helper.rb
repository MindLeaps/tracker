module DashboardsHelper
  def dashboard_delta(current, previous)
    change = current - previous
    t(:dashboard_comparison, previous: previous, change: change.positive? ? "+#{change}" : change.to_s)
  end

  def dashboard_student_name(pattern)
    "#{pattern[:last_name]}, #{pattern[:first_name]}"
  end

  def dashboard_date_range(period)
    "#{l(period.begin, format: :long)} – #{l(period.end, format: :long)}"
  end

  def dashboard_trend_coordinates(evidence)
    marks = evidence.pluck(:mark)
    minimum, maximum = marks.minmax
    span = [maximum - minimum, 1].max.to_f
    marks.each_with_index.map { |mark, index| [8 + (index * 42), (32 - ((mark - minimum) / span * 24)).round(1)] }
  end
end
