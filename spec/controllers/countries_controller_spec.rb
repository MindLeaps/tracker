require 'rails_helper'

RSpec.describe CountriesController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#index' do
    it 'gets a list of countries' do
      first_country = create :country
      second_country = create :country

      get :index
      expect(response).to be_successful

      expect(assigns(:countries).map(&:country_name)).to include first_country.country_name, second_country.country_name
    end
  end

  describe '#new' do
    before :each do
      get :new
    end

    it { should respond_with 200 }
    it { should render_template 'new' }
    it 'assigns the new empty country' do
      expect(assigns(:country)).to be_kind_of(Country)
    end
  end

  describe '#create' do
    let(:existing_country) { create :country, country_name: 'Existing Country' }

    describe 'successful creation' do
      before :each do
        post :create, params: { country: { country_name: 'New Test Country' } }
      end

      it { should redirect_to countries_url }
      it { should set_flash[:success_notice] }

      it 'creates a new country when supplied a valid country name' do
        expect(response).to redirect_to controller: :countries, action: :index

        country = Country.last
        expect(country.country_name).to eql 'New Test Country'
      end
    end

    describe 'failed creation' do
      before :each do
        post :create, params: { country: { country_name: '' } }
      end

      it { should respond_with :unprocessable_entity }
      it { should render_template :new }
      it { should set_flash[:failure_notice] }
    end
  end

  describe '#edit' do
    let(:country) { create :country }

    before :each do
      get :edit, params: { id: country.id }
    end

    it { should respond_with 200 }
    it { should render_template 'edit' }

    it 'assigns the existing country' do
      expect(assigns(:country)).to be_kind_of(Country)
      expect(assigns(:country).id).to eq(country.id)
    end
  end

  describe '#update' do
    let(:existing_country) { create :country, country_name: 'Existing Country' }

    describe 'successful update' do
      before :each do
        post :update, params: { id: existing_country.id, country: { country_name: 'Updated Country' } }
      end

      it { should redirect_to countries_url }
      it { should set_flash[:success_notice] }

      it 'updates the name of an existing country' do
        existing_country.reload

        expect(existing_country.country_name).to eq 'Updated Country'
      end
    end

    describe 'Failed update' do
      before :each do
        post :update, params: { id: existing_country.id, country: { country_name: '' } }
      end

      it { should respond_with 400 }
      it { should render_template :edit }
      it { should set_flash[:failure_notice] }
    end
  end

  describe '#destroy' do
    before :each do
      @country = create :country
      @organizations = create_list :organization, 3, country: @country
      @request.host = 'example.com'

      post :destroy, params: { id: @country.id }
    end

    it { should redirect_to 'http://example.com/countries' }
    it { should set_flash[:success_notice] }

    it 'removes the country completely' do
      expect(Country.exists?(@country.id)).to be false
    end

    it 'nullifies the country_id for associated organizations' do
      @organizations.each(&:reload)

      expect(@organizations.map(&:country_id)).to all(be_nil)
    end
  end
end
