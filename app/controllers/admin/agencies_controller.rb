class Admin::AgenciesController < Admin::AdminController
  helper_method :sort_column, :sort_direction
  respond_to :html, :xml, :json, :csv, :xls
  before_action :set_agency, only: [:show, :edit, :update, :destroy, :history, :restore, :reassign, :stats]
  protect_from_forgery except: :tokeninput
 
  before_action  :require_admin, except: [:tokeninput, :stats]
  before_action :admin_two_factor, except: [:tokeninput, :stats]

  def index 
    @agencies = Agency.all.order(sort_column + " " + sort_direction) 
    respond_to do |format|
      format.html { @agencies = [] }
      format.json { render "index" }
      format.xml { render xml: @agencies }
      format.csv { send_data @agencies.to_csv }
      format.xls { send_data @agencies.to_csv(col_sep: "\t")}
    end
  end

  def new
  	@agency = Agency.new
  end

  def show
    if @agency
      @agency = Agency.where(:id=> @agency.id).includes(:outlets,:mobile_apps,:galleries).first
    end
  end

  def edit
    
  end

  def create
  	@agency = Agency.new(agency_params)
  	respond_to do |format|
      if @agency.save
        format.html { redirect_to admin_agency_path(@agency), notice: 'Agency was successfully created.' }
        format.json { render :show, status: :created, location: @agency }
      else
        format.html { render :new }
        format.json { render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @agency.update(agency_params)
        format.html {redirect_to admin_agency_path(@agency), notice: 'Agency was successfully updated.'}
        format.json  {render :show, status: :ok, location: admin_agency_path(@agency)}
      else
        format.html {render :edit }
        format.json {render json: @agency.errors, status: :unprocessable_entity }
      end
    end
  end

  def stats

  end

  def reassign
    @new_agency = Agency.find(params[:new_agency])
    if @agency && @new_agency
      GalleryAgency.where(agency_id: @agency.id).update_all(agency_id: @new_agency.id)
      
      MobileAppAgency.where(agency_id: @agency.id).update_all(agency_id: @new_agency.id)
      
      first_agency_mappings = Sponsorship.where(agency_id: @agency.id)
      second_agency_outlet_ids = Sponsorship.where(agency_id: @new_agency.id).map(&:outlet_id)

      first_agency_mappings.each do |sponsporship|
        unless second_agency_outlet_ids.include? sponsporship.outlet_id
          sponsporship.agency_id = @new_agency.id
          sponsporship.save(validate: false)
          sponsporship.outlet.save(validate: false)
        end
      end
      MobileAppAgency.where(agency_id: @new_agency.id).each do |ma|
        ma.mobile_app.save(validate: false)
      end
      @agency.update_counters
      @agency.save

      @new_agency.update_counters
      @new_agency.save
    end
    redirect_to admin_agency_path(@new_agency)
  end

  def destroy
    @agency.destroy!
    respond_to do |format|
      format.html { redirect_to admin_agencies_url, notice: "Agency was successfully destroyed."}
      format.json { head :no_content }
    end
  end

  def tokeninput
    @agencies = Agency.where("name LIKE ? OR shortname LIKE ?", "%#{params[:q]}%","%#{params[:q]}%").select([:id,:name])
    respond_to do |format|
      format.json { render 'tokeninput'}
    end
  end

  private
    def set_agency
      @agency = Agency.find(params[:id])
    end
    def agency_params
      params.require(:agency).permit(:name, :shortname, :info_url, :agency_tokens, :parent_id, :stats_enabled)
    end

    def sort_column
      Agency.column_names.include?(params[:sort]) ? params[:sort] : "name"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end 
end
