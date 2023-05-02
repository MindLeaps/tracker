# frozen_string_literal: true

class OrganizationsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash

  def index
    authorize Organization
    @pagy, @organizations = pagy apply_scopes(policy_scope(OrganizationSummary, policy_scope_class: OrganizationPolicy::Scope))
  end

  def new
    authorize Organization
    @organization = Organization.new params.permit :organization_name
  end

  def create
    authorize Organization
    @organization = Organization.new(params.require(:organization).permit(:organization_name, :mlid))
    @organization.mlid = @organization.mlid&.upcase

    if @organization.save
      success_notice t(:organization_added), t(:organization_name_added, name: @organization.organization_name)
      return redirect_to organizations_url if @organization.save
    end

    failure_notice t(:organization_invalid), t(:fix_form_errors)
    render :new, status: :bad_request
  end

  def edit
    @organization = Organization.find params.require :id
    authorize @organization
  end

  def update
    @organization = Organization.find params.require :id
    authorize @organization

    if @organization.update params.require(:organization).permit :organization_name, :mlid
      success_notice t(:organization_updated), t(:organization_name_updated, name: @organization.organization_name)
      return redirect_to organizations_url
    end

    failure_notice t(:organization_invalid), t(:fix_form_errors)
    render :edit, status: :bad_request
  end

  def show
    id = params.require :id
    @organization = Organization.find id
    authorize @organization
    @pagy, @chapters = pagy ChapterSummary.includes(:organization).where organization_id: id
  end

  def add_member
    @organization = Organization.find params.require :id
    authorize @organization
    member_params.tap do |p|
      return redirect_to @organization if @organization.add_user_with_role p.require(:email), p.require(:role).to_sym

      member_conflict_response
    end
  rescue ActionController::ParameterMissing
    flash[:alert] = t :member_email_missing
    render :show, status: :bad_request
  end

  private

  def member_params
    params.require(:member).permit(:email, :role)
  end

  def member_conflict_response
    flash[:alert] = t :already_member
    render :show, status: :conflict
  end
end
