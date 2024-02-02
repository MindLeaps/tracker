# frozen_string_literal: true

class OrganizationsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }, only: :index
  has_scope :table_order_chapters, type: :hash, only: :show
  has_scope :table_order_members, type: :hash, only: :show
  has_scope :search, only: :index
  def index
    authorize Organization
    @pagy, @organizations = pagy apply_scopes(policy_scope(OrganizationSummary, policy_scope_class: OrganizationPolicy::Scope))
  end

  def new
    authorize Organization
    @organization = Organization.new params.permit :organization_name
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def create
    authorize Organization
    @organization = Organization.new(params.require(:organization).permit(:organization_name, :mlid))
    @organization.mlid = @organization.mlid&.upcase

    if @organization.save
      success title: t(:organization_added), text: t(:organization_name_added, name: @organization.organization_name)
      return redirect_to organizations_url
    end

    handle_turbo_failure_responses({ title: t(:organization_invalid), text: t(:fix_form_errors) })
  end

  def edit
    @organization = Organization.find params.require :id
    authorize @organization
  end

  def update
    @organization = Organization.find params.require :id
    authorize @organization

    if @organization.update params.require(:organization).permit :organization_name, :mlid
      success title: t(:organization_updated), text: t(:organization_name_updated, name: @organization.organization_name)
      return redirect_to organizations_url
    end

    failure title: t(:organization_invalid), text: t(:fix_form_errors)
    render :edit, status: :bad_request
  end

  def show
    id = params.require :id
    @organization = Organization.find id
    authorize @organization
    initialize_organization id
  end

  def initialize_organization(id)
    @pagy_chapters, @chapters = pagy apply_scopes(ChapterSummary.where(organization_id: id), { table_order_chapters: params['table_order_chapters'] || { key: :chapter_name, order: :asc } })
    @pagy_users, @members = pagy apply_scopes(@organization.members, { table_order_members: params['table_order_members'] || { key: :email, order: :asc } })
    @new_member = User.new
    @roles = Role::LOCAL_ROLES.keys
  end

  def add_member
    @organization = Organization.find params.require :id
    authorize @organization
    member_params.tap do |p|
      return redirect_to @organization if @organization.add_user_with_role p.require(:email), p.require(:role).to_sym

      member_conflict_response @organization.id
    end
  rescue ActionController::ParameterMissing
    failure title: t(:invalid_user), text: t(:member_email_missing)
    initialize_organization @organization.id
    render :show, status: :bad_request
  end

  private

  def member_params
    params.require(:user).permit(:email, :role)
  end

  def member_conflict_response(id)
    initialize_organization id
    failure title: t(:invalid_user), text: t(:already_member)
    render :show, status: :conflict
  end
end
