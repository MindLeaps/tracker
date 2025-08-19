class StudentFormComponent < ViewComponent::Base
  include Turbo::FramesHelper

  attr_reader :chapter_groups, :permitted_tags

  class ChapterGroups
    attr_reader :id, :groups, :chapter_display, :organization_id

    def initialize(chapter, permitted_groups)
      @id = chapter.id
      @groups = permitted_groups.filter { |g| g.chapter_id == chapter.id }.sort_by(&:chapter_group_name_with_full_mlid)
      @chapter_display = "#{chapter.organization_name} - #{chapter.chapter_name} (#{chapter.full_mlid})"
      @organization_id = chapter.organization_id
    end
  end

  def initialize(student:, action:, current_user:)
    @student = student
    @action = action
    @permitted_organizations = OrganizationPolicy::Scope.new(current_user, Organization).resolve.order(organization_name: :asc)
    permitted_groups = GroupPolicy::Scope.new(current_user, Group.includes(chapter: :organization)).resolve
    @chapter_groups = structure_groups(permitted_groups).sort_by(&:chapter_display)
    @permitted_tags = TagPolicy::Scope.new(current_user, Tag).resolve
  end

  def estimated_dob_checked?
    @student.estimated_dob.nil? || @student.estimated_dob
  end

  def countries_for_select_box
    I18nData.countries(helpers.locale.to_s).map { |k, v| [v, k] }.sort_alphabetical_by(&:first)
  end

  private

  def structure_groups(permitted_groups)
    permitted_groups.map(&:chapter).uniq.map do |chapter|
      ChapterGroups.new(chapter, permitted_groups)
    end
  end
end
