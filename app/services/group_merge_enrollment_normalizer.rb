class GroupMergeEnrollmentNormalizer
  def initialize(enrollments:, destination_group:)
    @enrollments = enrollments
    @destination_group = destination_group
  end

  def normalize
    sorted_enrollments.each_with_object([]) do |enrollment, ranges|
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

  private

  attr_reader :enrollments, :destination_group

  def sorted_enrollments
    enrollments.sort_by(&:active_since)
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
end
