class GroupFormComponent < ViewComponent::Base
  attr_reader :org_chapters, :permitted_tags

  class OrganizationChapters
    attr_reader :chapters, :org_display

    def initialize(org, permitted_chapters)
      @chapters = permitted_chapters.filter { |c| c.organization_id == org.id }.sort_by(&:chapter_name)
      @org_display = I18n.t(:display_with_mlid, name: org.organization_name, mlid: org.mlid)
    end
  end

  def initialize(group:, action:, current_user:, cancel: false)
    @group = group
    @action = action
    permitted_chapters = ChapterPolicy::Scope.new(current_user, Chapter.includes(:organization)).resolve
    @org_chapters = structure_chapters(permitted_chapters)
    @permitted_tags = tags_for_group(current_user, group)
    @cancel = cancel
  end

  def structure_chapters(permitted_chapters)
    permitted_chapters.map(&:organization).uniq.sort_by(&:organization_name).map do |org|
      OrganizationChapters.new(org, permitted_chapters)
    end
  end

  def tags_for_group(current_user, group)
    scope = TagPolicy::Scope.new(current_user, Tag)
    tags = group.chapter ? scope.resolve_for_organization_id(group.chapter.organization_id) : scope.resolve
    tags.order(:tag_name)
  end
end
