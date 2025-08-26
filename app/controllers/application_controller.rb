class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!, except: :health

  def append_info_to_payload(payload)
    super
    payload[:user_email] = current_user.try :email
  end

  def health
    conn = ActiveRecord::Base.connection.raw_connection
    migrations = conn.exec('SELECT * FROM schema_migrations').values
    render json: migrations, status: :ok
  end

  def current_user
    # Including roles in Devise's current_user so we can use has_cached_role? and avoid N+1 when checking for roles
    # https://stackoverflow.com/questions/6902531/how-to-eager-load-associations-with-the-current-user
    @current_user ||= super && User.includes(:roles).where(id: @current_user.id).first
  end

  # Uncomment this to skip authentication in development
  # def authenticate_user!
  #   return true if Rails.env.development?
  #
  #   raise SecurityError
  # end
  #
  # def current_user
  #   raise SecurityError unless Rails.env.development?
  #
  #   user = User.find_or_create_by!(email: 'test@example.com')
  #   user.add_role :super_admin
  #   user
  # end
end
