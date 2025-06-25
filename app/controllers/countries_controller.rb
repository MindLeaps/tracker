class CountriesController < HtmlController
  include Pagy::Backend
  has_scope :exclude_deleted, type: :boolean, default: true, only: %i[show]
  has_scope :table_order, type: :hash
  has_scope :search, only: :index

  def index
    authorize Country
    @pagy, @countries = pagy apply_scopes(policy_scope(CountrySummary, policy_scope_class: CountryPolicy::Scope))
  end

  def show
    id = params.require :id
    @country = Country.find id
    authorize @country
    @pagy_organizations, @organizations = pagy apply_scopes(policy_scope(OrganizationSummary.where(organization_mlid: @country.organizations.map(&:mlid)), policy_scope_class: OrganizationPolicy::Scope))
  end

  def new
    authorize Country
    @country = Country.new params.permit :country_name
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

    if @country.save
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

    success title: t(:country_deleted), text: t(:country_deleted_text, name: @country.country_name)
    redirect_to countries_path
  end
end
