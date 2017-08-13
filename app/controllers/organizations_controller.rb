# frozen_string_literal: true

class OrganizationsController < ApplicationController
  def index
    authorize Organization
    @organizations = Organization.includes(:chapters).all
    @organization = Organization.new
  end

  def create
    authorize Organization
    @organization = Organization.new(params.require(:organization).permit(:organization_name))
    @organization.save
    redirect_to organizations_url
  end

  def show
    authorize Organization
    @organization = Organization.includes(chapters: { groups: [:students] }).find params[:id]
  end

  def add_member
    @organization = Organization.find params.require :id
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
