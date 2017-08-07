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
    @organization = Organization.includes(chapters: {groups: [:students]}).find params[:id]
  end

  def add_member
    authorize Organization

    organization = Organization.find params[:id]


    redirect_to organization_url params.require(:id)
  end
end
