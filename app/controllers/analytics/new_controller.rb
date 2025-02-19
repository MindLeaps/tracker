module Analytics
  class NewController < AnalyticsController
    def index
      @groups = policy_scope(apply_scopes(Group), policy_scope_class: GroupPolicy::Scope)
      @first_group_summaries = GroupLessonSummary.where(group_id: 420)


    end
  end
end
