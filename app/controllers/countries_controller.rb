class CountriesController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }, only: :index
  has_scope :search, only: :index
  def index
    authorize Country
    @pagy, @countries = pagy apply_scopes(policy_scope(CountryRow, policy_scope_class: CountryPolicy::Scope))
  end

  def new
    authorize Country
    @country = Organization.new params.permit :country_name
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def edit
    @country = Country.find params.require :id
    authorize @country
  end

  def create
    authorize Country
    @country = Country.new(params.require(:country).permit(:country_name))

    if @organization.save
      success title: t(:country_added), text: t(:country_name_added, name: @country.country_name)
      return redirect_to countries_url
    end

    handle_turbo_failure_responses({ title: t(:country_invalid), text: t(:fix_form_errors) })
  end

  def update
    @country = Country.find params.require :id
    authorize @country

    if @country.update params.require(:country).permit :country_name
      success title: t(:country_updated), text: t(:country_name_updated, name: @country.country_name)
      return redirect_to countries_url
    end

    failure title: t(:country_invalid), text: t(:fix_form_errors)
    render :edit, status: :bad_request
  end

  def destroy
    @country = Country.find params.require :id
    authorize @country

    return unless @country.destroy

    success title: t(:country_deleted), text: t(:country_deleted_text, country_name: @country.country_name)
    redirect_to countries_path
  end
end
