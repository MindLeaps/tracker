class StudentAnalyticsSummaryPolicy < StudentPolicy
  def index?
    true
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.global_role?
        scope.all
      else
        scope.where(organization_id: user.membership_organizations)
      end
    end
  end
end
