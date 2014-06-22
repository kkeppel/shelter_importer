class OrganizationsController < ApplicationController
  # before_action :set_organization, only: [:show]

  def index; end

  def import
    Pet.import(params[:organization_id], params[:count])

    redirect_to organization_path(params[:organization_id]), notice: "You have imported #{params[:count]} pets from Organization #{params[:organization_id]}"
  end

  def show
    @organization = Organization.find_by(shelter_id: params[:id])
    @pets = @organization.pets.all
  end

end
