class RolesController < ApplicationController

  before_action :set_role, only: [:create,:destroy]
  before_action :set_user, only: [:create,:destroy]

  # GET /roles
  # GET /roles.json
  def index
    authorize! :read, Role
    @roles = Role.all
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_role
    @role = Role.find_by_name(params[:id])
  end


  # Never trust parameters from the scary internet, only allow the white list through.
  def role_params
    params.require(:role).permit(:name)
  end
end
