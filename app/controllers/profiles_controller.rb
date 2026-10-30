class ProfilesController < HtmlController
  skip_after_action :verify_policy_scoped
  after_action :verify_policy_scoped
  before_action :set_profile

  def show; end

  def update
    @selected_chapter_id = params.require(:profile).permit(:preferred_chapter_id)[:preferred_chapter_id].presence

    if @selected_chapter_id && @available_chapters.none? { |chapter| chapter.id.to_s == @selected_chapter_id }
      @user.errors.add(:base, t(:profile_invalid_chapter))
      return render :show, status: :unprocessable_content
    end

    return render :show, status: :unprocessable_content unless @user.update(preferred_chapter_id: @selected_chapter_id)

    success(title: t(:profile_saved), text: t(:profile_saved_text))
    redirect_to profile_path, status: :see_other
  end

  private

  def set_profile
    @user = current_user
    authorize @user, :profile?
    @available_chapters = policy_scope(Chapter).joins(:organization).includes(:organization)
                                               .where(deleted_at: nil, organizations: { deleted_at: nil })
                                               .order('organizations.organization_name', :chapter_name).to_a
    @selected_chapter_id = @user.preferred_chapter_id.to_s if @available_chapters.any? { |chapter| chapter.id == @user.preferred_chapter_id }
  end
end
