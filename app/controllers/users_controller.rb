class UsersController < HtmlController
  include Pagy::Method

  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }
  has_scope :search, only: [:index, :show]

  before_action do
    @pagy, @users = pagy apply_scopes(policy_scope(User.includes(:roles).all))
  end

  def index
    authorize User
  end

  def show
    @user = User.includes(:roles).find params[:id]
    @user_roles = @user.roles.to_h { |r| [r.resource_id, r.name.to_sym] }
    @pagy, @organizations = pagy apply_scopes(policy_scope(Organization))
    @membership = Membership.new user: @user
    authorize @user
  rescue Pundit::NotAuthorizedError
    redirect_to users_path
  end

  def new
    authorize User
    @user = User.new
  end

  def create
    @user = User.new params.require(:user).permit(:email)
    authorize @user
    if @user.save
      success title: t(:user_added), text: t(:user_with_email_added, email: @user.email), link_path: new_user_path, link_text: t(:create_another)
      return redirect_to user_path(@user)
    end
    failure title: t(:user_invalid), text: @user.errors.full_messages.join('\n')
    render :new, status: :unprocessable_entity
  end

  def destroy
    @user = User.includes(:roles).find params[:id]
    authorize @user
    @user.destroy!

    success(title: t(:user_deleted), text: t(:user_deleted_text, email: @user.email))
    redirect_to users_path
  end

  def create_api_token
    @user = User.find params.require(:id)
    authorize @user
    @user.authentication_tokens.destroy_all
    @token = Tiddle.create_and_return_token @user, request, expires_in: 1.hour
    render :show, status: :created
  end
end
