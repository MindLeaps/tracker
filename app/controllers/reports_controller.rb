class ReportsController < HtmlController
  include Pagy::Backend
    has_scope :exclude_deleted, type: :boolean, default: true
    has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }
    has_scope :search, only: [:show, :index]

    before_action do
          @available_organizations = policy_scope Organization.where(deleted_at: nil).order(:organization_name)
          @available_chapters = policy_scope Chapter.where(deleted_at: nil).order(:chapter_name)
          @available_groups = policy_scope Group.where(deleted_at: nil).order(:group_name)

          @selected_organization_id = params[:organization_id] || @available_organizations.first.id
          @selected_chapter_id = params[:chapter_id]
          @selected_group_id = params[:group_id]
        end


    def index
        authorize Group
        @group = Group.new
        @pagy, @groups = pagy policy_scope(apply_scopes(GroupSummary.includes(chapter: [:organization])), policy_scope_class: GroupPolicy::Scope)
    end

    def show
        @group = Group.includes(:chapter).find params[:group_select]
        authorize @group
        @pagy, @student_rows = pagy apply_scopes(StudentTableRow.where(group_id: @group.id).includes(:tags, :group))
        @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: @student_rows, row_component: TableComponents::StudentRow)
    end
end