# frozen_string_literal: true
class OrganizationsController < ApplicationController
  def index
    authorize Organization
    @organizations = Organization.all
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
    @organization = Organization.find params[:id]
  end
end
