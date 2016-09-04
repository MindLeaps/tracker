class OrganizationsController < ApplicationController
  def index
    @organizations = Organization.all
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params.require(:organization).permit(:organization_name))
    @organization.save
    redirect_to organizations_url
  end
end
