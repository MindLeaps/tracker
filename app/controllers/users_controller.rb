# frozen_string_literal: true

class UsersController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash
  has_scope :search, only: :index

  before_action do
    @pagy, @users = pagy apply_scopes(policy_scope(User.includes(:roles).all))
  end

  def index
    authorize User
  end

  def new
    authorize User
    @user = User.new
  end

  def create
    @user = User.new params.require(:user).permit(:email)
    authorize @user
    return notice_and_redirect(t(:user_added, email: params[:user][:email]), users_url) if @user.save

    render :index
  end

  def destroy
    @user = User.includes(:roles).find params[:id]
    authorize @user
    @user.destroy!

    notice_and_redirect t(:delete_user_notice, email: @user.email), users_path
  end

  def create_api_token
    @user = User.find params.require(:id)
    authorize @user
    @user.authentication_tokens.destroy_all
    @token = Tiddle.create_and_return_token @user, request, expires_in: 1.hour
    render :show, status: :created
  end

  def show
    @user = User.includes(:roles).find params[:id]
    @user_roles = @user.roles.map { |r| [r.resource_id, r.name.to_sym] }.to_h # { organization_id => :role_name }
    @membership = Membership.new user: @user
    authorize @user
  end
end
