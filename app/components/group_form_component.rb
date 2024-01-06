# frozen_string_literal: true

class GroupFormComponent < ViewComponent::Base
  attr_reader :org_chapters

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
    @cancel = cancel
  end

  def structure_chapters(permitted_chapters)
    permitted_chapters.map(&:organization).uniq.map do |org|
      OrganizationChapters.new(org, permitted_chapters)
    end
  end
end
